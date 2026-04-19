import 'package:flutter/foundation.dart' show immutable;
import 'package:injectable/injectable.dart';
import 'package:side_project/feature/chat/data/models/chat_conversation_enriched.dart';
import 'package:side_project/feature/followers_page/data/models/profile_follow_row.dart';
import 'package:side_project/feature/followers_page/data/repository/follow_list_repository.dart';
import 'package:side_project/feature/profile/data/models/profile_search_hit.dart';
import 'package:side_project/feature/profile/data/repository/profile_repository.dart';

/// Результат поиска пользователей для Messenger (двухэтапно: «свои» контакты → глобально).
@immutable
class MessengerSearchHit {
  const MessengerSearchHit({
    required this.profile,
    this.existingConversationId,
  });

  final ProfileSearchHit profile;

  /// Уже есть DM — открыть без [create_dm].
  final String? existingConversationId;
}

@immutable
class MessengerSearchOutcome {
  const MessengerSearchOutcome({
    required this.people,
    required this.suggested,
  });

  /// Подписки / подписчики / собеседники из текущих чатов + совпадения из глобального поиска в этом круге.
  final List<MessengerSearchHit> people;

  /// Глобальный поиск: остальные профили.
  final List<MessengerSearchHit> suggested;
}

/// Этап 1: фильтрация среди following / followers / участников открытых диалогов.
/// Этап 2 (если мало совпадений): [ProfileRepository.searchProfilesForTagging].
@lazySingleton
class MessengerUserSearchService {
  MessengerUserSearchService(this._profiles, this._follow);

  final ProfileRepository _profiles;
  final FollowListRepository _follow;

  static const _minPeopleBeforeGlobal = 8;
  static const _followCap = 400;

  static ProfileSearchHit _fromFollowRow(ProfileFollowRow r) {
    return ProfileSearchHit(
      id: r.profileId,
      username: r.username,
      fullName: null,
      avatarUrl: r.avatarUrl,
    );
  }

  static ProfileSearchHit _fromDmOther(ChatConversationEnriched e) {
    final u = e.otherUser;
    if (u == null) {
      return ProfileSearchHit(id: e.conversation.id, username: null, fullName: null, avatarUrl: null);
    }
    return ProfileSearchHit(
      id: u.id,
      username: u.username,
      fullName: null,
      avatarUrl: u.avatarUrl,
    );
  }

  static bool _matchesQuery(String qLower, ProfileSearchHit p) {
    final u = (p.username ?? '').toLowerCase();
    final f = (p.fullName ?? '').toLowerCase();
    return u.startsWith(qLower) || u.contains(qLower) || f.contains(qLower);
  }

  static int _rank(String qLower, ProfileSearchHit p) {
    final u = (p.username ?? '').toLowerCase();
    if (u.startsWith(qLower)) return 0;
    if (u.contains(qLower)) return 1;
    return 2;
  }

  Future<MessengerSearchOutcome> search({
    required String rawQuery,
    required String myUserId,
    required List<ChatConversationEnriched> conversations,
  }) async {
    final q = rawQuery.trim().toLowerCase();
    if (q.isEmpty) {
      return const MessengerSearchOutcome(people: [], suggested: []);
    }

    final myNorm = myUserId.trim().toLowerCase();

    final dmConvByOther = <String, String>{};
    final closeHits = <String, ProfileSearchHit>{};

    for (final c in conversations) {
      if (c.conversation.type != 'dm') continue;
      final other = c.otherUser;
      if (other == null) continue;
      final oid = other.id.trim().toLowerCase();
      if (oid.isEmpty || oid == myNorm) continue;
      dmConvByOther[oid] = c.conversation.id;
      final hit = _fromDmOther(c);
      if (_matchesQuery(q, hit)) {
        closeHits[oid] = hit;
      }
    }

    final following = await _follow.listFollowing(myUserId, limit: _followCap, offset: 0);
    final followers = await _follow.listFollowers(myUserId, limit: _followCap, offset: 0);

    for (final row in following) {
      final hit = _fromFollowRow(row);
      final id = hit.id.trim().toLowerCase();
      if (id == myNorm) continue;
      if (_matchesQuery(q, hit)) closeHits[id] = hit;
    }
    for (final row in followers) {
      final hit = _fromFollowRow(row);
      final id = hit.id.trim().toLowerCase();
      if (id == myNorm) continue;
      if (_matchesQuery(q, hit)) closeHits[id] = hit;
    }

    final closeCircleIds = <String>{
      ...following.map((e) => e.profileId.trim().toLowerCase()),
      ...followers.map((e) => e.profileId.trim().toLowerCase()),
      ...dmConvByOther.keys,
    }..remove(myNorm);

    var peopleList = closeHits.values.toList()
      ..sort((a, b) {
        final ra = _rank(q, a);
        final rb = _rank(q, b);
        if (ra != rb) return ra.compareTo(rb);
        final ua = (a.username ?? a.id).toLowerCase();
        final ub = (b.username ?? b.id).toLowerCase();
        return ua.compareTo(ub);
      });

    final peopleWrapped = <MessengerSearchHit>[
      for (final p in peopleList)
        MessengerSearchHit(
          profile: p,
          existingConversationId: dmConvByOther[p.id.trim().toLowerCase()],
        ),
    ];

    if (peopleWrapped.length >= _minPeopleBeforeGlobal) {
      return MessengerSearchOutcome(people: peopleWrapped, suggested: const []);
    }

    final global = await _profiles.searchProfilesForTagging(query: rawQuery.trim(), limit: 24);
    final peopleIds = {for (final m in peopleWrapped) m.profile.id.trim().toLowerCase()};

    final nextPeople = List<MessengerSearchHit>.from(peopleWrapped);
    final suggested = <MessengerSearchHit>[];

    for (final g in global) {
      final gid = g.id.trim().toLowerCase();
      if (gid.isEmpty || gid == myNorm) continue;

      if (peopleIds.contains(gid)) continue;

      final inClose = closeCircleIds.contains(gid);
      final convId = dmConvByOther[gid];

      final hit = MessengerSearchHit(profile: g, existingConversationId: convId);

      if (inClose || convId != null) {
        nextPeople.add(hit);
        peopleIds.add(gid);
      } else {
        suggested.add(hit);
      }
    }

    final sugDedupe = <String, MessengerSearchHit>{};
    for (final s in suggested) {
      sugDedupe[s.profile.id.trim().toLowerCase()] = s;
    }
    final suggestedUnique = sugDedupe.values.toList()
      ..sort((a, b) {
        final ua = (a.profile.username ?? a.profile.id).toLowerCase();
        final ub = (b.profile.username ?? b.profile.id).toLowerCase();
        return ua.compareTo(ub);
      });

    nextPeople.sort((a, b) {
      final ra = _rank(q, a.profile);
      final rb = _rank(q, b.profile);
      if (ra != rb) return ra.compareTo(rb);
      final ua = (a.profile.username ?? a.profile.id).toLowerCase();
      final ub = (b.profile.username ?? b.profile.id).toLowerCase();
      return ua.compareTo(ub);
    });

    final dedupe = <String, MessengerSearchHit>{};
    for (final e in nextPeople) {
      dedupe[e.profile.id.trim().toLowerCase()] = e;
    }

    return MessengerSearchOutcome(
      people: dedupe.values.toList(),
      suggested: suggestedUnique,
    );
  }
}
