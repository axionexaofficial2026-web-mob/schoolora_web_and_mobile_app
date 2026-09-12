class MultiTenancyMeta {
  final bool supported;
  final String? isolationLevel;

  const MultiTenancyMeta({required this.supported, this.isolationLevel});

  factory MultiTenancyMeta.fromJson(Map<String, dynamic> json) {
    return MultiTenancyMeta(
      supported: json['supported'] == true,
      isolationLevel: json['isolationLevel']?.toString(),
    );
  }
}

class MetaModel {
  final String appName;
  final String version;
  final String phase;
  final String environment;
  final String apiVersion;
  final String? timestamp;
  final MultiTenancyMeta? multiTenancy;
  final List<String> supportedModulesPhase1;

  const MetaModel({
    required this.appName,
    required this.version,
    required this.phase,
    required this.environment,
    required this.apiVersion,
    this.timestamp,
    this.multiTenancy,
    this.supportedModulesPhase1 = const [],
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      appName: json['appName']?.toString() ?? 'Schoolaora ERP',
      version: json['version']?.toString() ?? '1.0.0',
      phase: json['phase']?.toString() ?? 'Phase 1: Foundation',
      environment: json['environment']?.toString() ?? 'development',
      apiVersion: json['apiVersion']?.toString() ?? 'v1',
      timestamp: json['timestamp']?.toString(),
      multiTenancy: json['multiTenancy'] is Map<String, dynamic>
          ? MultiTenancyMeta.fromJson(
              json['multiTenancy'] as Map<String, dynamic>,
            )
          : null,
      supportedModulesPhase1:
          (json['supportedModulesPhase1'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
