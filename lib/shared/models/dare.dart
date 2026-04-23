// lib/shared/models/dare.dart

enum DareMode { solo, openSplit, openBest }

enum DareStatus {
  open,
  locked,
  underReview,
  completed,
  rejected,
  cancelled,
  disputed,
}

extension DareModeX on DareMode {
  String get label {
    switch (this) {
      case DareMode.solo:
        return 'Solo';
      case DareMode.openSplit:
        return 'Split';
      case DareMode.openBest:
        return 'Best';
    }
  }

  String get description {
    switch (this) {
      case DareMode.solo:
        return 'First to claim gets it. One submission wins all.';
      case DareMode.openSplit:
        return 'Everyone who passes splits the pot equally.';
      case DareMode.openBest:
        return 'Many can submit. Poster picks the winner.';
    }
  }

  static DareMode fromString(String value) {
    switch (value) {
      case 'open_split':
        return DareMode.openSplit;
      case 'open_best':
        return DareMode.openBest;
      case 'solo':
      default:
        return DareMode.solo;
    }
  }

  String get dbValue {
    switch (this) {
      case DareMode.solo:
        return 'solo';
      case DareMode.openSplit:
        return 'open_split';
      case DareMode.openBest:
        return 'open_best';
    }
  }
}

extension DareStatusX on DareStatus {
  String get label {
    switch (this) {
      case DareStatus.open:
        return 'Open';
      case DareStatus.locked:
        return 'Claimed';
      case DareStatus.underReview:
        return 'Under Review';
      case DareStatus.completed:
        return 'Completed';
      case DareStatus.rejected:
        return 'Rejected';
      case DareStatus.cancelled:
        return 'Cancelled';
      case DareStatus.disputed:
        return 'Disputed';
    }
  }

  static DareStatus fromString(String value) {
    switch (value) {
      case 'locked':
        return DareStatus.locked;
      case 'under_review':
        return DareStatus.underReview;
      case 'completed':
        return DareStatus.completed;
      case 'rejected':
        return DareStatus.rejected;
      case 'cancelled':
        return DareStatus.cancelled;
      case 'disputed':
        return DareStatus.disputed;
      case 'open':
      default:
        return DareStatus.open;
    }
  }

  String get dbValue {
    switch (this) {
      case DareStatus.open:
        return 'open';
      case DareStatus.locked:
        return 'locked';
      case DareStatus.underReview:
        return 'under_review';
      case DareStatus.completed:
        return 'completed';
      case DareStatus.rejected:
        return 'rejected';
      case DareStatus.cancelled:
        return 'cancelled';
      case DareStatus.disputed:
        return 'disputed';
    }
  }

  bool get isActive => this == DareStatus.open || this == DareStatus.locked;
}

class Dare {
  final String id;
  final String posterId;
  final String? performerId;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final int bountyAmount;
  final double platformFeePct;
  final DareMode dareMode;
  final DareStatus status;
  final DateTime? expiresAt;
  final String? proofVideoUrl;
  final String? proofText;
  final Map<String, dynamic>? moderationResult;
  final String? moderationModel;
  final DateTime? judgingDeadline;
  final String? winnerPerformerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (from queries with profile data)
  final String? posterUsername;
  final String? posterAvatarUrl;
  final String? posterDisplayName;
  final int submissionCount;

  const Dare({
    required this.id,
    required this.posterId,
    this.performerId,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.bountyAmount,
    required this.platformFeePct,
    required this.dareMode,
    required this.status,
    this.expiresAt,
    this.proofVideoUrl,
    this.proofText,
    this.moderationResult,
    this.moderationModel,
    this.judgingDeadline,
    this.winnerPerformerId,
    required this.createdAt,
    required this.updatedAt,
    this.posterUsername,
    this.posterAvatarUrl,
    this.posterDisplayName,
    this.submissionCount = 0,
  });

  int get performerShare => (bountyAmount * (1 - platformFeePct)).round();
  int get platformFee => (bountyAmount * platformFeePct).round();
  int get splitShare =>
      submissionCount > 0 ? (performerShare / submissionCount).round() : performerShare;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory Dare.fromJson(Map<String, dynamic> json) {
    final poster = json['profiles'] as Map<String, dynamic>?;
    return Dare(
      id: json['id'] as String,
      posterId: json['poster_id'] as String,
      performerId: json['performer_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      bountyAmount: json['bounty_amount'] as int,
      platformFeePct: (json['platform_fee_pct'] as num?)?.toDouble() ?? 0.20,
      dareMode: DareModeX.fromString(json['dare_mode'] as String? ?? 'solo'),
      status: DareStatusX.fromString(json['status'] as String? ?? 'open'),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      proofVideoUrl: json['proof_video_url'] as String?,
      proofText: json['proof_text'] as String?,
      moderationResult: json['moderation_result'] as Map<String, dynamic>?,
      moderationModel: json['moderation_model'] as String?,
      judgingDeadline: json['judging_deadline'] != null
          ? DateTime.parse(json['judging_deadline'] as String)
          : null,
      winnerPerformerId: json['winner_performer_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      posterUsername: poster?['username'] as String?,
      posterAvatarUrl: poster?['avatar_url'] as String?,
      posterDisplayName: poster?['display_name'] as String?,
      submissionCount: json['submission_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'poster_id': posterId,
        'performer_id': performerId,
        'title': title,
        'description': description,
        'category': category,
        'tags': tags,
        'bounty_amount': bountyAmount,
        'platform_fee_pct': platformFeePct,
        'dare_mode': dareMode.dbValue,
        'status': status.dbValue,
        'expires_at': expiresAt?.toIso8601String(),
        'proof_video_url': proofVideoUrl,
        'proof_text': proofText,
        'moderation_result': moderationResult,
        'moderation_model': moderationModel,
        'judging_deadline': judgingDeadline?.toIso8601String(),
        'winner_performer_id': winnerPerformerId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class DareSubmission {
  final String id;
  final String dareId;
  final String performerId;
  final String? proofVideoUrl;
  final String? proofText;
  final String? aiVerdict; // approved | rejected | escalated
  final double? aiConfidence;
  final String? posterVerdict; // approved | rejected | winner
  final String? posterNote;
  final bool isContested;
  final String? adminVerdict;
  final int? payoutAmount;
  final DateTime? settledAt;
  final DateTime createdAt;

  const DareSubmission({
    required this.id,
    required this.dareId,
    required this.performerId,
    this.proofVideoUrl,
    this.proofText,
    this.aiVerdict,
    this.aiConfidence,
    this.posterVerdict,
    this.posterNote,
    required this.isContested,
    this.adminVerdict,
    this.payoutAmount,
    this.settledAt,
    required this.createdAt,
  });

  factory DareSubmission.fromJson(Map<String, dynamic> json) => DareSubmission(
        id: json['id'] as String,
        dareId: json['dare_id'] as String,
        performerId: json['performer_id'] as String,
        proofVideoUrl: json['proof_video_url'] as String?,
        proofText: json['proof_text'] as String?,
        aiVerdict: json['ai_verdict'] as String?,
        aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
        posterVerdict: json['poster_verdict'] as String?,
        posterNote: json['poster_note'] as String?,
        isContested: json['is_contested'] as bool? ?? false,
        adminVerdict: json['admin_verdict'] as String?,
        payoutAmount: json['payout_amount'] as int?,
        settledAt: json['settled_at'] != null
            ? DateTime.parse(json['settled_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
