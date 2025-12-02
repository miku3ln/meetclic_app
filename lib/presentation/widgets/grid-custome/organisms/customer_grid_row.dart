import 'package:flutter/material.dart';
import '../../../../domain/models/customer_model.dart';
import '../../../components/input_text_field.dart';
import '../../../components/dropdown_selector.dart';
import '../../../../aplication/usecases/validate_cedula_usecase.dart';
import '../../../../infrastructure/services/customer_api_service.dart';
import '../../../../shared/utils/util_common.dart';

class CustomerGridRow extends StatefulWidget {
  final CustomerModel customer;
  final ValueChanged<CustomerModel> onUpdate;
  final VoidCallback onDelete;

  CustomerGridRow({
    required this.customer,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _CustomerGridRowState createState() => _CustomerGridRowState();
}

class _CustomerGridRowState extends State<CustomerGridRow> {
  late TextEditingController fullNameController;
  late TextEditingController documentController;
  late TextEditingController ageController;

  bool isNameTouched = false;
  bool isDocumentTouched = false;
  bool isAgeTouched = false;

  late FocusNode documentFocusNode;
  final ValidateCedulaUseCase validateCedulaUseCase = ValidateCedulaUseCase(
    CustomerApiService(),
  );

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.customer.fullName);
    documentController = TextEditingController(
      text: widget.customer.documentNumber,
    );
    ageController = TextEditingController(
      text: widget.customer.age != 0 ? widget.customer.age.toString() : '',
    );

    fullNameController = TextEditingController(text: widget.customer.fullName);
    documentController = TextEditingController(
      text: widget.customer.documentNumber,
    );
    ageController = TextEditingController(
      text: widget.customer.age != 0 ? widget.customer.age.toString() : '',
    );
    documentFocusNode = FocusNode();

    documentFocusNode.addListener(() {
      if (!documentFocusNode.hasFocus) {
        _onDocumentFieldBlur();
      }
    });
  }

  Future<void> _onDocumentFieldBlur() async {
    final cedula = documentController.text.trim();
    if (cedula.isNotEmpty) {
      try {
        if( UtilCommon.isValidCedulaEcuatoriana(cedula)){
          final data = await validateCedulaUseCase.execute(cedula);
          if (data.success) {
            setState(() {
              fullNameController.text = data.fullName;
            });
            widget.onUpdate(
              widget.customer.copyWith(
                fullName: data.fullName,
                documentNumber: cedula,
              ),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(data.message)));
            setState(() {
              fullNameController.text = "";
            });
            widget.onUpdate(
              widget.customer.copyWith(fullName: "", documentNumber: cedula),
            );
          }
        }

      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    documentController.dispose();
    ageController.dispose();
    super.dispose();
  }

  bool isNotEmpty(String value) => value.trim().isNotEmpty;

  bool isValidAge(String value) {
    int? age = int.tryParse(value);
    return age != null && age > 0 && age <= 120;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InputTextField(
            focusNode: documentFocusNode,
            hintText: 'Document',
            controller: documentController,
            onChanged: (value) {
              setState(() => isDocumentTouched = true);
              widget.onUpdate(widget.customer.copyWith(documentNumber: value));
            },
            isTouched: isDocumentTouched,
            isValid: isNotEmpty(documentController.text),
            errorMessage: 'Document is required',
          ),
        ),
        Expanded(
          child: InputTextField(
            hintText: 'Full Name',
            controller: fullNameController,
            onChanged: (value) {
              setState(() => isNameTouched = true);
              widget.onUpdate(widget.customer.copyWith(fullName: value));
            },
            isTouched: isNameTouched,
            isValid: isNotEmpty(fullNameController.text),
            errorMessage: 'Name is required',
          ),
        ),
      /*  Expanded(
          child: DropdownSelector(
            width: 2,
            options: ['A', 'NI'],
            selectedValue: widget.customer.type,
            onChanged: (value) =>
                widget.onUpdate(widget.customer.copyWith(type: value)),
          ),
        ),*/
        Expanded(
          child: InputTextField(
            hintText: 'Age',
            controller: ageController,
            onChanged: (value) {
              setState(() => isAgeTouched = true);
              widget.onUpdate(
                widget.customer.copyWith(age: int.tryParse(value) ?? 0),
              );
            },
            isTouched: isAgeTouched,
            isValid: isValidAge(ageController.text),
            errorMessage: 'Enter valid age',
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: widget.onDelete,
          tooltip: 'Delete Row',
        ),
      ],
    );
  }
}
