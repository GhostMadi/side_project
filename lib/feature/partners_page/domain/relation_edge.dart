/// One row of `public.relations` visible to the current user (RLS).
class RelationEdge {
  const RelationEdge({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.initiatorId,
    required this.relationType,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String fromAccountId;
  final String toAccountId;
  final String initiatorId;
  final String relationType;
  final String status;
  final DateTime? updatedAt;

  /// The other account in the canonical pair when `me` is one of the endpoints.
  String? otherAccountId(String me) {
    if (me == fromAccountId) return toAccountId;
    if (me == toAccountId) return fromAccountId;
    return null;
  }

  bool isPendingReceiver(String me) => status == 'pending' && initiatorId != me;

  bool isPendingInitiator(String me) => status == 'pending' && initiatorId == me;

  factory RelationEdge.fromRow(Map<String, dynamic> m) {
    DateTime? u;
    final raw = m['updated_at'];
    if (raw != null) {
      u = DateTime.tryParse(raw.toString());
    }
    return RelationEdge(
      id: m['id'] as String,
      fromAccountId: m['from_account_id'] as String,
      toAccountId: m['to_account_id'] as String,
      initiatorId: m['initiator_id'] as String,
      relationType: (m['relation_type'] as String?)?.trim() ?? 'hire',
      status: (m['status'] as String?)?.trim() ?? 'pending',
      updatedAt: u,
    );
  }
}
