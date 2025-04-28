import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Column(
        children: [
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your username',
            ),
          ),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your password',
            ),
          ),
          ElevatedButton(onPressed: (){
            Navigator.of(context).pushNamed('/home');
          }, child: Text('SIGN IN'))
        ],
      ),
    );
  }
}
