// lib/shared/models/performer_post.dart

enum PerformerPostStatus { open, funded, underReview, completed, cancelled }

extension PerformerPostStatusX on PerformerPostStatus {
  String get dbValue {
    switch (this) {
      case PerformerPostStatus.open:
        return 'open';
      case PerformerPostStatus.funded:
        return 'funded';
      case PerformerPostStatus.underReview:
        return 'under_review';
      case PerformerPostStatus.completed:
        return 'completed';
      case PerformerPostStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case PerformerPostStatus.open:
        return 'Open for funding';
      case PerformerPostStatus.funded:
        return 'Funded';
      case PerformerPostStatus.underReview:
        return 'Under Review';
      case PerformerPostStatus.completed:
        return 'Completed';
      case PerformerPostStatus.cancelled:
        return 'Cancelled';
    }
  }

  static PerformerPostStatus fromString(String value) {
    switch (value) {
      case 'funded':
        return PerformerPostStatus.funded;
      case 'under_review':
        return PerformerPostStatus.underReview;
      case 'completed':
        return PerformerPostStatus.completed;
      case 'cancelled':
        return PerformerPostStatus.cancelled;
      case 'open':
      default:
        return PerformerPostStatus.open;
    }
  }
}

class PerformerPost {
  final String id;
  final String performerId;
  final String title;
  final String description;
  final String category;
  final int askingPrice;
  final PerformerPostStatus status;
  final String? funderId;
  final String? proofVideoUrl;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? performerUsername;
  final String? performerAvatarUrl;
  final String? performerDisplayName;

  const PerformerPost({
    required this.id,
    required this.performerId,
    required this.title,
    required this.description,
    required this.category,
    required this.askingPrice,
    required this.status,
    this.funderId,
    this.proofVideoUrl,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.performerUsername,
    this.performerAvatarUrl,
    this.performerDisplayName,
  });

  int get performerShare => (askingPrice * 0.80).round();
  bool get isExpired =>
      deadline != null && DateTime.now().isAfter(deadline!);

  /// Number of unique funders (simplification: 1 if funderId != null)
  int get funders => funderId != null ? 1 : 0;

  /// Total coins funded (simplified: equals asking price when funded)
  int get totalFunded => funderId != null ? askingPrice : 0;

  /// Status as string (for open check without importing enum everywhere)
  String get statusString => status.dbValue;

  factory PerformerPost.fromJson(Map<String, dynamic> json) {
    final performer = json['profiles'] as Map<String, dynamic>?;
    return PerformerPost(
      id: json['id'] as String,
      performerId: json['performer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      askingPrice: json['asking_price'] as int,
      status: PerformerPostStatusX.fromString(json['status'] as String? ?? 'open'),
      funderId: json['funder_id'] as String?,
      proofVideoUrl: json['proof_video_url'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      performerUsername: performer?['username'] as String?,
      performerAvatarUrl: performer?['avatar_url'] as String?,
      performerDisplayName: performer?['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'performer_id': performerId,
        'title': title,
        'description': description,
        'category': category,
        'asking_price': askingPrice,
        'status': status.dbValue,
        'funder_id': funderId,
        'proof_video_url': proofVideoUrl,
        'deadline': deadline?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
