const dtcPattern = r'^[PBCU][0-3][0-9A-F]{3}$';

List<String> parseCodes(String input) {
  final codes = input
      .toUpperCase()
      .split(RegExp(r'[,;\s]+'))
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();
  if (codes.length > 20 || codes.any((s) => !RegExp(dtcPattern).hasMatch(s))) {
    throw const FormatException('Enter up to 20 DTCs such as P0300, P0171.');
  }
  return codes;
}

class DiagnosticInput {
  const DiagnosticInput(
      {this.codes = const [],
      this.symptoms = const [],
      this.notes = '',
      this.safetyFlags = const [],
      this.safetyCheckCompleted = false,
      this.source = 'manual',
      this.make = '',
      this.model = '',
      this.year});
  final List<String> codes, symptoms, safetyFlags;
  final String notes, source, make, model;
  final bool safetyCheckCompleted;
  final int? year;
  Map<String, dynamic> toJson() => {
        'codes': codes,
        'symptoms': symptoms,
        'notes': notes,
        'safety_flags': safetyFlags,
        'safety_check_completed': safetyCheckCompleted,
        'source': source,
        'vehicle': {'make': make, 'model': model, 'year': year},
      };
}

class PossibleCause {
  PossibleCause.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        certainty = json['certainty'] as String,
        evidence = List<String>.from(json['evidence'] as List);
  final String title, certainty;
  final List<String> evidence;
}

class DtcLookup {
  DtcLookup.fromJson(Map<String, dynamic> json)
      : code = json['code'] as String,
        found = json['found'] as bool,
        title = (json['entry'] as Map?)?['title'] as String?,
        explanation = (json['entry'] as Map?)?['explanation'] as String?,
        message = json['message'] as String;
  final String code, message;
  final bool found;
  final String? title, explanation;
}

class DiagnosticResult {
  DiagnosticResult.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        createdAt = DateTime.parse(json['created_at'] as String),
        summary = json['summary'] as String,
        urgency = json['urgency'] as String,
        simulated = json['simulated'] as bool,
        safetyMessage = json['safety_message'] as String,
        reasons = List<String>.from(json['urgency_reasons'] as List),
        nextSteps = List<String>.from(json['next_steps'] as List),
        limitations = List<String>.from(json['limitations'] as List),
        dtcs =
            (json['dtcs'] as List).map((e) => DtcLookup.fromJson(e)).toList(),
        causes = (json['possible_causes'] as List)
            .map((e) => PossibleCause.fromJson(e))
            .toList();
  final String id, summary, urgency, safetyMessage;
  final DateTime createdAt;
  final bool simulated;
  final List<String> reasons, nextSteps, limitations;
  final List<DtcLookup> dtcs;
  final List<PossibleCause> causes;
}
