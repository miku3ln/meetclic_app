import '../../domain/models/customer_model.dart';

class CustomerService {
  Future<void> submitCustomerData(List<CustomerModel> customers) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    print('Submitted ${customers.length} customers');
  }
}
