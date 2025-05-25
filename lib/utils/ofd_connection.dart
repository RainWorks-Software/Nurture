import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:ofd/configuration.dart';

/// A custom HTTP client that allows setting a base URL for requests.
///
/// This client wraps the standard `http.Client` and prepends the
/// provided base URL to all request paths.
class _CustomHttpClient {
  final String baseUrl;
  final http.Client _client;

  /// Creates a [_CustomHttpClient] with the given [baseUrl].
  ///
  /// An optional [http.Client] can be provided; otherwise, a new one is created.
  _CustomHttpClient(this.baseUrl, {http.Client? client})
    : _client = client ?? http.Client();

  /// Constructs the full URL by combining the base URL and the relative path.
  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters != null) {
      return uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  /// Sends an HTTP GET request to the specified path.
  ///
  /// The [path] is appended to the [baseUrl].
  /// Optional [headers] and [queryParameters] can be provided.
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = _buildUri(path, queryParameters: queryParameters);
    print('GET Request to: $uri'); // For debugging
    return _client.get(uri, headers: headers);
  }

  /// Sends an HTTP POST request to the specified path.
  ///
  /// The [path] is appended to the [baseUrl].
  /// Optional [headers], [body], and [encoding] can be provided.
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    final uri = _buildUri(path);
    print('POST Request to: $uri'); // For debugging
    return _client.post(uri, headers: headers, body: body, encoding: encoding);
  }

  /// Sends an HTTP PUT request to the specified path.
  ///
  /// The [path] is appended to the [baseUrl].
  /// Optional [headers], [body], and [encoding] can be provided.
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    final uri = _buildUri(path);
    print('PUT Request to: $uri'); // For debugging
    return _client.put(uri, headers: headers, body: body, encoding: encoding);
  }

  /// Sends an HTTP DELETE request to the specified path.
  ///
  /// The [path] is appended to the [baseUrl].
  /// Optional [headers] can be provided.
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    final uri = _buildUri(path);
    print('DELETE Request to: $uri'); // For debugging
    return _client.delete(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  /// Closes the underlying HTTP client.
  ///
  /// This should be called when the client is no longer needed to free up resources.
  void close() {
    _client.close();
  }
}

final OFDHttpClient = _CustomHttpClient(Configuration.url);

Future<bool> testConnection() async {
  try {
    var _ = await OFDHttpClient.get("/");
    return true; 
  } catch (_) {
    return false;
  } finally {
    OFDHttpClient.close();
  }
}