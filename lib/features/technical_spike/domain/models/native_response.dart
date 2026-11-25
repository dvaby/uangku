class NativeResponse {
  const NativeResponse({
    required this.message,
    required this.platform,
    required this.sdkInt,
  });

  final String message;
  final String platform;
  final int sdkInt;

  factory NativeResponse.fromMap(Map<Object?, Object?> map) {
    final message = map['message'];
    final platform = map['platform'];
    final sdkInt = map['sdkInt'];

    if (message is! String || platform is! String || sdkInt is! int) {
      throw const FormatException('Invalid native bridge response.');
    }

    return NativeResponse(
      message: message,
      platform: platform,
      sdkInt: sdkInt,
    );
  }
}
