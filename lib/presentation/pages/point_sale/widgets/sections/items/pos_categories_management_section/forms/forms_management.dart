
import 'package:flutter/cupertino.dart';

import '../../../../../../../../services/alert_manager.dart';
import '../../../../../../../../shared/services/media_picker_service.dart';
import '../../../../../../../../shared/theme/configuration/app_spacing.dart';
import '../../../../../../../../shared/utils/validators/validators.dart';
import '../../../../molecules/inputs/ps_field_row.dart';
import '../../../../molecules/inputs/ps_input.dart';
import '../../../../molecules/ps_image_picker.dart';
import '../../../../organisms/dialogs/product_modal.dart';
import '../../../product/ps_section_card.dart';
import '../../pos_items_management_section.dart';
import '../controller/controllers_management.dart';

Future<void> showManagementForm({
  required BuildContext context,
  required CategoryModalController controller,
  required String title,
  required String btnCancelTitle,
  required String btnSaveTitle,
  CrudType typeManagement = CrudType.update,
  required bool barrierDismissible,
  int managementId = -1,

}) async {

  controller.setManagerInitProcess(typeManagement, managementId);

  final content = AnimatedBuilder(
    animation: controller,
    builder: (_, __) {
      return PsModalLayout(
        isLoading: controller.isLoading,
        useDialog: false,
        title: title,
        btnCancelTitle: btnCancelTitle,
        btnSaveTitle: btnSaveTitle,
        onSave: controller.canSubmit
            ? () async {
          if (controller.validateForm().success) {
            controller.setLoading(true);
            final resultSave = await controller.saveCategory(
              typeManagement,
            );

            if (resultSave.success) {
              bool allowClose = true;
              AlertService.success(context, message: resultSave.message);

              var allowReload = true;
              controller.setAllowReloadData(allowReload);
              controller.emit(ProductModalEvents.save, {
                "allowReload": allowReload,
              });
              Navigator.pop(context, resultSave);

            } else {
              AlertService.error(context, message: resultSave.message);
            }
            controller.setLoading(false);
          }
        }
            : null,
        body: _buildManagerForm(context, controller, typeManagement, title),
      );
    },
  );

  await Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return content;
      },
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
    ),
  );
}

Widget _buildManagerForm(
    BuildContext context,
    CategoryModalController controller,
    CrudType type,
    String title,
    ) {
  return SingleChildScrollView(
    child: Column(
      children: [
        AppSpacing.spaceBetweenSections,

        PsSectionSplit(
          leftFlex: 7,
          rightFlex: 3,
          left: PsSectionCard(
            title: controller.titleCardInformation,
            child: Column(
              children: [
                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsInput(
                        label: controller.codeLabel,
                        requiredField: true,
                        value: controller.code,
                        onChanged: controller.setCode,
                        error: controller.codeError,
                        isTouched: controller.codeTouched,
                        isValid: controller.codeError == null,
                      ),
                    ),

                    PsFieldItem(
                      child: PsInput(
                        label: controller.descriptionLabel,
                        requiredField: true,
                        value: controller.description,
                        onChanged: controller.setDescription,
                        error: controller.descriptionError,
                        isTouched: controller.descriptionTouched,
                        isValid: controller.descriptionError == null,
                      ),
                    ),
                  ],
                ),

                AppSpacing.spaceBetweenInputs,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsInput(
                        label: controller.nameLabel,
                        requiredField: true,
                        value: controller.name,
                        onChanged: controller.setName,
                        error: controller.nameError,
                        isTouched: controller.nameTouched,
                        isValid: controller.nameError == null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.spaceBetweenInputs,

                PsFieldRow(
                  children: [
                    PsFieldItem(
                      child: PsInput(
                        label: controller.subtitleLabel,
                        requiredField: true,
                        value: controller.subtitle,
                        onChanged: controller.setSubtitle,
                        error: controller.subtitleError,
                        isTouched: controller.subtitleTouched,
                        isValid: controller.subtitleError == null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          right: PsSectionCard(
            title: controller.imageLabel,
            child: Center(
              child: PsImagePicker(
                image: controller.image,
                error: controller.imageError,
                onPick: () async {
                  final mediaService = MediaPickerService();
                  final file = await showImageSourceSelector(
                    context,
                    mediaService.pickFromCamera,
                    mediaService.pickFromGallery,
                  );

                  if (file != null) {
                    controller.setImage(file);
                  }
                },
                onRemove: controller.removeImage,
                requiredField: true,
                isTouched: controller.imageTouched,
                isValid: controller.image != null,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
