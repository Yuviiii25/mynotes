import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/Services/auth/auth_user.dart';
import 'package:mynotes/Services/auth/auth_provider.dart';
import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'package:mynotes/firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider{
  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password,}) async{
    try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        final user = currentUSer;
        if(user != null){
          return user;
        }
        else{
          throw USerNotLoggedInAuthException();
        }
    }on FirebaseAuthException catch(e){
                if(e.code == 'weak-password')
                {
                    throw WeakPasswordAuthException();
                }
                else if(e.code == 'email-already-in-use')
                {
                    throw EmailAlreadyInUSeAuthException();
                }
                else if(e.code == 'invalid-email')
                {
                  throw InvalidEmailAuthException();
                }
                else{
                  throw GenericAuthExceptions();
                }  
              }
    catch (_) {
      throw GenericAuthExceptions();
    }
  }

  @override
  AuthUser? get currentUSer {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return AuthUser.fromFirebase(user);
    }
    else{
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password,}) async{
              try{
                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
                final user = currentUSer;
                if(user != null){
                  return user;
                }
                else{
                  throw USerNotLoggedInAuthException();
                }
              } on FirebaseAuthException catch(e){
                 if(e.code == 'user-not-found')
                 {
                    throw UserNotFoundAuthException();
                 }
                 else if(e.code == 'wrong-password')
                 {
                    throw WrongPasswordAuthException();
                 }
                 else{
                  throw GenericAuthExceptions();
                 } 
              }catch(_){
                throw GenericAuthExceptions();
              }
  }

  @override
  Future<void> logOut() async {
   final user = FirebaseAuth.instance.currentUser;
   if(user != null){
    await FirebaseAuth.instance.signOut();
   }
   else{
    throw USerNotLoggedInAuthException();
   }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user = FirebaseAuth.instance.currentUser;
    if(user != null)
    {
      await user.sendEmailVerification();
    }
    else{
      throw USerNotLoggedInAuthException();
    }
  }
  
  @override
  Future<void> initialize() async{
    await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    }on FirebaseAuthException catch(e){
      switch(e.code){
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthExceptions();
      }
    }catch(_){
      throw GenericAuthExceptions();
    }
  }
}