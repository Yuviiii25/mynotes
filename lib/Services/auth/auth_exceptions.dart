//Login Exceptions
class UserNotFoundAuthException implements Exception{}
class WrongPasswordAuthException implements Exception{}

//Register Exceptions
class WeakPasswordAuthException implements Exception{}
class EmailAlreadyInUSeAuthException implements Exception{}
class InvalidEmailAuthException implements Exception{}

//GEneric Exceptions
class GenericAuthExceptions implements Exception{}
class USerNotLoggedInAuthException implements Exception{}