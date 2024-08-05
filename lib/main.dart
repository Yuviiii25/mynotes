import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/View/Login_view.dart';
import 'package:mynotes/View/Verify_email_view.dart';
import 'package:mynotes/View/notes/create_update_note_view.dart.dart';
import 'package:mynotes/View/notes/notes_view.dart';
import 'package:mynotes/View/register_view.dart';
 
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
        VerifyEmailRoute:(context) => const VerifyEmailView(),
        createorUpdateNoteRoute:(context) => const CreateUpdateNoteView(),
      },
      
      ),
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:AuthService.firebase().initialize(),
        builder: (context, snapshot) {
        switch (snapshot.connectionState){
          case ConnectionState.done:
          final user = AuthService.firebase().currentUSer;
          if(user != null){
            if(user.isEmailVerified)
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