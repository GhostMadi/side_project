// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i56;

import 'package:auto_route/auto_route.dart' as _i51;
import 'package:flutter/foundation.dart' as _i53;
import 'package:flutter/material.dart' as _i52;
import 'package:side_project/feature/account_page/presentation/page/account_page.dart'
    as _i1;
import 'package:side_project/feature/app/application_page.dart' as _i3;
import 'package:side_project/feature/archive_page/presentation/archived_page.dart'
    as _i4;
import 'package:side_project/feature/chat/presentation/page/chat_list_page.dart'
    as _i19;
import 'package:side_project/feature/chat/presentation/page/chat_search_page.dart'
    as _i20;
import 'package:side_project/feature/chat/presentation/page/chat_thread_page.dart'
    as _i21;
import 'package:side_project/feature/cluster_create_page/presentation/page/cluster_create_page.dart'
    as _i22;
import 'package:side_project/feature/edit_profile_page/edit_profile_field_page.dart'
    as _i23;
import 'package:side_project/feature/edit_profile_page/edit_profile_page.dart'
    as _i24;
import 'package:side_project/feature/edit_profile_page/edit_profile_select_field_page.dart'
    as _i25;
import 'package:side_project/feature/edit_profile_page/profile_image_edit_page.dart'
    as _i42;
import 'package:side_project/feature/followers_page/presentation/page/follow_lists_page.dart'
    as _i30;
import 'package:side_project/feature/login_page/presentation/page/login_page.dart'
    as _i32;
import 'package:side_project/feature/login_page/presentation/page/session_gate_page.dart'
    as _i47;
import 'package:side_project/feature/map_page/presentation/map_page.dart'
    as _i34;
import 'package:side_project/feature/map_page/presentation/page/main_map_page.dart'
    as _i33;
import 'package:side_project/feature/media_pick_edit/media_pick_edit.dart'
    as _i54;
import 'package:side_project/feature/people_search_page/presentation/page/people_search_page.dart'
    as _i38;
import 'package:side_project/feature/post_create_page/presentation/page/post_create_page.dart'
    as _i39;
import 'package:side_project/feature/posts/data/models/post_model.dart' as _i55;
import 'package:side_project/feature/posts/presentation/page/post_detail_page.dart'
    as _i40;
import 'package:side_project/feature/profile_page/presentation/page/guest_profile_page.dart'
    as _i31;
import 'package:side_project/feature/profile_page/presentation/page/profile_for_guest_page.dart'
    as _i41;
import 'package:side_project/feature/profile_page/presentation/page/profile_page.dart'
    as _i43;
import 'package:side_project/feature/save_page/presentation/page/saved_page.dart'
    as _i46;
import 'package:side_project/feature/settings/presentation/page/business_account_page.dart'
    as _i5;
import 'package:side_project/feature/settings/presentation/page/business_analytics_list_page.dart'
    as _i6;
import 'package:side_project/feature/settings/presentation/page/business_analytics_page.dart'
    as _i7;
import 'package:side_project/feature/settings/presentation/page/business_analytics_services_page.dart'
    as _i8;
import 'package:side_project/feature/settings/presentation/page/business_bookings_page.dart'
    as _i9;
import 'package:side_project/feature/settings/presentation/page/business_client_import_page.dart'
    as _i10;
import 'package:side_project/feature/settings/presentation/page/business_client_import_result_page.dart'
    as _i11;
import 'package:side_project/feature/settings/presentation/page/business_client_mapping_page.dart'
    as _i12;
import 'package:side_project/feature/settings/presentation/page/business_client_profile_page.dart'
    as _i13;
import 'package:side_project/feature/settings/presentation/page/business_clients_broadcast_page.dart'
    as _i14;
import 'package:side_project/feature/settings/presentation/page/business_clients_page.dart'
    as _i15;
import 'package:side_project/feature/settings/presentation/page/business_growth_page.dart'
    as _i16;
import 'package:side_project/feature/settings/presentation/page/business_schedule_page.dart'
    as _i18;
import 'package:side_project/feature/settings/presentation/page/employer_detail_page.dart'
    as _i26;
import 'package:side_project/feature/settings/presentation/page/employer_service_share_page.dart'
    as _i27;
import 'package:side_project/feature/settings/presentation/page/employers_page.dart'
    as _i28;
import 'package:side_project/feature/settings/presentation/page/settings_page.dart'
    as _i48;
import 'package:side_project/feature/settings/presentation/page/workers_page.dart'
    as _i50;
