import 'package:flutter/services.dart';

class MethodChannelExample {
  // Create a method channel with the channel name "methodChannelDemo"
  static MethodChannel methodChannel =
      const MethodChannel('methodChannelExample');

  // Define a method to increment the counter on the native side
  static Future<String> getMsg() async {
    // Invoke the 'increment' method on the native side with the 'count' argument
    final String? result = await methodChannel.invokeMethod<String>('getMsg');
    if (result == null) {
      throw Exception("no message received from platform channel");
    }
    // Return the result received from the native side
    return result;
  }
}
