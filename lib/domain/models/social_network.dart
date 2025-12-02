class SocialNetwork {
  final int id;
  final String value;
  final String state;
  final int entityId;
  final int main;
  final int entityType;
  final int informationSocialNetworkTypeId;
  final String socialNetworkName;
  final String socialNetworkIcon;
  final String typeSocial; // <- Nuevo campo agregado

  SocialNetwork({
    required this.id,
    required this.value,
    required this.state,
    required this.entityId,
    required this.main,
    required this.entityType,
    required this.informationSocialNetworkTypeId,
    required this.socialNetworkName,
    required this.socialNetworkIcon,
    required this.typeSocial, // <- Nuevo campo
  });

  factory SocialNetwork.fromJson(Map<String, dynamic> json, String typeSocial) {
    return SocialNetwork(
      id: json['id'] ?? 0,
      value: json['value'] ?? '',
      state: json['state'] ?? 'INACTIVE',
      entityId: json['entity_id'] ?? 0,
      main: json['main'] ?? 0,
      entityType: json['entity_type'] ?? 0,
      informationSocialNetworkTypeId: json['information_social_network_type_id'] ?? 0,
      socialNetworkName: json['social_network_name'] ?? '',
      socialNetworkIcon: json['social_network_icon'] ?? '',
      typeSocial: typeSocial, // <- Se asigna desde el key
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
    'state': state,
    'entity_id': entityId,
    'main': main,
    'entity_type': entityType,
    'information_social_network_type_id': informationSocialNetworkTypeId,
    'social_network_name': socialNetworkName,
    'social_network_icon': socialNetworkIcon,
    'type_social': typeSocial,
  };

  static List<SocialNetwork> fromMap(Map<String, dynamic> json) {
    final List<SocialNetwork> result = [];

    json.forEach((key, value) {
      if (value != null) {
        final network = SocialNetwork.fromJson(value, key);
        result.add(network);
      }
    });

    return result;
  }
}