import 'package:side_project/feature_draft/admin_editor_page.dart' as _i2;
import 'package:side_project/feature_draft/example.dart' as _i29;
import 'package:side_project/feature_draft/order/order_page.dart' as _i36;
import 'package:side_project/feature_draft/presentation/public_page.dart'
    as _i44;
import 'package:side_project/feature_draft/profile/presentation/page/my_appointments_page.dart'
    as _i35;
import 'package:side_project/feature_draft/profile/presentation/page/organizer_profile_page.dart'
    as _i37;
import 'package:side_project/feature_draft/register/presentation/page/register_page.dart'
    as _i45;
import 'package:side_project/feature_draft/request/presentation/page/all_request_page.dart'
    as _i17;
import 'package:side_project/feature_draft/ticket_view/presentation/page/ticket_view_page.dart'
    as _i49;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i51.PageRouteInfo<void> {
  const AccountRoute({List<_i51.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.AdminEditorPage]
class AdminEditorRoute extends _i51.PageRouteInfo<void> {
  const AdminEditorRoute({List<_i51.PageRouteInfo>? children})
    : super(AdminEditorRoute.name, initialChildren: children);

  static const String name = 'AdminEditorRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdminEditorPage();
    },
  );
}

/// generated route for
/// [_i3.ApplicationPage]
class ApplicationRoute extends _i51.PageRouteInfo<void> {
  const ApplicationRoute({List<_i51.PageRouteInfo>? children})
    : super(ApplicationRoute.name, initialChildren: children);

  static const String name = 'ApplicationRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i3.ApplicationPage();
    },
  );
}

/// generated route for
/// [_i4.ArchivedPage]
class ArchivedRoute extends _i51.PageRouteInfo<void> {
  const ArchivedRoute({List<_i51.PageRouteInfo>? children})
    : super(ArchivedRoute.name, initialChildren: children);

  static const String name = 'ArchivedRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i4.ArchivedPage();
    },
  );
}

/// generated route for
/// [_i5.BusinessAccountPage]
class BusinessAccountRoute extends _i51.PageRouteInfo<void> {
  const BusinessAccountRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessAccountRoute.name, initialChildren: children);

  static const String name = 'BusinessAccountRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i5.BusinessAccountPage();
    },
  );
}

/// generated route for
/// [_i6.BusinessAnalyticsListPage]
class BusinessAnalyticsListRoute extends _i51.PageRouteInfo<void> {
  const BusinessAnalyticsListRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessAnalyticsListRoute.name, initialChildren: children);

  static const String name = 'BusinessAnalyticsListRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i6.BusinessAnalyticsListPage();
    },
  );
}

/// generated route for
/// [_i7.BusinessAnalyticsPage]
class BusinessAnalyticsRoute extends _i51.PageRouteInfo<void> {
  const BusinessAnalyticsRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessAnalyticsRoute.name, initialChildren: children);

  static const String name = 'BusinessAnalyticsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i7.BusinessAnalyticsPage();
    },
  );
}

/// generated route for
/// [_i8.BusinessAnalyticsServicesPage]
class BusinessAnalyticsServicesRoute extends _i51.PageRouteInfo<void> {
  const BusinessAnalyticsServicesRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessAnalyticsServicesRoute.name, initialChildren: children);

  static const String name = 'BusinessAnalyticsServicesRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i8.BusinessAnalyticsServicesPage();
    },
  );
}

/// generated route for
/// [_i9.BusinessBookingsPage]
class BusinessBookingsRoute extends _i51.PageRouteInfo<void> {
  const BusinessBookingsRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessBookingsRoute.name, initialChildren: children);

  static const String name = 'BusinessBookingsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i9.BusinessBookingsPage();
    },
  );
}

/// generated route for
/// [_i10.BusinessClientImportPage]
class BusinessClientImportRoute extends _i51.PageRouteInfo<void> {
  const BusinessClientImportRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessClientImportRoute.name, initialChildren: children);

  static const String name = 'BusinessClientImportRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i10.BusinessClientImportPage();
    },
  );
}

/// generated route for
/// [_i11.BusinessClientImportResultPage]
class BusinessClientImportResultRoute extends _i51.PageRouteInfo<void> {
  const BusinessClientImportResultRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessClientImportResultRoute.name, initialChildren: children);

  static const String name = 'BusinessClientImportResultRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i11.BusinessClientImportResultPage();
    },
  );
}

/// generated route for
/// [_i12.BusinessClientMappingPage]
class BusinessClientMappingRoute
    extends _i51.PageRouteInfo<BusinessClientMappingRouteArgs> {
  BusinessClientMappingRoute({
    _i52.Key? key,
    required String methodId,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         BusinessClientMappingRoute.name,
         args: BusinessClientMappingRouteArgs(key: key, methodId: methodId),
         initialChildren: children,
       );

  static const String name = 'BusinessClientMappingRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessClientMappingRouteArgs>();
      return _i12.BusinessClientMappingPage(
        key: args.key,
        methodId: args.methodId,
      );
    },
  );
}

