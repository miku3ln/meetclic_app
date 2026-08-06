import '../models/printer_info.dart';

abstract class PrinterRepository{

  Future<void> save(
      PrinterInfo printer);

  Future<void> delete(
      String id);

  Future<List<PrinterInfo>> getAll();

  Future<PrinterInfo?> getDefault();

  Future<void> setDefault(
      String id);

}