class PassWordMismatchException implements Exception {
  const PassWordMismatchException() : super();
}

class MQTTException implements Exception {
  final String? message;
  const MQTTException(this.message) : super();

  @override
  String toString() {
    String result = "MQTTException";
    if (message != null) result = "$result: $message";
    return result;
  }
}

class HTTPException implements Exception {
  final String? message;
  const HTTPException(this.message) : super();

  @override
  String toString() {
    String result = "HTTPException";
    if (message != null) result = "$result: $message";
    return result;
  }
}

class GenericException implements Exception {
  const GenericException() : super();
}