class BusinessClientMappingRouteArgs {
  const BusinessClientMappingRouteArgs({this.key, required this.methodId});

  final _i52.Key? key;

  final String methodId;

  @override
  String toString() {
    return 'BusinessClientMappingRouteArgs{key: $key, methodId: $methodId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessClientMappingRouteArgs) return false;
    return key == other.key && methodId == other.methodId;
  }

  @override
  int get hashCode => key.hashCode ^ methodId.hashCode;
}

/// generated route for
/// [_i13.BusinessClientProfilePage]
class BusinessClientProfileRoute
    extends _i51.PageRouteInfo<BusinessClientProfileRouteArgs> {
  BusinessClientProfileRoute({
    _i52.Key? key,
    required String clientName,
    required String clientNick,
    required String clientAvatar,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         BusinessClientProfileRoute.name,
         args: BusinessClientProfileRouteArgs(
           key: key,
           clientName: clientName,
           clientNick: clientNick,
           clientAvatar: clientAvatar,
         ),
         initialChildren: children,
       );

  static const String name = 'BusinessClientProfileRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessClientProfileRouteArgs>();
      return _i13.BusinessClientProfilePage(
        key: args.key,
        clientName: args.clientName,
        clientNick: args.clientNick,
        clientAvatar: args.clientAvatar,
      );
    },
  );
}

class BusinessClientProfileRouteArgs {
  const BusinessClientProfileRouteArgs({
    this.key,
    required this.clientName,
    required this.clientNick,
    required this.clientAvatar,
  });

  final _i52.Key? key;

  final String clientName;

  final String clientNick;

  final String clientAvatar;

  @override
  String toString() {
    return 'BusinessClientProfileRouteArgs{key: $key, clientName: $clientName, clientNick: $clientNick, clientAvatar: $clientAvatar}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessClientProfileRouteArgs) return false;
    return key == other.key &&
        clientName == other.clientName &&
        clientNick == other.clientNick &&
        clientAvatar == other.clientAvatar;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      clientName.hashCode ^
      clientNick.hashCode ^
      clientAvatar.hashCode;
}

/// generated route for
/// [_i14.BusinessClientsBroadcastPage]
class BusinessClientsBroadcastRoute extends _i51.PageRouteInfo<void> {
  const BusinessClientsBroadcastRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessClientsBroadcastRoute.name, initialChildren: children);

  static const String name = 'BusinessClientsBroadcastRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i14.BusinessClientsBroadcastPage();
    },
  );
}

/// generated route for
/// [_i15.BusinessClientsPage]
class BusinessClientsRoute extends _i51.PageRouteInfo<void> {
  const BusinessClientsRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessClientsRoute.name, initialChildren: children);

  static const String name = 'BusinessClientsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i15.BusinessClientsPage();
    },
  );
}

/// generated route for
/// [_i16.BusinessGrowthPage]
class BusinessGrowthRoute extends _i51.PageRouteInfo<void> {
  const BusinessGrowthRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessGrowthRoute.name, initialChildren: children);

  static const String name = 'BusinessGrowthRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i16.BusinessGrowthPage();
    },
  );
}

/// generated route for
/// [_i17.BusinessRequestsPage]
class BusinessRequestsRoute extends _i51.PageRouteInfo<void> {
  const BusinessRequestsRoute({List<_i51.PageRouteInfo>? children})
    : super(BusinessRequestsRoute.name, initialChildren: children);

  static const String name = 'BusinessRequestsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i17.BusinessRequestsPage();
    },
  );
}

/// generated route for
/// [_i18.BusinessSchedulePage]
class BusinessScheduleRoute
    extends _i51.PageRouteInfo<BusinessScheduleRouteArgs> {
  BusinessScheduleRoute({
    _i52.Key? key,
    bool showWorkers = false,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         BusinessScheduleRoute.name,
         args: BusinessScheduleRouteArgs(key: key, showWorkers: showWorkers),
         initialChildren: children,
       );

  static const String name = 'BusinessScheduleRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BusinessScheduleRouteArgs>(
        orElse: () => const BusinessScheduleRouteArgs(),
      );
      return _i18.BusinessSchedulePage(
        key: args.key,
        showWorkers: args.showWorkers,
      );
    },
  );
}

class BusinessScheduleRouteArgs {
  const BusinessScheduleRouteArgs({this.key, this.showWorkers = false});

