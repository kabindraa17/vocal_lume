import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Computes the required Podcast Index API auth headers for a single request.
///
/// Every request needs three extra headers:
///   - `X-Auth-Key`   — the raw API key
///   - `X-Auth-Date`  — current Unix timestamp (seconds) as a string
///   - `Authorization`— SHA-1(apiKey + apiSecret + unixTimestamp) as hex
///
/// All values are computed fresh on each call so they are never stale.
abstract final class PodcastIndexAuthHelper {
  /// Returns a map of the three auth headers ready to merge into [RequestOptions].
  static Map<String, String> buildHeaders({
    required String apiKey,
    required String apiSecret,
  }) {
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final authToken = _sha1Hex('$apiKey$apiSecret$timestamp');

    return {
      'X-Auth-Key': apiKey,
      'X-Auth-Date': timestamp,
      'Authorization': authToken,
      'User-Agent': 'VocalLume/1.0', // TODO: customise the app name if needed
    };
  }

  /// Computes SHA-1 of [input] and returns the lowercase hex digest.
  static String _sha1Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
