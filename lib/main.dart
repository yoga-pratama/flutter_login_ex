import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _formKey = GlobalKey<FormState>();
final FirebaseAuth _auth = FirebaseAuth.instance;

void main() => runApp(MyApp());

final ThemeData KIOSTheme = new ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.orangeAccent[100],
);

/* defaultTargetPlatform == TargetPlatform.iOS
          ? KIOSTheme
          : kDefaultTheme */
class MyApp extends StatelessWidget {
  Widget _handleCurrentState() {
    return new StreamBuilder<FirebaseUser>(
        stream: _auth.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return new HomePage(user: snapshot.data);
          } else {
            return new LoginPage();
          }
        });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blue,
      ),
      home: _handleCurrentState(),
    );
  }
}

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logOut,
          )
        ],
      ),
      body: Builder(
        builder: (context) => Container(
              child: Center(
                child: Text('Welcome ${widget.user.email}'),
              ),
            ),
      ),
    );
  }

  void logOut() {
    _handlSignOut()
        .catchError((e) => Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('${e.toString()}'),
            )));
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailText = new TextEditingController();
  final TextEditingController _passText = new TextEditingController();
  bool isSubmit = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
          builder: (context) => Container(
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  image: new AssetImage("images/lake.jpg"),
                  fit: BoxFit.cover,
                )),
                child: Center(
                    child: Container(
                        width: 400,
                        height: 400,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _emailText,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    labelText: ('Enter Your Email'),
                                    suffixIcon:
                                        Icon(Icons.account_circle, size: 30)),
                                validator: validateEmail,
                              ),
                              TextFormField(
                                controller: _passText,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: ('Enter Your Password'),
                                  suffixIcon: Icon(
                                    Icons.lock,
                                    size: 30,
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter Password';
                                  }
                                },
                              ),
                              new Container(
                                width: 400,
                                child: !isSubmit
                                    ? RaisedButton(
                                        textColor: Colors.white,
                                        color: Colors.blueAccent,
                                        child: Text('Login'),
                                        onPressed: () =>
                                            _submitPressed(context))
                                    : Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          backgroundColor: Colors.blue,
                                        )),
                                      ),
                              )
                            ],
                          ),
                        ))),
              )),
    );
  }

  void _submitPressed(BuildContext context) {
    if (_formKey.currentState.validate()) {
      setState(() {
        isSubmit = !isSubmit;
      });

      _handelSignin(_emailText.text, _passText.text)
          .then(
              (FirebaseUser user) => Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Welcome , ${user.email}'),
                  )))
          .catchError((e) => Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('${e.toString()}'),
              )))
          .whenComplete(() => setState(() {
                isSubmit = false;
              }));
      /*  _handelSignin(_emailText.text, _passText.text)
          .whenComplete(() => setState(() {
                isSubmit = false;
              })); */
    }
  }
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return 'Enter Valid Email';
  else
    return null;
}

Future<FirebaseUser> _handelSignin(String email, String password) async {
  print('Auth....');
  FirebaseUser user =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

  //print("sign in " + user.displayName);
  return user;
}

Future<FirebaseUser> _handlSignOut() async {
  _auth.signOut();
  return null;
}