  final _i52.Key? key;

  final bool showWorkers;

  @override
  String toString() {
    return 'BusinessScheduleRouteArgs{key: $key, showWorkers: $showWorkers}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BusinessScheduleRouteArgs) return false;
    return key == other.key && showWorkers == other.showWorkers;
  }

  @override
  int get hashCode => key.hashCode ^ showWorkers.hashCode;
}

/// generated route for
/// [_i19.ChatListPage]
class ChatListRoute extends _i51.PageRouteInfo<void> {
  const ChatListRoute({List<_i51.PageRouteInfo>? children})
    : super(ChatListRoute.name, initialChildren: children);

  static const String name = 'ChatListRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i19.ChatListPage();
    },
  );
}

/// generated route for
/// [_i20.ChatSearchPage]
class ChatSearchRoute extends _i51.PageRouteInfo<void> {
  const ChatSearchRoute({List<_i51.PageRouteInfo>? children})
    : super(ChatSearchRoute.name, initialChildren: children);

  static const String name = 'ChatSearchRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i20.ChatSearchPage();
    },
  );
}

/// generated route for
/// [_i21.ChatThreadPage]
class ChatThreadRoute extends _i51.PageRouteInfo<ChatThreadRouteArgs> {
  ChatThreadRoute({
    _i52.Key? key,
    required String conversationId,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         ChatThreadRoute.name,
         args: ChatThreadRouteArgs(key: key, conversationId: conversationId),
         initialChildren: children,
       );

  static const String name = 'ChatThreadRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatThreadRouteArgs>();
      return _i21.ChatThreadPage(
        key: args.key,
        conversationId: args.conversationId,
      );
    },
  );
}

class ChatThreadRouteArgs {
  const ChatThreadRouteArgs({this.key, required this.conversationId});

  final _i52.Key? key;

  final String conversationId;

  @override
  String toString() {
    return 'ChatThreadRouteArgs{key: $key, conversationId: $conversationId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatThreadRouteArgs) return false;
    return key == other.key && conversationId == other.conversationId;
  }

  @override
  int get hashCode => key.hashCode ^ conversationId.hashCode;
}

/// generated route for
/// [_i22.ClusterCreatePage]
class ClusterCreateRoute extends _i51.PageRouteInfo<void> {
  const ClusterCreateRoute({List<_i51.PageRouteInfo>? children})
    : super(ClusterCreateRoute.name, initialChildren: children);

  static const String name = 'ClusterCreateRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i22.ClusterCreatePage();
    },
  );
}

/// generated route for
/// [_i23.EditProfileFieldPage]
class EditProfileFieldRoute
    extends _i51.PageRouteInfo<EditProfileFieldRouteArgs> {
  EditProfileFieldRoute({
    _i52.Key? key,
    required String fieldKey,
    required String initialValue,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         EditProfileFieldRoute.name,
         args: EditProfileFieldRouteArgs(
           key: key,
           fieldKey: fieldKey,
           initialValue: initialValue,
         ),
         initialChildren: children,
       );

  static const String name = 'EditProfileFieldRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileFieldRouteArgs>();
      return _i23.EditProfileFieldPage(
        key: args.key,
        fieldKey: args.fieldKey,
        initialValue: args.initialValue,
      );
    },
  );
}

class EditProfileFieldRouteArgs {
  const EditProfileFieldRouteArgs({
    this.key,
    required this.fieldKey,
    required this.initialValue,
  });

  final _i52.Key? key;

  final String fieldKey;

  final String initialValue;

  @override
  String toString() {
    return 'EditProfileFieldRouteArgs{key: $key, fieldKey: $fieldKey, initialValue: $initialValue}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileFieldRouteArgs) return false;
    return key == other.key &&
        fieldKey == other.fieldKey &&
        initialValue == other.initialValue;
  }

  @override
  int get hashCode => key.hashCode ^ fieldKey.hashCode ^ initialValue.hashCode;
}

/// generated route for
/// [_i24.EditProfilePage]
class EditProfileRoute extends _i51.PageRouteInfo<void> {
  const EditProfileRoute({List<_i51.PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i24.EditProfilePage();
    },
  );
}

/// generated route for
/// [_i25.EditProfileSelectFieldPage]
class EditProfileSelectFieldRoute
    extends _i51.PageRouteInfo<EditProfileSelectFieldRouteArgs> {
  EditProfileSelectFieldRoute({
    _i52.Key? key,
    required String fieldKey,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         EditProfileSelectFieldRoute.name,
         args: EditProfileSelectFieldRouteArgs(key: key, fieldKey: fieldKey),
         initialChildren: children,
       );

  static const String name = 'EditProfileSelectFieldRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditProfileSelectFieldRouteArgs>();
      return _i25.EditProfileSelectFieldPage(
        key: args.key,
        fieldKey: args.fieldKey,
      );
    },
  );
}

