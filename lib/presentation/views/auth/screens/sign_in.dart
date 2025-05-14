import 'package:CAPO/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if(state is SignInFailure){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
          else if(state is SignInSuccess){
            Navigator.pushNamed(context, '/project');
          }
        },
        builder: (context, state) {
          if(state is SignInInProgress){
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your username',
                  ),
                ),
                SizedBox(height: 12.0,),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                ),
                SizedBox(height: 12.0,),
                ElevatedButton(onPressed: () {
                  String username = usernameController.text;
                  String password = passwordController.text;
                  BlocProvider.of<AuthBloc>(context).add(
                      AuthRequest(username: username, password: password));
                }, child: Text('SIGN IN'))
              ],
            ),
          );
        },
      ),
    );
  }
}
