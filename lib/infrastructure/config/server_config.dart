// ===============================
// 📦 INFRASTRUCTURE LAYER
// ===============================

// infrastructure/config/server_config.dart
enum Environment { production, developer, test, local }

abstract class Config {
  static const socket = '185.28.23.139';

  //static const socket = '10.143.10.83';
  static const port = 8081;
}

class ServerConfig {
  static Environment currentEnv = Environment.production;

  static String get getSocketServer {
    //return 'ws://${Config.socket}:${Config.port}/audio';
    //   return 'ws://${Config.socket}/socketMigu3ln/audio';
    // compu return 'ws://${Config.socket}:${Config.port}/socketMigu3ln/audio';
    return 'ws://${Config.socket}/socketMigu3ln/audio';
  }

  static String get baseUrl {
    switch (currentEnv) {
      case Environment.production:
        return 'https://meetclic.com/api';
      case Environment.local:
        return 'http://10.0.2.2:8080/meetclic-manager/api';
      case Environment.developer:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Environment.test:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