class EditProfileSelectFieldRouteArgs {
  const EditProfileSelectFieldRouteArgs({this.key, required this.fieldKey});

  final _i52.Key? key;

  final String fieldKey;

  @override
  String toString() {
    return 'EditProfileSelectFieldRouteArgs{key: $key, fieldKey: $fieldKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditProfileSelectFieldRouteArgs) return false;
    return key == other.key && fieldKey == other.fieldKey;
  }

  @override
  int get hashCode => key.hashCode ^ fieldKey.hashCode;
}

/// generated route for
/// [_i26.EmployerDetailPage]
class EmployerDetailRoute extends _i51.PageRouteInfo<EmployerDetailRouteArgs> {
  EmployerDetailRoute({
    _i52.Key? key,
    required String employerId,
    required String employerName,
    required String employerAvatar,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         EmployerDetailRoute.name,
         args: EmployerDetailRouteArgs(
           key: key,
           employerId: employerId,
           employerName: employerName,
           employerAvatar: employerAvatar,
         ),
         initialChildren: children,
       );

  static const String name = 'EmployerDetailRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployerDetailRouteArgs>();
      return _i26.EmployerDetailPage(
        key: args.key,
        employerId: args.employerId,
        employerName: args.employerName,
        employerAvatar: args.employerAvatar,
      );
    },
  );
}

class EmployerDetailRouteArgs {
  const EmployerDetailRouteArgs({
    this.key,
    required this.employerId,
    required this.employerName,
    required this.employerAvatar,
  });

  final _i52.Key? key;

  final String employerId;

  final String employerName;

  final String employerAvatar;

  @override
  String toString() {
    return 'EmployerDetailRouteArgs{key: $key, employerId: $employerId, employerName: $employerName, employerAvatar: $employerAvatar}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmployerDetailRouteArgs) return false;
    return key == other.key &&
        employerId == other.employerId &&
        employerName == other.employerName &&
        employerAvatar == other.employerAvatar;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      employerId.hashCode ^
      employerName.hashCode ^
      employerAvatar.hashCode;
}

/// generated route for
/// [_i27.EmployerServiceSharePage]
class EmployerServiceShareRoute
    extends _i51.PageRouteInfo<EmployerServiceShareRouteArgs> {
  EmployerServiceShareRoute({
    _i52.Key? key,
    required String employerId,
    required String employerName,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         EmployerServiceShareRoute.name,
         args: EmployerServiceShareRouteArgs(
           key: key,
           employerId: employerId,
           employerName: employerName,
         ),
         initialChildren: children,
       );

  static const String name = 'EmployerServiceShareRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmployerServiceShareRouteArgs>();
      return _i27.EmployerServiceSharePage(
        key: args.key,
        employerId: args.employerId,
        employerName: args.employerName,
      );
    },
  );
}

class EmployerServiceShareRouteArgs {
  const EmployerServiceShareRouteArgs({
    this.key,
    required this.employerId,
    required this.employerName,
  });

  final _i52.Key? key;

  final String employerId;

  final String employerName;

  @override
  String toString() {
    return 'EmployerServiceShareRouteArgs{key: $key, employerId: $employerId, employerName: $employerName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmployerServiceShareRouteArgs) return false;
    return key == other.key &&
        employerId == other.employerId &&
        employerName == other.employerName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ employerId.hashCode ^ employerName.hashCode;
}

/// generated route for
/// [_i28.EmployersPage]
class EmployersRoute extends _i51.PageRouteInfo<void> {
  const EmployersRoute({List<_i51.PageRouteInfo>? children})
    : super(EmployersRoute.name, initialChildren: children);

  static const String name = 'EmployersRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i28.EmployersPage();
    },
  );
}

/// generated route for
/// [_i29.ExamplePage]
class ExampleRoute extends _i51.PageRouteInfo<void> {
  const ExampleRoute({List<_i51.PageRouteInfo>? children})
    : super(ExampleRoute.name, initialChildren: children);

  static const String name = 'ExampleRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i29.ExamplePage();
    },
  );
}

