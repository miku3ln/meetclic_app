import 'package:flutter/foundation.dart';

@immutable
class PosShiftState {
  final bool isOpen;

  const PosShiftState({required this.isOpen});

  PosShiftState copyWith({bool? isOpen}) => PosShiftState(
    isOpen: isOpen ?? this.isOpen,
  );
}