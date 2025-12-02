class Totem {
  final String id;
  final String nameEs;
  final String nameKi;
  final double lat;
  final double lng;
  final double captureRadius; // metros
  final String assetPng; // ícono o preview 2D
  final String assetGlb; // ruta local o url remota
  final String loreShort;
  final String loreQrUrl;
  final bool isLocal; // true = assets/, false = url

  const Totem({
    required this.id,
    required this.nameEs,
    required this.nameKi,
    required this.lat,
    required this.lng,
    required this.captureRadius,
    required this.assetPng,
    required this.assetGlb,
    required this.loreShort,
    required this.loreQrUrl,
    required this.isLocal,
  });

  factory Totem.fromJson(Map<String, dynamic> j) => Totem(
    id: j['id'],
    nameEs: j['name_es'],
    nameKi: j['name_ki'],
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    captureRadius: (j['capture_radius'] as num).toDouble(),
    assetPng: j['asset_png'],
    assetGlb: j['asset_glb'],
    loreShort: j['lore_short'],
    loreQrUrl: j['lore_qr_url'],
    isLocal: j['is_local'] ?? true, // por defecto local
  );
}