/// generated route for
/// [_i30.FollowListsPage]
class FollowListsRoute extends _i51.PageRouteInfo<FollowListsRouteArgs> {
  FollowListsRoute({
    _i52.Key? key,
    required String profileId,
    String? username,
    int initialTabIndex = 0,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         FollowListsRoute.name,
         args: FollowListsRouteArgs(
           key: key,
           profileId: profileId,
           username: username,
           initialTabIndex: initialTabIndex,
         ),
         initialChildren: children,
       );

  static const String name = 'FollowListsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FollowListsRouteArgs>();
      return _i30.FollowListsPage(
        key: args.key,
        profileId: args.profileId,
        username: args.username,
        initialTabIndex: args.initialTabIndex,
      );
    },
  );
}

class FollowListsRouteArgs {
  const FollowListsRouteArgs({
    this.key,
    required this.profileId,
    this.username,
    this.initialTabIndex = 0,
  });

  final _i52.Key? key;

  final String profileId;

  final String? username;

  final int initialTabIndex;

  @override
  String toString() {
    return 'FollowListsRouteArgs{key: $key, profileId: $profileId, username: $username, initialTabIndex: $initialTabIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FollowListsRouteArgs) return false;
    return key == other.key &&
        profileId == other.profileId &&
        username == other.username &&
        initialTabIndex == other.initialTabIndex;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      profileId.hashCode ^
      username.hashCode ^
      initialTabIndex.hashCode;
}

/// generated route for
/// [_i31.GuestProfilePage]
class GuestProfileRoute extends _i51.PageRouteInfo<GuestProfileRouteArgs> {
  GuestProfileRoute({
    _i52.Key? key,
    required String profileId,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         GuestProfileRoute.name,
         args: GuestProfileRouteArgs(key: key, profileId: profileId),
         initialChildren: children,
       );

  static const String name = 'GuestProfileRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GuestProfileRouteArgs>();
      return _i31.GuestProfilePage(key: args.key, profileId: args.profileId);
    },
  );
}

class GuestProfileRouteArgs {
  const GuestProfileRouteArgs({this.key, required this.profileId});

  final _i52.Key? key;

  final String profileId;

  @override
  String toString() {
    return 'GuestProfileRouteArgs{key: $key, profileId: $profileId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuestProfileRouteArgs) return false;
    return key == other.key && profileId == other.profileId;
  }

  @override
  int get hashCode => key.hashCode ^ profileId.hashCode;
}

/// generated route for
/// [_i32.LoginPage]
class LoginRoute extends _i51.PageRouteInfo<void> {
  const LoginRoute({List<_i51.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i32.LoginPage();
    },
  );
}

/// generated route for
/// [_i33.MainMapPage]
class MainMapRoute extends _i51.PageRouteInfo<void> {
  const MainMapRoute({List<_i51.PageRouteInfo>? children})
    : super(MainMapRoute.name, initialChildren: children);

  static const String name = 'MainMapRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i33.MainMapPage();
    },
  );
}

/// generated route for
/// [_i34.MapPage]
class MapRoute extends _i51.PageRouteInfo<void> {
  const MapRoute({List<_i51.PageRouteInfo>? children})
    : super(MapRoute.name, initialChildren: children);

  static const String name = 'MapRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i34.MapPage();
    },
  );
}

/// generated route for
/// [_i35.MyAppointmentsPage]
class MyAppointmentsRoute extends _i51.PageRouteInfo<void> {
  const MyAppointmentsRoute({List<_i51.PageRouteInfo>? children})
    : super(MyAppointmentsRoute.name, initialChildren: children);

  static const String name = 'MyAppointmentsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i35.MyAppointmentsPage();
    },
  );
}

/// generated route for
/// [_i36.OrderPage]
class OrderRoute extends _i51.PageRouteInfo<void> {
  const OrderRoute({List<_i51.PageRouteInfo>? children})
    : super(OrderRoute.name, initialChildren: children);

  static const String name = 'OrderRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i36.OrderPage();
    },
  );
}

/// generated route for
/// [_i37.OrganizerProfilePage]
class OrganizerProfileRoute
    extends _i51.PageRouteInfo<OrganizerProfileRouteArgs> {
  OrganizerProfileRoute({
    _i52.Key? key,
    String? organizerId,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         OrganizerProfileRoute.name,
         args: OrganizerProfileRouteArgs(key: key, organizerId: organizerId),
         initialChildren: children,
       );

  static const String name = 'OrganizerProfileRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrganizerProfileRouteArgs>(
        orElse: () => const OrganizerProfileRouteArgs(),
      );
      return _i37.OrganizerProfilePage(
        key: args.key,
        organizerId: args.organizerId,
      );
    },
  );
}

class OrganizerProfileRouteArgs {
  const OrganizerProfileRouteArgs({this.key, this.organizerId});

  final _i52.Key? key;

  final String? organizerId;

