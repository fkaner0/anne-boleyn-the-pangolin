const bool httpsAvailable = true;

Uri newUri(String baseUrl, String endpoint, [bool secure = httpsAvailable]) {
  return secure ? Uri.https(baseUrl, endpoint) : Uri.http(baseUrl, endpoint);
}
