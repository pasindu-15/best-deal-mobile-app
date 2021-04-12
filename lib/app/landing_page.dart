import 'package:best_deal_app_v2/app/home_page.dart';
import 'package:best_deal_app_v2/app/sign_in/sign_in_page.dart';
import 'package:best_deal_app_v2/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class LandingPage extends StatelessWidget {
  final AuthBase auth;

  const LandingPage({Key key, this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.active){
            final user = snapshot.data;
            if(user == null) {
            return SignInPage(
              auth: auth,
            );
            }
            return MyHomePage(auth: auth, title: "Best Deal App");
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },

    );
    
    

  }
}
