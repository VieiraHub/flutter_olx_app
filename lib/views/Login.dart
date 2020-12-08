import 'package:flutter/material.dart';
import 'package:olx/models/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/views/widgets/CustomButton.dart';
import 'package:olx/views/widgets/CustomInput.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController(text: "vieira@gmail.com");
  TextEditingController _controllerPassword = TextEditingController(text: "1234567");
  bool _signup = false;
  String _errorMessage = "";
  String _buttonText = "Log in";

  _signupUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.createUserWithEmailAndPassword(email: user.email, password: user.password)
        .then((firebaseUser) {
          // Redireciona para tela principal
          Navigator.pushReplacementNamed(context, "/");
    });
  }

  _loginUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(email: user.email, password: user.password)
        .then((firebaseUser) {
          // Redireciona para tela principal
          Navigator.pushReplacementNamed(context, "/");
    });
  }

  _validateFields() {
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (password.isNotEmpty && password.length > 6) {

        //Configura User
        User user = User();
        user.email = email;
        user.password = password;

        //Cadastrar ou Loggar
        if (_signup) {  _signupUser(user);  }
        else {  _loginUser(user);  }

      } else {
        setState(() {  _errorMessage = "Fill in the password, enter more than 6 characters";  });
      }
    } else {
      setState(() {  _errorMessage = "Fill in a valid email";  });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset("images/logo.png", width: 200, height: 150),
                ),

                CustomInput(
                    controller: _controllerEmail,
                    hint: "E-mail",
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress
                ),

                CustomInput(
                  controller: _controllerPassword,
                  hint: "Password",
                  obscure: true
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Log in"),
                    Switch(
                        value: _signup,
                        onChanged: (bool value) {
                          setState(() {
                            _signup = value;
                            _buttonText = "Log in";
                            if ( _signup ) {  _buttonText = "Sign up";  }
                          });
                        }
                    ),
                    Text("Sign up"),
                  ],
                ),

                CustomButton(
                  text: _buttonText,
                  onPressed: () {  _validateFields();  }
                ),

                FlatButton(
                    child: Text("Go to ads"),
                    onPressed: (){  Navigator.pushReplacementNamed(context, "/");  }
                ),

                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(_errorMessage, style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
