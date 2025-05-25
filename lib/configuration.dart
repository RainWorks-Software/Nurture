// This is configuration information and should not be changed.

class OFDConfiguration {
  final String version;
  final String url;

  OFDConfiguration({required this.version, required this.url});
}

final OFDConfiguration Configuration = OFDConfiguration(
  version: "1.0.0",
  url: "https://example.com"
);