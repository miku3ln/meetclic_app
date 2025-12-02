import 'package:flutter/material.dart';

class AppColors {
  static const Color azulClic = Color(0xFF4C4CFF);
  static const Color amarilloVital = Color(0xFFFFCC00);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisOscuro = Color(0xFF2C2C2C);
  static const Color moradoSuave = Color(0xFF5C5CFF);
}

class AppStyles {
  static const TextStyle textFieldStyle = TextStyle(
    fontSize: 16,
    color: AppColors.grisOscuro,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    color: AppColors.grisOscuro,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle dropdownItemStyle = TextStyle(
    fontSize: 16,
    color: AppColors.grisOscuro,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.blanco,
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppStyles.labelStyle,
      filled: true,
      fillColor: AppColors.blanco,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.azulClic),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.azulClic, width: 2),
      ),
    );
  }
}

void showRegisterUser(BuildContext context, VoidCallback saveRegister) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const RegisterForm();
    },
  );
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final _identificationController = TextEditingController();
  String? _selectedIdentificationType;
  final _lastNameController = TextEditingController();
  final _birthdateController = TextEditingController();
  String? _selectedGender;
  final _emailController = TextEditingController();

  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    _identificationController.addListener(_checkFormValidity);
    _lastNameController.addListener(_checkFormValidity);
    _birthdateController.addListener(_checkFormValidity);
    _emailController.addListener(_checkFormValidity);
  }

  void _checkFormValidity() {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _formValid = valid;
    });
  }

  @override
  void dispose() {
    _identificationController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildDropdown<T>({
    required String label,
    required String? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value as T?,
      decoration: AppStyles.inputDecoration(label),
      dropdownColor: AppColors.blanco,
      iconEnabledColor: AppColors.azulClic,
      style: AppStyles.dropdownItemStyle,
      items: items,
      onChanged: (newValue) {
        onChanged(newValue);
        _checkFormValidity();
      },
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          onChanged: _checkFormValidity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              TextFormField(
                controller: _identificationController,
                style: AppStyles.textFieldStyle,
                decoration: AppStyles.inputDecoration('Documento de Identificación'),
                validator: (value) {
                  if ((_selectedIdentificationType == '1') && (value == null || value.isEmpty)) {
                    return 'Documento de identificación es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildDropdown<String>(
                label: 'Tipo de Identificación',
                value: _selectedIdentificationType,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Cédula', style: AppStyles.dropdownItemStyle)),
                  DropdownMenuItem(value: '2', child: Text('Pasaporte', style: AppStyles.dropdownItemStyle)),
                  DropdownMenuItem(value: '3', child: Text('RUC', style: AppStyles.dropdownItemStyle)),
                ],
                onChanged: (value) => setState(() => _selectedIdentificationType = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipo de identificación es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                style: AppStyles.textFieldStyle,
                decoration: AppStyles.inputDecoration('Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El apellido es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _birthdateController,
                style: AppStyles.textFieldStyle,
                readOnly: true,
                decoration: AppStyles.inputDecoration('Fecha de nacimiento'),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _birthdateController.text = pickedDate.toIso8601String().split('T').first;
                    _checkFormValidity();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha de nacimiento es obligatoria';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildDropdown<String>(
                label: 'Género',
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Masculino', style: AppStyles.dropdownItemStyle)),
                  DropdownMenuItem(value: 'F', child: Text('Femenino', style: AppStyles.dropdownItemStyle)),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El género es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                style: AppStyles.textFieldStyle,
                keyboardType: TextInputType.emailAddress,
                decoration: AppStyles.inputDecoration('Correo electrónico'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es obligatorio';
                  }
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Debe ser un correo válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _formValid
                    ? () {
                  final data = {
                    'identification_document': _identificationController.text,
                    'people_type_identification_id': _selectedIdentificationType,
                    'last_name': _lastNameController.text,
                    'birthdate': _birthdateController.text,
                    'gender': _selectedGender,
                    'email': _emailController.text,
                  };
                  print('Datos enviados: $data');
                  Navigator.pop(context);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulClic,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: AppStyles.buttonTextStyle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Guardar',style:TextStyle(
                  color: AppColors.grisOscuro,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
