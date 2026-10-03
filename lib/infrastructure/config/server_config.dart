// ===============================
// 📦 INFRASTRUCTURE LAYER
// ===============================

enum Environment {
  production,
  developer,
  test,
  local,
}

abstract class Config {
  // ===========================================================================
  // LEGACY SOCKET
  // ===========================================================================

  static const String socket =
      '185.28.23.139';

  static const int port =
  8081;

  // ===========================================================================
  // PRODUCTION - API
  // ===========================================================================

  static const String productionApi =
      'https://meetclic.com/api';

  // ===========================================================================
  // PRODUCTION - POS SOCKET
  // ===========================================================================

  // Cuando el socket esté publicado con SSL:
  //
  // wss://socket.meetclic.com
  //
  // Por ahora puedes colocar aquí la URL real
  // que tengas disponible en producción.

  static const String productionSocketUrl =
      'wss://post-venta-manager.meetclic.com';

  // ===========================================================================
  // DEVELOPER - API
  // ===========================================================================

  // PC donde está Docker.
  //
  // PC:      192.168.0.101
  // Celular: 192.168.0.100
  //
  // Docker:
  // 0.0.0.0:8080 -> 80/tcp

  static const String developerApi =
      'http://192.168.0.101:8080/meetclic-manager/api';

  // ===========================================================================
  // DEVELOPER - POS SOCKET
  // ===========================================================================

  // Docker:
  // 0.0.0.0:3000 -> 3000/tcp

  static const String developerSocketUrl =
      'ws://192.168.0.101:3000';

  // ===========================================================================
  // TEST - API
  // ===========================================================================

  static const String testApi =
      'http://192.168.0.101:8080/meetclic-manager/api';

  // ===========================================================================
  // TEST - POS SOCKET
  // ===========================================================================

  static const String testSocketUrl =
      'ws://192.168.0.101:3000';

  // ===========================================================================
  // LOCAL - API
  // ===========================================================================

  // Android Emulator -> PC host.

  static const String localApi =
      'http://10.0.2.2:8080/meetclic-manager/api';

  // ===========================================================================
  // LOCAL - POS SOCKET
  // ===========================================================================

  static const String localSocketUrl =
      'ws://10.0.2.2:3000';
}

class ServerConfig {
  // ===========================================================================
  // ENVIRONMENT
  // ===========================================================================

  static Environment currentEnv =
      Environment.production;

  // ===========================================================================
  // LEGACY SOCKET
  // ===========================================================================

  static const String socket =
      '185.28.23.139';

  static String get getSocketServer {
    return 'ws://${Config.socket}/socketMigu3ln/audio';
  }

  // ===========================================================================
  // API
  // ===========================================================================

  static String get baseUrl {
    switch (currentEnv) {
      case Environment.production:
        return Config.productionApi;

      case Environment.developer:
        return Config.developerApi;

      case Environment.test:
        return Config.testApi;

      case Environment.local:
        return Config.localApi;
    }
  }

  // ===========================================================================
  // POS SOCKET
  // ===========================================================================

  static String get socketUrl {
    switch (currentEnv) {
      case Environment.production:
        return Config.productionSocketUrl;

      case Environment.developer:
        return Config.developerSocketUrl;

      case Environment.test:
        return Config.testSocketUrl;

      case Environment.local:
        return Config.localSocketUrl;
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  static bool get isProduction =>
      currentEnv == Environment.production;

  static bool get isDevelopment =>
      currentEnv == Environment.developer;

  static bool get isTest =>
      currentEnv == Environment.test;

  static bool get isLocal =>
      currentEnv == Environment.local;
}