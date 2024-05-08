enum LogType {success, finish, error, normal}

class Log {
  final String text;
  final LogType type;

  Log({
    required this.text,
    required this.type,
  });
}