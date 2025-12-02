import 'package:meetclic_app/models/totem.dart';

final List<Totem> totems = [
  Totem(
    id: "totem_imbabura",
    nameEs: "Taita Imbabura – El Abuelo que todo lo ve",
    nameKi: "Ñawi Hatun Yaya",
    lat: -0.3495,
    lng: -78.1220,
    captureRadius: 50,
    assetPng: "assets/totems/imbabura/icon.png",
    assetGlb: "assets/totems/imbabura/model.glb",
    loreShort: "Sabio y protector, guardián del viento y los ciclos.",
    loreQrUrl: "https://tu-sitio/qr/imbabura",
    isLocal: true,
  ),
  Totem(
    id: "totem_cotacachi",
    nameEs: "Mama Cotacachi – La Madre Montaña",
    nameKi: "Mama Qutakachi",
    lat: -0.3050,
    lng: -78.2640,
    captureRadius: 50,
    assetPng: "assets/totems/cotacachi/icon.png",
    assetGlb:
        "https://mi-bucket.s3.amazonaws.com/models/cotacachi.glb", // remoto
    loreShort: "Madre sabia que protege los valles y lagunas.",
    loreQrUrl: "https://tu-sitio/qr/cotacachi",
    isLocal: true,
  ),
];
