// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  Future<void> savePinCode(String pinCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pinCode);
  }

  Future<String?> getPinCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_pin');
  }

  Future<bool> authenticateUser() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason:
            'Ilovaga kirish uchun biometrik maʼlumotlaringizni kiriting',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      print("Biometrik autentifikatsiya xatosi: $e");
    }

    return authenticated;
  }

  String pinCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("PIN Code"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: PinCodeTextField(
              appContext: context,
              length: 4,
              onChanged: (value) {
                pinCode = value;
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pinCode.length == 4) {
                await savePinCode(pinCode);
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text("PIN kod saqlandi!"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text("Saqlash"),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () async {
              bool authenticated = await authenticateUser();

              if (authenticated) {
                // Biometrik autentifikatsiya muvaffaqiyatli bo'ldi
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text(
                        "Biometrik autentifikatsiya muvaffaqiyatli bo'ldi!"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              } else {
                // PIN kodni tekshirish
                String? savedPin = await getPinCode();
                if (savedPin == pinCode) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text("PIN kod to'g'ri!"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text("PIN kod noto'g'ri!"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: const Text("Kirish"),
          ),
        ],
      ),
    );
  }
}
