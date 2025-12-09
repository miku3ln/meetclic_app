import 'package:flutter/material.dart';

import '../models/more_item_id.dart';
import '../models/more_item_model.dart';
import '../models/more_section_model.dart';

class MoreMapperService {
  const MoreMapperService();

  List<MoreSectionModel> buildSections(BuildContext context) {
    return [
      // ==========================
      // SECCIÓN: Herramientas / Negocio
      // ==========================
      MoreSectionModel(
        id: MoreItemSectionId.tools.value,
        title: "Herramientas para negocios",
        description:
            "Accesos rápidos para que las empresas gestionen su presencia en MeetClic.",
        items: [
          MoreItemModel(
            id: MoreItemProcessId.addBusiness.value,
            title: "Añadir un negocio",
            description:
                "Registra un nuevo negocio en MeetClic para que pueda ser descubierto.",
            icon: Icons.storefront_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.exploreBusiness.value,
            title: "Explora MeetClic para negocios",
            description:
                "Conoce las herramientas disponibles para empresas dentro de MeetClic.",
            icon: Icons.business_center_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.dictionary.value,
            title: "Diccionario Kichwa",
            description:
                "Accede al diccionario digital Kichwa–Español–Inglés integrado en MeetClic.",
            icon: Icons.menu_book_outlined,
          ),
        ],
      ),

      // ==========================
      // SECCIÓN: Comunidad
      // ==========================
      MoreSectionModel(
        id: MoreItemSectionId.community.value,
        title: "Comunidad",
        description:
            "Conecta con otras personas, participa en actividades y eventos.",
        items: [
          MoreItemModel(
            id: MoreItemProcessId.eliteSquad.value,
            title: "Escuadra Elite de MeetClic",
            description:
                "Programa especial para usuarios altamente activos y colaboradores.",
            icon: Icons.military_tech_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.friendsCheckins.value,
            title: "Actividad de mis amigos",
            description:
                "Revisa qué negocios visitan y con qué interactúan tus amigos.",
            icon: Icons.group_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.chat.value,
            title: "Conversaciones",
            description:
                "Chatea con negocios aliados o con otros usuarios (futuro módulo).",
            icon: Icons.chat_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.events.value,
            title: "Eventos",
            description:
                "Encuentra eventos, ferias, activaciones y experiencias especiales.",
            icon: Icons.event_outlined,
          ),
        ],
      ),

      // ==========================
      // SECCIÓN: Configuración y soporte
      // ==========================
      MoreSectionModel(
        id: MoreItemSectionId.settingsAndSupport.value,
        title: "Configuración y soporte",
        description:
            "Ajusta tu experiencia en MeetClic y obtén ayuda cuando la necesites.",
        items: [
          MoreItemModel(
            id: MoreItemProcessId.settings.value,
            title: "Ajustes",
            description:
                "Configura idioma, notificaciones y preferencias de tu cuenta.",
            icon: Icons.settings_outlined,
          ),
          MoreItemModel(
            id: MoreItemProcessId.helpCenter.value,
            title: "Centro de ayuda",
            description:
                "Encuentra respuestas a preguntas frecuentes y guías de uso.",
            icon: Icons.help_outline,
          ),
        ],
      ),
    ];
  }
}
