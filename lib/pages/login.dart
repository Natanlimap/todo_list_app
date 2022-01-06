import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  final email = TextEditingController();
  final password = TextEditingController();
  bool isLogin = true;

  String title = "";
  String actionText = "";
  String buttonText = "";
  @override
  void initState() {
    setState(() {
      title = "Welcome";
      actionText = "Register now";
      buttonText = "Login";
    });
    super.initState();
  }

  void submit() {
    isLogin ? login() : register();
  }

  void login() async {
    try {
      await context
          .read<AuthService>()
          .login(email: email.text, password: password.text);
    } on AuthException catch (e) {
      _messangerKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  register() async {
    try {
      await context
          .read<AuthService>()
          .register(email: email.text, password: password.text);
    } on AuthException catch (e) {
      _messangerKey.currentState!
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void actionButton() {
    if (isLogin) {
      setState(() {
        title = "Register now";
        actionText = "Already registered? Enter now";
        buttonText = "Create account";
      });
      isLogin = false;
    } else {
      setState(() {
        title = "Welcome";
        actionText = "Don't have an account? Register now";
        buttonText = "Login";
      });
      isLogin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: _messangerKey,
        home: Scaffold(
            body: SingleChildScrollView(
                child: Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(),
                          labelText: "Email"),
                      controller: email,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(color: Colors.red),
                          border: OutlineInputBorder(),
                          labelText: "Password"),
                      controller: password,
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(vertical: 14)),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red)),
                        onPressed: submit,
                        child: Text(
                          buttonText,
                          style: const TextStyle(color: Colors.white),
                        )),
                  ),
                  TextButton(
                      onPressed: actionButton,
                      child: Text(
                        actionText,
                        style: const TextStyle(color: Colors.black),
                      )),
                ],
              )),
        ))));
  }
}
