import 'package:bloc/bloc.dart';
import 'package:mynotes/Services/auth/auth_provider.dart';
import 'package:mynotes/Services/auth/bloc/auth_event.dart';
import 'package:mynotes/Services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
    AuthBloc(AuthProvider provider) : super(const AuthStateUnintialized(isLoading: true)){

      on<AuthEventShouldRegister>((event,emit){
        emit(const AuthStateRegistering(exception: null, isLoading: false));
      });

      on<AuthEventForgotPassword>((event,emit)async{
        emit(const AuthStateForgotPassword(isLoading: false, exception: null, hasSentEmail: false));
        final email = event.email;
        if(email == null){
          return;
        }

        bool didSendEmail;
        Exception? exception;
        emit(const AuthStateForgotPassword(isLoading: true, exception: null, hasSentEmail: false));
        try{
          await provider.sendPasswordReset(toEmail:email);
          didSendEmail = true;
          exception = null;
        }on Exception catch(e){
          didSendEmail = false;
          exception = e;
        }

        emit(AuthStateForgotPassword(isLoading: false, exception: exception, hasSentEmail: didSendEmail));
      });

      on<AuthEventSendEmailVerification>((event, emit)async{
        await provider.sendEmailVerification();
        emit(state);
      });

      on<AuthEventRegister>((event,emit)async{
        final email = event.email;
        final password = event.password;
        try{
          await provider.createUser(email:email,password:password);
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        }on Exception catch(e){
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      });

      on<AuthEventInitialize>((event, emit) async {
         await provider.initialize();
         final user = provider.currentUSer;
         if(user == null){
          emit(const AuthStateLoggedOut(exception:null ,isLoading: false));
         } else if(!user.isEmailVerified){
          emit(const AuthStateNeedsVerification(isLoading: false));
         }else{
          emit(AuthStateLoggedIn(user: user, isLoading: false));
         }
      });

      on<AuthEventLogIn>((event,emit) async{
        emit(const AuthStateLoggedOut(exception: null,isLoading: true,loadingText: 'Please wait while I log you in', ));
        await Future.delayed(const Duration(seconds: 2));
        final email = event.email;
        final password = event.password;
        try{
          final user = await provider.logIn(email:email, password: password,);
          if(!user.isEmailVerified){
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(const AuthStateNeedsVerification(isLoading: false));
          }else{
            emit(const AuthStateLoggedOut(exception: null, isLoading: false));
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }
        }on Exception catch (e){
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      });


      on<AuthEventLogOut>((event,emit) async{
        try{
          await provider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }on Exception catch(e){
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      });
    }
}