  @override
  String toString() {
    return 'OrganizerProfileRouteArgs{key: $key, organizerId: $organizerId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrganizerProfileRouteArgs) return false;
    return key == other.key && organizerId == other.organizerId;
  }

  @override
  int get hashCode => key.hashCode ^ organizerId.hashCode;
}

/// generated route for
/// [_i38.PeopleSearchPage]
class PeopleSearchRoute extends _i51.PageRouteInfo<void> {
  const PeopleSearchRoute({List<_i51.PageRouteInfo>? children})
    : super(PeopleSearchRoute.name, initialChildren: children);

  static const String name = 'PeopleSearchRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i38.PeopleSearchPage();
    },
  );
}

/// generated route for
/// [_i39.PostCreatePage]
class PostCreateRoute extends _i51.PageRouteInfo<PostCreateRouteArgs> {
  PostCreateRoute({
    _i53.Key? key,
    _i54.MediaPickEditConfig? mediaConfig,
    _i52.Widget Function(_i52.BuildContext, _i54.MediaPickEditOutcome)?
    customThirdStep,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         PostCreateRoute.name,
         args: PostCreateRouteArgs(
           key: key,
           mediaConfig: mediaConfig,
           customThirdStep: customThirdStep,
         ),
         initialChildren: children,
       );

  static const String name = 'PostCreateRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostCreateRouteArgs>(
        orElse: () => const PostCreateRouteArgs(),
      );
      return _i39.PostCreatePage(
        key: args.key,
        mediaConfig: args.mediaConfig,
        customThirdStep: args.customThirdStep,
      );
    },
  );
}

class PostCreateRouteArgs {
  const PostCreateRouteArgs({this.key, this.mediaConfig, this.customThirdStep});

  final _i53.Key? key;

  final _i54.MediaPickEditConfig? mediaConfig;

  final _i52.Widget Function(_i52.BuildContext, _i54.MediaPickEditOutcome)?
  customThirdStep;

  @override
  String toString() {
    return 'PostCreateRouteArgs{key: $key, mediaConfig: $mediaConfig, customThirdStep: $customThirdStep}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostCreateRouteArgs) return false;
    return key == other.key && mediaConfig == other.mediaConfig;
  }

  @override
  int get hashCode => key.hashCode ^ mediaConfig.hashCode;
}

/// generated route for
/// [_i40.PostDetailPage]
class PostDetailRoute extends _i51.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i52.Key? key,
    required _i55.PostModel post,
    bool? initialIsSaved,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(
           key: key,
           post: post,
           initialIsSaved: initialIsSaved,
         ),
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostDetailRouteArgs>();
      return _i40.PostDetailPage(
        key: args.key,
        post: args.post,
        initialIsSaved: args.initialIsSaved,
      );
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({
    this.key,
    required this.post,
    this.initialIsSaved,
  });

  final _i52.Key? key;

  final _i55.PostModel post;

  final bool? initialIsSaved;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, post: $post, initialIsSaved: $initialIsSaved}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailRouteArgs) return false;
    return key == other.key &&
        post == other.post &&
        initialIsSaved == other.initialIsSaved;
  }

  @override
  int get hashCode => key.hashCode ^ post.hashCode ^ initialIsSaved.hashCode;
}

/// generated route for
/// [_i41.ProfileForGuestPage]
class ProfileForGuestRoute
    extends _i51.PageRouteInfo<ProfileForGuestRouteArgs> {
  ProfileForGuestRoute({
    _i52.Key? key,
    required String profileId,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         ProfileForGuestRoute.name,
         args: ProfileForGuestRouteArgs(key: key, profileId: profileId),
         initialChildren: children,
       );

  static const String name = 'ProfileForGuestRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileForGuestRouteArgs>();
      return _i41.ProfileForGuestPage(key: args.key, profileId: args.profileId);
    },
  );
}

class ProfileForGuestRouteArgs {
  const ProfileForGuestRouteArgs({this.key, required this.profileId});

  final _i52.Key? key;

  final String profileId;

  @override
  String toString() {
    return 'ProfileForGuestRouteArgs{key: $key, profileId: $profileId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileForGuestRouteArgs) return false;
    return key == other.key && profileId == other.profileId;
  }

  @override
  int get hashCode => key.hashCode ^ profileId.hashCode;
}

