enum UserStatus {
  pendingVerification,
  active,
  suspended,
  inactive;

  static UserStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'SUSPENDED':
        return UserStatus.suspended;
      case 'INACTIVE':
        return UserStatus.inactive;
      case 'PENDING_VERIFICATION':
      default:
        return UserStatus.pendingVerification;
    }
  }

  String toBackendString() {
    switch (this) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.suspended:
        return 'SUSPENDED';
      case UserStatus.inactive:
        return 'INACTIVE';
      case UserStatus.pendingVerification:
        return 'PENDING_VERIFICATION';
    }
  }
}

enum OtpPurpose {
  login,
  passwordReset,
  emailVerification,
  transactionVerification;

  static OtpPurpose fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PASSWORD_RESET':
        return OtpPurpose.passwordReset;
      case 'EMAIL_VERIFICATION':
        return OtpPurpose.emailVerification;
      case 'TRANSACTION_VERIFICATION':
        return OtpPurpose.transactionVerification;
      case 'LOGIN':
      default:
        return OtpPurpose.login;
    }
  }

  String toBackendString() {
    switch (this) {
      case OtpPurpose.login:
        return 'LOGIN';
      case OtpPurpose.passwordReset:
        return 'PASSWORD_RESET';
      case OtpPurpose.emailVerification:
        return 'EMAIL_VERIFICATION';
      case OtpPurpose.transactionVerification:
        return 'TRANSACTION_VERIFICATION';
    }
  }
}

enum LoginStatus {
  success,
  failed;

  static LoginStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'FAILED':
        return LoginStatus.failed;
      case 'SUCCESS':
      default:
        return LoginStatus.success;
    }
  }

  String toBackendString() {
    switch (this) {
      case LoginStatus.failed:
        return 'FAILED';
      case LoginStatus.success:
        return 'SUCCESS';
    }
  }
}

class AuthenticatedUser {
  final String id;
  final String tenantId;
  final String? schoolId;
  final String? branchId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserStatus status;
  final bool emailVerified;
  final bool mustChangePassword;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  const AuthenticatedUser({
    required this.id,
    required this.tenantId,
    this.schoolId,
    this.branchId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.status,
    required this.emailVerified,
    required this.mustChangePassword,
    this.lastLoginAt,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId']?.toString() ?? '',
      schoolId: json['schoolId']?.toString(),
      branchId: json['branchId']?.toString(),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      status: UserStatus.fromString(json['status']?.toString()),
      emailVerified: json['emailVerified'] == true,
      mustChangePassword: json['mustChangePassword'] == true,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tenantId': tenantId,
    'schoolId': schoolId,
    'branchId': branchId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'status': status.toBackendString(),
    'emailVerified': emailVerified,
    'mustChangePassword': mustChangePassword,
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
  };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = '15m',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresIn: json['expiresIn']?.toString() ?? '15m',
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
  };
}

class LoginResponseData {
  final AuthenticatedUser user;
  final AuthTokens tokens;
  final AuthSessionItem? session;
  final bool mustChangePassword;

  const LoginResponseData({
    required this.user,
    required this.tokens,
    this.session,
    required this.mustChangePassword,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      user: AuthenticatedUser.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : {},
      ),
      tokens: AuthTokens.fromJson(
        json['tokens'] is Map<String, dynamic>
            ? json['tokens'] as Map<String, dynamic>
            : {},
      ),
      session: json['session'] is Map<String, dynamic>
          ? AuthSessionItem.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'tokens': tokens.toJson(),
    'session': session?.toJson(),
    'mustChangePassword': mustChangePassword,
  };
}

class AuthSessionItem {
  final String id;
  final String? deviceInfo;
  final String? ipAddress;
  final bool isCurrent;
  final bool isCurrentSession;
  final bool isRevoked;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const AuthSessionItem({
    required this.id,
    this.deviceInfo,
    this.ipAddress,
    this.isCurrent = false,
    this.isCurrentSession = false,
    this.isRevoked = false,
    this.createdAt,
    this.expiresAt,
  });

  bool get activeIsCurrent => isCurrent || isCurrentSession;

  factory AuthSessionItem.fromJson(Map<String, dynamic> json) {
    return AuthSessionItem(
      id: json['id']?.toString() ?? '',
      deviceInfo: json['deviceInfo']?.toString(),
      ipAddress: json['ipAddress']?.toString(),
      isCurrent: json['isCurrent'] == true,
      isCurrentSession: json['isCurrentSession'] == true,
      isRevoked: json['isRevoked'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceInfo': deviceInfo,
    'ipAddress': ipAddress,
    'isCurrent': isCurrent,
    'isCurrentSession': isCurrentSession,
    'isRevoked': isRevoked,
    'createdAt': createdAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
  };
}

class LoginHistoryItem {
  final String id;
  final LoginStatus status;
  final String? failureReason;
  final String? ipAddress;
  final String? deviceInfo;
  final DateTime? createdAt;

  const LoginHistoryItem({
    required this.id,
    required this.status,
    this.failureReason,
    this.ipAddress,
    this.deviceInfo,
    this.createdAt,
  });

  bool get isSuccess => status == LoginStatus.success;

  factory LoginHistoryItem.fromJson(Map<String, dynamic> json) {
    return LoginHistoryItem(
      id: json['id']?.toString() ?? '',
      status: LoginStatus.fromString(json['status']?.toString()),
      failureReason: json['failureReason']?.toString(),
      ipAddress: json['ipAddress']?.toString(),
      deviceInfo: json['deviceInfo']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.toBackendString(),
    'failureReason': failureReason,
    'ipAddress': ipAddress,
    'deviceInfo': deviceInfo,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class OtpRequestResponse {
  final String identifier;
  final OtpPurpose purpose;
  final int expiresInSeconds;
  final String? message;

  const OtpRequestResponse({
    required this.identifier,
    required this.purpose,
    required this.expiresInSeconds,
    this.message,
  });

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      identifier: json['identifier']?.toString() ?? '',
      purpose: OtpPurpose.fromString(json['purpose']?.toString()),
      expiresInSeconds: (json['expiresInSeconds'] as num?)?.toInt() ?? 300,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'purpose': purpose.toBackendString(),
    'expiresInSeconds': expiresInSeconds,
    'message': message,
  };
}

class OtpVerifyResponse {
  final bool verified;
  final String? message;

  const OtpVerifyResponse({required this.verified, this.message});

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      verified: json['verified'] == true,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'verified': verified, 'message': message};
}
