import 'package:mynotes/Services/auth/auth_exceptions.dart';
import 'package:mynotes/Services/auth/auth_provider.dart';
import 'package:mynotes/Services/auth/auth_user.dart';
import 'package:test/test.dart';


void main(){
final provider = MockAuthProvider();
  group('Mock Authentication', (){
      test('Should not be initialized to begin with', (){
        expect(provider.isInitialized, false);
      });

      test('Cannot log out if not initialized', (){
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
      });
  });

  test('Should be able to be initialized', ()async{
      await provider.initialize();
      expect(provider.isInitialized, true);
  });

  test('User Should be null after initialization', (){
      expect(provider.currentUSer, null);
  });

  test('Should be able to initialize in less than 2 seconds', () async{
       await provider.initialize();
      expect(provider.isInitialized, true);
  },
      timeout: const Timeout(Duration(seconds: 2)),
  );

  test('Create User should delegate to login function', () async{
    final badEmailuser = provider.createUser(email: 'foo@bar.com', password: 'anypassword');
    expect(badEmailuser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

    final badPassworduser = provider.createUser(email: 'someone@bar.com', password: 'foobar');
    expect(badPassworduser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

    final user = await provider.createUser(email: 'foo', password: 'bar');
    expect(provider.currentUSer, user);
    expect(user.isEmailVerified, false);
  });

    test('Logged in user should be able to get verified', (){
        provider.sendEmailVerification();
        final user = provider.currentUSer;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
    });

    test('Should be able to oog out and log in again', () async{
        await provider.logOut();
        await provider.logIn(email: 'email', password: 'password');
        final user = provider.currentUSer;
        expect(user,isNotNull);
    });
    
}



class NotInitializedException implements Exception{}


class MockAuthProvider implements AuthProvider{
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;


  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
   if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds:1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUSer => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds:1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitializedException();
    if(email == 'foo@bar.com') throw UserNotFoundAuthException();
    if(password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com', id: 'my_id',);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async{
    if(!isInitialized) throw NotInitializedException();
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds:1));
    _user = null;
    
  }

  @override
  Future<void> sendEmailVerification() async {
     if(!isInitialized) throw NotInitializedException();
     final user = _user;
     if(user == null) throw UserNotFoundAuthException();
     const newUser = AuthUser(isEmailVerified: true, email: 'foo@bar.com', id: 'my_id');
     _user = newUser;
  }
  
  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }
  
}