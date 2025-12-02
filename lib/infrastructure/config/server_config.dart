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
  // static const String baseUrl = 'http://192.168.137.1/meetclickmanager/api';
  //static const String baseUrl = 'http://192.168.0.101/meetclickmanager/api';
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
      case Environment.developer:
        return 'http://192.168.0.101/meetclickmanager/api';
      case Environment.test:
        return 'http://192.168.137.1/meetclickmanager/api';
      case Environment.local:
        return 'http://10.143.10.83/meetclickmanager/api'; //PC WORK RED

      // return 'http://192.168.0.102/meetclickmanager/api';
    }
  }
}
