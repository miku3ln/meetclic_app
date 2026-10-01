// lib/shared/utils/util_common.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../domain/services/session_service.dart';
import '../pagination_response.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
class UtilCommon {
  static Future<void> handleTap({
    required BuildContext context,
    required String type,
    required String text,
  }) async {
    Uri url;
    try {
      switch (type) {
        case 'whatsapp':
          final phone = text.replaceAll(RegExp(r'\s|\+'), '');
          const message = 'Hola, estoy interesado en tu empresa desde la app MeetClic 😊';
          final encoded = Uri.encodeComponent(message);

          // Intentar con la app de WhatsApp
          url = Uri.parse('whatsapp://send?phone=$phone&text=$encoded');

          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            // Fallback al navegador si no está instalada la app
            final fallbackUrl = Uri.parse('https://wa.me/$phone?text=$encoded');
            if (!await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication)) {
              _showError(context, 'No se pudo abrir WhatsApp.');
            }
          }
          return;

        case 'email':
          url = Uri.parse('mailto:$text');
          break;

        case 'web':
          url = Uri.parse(text.startsWith('http') ? text : 'https://$text');
          break;

        case 'map':
          url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(text)}');
          break;

        default:
          _showError(context, 'Tipo de enlace no reconocido.');
          return;
      }

      // Manejo general para email, web, mapa
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showError(context, 'No se pudo abrir el enlace.');
      }
    } catch (e) {
      debugPrint('Error en CommonLauncher: $e');
      _showError(context, 'Ocurrió un error inesperado.');
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  static final RegExp _ecuadorianCedulaRegex =
  RegExp(r'^(0[1-9]|1[0-9]|2[0-4])[0-6]\d{6}\d$');

  /// Valida si el número ingresado es una cédula ecuatoriana válida (solo por patrón)
  static bool isValidCedulaEcuatoriana(String cedula) {
    if (cedula.length != 10) return false;
    return _ecuadorianCedulaRegex.hasMatch(cedula);
  }
}
class PaginatedApiService {
  final String baseUrl;

  const PaginatedApiService({required this.baseUrl});

  Future<PaginatedResponse<GenericListItem<T>>> fetchPage<T>({
    required String endpoint,
    required Map<String, String> queryParams,
    required String totalKey,
    required String rowsKey,
    required GenericListItem<T> Function(Map<String, dynamic>) mapper,
  }) async {
    final token = SessionService().apiToken;

    final uri = Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token!}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return PaginatedResponse(
        current: int.tryParse(queryParams['current'] ?? '1') ?? 1,
        rowCount: int.tryParse(queryParams['rowCount'] ?? '0') ?? 0,
        rows: [],
        total: 0,
      );
    }

    final data = jsonDecode(response.body);

    final int total = data[totalKey] ?? 0;
    final List rows = data[rowsKey] ?? [];

    final mapped = rows
        .map<GenericListItem<T>>((json) => mapper(json))
        .toList();

    return PaginatedResponse(
      current: int.tryParse(queryParams['current'] ?? '1') ?? 1,
      rowCount: int.tryParse(queryParams['rowCount'] ?? '0') ?? 0,
      rows: mapped,
      total: total,
    );
  }
}


class PsApiTypeAhead<T> extends StatefulWidget {
  final String label;

  final T? value;

  final Future<List<T>> Function(
      String search,
      ) searchApi;

  final String Function(T item) getLabel;

  final void Function(T item) onSelected;

  final String? error;

  final bool requiredField;
  final bool isTouched;
  final bool isValid;

  const PsApiTypeAhead({
    super.key,
    required this.label,
    required this.searchApi,
    required this.getLabel,
    required this.onSelected,
    this.value,
    this.error,
    this.requiredField = false,
    this.isTouched = false,
    this.isValid = false,
  });

  @override
  State<PsApiTypeAhead<T>> createState() =>
      _PsApiTypeAheadState<T>();
}

