String formatearHoraColombiana(DateTime? fecha) {
  if (fecha == null) return 'Sin hora';

  DateTime fechaUtc = fecha.isUtc
      ? fecha
      : DateTime.utc(
          fecha.year,
          fecha.month,
          fecha.day,
          fecha.hour,
          fecha.minute,
          fecha.second,
        );

  final horaColombia = fechaUtc.subtract(const Duration(hours: 5));

  final dia = horaColombia.day.toString().padLeft(2, '0');
  final mes = horaColombia.month.toString().padLeft(2, '0');
  final anio = horaColombia.year;

  int hora24 = horaColombia.hour;
  String periodo = hora24 >= 12 ? 'PM' : 'AM';
  int hora12 = hora24 > 12 ? hora24 - 12 : (hora24 == 0 ? 12 : hora24);


  final horas = hora12.toString().padLeft(2, '0');
  final minutos = horaColombia.minute.toString().padLeft(2, '0');
  final segundos = horaColombia.second.toString().padLeft(2, '0');

  return '$dia/$mes/$anio $horas:$minutos:$segundos $periodo';
}
