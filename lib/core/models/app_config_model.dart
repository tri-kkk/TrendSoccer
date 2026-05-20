class AppConfigData {
  const AppConfigData({
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.updateMessage,
    required this.maintenanceMode,
    this.maintenanceMessage,
  });

  factory AppConfigData.fromJson(Map<String, dynamic> json) {
    return AppConfigData(
      minSupportedVersion: _readString(
            json,
            'minSupportedVersion',
            'min_supported_version',
          ) ??
          '0.0.0',
      latestVersion: _readString(json, 'latestVersion', 'latest_version') ??
          '0.0.0',
      forceUpdate: _readBool(json, 'forceUpdate', 'force_update'),
      updateMessage: _readString(json, 'updateMessage', 'update_message'),
      maintenanceMode: _readBool(json, 'maintenanceMode', 'maintenance_mode'),
      maintenanceMessage: _readString(
        json,
        'maintenanceMessage',
        'maintenance_message',
      ),
    );
  }

  final String minSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? updateMessage;
  final bool maintenanceMode;
  final String? maintenanceMessage;
}

bool _readBool(Map<String, dynamic> json, String camel, String snake) {
  final value = json[camel] ?? json[snake];
  if (value is bool) return value;
  return false;
}

String? _readString(Map<String, dynamic> json, String camel, String snake) {
  final value = json[camel] ?? json[snake];
  if (value is String && value.isNotEmpty) return value;
  return null;
}
