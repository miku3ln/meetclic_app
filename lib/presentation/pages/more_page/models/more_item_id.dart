// more_item_id.dart
enum MoreItemSectionId {
  tools(1),
  community(20),
  settingsAndSupport(40);

  final int value;
  const MoreItemSectionId(this.value);
}

enum MoreItemProcessId {
  // Tools / negocio
  addBusiness(1),
  exploreBusiness(2),
  dictionary(3),
  arBusiness(4),
  projects(5),

  // Comunidad
  eliteSquad(20),
  friendsCheckins(21),
  chat(22),
  events(23),

  // Configuración y soporte
  settings(40),
  helpCenter(41),
  dictionaryCenter(44);

  final int value;
  const MoreItemProcessId(this.value);

  static MoreItemProcessId? fromValue(int value) {
    try {
      return MoreItemProcessId.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}
