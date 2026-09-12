class ServiceHealthItem {
  final String status;
  final int? latencyMs;
  final String? error;

  const ServiceHealthItem({required this.status, this.latencyMs, this.error});

  bool get isConnected => status.toLowerCase() == 'connected';

  factory ServiceHealthItem.fromJson(Map<String, dynamic> json) {
    return ServiceHealthItem(
      status: json['status']?.toString() ?? 'unknown',
      latencyMs: json['latencyMs'] is num
          ? (json['latencyMs'] as num).toInt()
          : null,
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    if (latencyMs != null) 'latencyMs': latencyMs,
    if (error != null) 'error': error,
  };
}

class MemoryUsageMb {
  final double rss;
  final double heapTotal;
  final double heapUsed;
  final double externalUsage;

  const MemoryUsageMb({
    required this.rss,
    required this.heapTotal,
    required this.heapUsed,
    required this.externalUsage,
  });

  factory MemoryUsageMb.fromJson(Map<String, dynamic> json) {
    return MemoryUsageMb(
      rss: (json['rss'] as num?)?.toDouble() ?? 0.0,
      heapTotal: (json['heapTotal'] as num?)?.toDouble() ?? 0.0,
      heapUsed: (json['heapUsed'] as num?)?.toDouble() ?? 0.0,
      externalUsage: (json['external'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SystemHealthDetails {
  final String? nodeVersion;
  final MemoryUsageMb? memoryUsageMb;

  const SystemHealthDetails({this.nodeVersion, this.memoryUsageMb});

  factory SystemHealthDetails.fromJson(Map<String, dynamic> json) {
    return SystemHealthDetails(
      nodeVersion: json['nodeVersion']?.toString(),
      memoryUsageMb: json['memoryUsageMb'] is Map<String, dynamic>
          ? MemoryUsageMb.fromJson(
              json['memoryUsageMb'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class HealthModel {
  final String status; // healthy, degraded, unhealthy
  final int uptimeSeconds;
  final String? timestamp;
  final String? environment;
  final String? version;
  final Map<String, ServiceHealthItem> services;
  final SystemHealthDetails? system;

  const HealthModel({
    required this.status,
    required this.uptimeSeconds,
    this.timestamp,
    this.environment,
    this.version,
    this.services = const {},
    this.system,
  });

  bool get isHealthy => status.toLowerCase() == 'healthy';
  bool get isDegraded => status.toLowerCase() == 'degraded';
  bool get isUnhealthy => status.toLowerCase() == 'unhealthy';

  factory HealthModel.fromJson(Map<String, dynamic> json) {
    final servicesMap = <String, ServiceHealthItem>{};
    if (json['services'] is Map<String, dynamic>) {
      final rawServices = json['services'] as Map<String, dynamic>;
      rawServices.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          servicesMap[key] = ServiceHealthItem.fromJson(value);
        }
      });
    }

    return HealthModel(
      status: json['status']?.toString() ?? 'unknown',
      uptimeSeconds: (json['uptimeSeconds'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp']?.toString(),
      environment: json['environment']?.toString(),
      version: json['version']?.toString(),
      services: servicesMap,
      system: json['system'] is Map<String, dynamic>
          ? SystemHealthDetails.fromJson(json['system'] as Map<String, dynamic>)
          : null,
    );
  }
}
