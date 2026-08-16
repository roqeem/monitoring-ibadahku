class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String loginMethod;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.loginMethod,
    required this.createdAt,
  });
}

class ChildSummary {
  final String childId;
  final String? displayName;
  final String? photoUrl;
  final int completed;
  final int pending;
  final int skipped;
  final String worshipDate;

  ChildSummary({
    required this.childId,
    this.displayName,
    this.photoUrl,
    required this.completed,
    required this.pending,
    required this.skipped,
    required this.worshipDate,
  });
}

class Invitation {
  final String id;
  final String guardianId;
  final String tokenHash;
  final String status;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.guardianId,
    required this.tokenHash,
    required this.status,
    required this.createdAt,
  });
}
