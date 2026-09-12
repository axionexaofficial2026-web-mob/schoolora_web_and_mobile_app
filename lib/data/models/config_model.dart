class BrandingConfig {
  final String appName;
  final String defaultLocale;
  final List<String> supportedLocales;
  final String defaultTimezone;

  const BrandingConfig({
    required this.appName,
    required this.defaultLocale,
    required this.supportedLocales,
    required this.defaultTimezone,
  });

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      appName: json['appName']?.toString() ?? 'Schoolaora ERP',
      defaultLocale: json['defaultLocale']?.toString() ?? 'en-US',
      supportedLocales:
          (json['supportedLocales'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['en-US'],
      defaultTimezone: json['defaultTimezone']?.toString() ?? 'Asia/Kolkata',
    );
  }
}

class UploadsConfig {
  final int maxUploadSizeMb;
  final List<String> allowedMimeTypes;

  const UploadsConfig({
    required this.maxUploadSizeMb,
    required this.allowedMimeTypes,
  });

  factory UploadsConfig.fromJson(Map<String, dynamic> json) {
    return UploadsConfig(
      maxUploadSizeMb: (json['maxUploadSizeMb'] as num?)?.toInt() ?? 25,
      allowedMimeTypes:
          (json['allowedMimeTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class SystemConfig {
  final bool maintenanceMode;
  final String apiVersion;

  const SystemConfig({required this.maintenanceMode, required this.apiVersion});

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      maintenanceMode: json['maintenanceMode'] == true,
      apiVersion: json['apiVersion']?.toString() ?? 'v1',
    );
  }
}

class PublicConfigModel {
  final BrandingConfig branding;
  final UploadsConfig uploads;
  final SystemConfig system;

  const PublicConfigModel({
    required this.branding,
    required this.uploads,
    required this.system,
  });

  factory PublicConfigModel.fromJson(Map<String, dynamic> json) {
    return PublicConfigModel(
      branding: json['branding'] is Map<String, dynamic>
          ? BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>)
          : const BrandingConfig(
              appName: 'Schoolaora ERP',
              defaultLocale: 'en-US',
              supportedLocales: ['en-US'],
              defaultTimezone: 'Asia/Kolkata',
            ),
      uploads: json['uploads'] is Map<String, dynamic>
          ? UploadsConfig.fromJson(json['uploads'] as Map<String, dynamic>)
          : const UploadsConfig(maxUploadSizeMb: 25, allowedMimeTypes: []),
      system: json['system'] is Map<String, dynamic>
          ? SystemConfig.fromJson(json['system'] as Map<String, dynamic>)
          : const SystemConfig(maintenanceMode: false, apiVersion: 'v1'),
    );
  }
}
