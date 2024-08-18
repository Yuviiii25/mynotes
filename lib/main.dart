import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/Services/auth/bloc/auth_event.dart';
import 'package:mynotes/Services/auth/bloc/auth_state.dart';
import 'package:mynotes/Services/auth/firebase_auth_provider.dart';
import 'package:mynotes/View/Login_view.dart';
import 'package:mynotes/View/Verify_email_view.dart';
import 'package:mynotes/View/notes/create_update_note_view.dart.dart';
import 'package:mynotes/View/notes/notes_view.dart';
import 'package:mynotes/View/register_view.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createorUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener:(context, state){
        if(state.isLoading){
          LoadingScreen().show(context:context,text: state.loadingText ?? 'Please eait a moment',);
        }else{
          LoadingScreen().hide();
        }
    },
    builder: (context,state){
      if(state is AuthStateLoggedIn){
        return const NotesView();
      }else if(state is AuthStateNeedsVerification){
        return const VerifyEmailView();
      }else if(state is AuthStateLoggedOut){
        return const LoginView();
      }else if(state is AuthStateRegistering){
        return const RegisterView();
      }else{
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
