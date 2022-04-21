import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

_saveValues(dynamic user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("user", jsonEncode(user));
}

removeLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final success = await prefs.remove('user');
  return success;
}

getUserValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic user = jsonDecode(prefs.getString("user") ?? 'null');
  return user;
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  dynamic user = null;
  String login = '';
  String password = '';
  static const String apiUrlPub = String.fromEnvironment("HOST_PUB");

  @override
  void initState() {
    super.initState();
    getUserValues().then((data) => user = data != null ? Map<String, dynamic>.from(data) : null).then((d) => print(user.runtimeType));
  }
  void click(){}

  @override
  Widget build(BuildContext context) {
    return user == null ? Scaffold(
      appBar: AppBar(
        title: Text('Вхід'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purpleAccent,
                    Colors.amber,
                    Colors.blue,
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50,),
              SizedBox(
                height:200,
                width: 300,
                child: LottieBuilder.asset("assets/lottie/login2.json"),
              ),
              const SizedBox(height: 10,),
              Container(
                width: 325,
                height: 370, //470,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30,),
                    const Text("Hello",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight:FontWeight.bold
                      ),),
                    const SizedBox(height: 10,),
                    const Text("Please Login to Your Account",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),),
                    const SizedBox(height: 30,),
                    Container(
                      width: 260,
                      height: 60,
                      child: TextField(
                        onChanged: (value) => setState(() => this.login = value),
                        decoration: InputDecoration(
                          // suffix: Icon(FontAwesomeIcons.envelope,color: Colors.red,),
                            labelText: "Login",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            )
                        ),
                      ),
                    ),
                    const SizedBox(height: 12,),
                    Container(
                      width: 260,
                      height: 60,
                      child: TextField(
                        onChanged: (value) => setState(() => this.password = value),
                        obscureText: true,
                        decoration: InputDecoration(
                          // suffix: Icon(FontAwesomeIcons.eyeSlash,color: Colors.red,),
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding:const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: click,
                            child:const Text("", //Forget Password
                              style: TextStyle(
                                  color: Colors.deepOrange
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        print('Login: ${login}');
                        print('Password: ${password}');
                        final url = '$apiUrlPub/api/loginApp?username=$login&password=$password';
                        print('url: ${url}');
                        try {
                          final response = await Dio().get(url);
                          print('123456');
                          user = Map<String, dynamic>.from(response.data);
                          await _saveValues(user);
                          print('${user['massage']['success']}');
                          print('123456');
                        } catch(err) {
                          print('Something error. :( ');
                        }
                        // if (response.statusCode == 200) {
                        //   print('Body: ${response.body}');
                        //   // return response.body;
                        // } else {
                        //   throw Exception('Failed to post cases');
                        // }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 250,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF8A2387),
                                  Color(0xFFE94057),
                                  Color(0xFFF27121),
                                ])
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Login',
                            style: TextStyle(color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 17 ,),
                    // const Text("Or Login using Social Media Account",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold
                    //   ),),
                    // const SizedBox(height: 15,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.facebook,color: Colors.blue)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.google,color: Colors.redAccent,)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.twitter,color: Colors.orangeAccent,)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.linkedinIn,color: Colors.green,)
                    //     )
                    //   ],
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ) : Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      // appBar: AppBar(title: Text('Дерева (${titles.length})')),
      body: Center(
        child: Column(
          children: [
            Text('user == null: ${user == null}'),
            Text('user: ${user.runtimeType}'),
            ElevatedButton(
                onPressed: () async {
                  await removeLocalStorage();
                },
                child: Text('Log out'))
          ],
        ),
      ),
    );;
  }

}


// Dialog
// () => showDialog<String>(
// context: context,
// builder: (BuildContext context) => AlertDialog(
// title: const Text('AlertDialog Title'),
// content: const Text('AlertDialog description'),
// actions: <Widget>[
// TextButton(
// onPressed: () => Navigator.pop(context, 'Cancel'),
// child: const Text('Cancel'),
// ),
// TextButton(
// onPressed: () => Navigator.pop(context, 'OK'),
// child: const Text('OK'),
// ),
// ],
// ),
// ),



/*
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Profile

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  String password = '';
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    numberController.dispose();
    super.dispose();
  }

  void click(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вхід'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purpleAccent,
                    Colors.amber,
                    Colors.blue,
                  ]
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50,),
              SizedBox(
                height:200,
                width: 300,
                child: LottieBuilder.asset("assets/lottie/login2.json"),
              ),
              const SizedBox(height: 10,),
              Container(
                width: 325,
                height: 370, //470,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30,),
                    const Text("Hello",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight:FontWeight.bold
                      ),),
                    const SizedBox(height: 10,),
                    const Text("Please Login to Your Account",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),),
                    const SizedBox(height: 30,),
                    Container(
                      width: 260,
                      height: 60,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            // suffix: Icon(FontAwesomeIcons.envelope,color: Colors.red,),
                            labelText: "Login",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            )
                        ),
                      ),
                    ),
                    const SizedBox(height: 12,),
                    Container(
                      width: 260,
                      height: 60,
                      child: const TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            // suffix: Icon(FontAwesomeIcons.eyeSlash,color: Colors.red,),
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding:const EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: click,
                            child:const Text("", //Forget Password
                              style: TextStyle(
                                  color: Colors.deepOrange
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        alignment: Alignment.center,
                        width: 250,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF8A2387),
                                  Color(0xFFE94057),
                                  Color(0xFFF27121),
                                ])
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Login',
                            style: TextStyle(color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 17 ,),
                    // const Text("Or Login using Social Media Account",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold
                    //   ),),
                    // const SizedBox(height: 15,),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.facebook,color: Colors.blue)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.google,color: Colors.redAccent,)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.twitter,color: Colors.orangeAccent,)
                    //     ),
                    //     IconButton(
                    //         onPressed: click,
                    //         icon: const Icon(FontAwesomeIcons.linkedinIn,color: Colors.green,)
                    //     )
                    //   ],
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}


 // Dialog
// () => showDialog<String>(
// context: context,
// builder: (BuildContext context) => AlertDialog(
// title: const Text('AlertDialog Title'),
// content: const Text('AlertDialog description'),
// actions: <Widget>[
// TextButton(
// onPressed: () => Navigator.pop(context, 'Cancel'),
// child: const Text('Cancel'),
// ),
// TextButton(
// onPressed: () => Navigator.pop(context, 'OK'),
// child: const Text('OK'),
// ),
// ],
// ),
// ),

 */