/// generated route for
/// [_i42.ProfileImageEditPage]
class ProfileImageEditRoute
    extends _i51.PageRouteInfo<ProfileImageEditRouteArgs> {
  ProfileImageEditRoute({
    _i52.Key? key,
    required _i56.Uint8List imageBytes,
    required bool isCover,
    bool clusterCollectionThumb = false,
    bool postFeedCrop = false,
    bool freeFormCrop = false,
    List<_i51.PageRouteInfo>? children,
  }) : super(
         ProfileImageEditRoute.name,
         args: ProfileImageEditRouteArgs(
           key: key,
           imageBytes: imageBytes,
           isCover: isCover,
           clusterCollectionThumb: clusterCollectionThumb,
           postFeedCrop: postFeedCrop,
           freeFormCrop: freeFormCrop,
         ),
         initialChildren: children,
       );

  static const String name = 'ProfileImageEditRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileImageEditRouteArgs>();
      return _i42.ProfileImageEditPage(
        key: args.key,
        imageBytes: args.imageBytes,
        isCover: args.isCover,
        clusterCollectionThumb: args.clusterCollectionThumb,
        postFeedCrop: args.postFeedCrop,
        freeFormCrop: args.freeFormCrop,
      );
    },
  );
}

class ProfileImageEditRouteArgs {
  const ProfileImageEditRouteArgs({
    this.key,
    required this.imageBytes,
    required this.isCover,
    this.clusterCollectionThumb = false,
    this.postFeedCrop = false,
    this.freeFormCrop = false,
  });

  final _i52.Key? key;

  final _i56.Uint8List imageBytes;

  final bool isCover;

  final bool clusterCollectionThumb;

  final bool postFeedCrop;

  final bool freeFormCrop;

  @override
  String toString() {
    return 'ProfileImageEditRouteArgs{key: $key, imageBytes: $imageBytes, isCover: $isCover, clusterCollectionThumb: $clusterCollectionThumb, postFeedCrop: $postFeedCrop, freeFormCrop: $freeFormCrop}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileImageEditRouteArgs) return false;
    return key == other.key &&
        imageBytes == other.imageBytes &&
        isCover == other.isCover &&
        clusterCollectionThumb == other.clusterCollectionThumb &&
        postFeedCrop == other.postFeedCrop &&
        freeFormCrop == other.freeFormCrop;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      imageBytes.hashCode ^
      isCover.hashCode ^
      clusterCollectionThumb.hashCode ^
      postFeedCrop.hashCode ^
      freeFormCrop.hashCode;
}

/// generated route for
/// [_i43.ProfilePage]
class ProfileRoute extends _i51.PageRouteInfo<void> {
  const ProfileRoute({List<_i51.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i43.ProfilePage();
    },
  );
}

/// generated route for
/// [_i44.PublicPage]
class PublicRoute extends _i51.PageRouteInfo<void> {
  const PublicRoute({List<_i51.PageRouteInfo>? children})
    : super(PublicRoute.name, initialChildren: children);

  static const String name = 'PublicRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i44.PublicPage();
    },
  );
}

/// generated route for
/// [_i45.RegisterPage]
class RegisterRoute extends _i51.PageRouteInfo<void> {
  const RegisterRoute({List<_i51.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i45.RegisterPage();
    },
  );
}

/// generated route for
/// [_i46.SavedPage]
class SavedRoute extends _i51.PageRouteInfo<void> {
  const SavedRoute({List<_i51.PageRouteInfo>? children})
    : super(SavedRoute.name, initialChildren: children);

  static const String name = 'SavedRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i46.SavedPage();
    },
  );
}

/// generated route for
/// [_i47.SessionGatePage]
class SessionGateRoute extends _i51.PageRouteInfo<void> {
  const SessionGateRoute({List<_i51.PageRouteInfo>? children})
    : super(SessionGateRoute.name, initialChildren: children);

  static const String name = 'SessionGateRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i47.SessionGatePage();
    },
  );
}

/// generated route for
/// [_i48.SettingsPage]
class SettingsRoute extends _i51.PageRouteInfo<void> {
  const SettingsRoute({List<_i51.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i48.SettingsPage();
    },
  );
}

/// generated route for
/// [_i49.TicketViewPage]
class TicketViewRoute extends _i51.PageRouteInfo<void> {
  const TicketViewRoute({List<_i51.PageRouteInfo>? children})
    : super(TicketViewRoute.name, initialChildren: children);

  static const String name = 'TicketViewRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i49.TicketViewPage();
    },
  );
}

/// generated route for
/// [_i50.WorkersPage]
class WorkersRoute extends _i51.PageRouteInfo<void> {
  const WorkersRoute({List<_i51.PageRouteInfo>? children})
    : super(WorkersRoute.name, initialChildren: children);

  static const String name = 'WorkersRoute';

  static _i51.PageInfo page = _i51.PageInfo(
    name,
    builder: (data) {
      return const _i50.WorkersPage();
    },
  );
}
