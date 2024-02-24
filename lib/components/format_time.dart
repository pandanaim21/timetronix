String formatTime(int hour, int minute) {
  final String period = hour < 12 ? 'AM' : 'PM';
  final int hourOfDay = hour % 12 == 0 ? 12 : hour % 12;
  return '$hourOfDay:${minute.toString().padLeft(2, '0')} $period';
}
