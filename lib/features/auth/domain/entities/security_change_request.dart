/// Response after creating a security change request
class SecurityChangeRequestResponse {
  final String requestId;
  final String status;

  const SecurityChangeRequestResponse({
    required this.requestId,
    required this.status,
  });

  factory SecurityChangeRequestResponse.fromJson(Map<String, dynamic> json) {
    return SecurityChangeRequestResponse(
      requestId:
          json['requestId'] as String? ?? json['request_id'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}

/// One pending security change request (for reviewer list)
class SecurityChangeRequestItem {
  final String requestId;
  final String userId;
  final String changeType;
  final String payloadJson;
  final DateTime requestedAt;
  final String userEmail;
  final String? firstName;
  final String? lastName;

  const SecurityChangeRequestItem({
    required this.requestId,
    required this.userId,
    required this.changeType,
    required this.payloadJson,
    required this.requestedAt,
    required this.userEmail,
    this.firstName,
    this.lastName,
  });

  factory SecurityChangeRequestItem.fromJson(Map<String, dynamic> json) {
    return SecurityChangeRequestItem(
      requestId:
          json['requestId'] as String? ?? json['request_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      changeType:
          json['changeType'] as String? ?? json['change_type'] as String? ?? '',
      payloadJson: json['payloadJson'] as String? ??
          json['payload_json'] as String? ??
          '{}',
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'] as String)
          : json['requested_at'] != null
              ? DateTime.parse(json['requested_at'] as String)
              : DateTime.now(),
      userEmail:
          json['userEmail'] as String? ?? json['user_email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? json['first_name'] as String?,
      lastName: json['lastName'] as String? ?? json['last_name'] as String?,
    );
  }
}

/// Result of approve/reject
class SecurityChangeRequestReviewResult {
  final String requestId;
  final String userId;
  final String status;

  const SecurityChangeRequestReviewResult({
    required this.requestId,
    required this.userId,
    required this.status,
  });

  factory SecurityChangeRequestReviewResult.fromJson(Map<String, dynamic> json) {
    return SecurityChangeRequestReviewResult(
      requestId:
          json['requestId'] as String? ?? json['request_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
