import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:meetclic_app/aplication/services/user_login_service.dart';
import 'package:meetclic_app/aplication/services/user_service.dart';
import 'package:meetclic_app/domain/models/user_data_login.dart';
import 'package:meetclic_app/domain/models/user_registration_model.dart';
import 'package:meetclic_app/domain/services/session_service.dart';
import 'package:meetclic_app/domain/usecases/login_user_usecase.dart';
import 'package:meetclic_app/domain/usecases/register_user_usecase.dart';
import 'package:meetclic_app/infrastructure/models/summary_model.dart';
import 'package:meetclic_app/infrastructure/repositories/implementations/user_repository_impl.dart';
import 'package:meetclic_app/presentation/widgets/modals/register_user_modal.dart';
import 'package:meetclic_app/presentation/widgets/modals/show_login_user_modal.dart';
import 'package:meetclic_app/presentation/widgets/modals/show_management_login_modal.dart';
import 'package:meetclic_app/shared/models/api_response.dart';
import 'package:provider/provider.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

Future<ApiResponse<Map<String, dynamic>>> sendTokenToBackend(
  String idToken,
) async {
  try {
    final url = Uri.parse('https://tudominio.com/api/auth/google-mobile');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ApiResponse.fromJson(
        jsonResponse,
        (data) => data as Map<String, dynamic>,
      );
    } else {
      String backendMessage = response.body;
      try {
        final Map<String, dynamic> errorResponse = jsonDecode(response.body);
        backendMessage = errorResponse['message'] ?? backendMessage;
      } catch (_) {}

      return ApiResponse(
        success: false,
        message: 'Error ${response.statusCode}: $backendMessage',
        data: null,
      );
    }
  } catch (e) {
    return ApiResponse(success: false, message: 'Error de red: $e', data: null);
  }
}

Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle() async {
  try {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return ApiResponse(
        success: false,
        message: 'Cancelado por el usuario',
        data: null,
      );
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) {
      return ApiResponse(
        success: false,
        message: 'idToken es null',
        data: null,
      );
    }

    return await sendTokenToBackend(idToken);
  } catch (e) {
    return ApiResponse(success: false, message: 'Error: $e', data: null);
  }
}

class AccessManagerService {
  var theme;
  setDataByLoginRegister(
    BuildContext contextCurrent,
    UserDataLogin userDataMapManagement,
  ) async {
    final session = Provider.of<SessionService>(contextCurrent, listen: false);
    await session.saveSession(userDataMapManagement);
    theme = Theme.of(contextCurrent);
  }

  final BuildContext context;
  AccessManagerService(this.context);

  Future<ApiResponse> handleAccess(
    FutureOr<void> Function() onLoggedInAction,
  ) async {
    if (!SessionService().isLoggedIn) {
      final result = await _showManagementLoginModalWithResult();
      if (result.success) {
        await onLoggedInAction();
        return ApiResponse(
          success: true,
          message: 'Acceso concedido',
          data: null,
        );
      } else {
        return result;
      }
    } else {
      await onLoggedInAction();
      return ApiResponse(
        success: true,
        message: 'Acceso concedido',
        data: null,
      );
    }
  }

  Future<ApiResponse> _showManagementLoginModalWithResult() async {
    final completer = Completer<ApiResponse>();

    showManagementLoginModal(context, {
      'google': () async {
        final result = await loginWithGoogle();
        if (result.success) {
          Navigator.pop(context); // Cierra modal principal
        }
        completer.complete(result);
      },
      'facebook': () {
        completer.complete(
          ApiResponse(
            success: false,
            message: 'Login con Facebook no implementado',
            data: null,
          ),
        );
      },
      'login': () async {
        final result = await showLoginUserModal(context, (
          ctxModal,
          model,
        ) async {
          final repository = UserRepositoryImpl();
          final useCase = LoginUseCase(repository);
          final userService = UserLoginService(useCase);

          final response = await userService.loginUseCase(model);

          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login exitoso"),
                duration: Duration(seconds: 16), // ✅ Hasta 16 segundos
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
            var userDataMap = response.data['userData'] as Map<String, dynamic>;
            var summaryJson =
                response.data['userData']['gamificationLogData']["summary"];
            var summary = MovementSummaryModel.fromJson(summaryJson);
            final userDataMapManagement = UserDataLogin.fromJson(userDataMap);
            userDataMapManagement.summary = summary;
            await setDataByLoginRegister(context, userDataMapManagement);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                duration: Duration(seconds: 16), // ✅ Hasta 16 segundos
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          return response; // ✅ Devuelve bool al modal
        });

        if (result) {
          Navigator.pop(
            context,
          ); // ✅ Cierra el modal principal si login exitoso
          completer.complete(
            ApiResponse(
              success: true,
              message: 'Login realizado correctamente.',
              data: null,
            ),
          );
        } else {
          completer.complete(
            ApiResponse(
              success: false,
              message: 'No se pudo iniciar sesión.',
              data: null,
            ),
          );
        }
      },
      'signup': () {
        showRegisterUserModal(context, (ctxModal, user) async {
          final repository = UserRepositoryImpl();
          final useCase = RegisterUserUseCase(repository);
          final userService = UserService(useCase);
          final userSend = UserRegistrationLoginModel(
            email: user.email,
            password: user.password,
            name: user.nombres,
            last_name: user.apellidos,
            birthdate: user.fechaNacimiento,
          );
          final response = await userService.register(userSend);
          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                duration: Duration(seconds: 16), // ✅ Hasta 16 segundos
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error al registrar"),
                duration: Duration(seconds: 16), // ✅ Hasta 16 segundos
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          completer.complete(
            ApiResponse(
              success: response.success,
              message: response.message,
              data: null,
            ),
          );

          return response.success;
        });
      },
    });

    return completer.future;
  }
}
