import 'dart:io';
import 'package:drivers_app/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../methods/common_methods.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController userLastNameTextEditingController = TextEditingController();
  TextEditingController userIdTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController = TextEditingController();
  TextEditingController vehicleColorTextEditingController = TextEditingController();
  TextEditingController vehicleNumberTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";


  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    if(imageFile != null)
    {
      signUpFormValidation();
    }
    else
    {
      cMethods.displaySnackBar("Please choose image first.", context);
    }
  }

  signUpFormValidation()
  {
    if(userNameTextEditingController.text.trim().length < 2)
    {
      cMethods.displaySnackBar("Your user name must be at least 3 or more characters.", context);
    }
    else if (userPhoneTextEditingController.text.trim().length < 9)
    {
      cMethods.displaySnackBar("Please enter a valid phone number.", context);
    }
    else if (!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Please enter a valid email.", context);
    }
    else if (passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Your password must be 6 or more characters.", context);
    }
    else if (userIdTextEditingController.text.trim().length < 12)
    {
      cMethods.displaySnackBar("Please Enter a valid ID No.", context);
    }
    else if (vehicleModelTextEditingController.text.trim().isNotEmpty)
    {
      cMethods.displaySnackBar("Please enter vehicle model", context);
    }
    else if (vehicleColorTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Please enter vehicle color", context);
    }
    else if (vehicleNumberTextEditingController.text.trim().isEmpty)
    {
      cMethods.displaySnackBar("Please enter a valid reg.no.", context);
    }
    else
    {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });

    registerNewDriver
  }

  registerNewDriver() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("drivers").child(userFirebase!.uid);

    Map driverCarInfo =
    {
      "carColor": vehicleColorTextEditingController.text.trim(),
      "carModel": vehicleModelTextEditingController.text.trim(),
      "carNumber": vehicleNumberTextEditingController.text.trim(),

    };

    Map driverDataMap =
    {
      "photo": urlOfUploadedImage,
      "car_details": driverCarInfo,
      "name": userNameTextEditingController.text.trim(),
      "lastName": userLastNameTextEditingController.text.trim(),
      "idNo": userIdTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(driverDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const Dashboard()));
  }

  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(
                height: 40,
              ),

              imageFile == null ?
              const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarman.png"),
              ) : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(
                      File(
                        imageFile!.path,
                      ),
                    )
                  )
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              GestureDetector(
                onTap: ()
                {
                  chooseImageFromGallery();
                },
                child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              //Text Fields + Button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                     controller: userNameTextEditingController,
                     keyboardType: TextInputType.text,
                     decoration: const InputDecoration(
                       labelText: "First Name",
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
                      controller: userLastNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
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
                      controller: userIdTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "SA ID No. or Passport No.",
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
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
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
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
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
                        labelText: "Create Password",
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

                    TextField(
                      controller: vehicleModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Name & Model",
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
                      controller: vehicleColorTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Color",
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
                      controller: vehicleNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Reg. No. (Number Plate)",
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
                        "Sign Up"
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
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> const loginScreen()));
                },
                child: const Text(
                  "Already have an account? Login Here",
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
    