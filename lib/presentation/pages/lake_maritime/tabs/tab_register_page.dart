import 'package:flutter/material.dart';

import '../../../../domain/models/customer_model.dart';
import '../../../../domain/models/maritime_departure_model.dart';
import '../../../../infrastructure/services/maritime_departure_service.dart';
import '../../../widgets/grid-custome/gridview_header.dart';
import '../../../widgets/grid-custome/organisms/customer_grid_row.dart';
import '../../lake_maritime/lake_maritime_view_header.dart';

class TabRegisterPage extends StatefulWidget {
  const TabRegisterPage({super.key});

  @override
  State<TabRegisterPage> createState() => _TabRegisterPageState();
}

class _TabRegisterPageState extends State<TabRegisterPage> {
  List<CustomerModel> customers = [CustomerModel.empty()];
  final MaritimeDepartureService maritimeDepartureService =
      MaritimeDepartureService();
  bool isLoading = false;
  void addCustomerRow() {
    setState(() {
      customers.add(CustomerModel.empty());
    });
  }

  void deleteCustomerRow(int index) {
    setState(() {
      customers.removeAt(index);
    });
  }

  void updateCustomer(int index, CustomerModel updatedCustomer) {
    setState(() {
      customers[index] = updatedCustomer;
    });
  }

  bool allFieldsValid() {
    if (customers.isEmpty) return false;
    for (var customer in customers) {
      if (customer.fullName.isEmpty || customer.documentNumber.isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> saveRegisters() async {
    setState(() => isLoading = true);
    final now = DateTime.now();
    // ISO 8601 sin milisegundos, ejemplo: 2025-12-01T17:23:45
    final String arrivalTime = now.toIso8601String().split('.').first;
    try {
      var model = MaritimeDepartureModel(
        businessId: 1,
        userId: 1,
        userManagementId: 5,
        arrivalTime: arrivalTime,
        responsibleName: "Alex Alba",
      );

      final payload = maritimeDepartureService
          .buildMaritimeDeparturePayloadObject(customers, model);

      final sendUseCase = SendMaritimeDepartureUseCase(
        MaritimeDepartureService(),
      );
      final data = await sendUseCase.execute(payload);

      if (data.success) {
        setState(() {
          customers.clear();
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data.message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = allFieldsValid();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Opacity(
            opacity: isLoading ? 0.4 : 1,
            child: AbsorbPointer(
              absorbing: isLoading,
              child: Column(
                children: [
                  LakeMaritimeViewHeader(
                    nombreEmbarcacion: "Embarcación Taita Imbabura",
                    fecha: "03/05/2025",
                    nombreResponsable: "Cesar Iban Alba",
                    identificacion: "1002954889",
                    imageUrl:
                        "https://meetclic.com/public/uploads/business/information/logomuellecatalina.png",
                  ),
                  GridViewHeader(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: customers.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return CustomerGridRow(
                          customer: customers[index],
                          onUpdate: (updatedCustomer) =>
                              updateCustomer(index, updatedCustomer),
                          onDelete: () => deleteCustomerRow(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: isLoading ? null : addCustomerRow,
                        heroTag: 'addRow',
                        tooltip: 'Agregar Persona',
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.extended(
                        onPressed: isLoading || !isValid ? null : saveRegisters,
                        label: isLoading
                            ? const Text('Guardando...')
                            : const Text('Enviar Registro Embarque'),
                        icon: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        heroTag: 'saveButton',
                        backgroundColor: isLoading || !isValid
                            ? Colors.grey
                            : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
