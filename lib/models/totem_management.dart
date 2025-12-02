import 'dart:math';

/// ------------------ MODELOS ------------------
/// ------------------ MODELOS ------------------
/// ------------------ MODELOS ------------------
/// Posición geográfica de un item (WGS84)
class ItemPosition {
  /// Latitud en grados decimales
  final double lat;

  /// Longitud en grados decimales
  final double lng;

  /// Altitud en metros sobre el nivel del mar (opcional)
  final double? alt;

  const ItemPosition({required this.lat, required this.lng, this.alt});

  /// Distancia horizontal (2D) usando Haversine, en metros.
  double distanceHorizontalTo(ItemPosition other) {
    const R = 6371000.0; // radio de la Tierra en metros

    double _deg2rad(double d) => d * 3.141592653589793 / 180.0;

    final dLat = _deg2rad(other.lat - lat);
    final dLon = _deg2rad(other.lng - lng);
    final lat1 = _deg2rad(lat);
    final lat2 = _deg2rad(other.lat);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        (sin(dLon / 2) * sin(dLon / 2)) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// Distancia 3D (si ambas altitudes están presentes).
  /// Si alguna altitud es null, retorna la distancia horizontal.
  double distance3DTo(ItemPosition other) {
    final horizontal = distanceHorizontalTo(other);

    if (alt == null || other.alt == null) {
      return horizontal;
    }

    final dz = (other.alt! - alt!).abs();
    return sqrt(horizontal * horizontal + dz * dz);
  }
}

class ItemSources {
  final String glb;
  final String img;
  final bool isLocal;

  // ====== Estado de caché embebido (mutable) ======
  bool loadedOnce = false; // ¿ya se cargó al menos 1 vez en esta sesión?
  String? resolvedPath; // file:/data:/https: que funcionó
  int? bytes; // progreso temporal (recibidos)
  int? total; // total si el servidor lo expone

  ItemSources({required this.glb, required this.img, this.isLocal = false});

  // helpers opcionales
  void setProgress(int received, int? t) {
    bytes = received;
    total = (t != null && t > 0) ? t : null;
  }

  void sealAfterFirstLoad(String resolved) {
    loadedOnce = true;
    resolvedPath = resolved;
    // limpiar contadores para no confundir UI en reusos
    bytes = null;
    total = null;
  }

  bool get hasTotal => total != null && total! > 0;
}

class ItemAR {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final ItemPosition position;
  final ItemSources sources;

  const ItemAR({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.position,
    required this.sources,
  });
}

/// ------------------ DATA (paths reales) ------------------
final List<ItemAR> itemsSources = [
  ItemAR(
    id: "taita",
    title: "Taita Imbabura – Abuelo del Viento y del Valle",
    subtitle: "Ñawi Hatun Yaya Imbabura",
    description:
        "Volcán sabio y protector; guardián del viento que abraza la laguna y cuida a quienes caminan a sus pies.",
    position: ItemPosition(
      lat: 0.20477,
      lng: -78.20639,
      alt: 2670, // m s.n.m. aprox. orilla Lago San Pablo
    ),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/taita-imbabura-toon-1.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/taita-imbabura.png",
    ),
  ),
  ItemAR(
    id: "cerro-cusin",
    title: "Cusin – Guardián del Paso Fértil",
    subtitle: "Allpa Ñampi Rikcharik",
    description:
        "Cerro alegre y trabajador; sus laderas despiertan los caminos de siembra, cosecha y fiesta.",
    position: ItemPosition(lat: 0.20435, lng: -78.20688, alt: 2670),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/muelle-catalina/cusin.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/elcusin.png",
    ),
  ),
  ItemAR(
    id: "mojanda",
    title: "Mojanda – Susurro del Páramo y las Lagunas",
    subtitle: "Sachayaku Mama",
    description:
        "Entre neblinas y pajonales, sus lagunas tejen hilos de agua fría que renuevan el cuerpo y el espíritu.",
    position: ItemPosition(lat: 0.20401, lng: -78.20723, alt: 2670),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/muelle-catalina/mojanda.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/mojanda.png",
    ),
  ),
  ItemAR(
    id: "mama-cotacachi",
    title: "Mama Cotacachi – Madre de los Ciclos de la Vida",
    subtitle: "Allpa Mama – Warmi Rasu",
    description:
        "Montaña dulce y poderosa; guarda los tiempos de la siembra, el descanso y el renacer de la Pachamama.",
    position: ItemPosition(lat: 0.20369, lng: -78.20759, alt: 2670),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/mama-cotacachi.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/warmi-razu.png",
    ),
  ),
  ItemAR(
    id: "coraza",
    title: "El Coraza – Espíritu de Fiesta y Resistencia",
    subtitle: "Kawsay Taki Coraza",
    description:
        "Su danza es memoria viva de lucha y dignidad; cada paso honra a los ancestros y enciende la celebración.",
    position: ItemPosition(lat: 0.20349, lng: -78.20779, alt: 2670),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/coraza-one.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/elcoraza.png",
    ),
  ),
  ItemAR(
    id: "lechero",
    title: "El Lechero – Árbol del Encuentro y los Deseos",
    subtitle: "Kawsay Ranti Yura",
    description:
        "Árbol sagrado y testigo de promesas; desde sus ramas el mundo sueña, pide, agradece y se reconcilia.",
    position: ItemPosition(lat: 0.20316, lng: -78.20790, alt: 2670),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/muelle-catalina/lechero.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/lechero.png",
    ),
  ),
  ItemAR(
    id: "lago-san-pablo",
    title: "Yaku Mama – Laguna Viva de San Pablo",
    subtitle: "Yaku Mama – Kawsaycocha",
    description:
        "Agua que respira y recuerda; en su espejo se reflejan montes, nubes y la memoria de los pueblos.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802, alt: 2670),
    sources: ItemSources(
      glb:
          "https://meetclic.com/public/simi-rura/muelle-catalina/lago-san-pablo.glb",
      img:
          "https://meetclic.com/public/simi-rura/muelle-catalina/images/yaku-mama.png",
    ),
  ),
  ItemAR(
    id: "ayahuma-pacha",
    title: "Ayahuma – Guardián de los Sueños Profundos",
    subtitle: "Aya Uma Pacha Kawsay",
    description:
        "Espíritu que protege las visiones; conecta la memoria de la tierra con los sueños del caminante.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802, alt: 2670),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/pacha/ayahuma.glb",
      img: "https://meetclic.com/public/simi-rura/pacha/images/ayahuma.jpeg",
    ),
  ),
  ItemAR(
    id: "corazon-pacha",
    title: "Corazón Pacha – Latido de la Tierra Viva",
    subtitle: "Pacha Sonqo",
    description:
        "Centro espiritual donde todo se encuentra; cada latido une montes, agua, viento y corazón humano.",
    position: ItemPosition(lat: 0.20284, lng: -78.20802, alt: 2670),
    sources: ItemSources(
      glb: "https://meetclic.com/public/simi-rura/pacha/corazon.glb",
      img: "https://meetclic.com/public/simi-rura/pacha/images/corazon.jpeg",
    ),
  ),
];
