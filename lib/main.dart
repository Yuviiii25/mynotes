import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/View/Login_view.dart';
import 'package:mynotes/View/Verify_email_view.dart';
import 'package:mynotes/View/register_view.dart';
import 'package:mynotes/firebase_options.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute:(context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        NotesRoute:(context) => const NotesView(),
      },
      
      ),
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
        builder: (context, snapshot) {
        switch (snapshot.connectionState){
          case ConnectionState.done:
          final user = FirebaseAuth.instance.currentUser;
          if(user != null){
            if(user.emailVerified)
            {
              return const NotesView();
            }
            else
            {
              return const VerifyEmailView(); 
            }
          }
          else{
                return const LoginView();
          }
          
          default:
            return const CircularProgressIndicator();
         
      }  
      },
      );
  } 
}

enum MenuAction{logout}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if(shouldLogout){
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false,);
                }
            }
          },itemBuilder: (context){
            return const[
            const PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child:Text('Log Out')),
          ];
          },
        )
        ],
      ),
      body:const Text('Hello World'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog(
  context: context,
  builder: (context){
    return AlertDialog(
      title:const Text('Log Out'),
      content: const Text('Are you sure you want to Log out?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        },child: const Text('Cancel'),),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        },child: const Text('Log out'),),
      ],
    );
  }
  ).then((value) => value ?? false);
}