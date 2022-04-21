import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:green_kharkiv/main-config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

_saveValues(dynamic user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("user", jsonEncode(user));
}

removeLocalStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("user");
  // final success = await prefs.remove('user');
  // return success;
}

getUserValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic user = jsonDecode(prefs.getString("user") ?? 'null');
  return await user;
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  dynamic? user;
  dynamic verify = null;
  String login = '';
  String password = '';
  static const String apiUrlPub = EnvironmentConfig.HOST_PUB;

  @override
  bool checkUser() {
    print('checkUser $user');
    return user == null;
  }

  @override
  bool checkVerify() {
    print('checkVerify $verify');
    return verify != null;
  }

  @override
  void initState() {
    super.initState();
    print('initState $user');
    getUserValues().then((data) {
      user = data != null ? Map<String, dynamic>.from(data) : null;
      setState(() {});
    });
  }
  void click(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(checkUser() ? 'Вхід в систему' : 'Профіль'),
        ),
        body: checkUser()
            ? SingleChildScrollView(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                      // gradient: LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //     colors: [
                      //       Colors.purpleAccent,
                      //       Colors.amber,
                      //       Colors.blue,
                      //     ]
                      // )
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
                        height: 410, //370,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30,),
                            const Text("Вітаю",
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight:FontWeight.bold
                              ),),
                            const SizedBox(height: 30,),
                            Container(
                              width: 260,
                              height: 60,
                              child: TextField(
                                onChanged: (value) => setState(() {
                                  this.login = value;
                                  verify = null;
                                }),
                                decoration: InputDecoration(
                                    // suffix: Icon(FontAwesomeIcons.envelope,color: Colors.red,),
                                    labelText: "Логін",
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
                                onChanged: (value) => setState(() {
                                  this.password = value;
                                  verify = null;
                                }),
                                obscureText: true,
                                decoration: InputDecoration(
                                    // suffix: Icon(FontAwesomeIcons.eyeSlash,color: Colors.red,),
                                    labelText: "Пароль",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    )
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding:const EdgeInsets.fromLTRB(20, 0, 30, 0),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       TextButton(
                            //         onPressed: click,
                            //         child:const Text("", //Forget Password
                            //           style: TextStyle(
                            //               color: Colors.deepOrange
                            //           ),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            Padding(
                              padding:const EdgeInsets.fromLTRB(20, 10, 30, 10),
                              child: checkVerify() ? Text(verify,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight:FontWeight.bold
                                ),) : Text('')
                            ),
                            GestureDetector(
                              onTap: () async {
                                print('Login: ${login}');
                                print('Password: ${password}');
                                final url = '$apiUrlPub/api/loginApp?username=$login&password=$password';
                                print('url: ${url}');
                                try {
                                  print('12345');
                                  final response = await Dio().get(url);
                                  print('123456');
                                  user = Map<String, dynamic>.from(response.data);
                                  if (user['success']) {
                                    print('1234567');
                                    await _saveValues(user);
                                    setState(() {});
                                    print('${user['success']}');
                                    print('12345678');
                                  } else {
                                    print(user['error']);
                                    verify = user['error'];
                                    setState(() {});
                                    user = null;
                                  }
                                } catch(err) {
                                  print('Something error. :( $err');
                                  verify = 'Something error. :(';
                                  setState(() {});
                                  user = null;
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 250,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(50)),
                                    color: Colors.green,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Вхід',
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15 ,),
                            const Text("Або", // Or Login using Social Media Account",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                    onPressed: click,
                                    icon: const Icon(FontAwesomeIcons.facebook,color: Colors.blue)
                                ),
                                IconButton(
                                    onPressed: click,
                                    icon: const Icon(FontAwesomeIcons.google,color: Colors.redAccent,)
                                ),
                                // IconButton(
                                //     onPressed: click,
                                //     icon: const Icon(FontAwesomeIcons.twitter,color: Colors.orangeAccent,)
                                // ),
                                // IconButton(
                                //     onPressed: click,
                                //     icon: const Icon(FontAwesomeIcons.linkedinIn,color: Colors.green,)
                                // )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    Text(
                      '${user["user"]["user_name"]} ${user["user"]["sur_name"]}',
                      style: TextStyle(
                        fontFamily: 'SourceSansPro',
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                      width: 200,
                      child: Divider(
                        color: Colors.teal[100],
                      ),
                    ),
                    Card(
                        color: Colors.white,
                        margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                        child: ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.teal[900],
                          ),
                          title: Text(
                            '${user["user"]["phone"] == null ? '-' : user["user"]["phone"]}',
                            style:
                            TextStyle(fontFamily: 'BalooBhai', fontSize: 20.0),
                          ),
                        )),
                    Card(
                      color: Colors.white,
                      margin:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.teal[900],
                        ),
                        title: Text(
                          '${user["user"]["cdate"]}',
                          style: TextStyle(fontSize: 20.0, fontFamily: 'Neucha'),
                        ),
                      ),
                    ),
                    // Text('user: ${user}'),
                    ElevatedButton(
                      onPressed: () async {
                        await removeLocalStorage();
                        user = null;
                        setState(() {});
                      },
                      child: Text('Вийти')
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