class _PsApiTypeAheadState<T>
    extends State<PsApiTypeAhead<T>> {

  /**
   * Evita que seleccionar un elemento
   * vuelva a disparar una búsqueda.
   */
  bool _isSelecting = false;

  /**
   * Texto correspondiente al elemento seleccionado.
   */
  String? _selectedLabel;

  /**
   * Indica que realmente se ejecutó una consulta.
   */
  bool _hasSearch = false;

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      /**
       * ============================================================
       * DIRECCIÓN DEL LISTADO
       * ============================================================
       *
       * IMPORTANTE:
       *
       * Las sugerencias se muestran ENCIMA del input.
       *
       * Esto evita que cuando el teclado esté abierto
       * el listado quede oculto detrás del teclado.
       */
      direction: VerticalDirection.up,

      /**
       * ============================================================
       * CONFIGURACIÓN
       * ============================================================
       */
      debounceDuration: const Duration(
        milliseconds: 500,
      ),

      /**
       * IMPORTANTE:
       *
       * Al recibir focus abre las sugerencias.
       *
       * Esto hace que suggestionsCallback sea ejecutado
       * incluso cuando el texto está vacío.
       */
      showOnFocus: true,

      /**
       * ============================================================
       * BÚSQUEDA
       * ============================================================
       */
      suggestionsCallback: (search) async {
        final currentSearch = search.trim();

        /**
         * Si estamos seleccionando un elemento,
         * NO ejecutar otra consulta.
         */
        if (_isSelecting) {
          return <T>[];
        }

        /**
         * Si el texto corresponde exactamente
         * al elemento seleccionado,
         * NO volver a consultar.
         */
        if (_selectedLabel != null &&
            currentSearch == _selectedLabel) {
          return <T>[];
        }

        /**
         * IMPORTANTE:
         *
         * Aquí NO bloqueamos:
         *
         * currentSearch.isEmpty
         *
         * porque queremos:
         *
         * focus
         *   ↓
         * searchApi('')
         *
         * para traer los primeros elementos.
         */
        _hasSearch = true;

        final results = await widget.searchApi(
          currentSearch,
        );

        return results;
      },

      /**
       * ============================================================
       * SIN RESULTADOS
       * ============================================================
       */
      emptyBuilder: (context) {
        /**
         * No mostrar mensaje si no hubo
         * una búsqueda real.
         */
        if (!_hasSearch) {
          return const SizedBox.shrink();
        }

        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No se encontraron resultados.',
          ),
        );
      },

      /**
       * ============================================================
       * ITEM
       * ============================================================
       */
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(
            widget.getLabel(item),
          ),
        );
      },

      /**
       * ============================================================
       * SELECCIÓN
       * ============================================================
       */
      onSelected: (item) {
        /**
         * Bloqueamos cualquier búsqueda provocada
         * por el cambio automático del texto.
         */
        _isSelecting = true;

        /**
         * Guardamos el label seleccionado.
         */
        _selectedLabel =
            widget.getLabel(item).trim();

        /**
         * Ya no queremos mostrar
         * "No se encontraron resultados".
         */
        _hasSearch = false;

        /**
         * Notificamos al formulario.
         */
        widget.onSelected(item);

        /**
         * Liberamos el bloqueo después
         * de terminar este frame.
         */
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          _isSelecting = false;
        });
      },

      /**
       * ============================================================
       * CAMPO
       * ============================================================
       */
      builder: (
          context,
          textController,
          focusNode,
          ) {
        /**
         * Cargar valor inicial.
         */
        if (widget.value != null &&
            textController.text.isEmpty) {

          final initialLabel = widget
              .getLabel(
            widget.value as T,
          )
              .trim();

          _selectedLabel = initialLabel;

          textController.value = TextEditingValue(
            text: initialLabel,
            selection: TextSelection.collapsed(
              offset: initialLabel.length,
            ),
          );
        }

        return TextField(
          controller: textController,
          focusNode: focusNode,

          /**
           * ========================================================
           * CAMBIO DE TEXTO
           * ========================================================
           */
          onChanged: (text) {
            final currentText = text.trim();

            /**
             * Si el usuario modifica el texto seleccionado,
             * significa que quiere hacer una nueva búsqueda.
             */
            if (_selectedLabel != null &&
                currentText != _selectedLabel) {
              _selectedLabel = null;
            }

            /**
             * TypeAheadField detectará el cambio
             * y ejecutará suggestionsCallback.
             *
             * NO llamamos searchApi aquí porque
             * duplicaríamos la consulta.
             */
          },

          decoration: InputDecoration(
            labelText: widget.label,

            errorText:
            widget.isTouched &&
                widget.error != null
                ? widget.error
                : null,
          ),
        );
      },
    );
  }
}
enum ModalType { dialog, page }
enum ControllerType {
  app,
  session,
  drawer,
  posMain,
}

class ControllerData<T> {
  final T data;
  final ControllerType type;
  final String name;
  final String description;

  const ControllerData({
    required this.data,
    required this.type,
    required this.name,
    required this.description,
  });
}
class ControllerProvider {
  ControllerProvider._();

  static ControllerData<T> get<T>(
      BuildContext context,
      ControllerType type, {
        bool listen = false,
      }) {
    final controller = listen
        ? context.watch<T>()
        : context.read<T>();

    switch (type) {
      case ControllerType.app:
        return ControllerData<T>(
          data: controller,
          type: type,
          name: 'AppController',
          description: 'Controla la aplicación.',
        );

      case ControllerType.session:
        return ControllerData<T>(
          data: controller,
          type: type,
          name: 'SessionService',
          description: 'Administra la sesión del usuario.',
        );

      case ControllerType.drawer:
        return ControllerData<T>(
          data: controller,
          type: type,
          name: 'AppDrawerController',
          description: 'Administra el menú lateral.',
        );

      case ControllerType.posMain:
        return ControllerData<T>(
          data: controller,
          type: type,
          name: 'PosMainController',
          description:
          'Controller principal del Punto de Venta.',
        );
    }
  }
}

class SafeExecutor {
  static Future<T> run<T>(
      Future<T> Function() action,
      T defaultValue, {
        Duration timeout = const Duration(seconds: 35),
      }) async {
    try {
      return await action().timeout(timeout);

    } on SocketException {
      return defaultValue;

    } on TimeoutException {
      return defaultValue;

    } on http.ClientException {
      return defaultValue;

    } catch (_) {
      return defaultValue;
    }
  }
}