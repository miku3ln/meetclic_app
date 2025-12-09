import '../models/more_section_model.dart';

class MoreState {
  final List<MoreSectionModel> sections;

  MoreState({required this.sections});

  factory MoreState.initial() => MoreState(sections: []);
}
