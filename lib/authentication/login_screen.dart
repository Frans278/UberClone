import 'package:drivers_app/authentication/signup_screen.dart';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();

}



class _loginScreenState extends State<loginScreen>
{
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();



  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    signinFormValidation();
  }

  signinFormValidation()
  {
    if (!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Please enter a valid email.", context);
    }
    else if (passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Your password must be 6 or more characters.", context);
    }
    else
    {
      signInUser();
    }
  }

  signInUser() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Logging In..."),
    );

    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg)
        {
          Navigator.pop(context);
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);
      usersRef.once().then((snap)
      {
        if(snap.snapshot.value != null)
        {
          if((snap.snapshot.value as Map)["blockStatus"] == "no")
          {
            //userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));
          }
          else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("Your Account has been blocked. Contact admin: fstechsolutions1@outlook.com", context);
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Sorry! you are not registered as a Driver.", context);
        }
      });
    }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [


            const SizedBox(
              height: 60,
            ),

            Image.asset(
                "assets/images/uberexec.png",
              width: 220,
            ),

            const SizedBox(
              height: 30,
            ),

            const Text(
              "Login as Driver",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            //Text Fields + Button
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [

                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Driver Email",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22,),

                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Driver Password",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 32,),

                  ElevatedButton(
                    onPressed: ()
                    {
                      checkIfNetworkIsAvailable();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 10)
                    ),
                    child: const Text(
                        "Login"
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 12,),

            //text button
            TextButton(
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (c)=> SignupScreen()));
              },
              child: const Text(
                "Don't have an account? Register here",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

          ],
        ),
      ), // Padding
    ), // SingleChildScrollView
  );
}
}
