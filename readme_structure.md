
---

# 📌 `state/`

### **Qué contiene**
Clases que representan el **estado de la pantalla**, por ejemplo:
- filtros
- información del mapa
- carga (loading)
- markers
- ubicación actual

### **Para qué sirve**
- Mantener el estado de manera **ordenada e inmutable**.
- Evitar mezclar lógica y UI.
- Facilitar `copyWith()` para actualizaciones limpias.

### **Ejemplos**
- `BusinessMapState`
- `BusinessFiltersState`

---

# 📌 `services/`

### **Qué contiene**
Clases que manejan la **lógica interna** de la pantalla, como:
- llamadas a casos de uso
- procesamiento de datos
- reglas de negocio específicas del mapa

### **Para qué sirve**
- Actuar como **intermediario entre la UI y el dominio**.
- Encapsular lógica compleja que no debe vivir en widgets.
- Preparar, validar o transformar datos antes de mostrarlos.

### **Ejemplos**
- `BusinessMapService`
- `MarkerBuilderService`

---

# 📌 `models/`

### **Qué contiene**
Modelos propios de la **UI de esta pantalla**.  
No son modelos globales ni de domain.

### **Para qué sirve**
- Simplificar la estructura de datos consumida por el mapa.
- Representar coordenadas, ubicaciones o estados que son específicos del feature.
- Mantener separados los modelos del dominio y los de presentación.

### **Ejemplos**
- `SearchLocationInfoModel`
- `BusinessPosition`

---

# 📌 `widgets/` — Atomic Design

La UI de esta pantalla se divide siguiendo **Atomic Design**:

---

## 🔹 `atoms/`

### **Qué contiene**
Componentes UI pequeños e indivisibles:
- botones
- íconos
- textos
- toggles

### **Para qué sirve**
- Son la base visual más simple.
- Máxima **reutilización**.

### **Ejemplos**
- `ToggleFilterTileAtom`
- `LoadingOverlayAtom`
- `CurrentLocationFabAtom`

---

## 🔹 `molecules/`

### **Qué contiene**
Componentes que combinan varios **atoms**.

### **Para qué sirve**
- Crear piezas UI reutilizables más complejas sin lógica pesada.

### **Ejemplos**
- `TopSearchBarMolecule`
- `CategoryExpansionMolecule`
- `SearchLocationSummaryCard`

---

## 🔹 `organisms/`

### **Qué contiene**
Componentes grandes y completos:
- combinan molecules y atoms
- pueden manejar estado local
- pueden contener animaciones o interacciones avanzadas

### **Para qué sirve**
- Construir **secciones completas** o paneles de la pantalla.

### **Ejemplos**
- `BusinessFiltersBottomSheetOrganism`
- `SearchLocationDetailOrganism`

---

# 📌 `helpers/`

### **Qué contiene**
Funciones utilitarias pequeñas y clases auxiliares.

### **Para qué sirve**
- Crear markers del mapa.
- Formatear distancias o coordenadas.
- Definir reglas de refresco.
- Evitar duplicar lógica en widgets.

### **Ejemplos**
- `MarkerHelper`
- `MapRefreshHelper`

---

# 📌 `theme/`

### **Qué contiene**
Colores, estilos y configuraciones visuales específicas de esta pantalla.

### **Para qué sirve**
- Mantener un estilo coherente dentro del feature.
- Evitar hardcodear colores.
- Permitir personalizar la UI sin afectar el resto del proyecto.

### **Ejemplos**
- `BusinessFiltersColors`
- `SearchBarColors`

---

# ✅ RESUMEN FINAL

| Carpeta | Propósito |
|--------|-----------|
| **state/** | Manejo del estado inmutable de la UI |
| **services/** | Lógica interna del mapa y filtros |
| **models/** | Modelos propios de UI |
| **widgets/atoms** | Piezas UI más pequeñas |
| **widgets/molecules** | Bloques UI reutilizables |
| **widgets/organisms** | Secciones complejas de UI |
| **helpers/** | Utilidades pequeñas y funciones auxiliares |
| **theme/** | Colores y estilos visuales del módulo |

---

Si deseas, puedo generar también:

✅ un documento PDF  
✅ una plantilla estándar para crear nuevas features  
✅ un ejemplo completo de cómo agregar una nueva sección siguiendo esta arquitectura

¿Deseas alguno de estos?
