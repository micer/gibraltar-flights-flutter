import 'dart:io';

class MyProxyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY 192.168.18.100:8888;";
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
