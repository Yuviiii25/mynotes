// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' show join;
// import 'package:mynotes/Services/crud/crud_exceptions.dart';

// class NotesService{

//   Database? _db;

//   List<DatabaseNote> _notes = [];

//   DatabaseUser? _user;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance(){
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: (){
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _shared;

//   late final  StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note)  {
//     final currentUser = _user;
//     if(currentUser != null){
//       return note.userId == currentUser.id;
//     }else{
//       throw UserShouldBeSetBeforeReadingAllNotes();
//     }
//   });

//   Future<void> _ensureDBlsOpen() async{
//       try{
//         await open();
//       }on DatabaseAlreadyOpenException{
//         //empty
//       }
//   }
  
//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUSer = true,}) async{
//     try{
//       final user = await getUser(email: email);
//       if(setAsCurrentUSer){
//         _user = user;
//       }
//       return user;
//     }on CouldNotFindUser{
//       final createdUser = await createUSer(email: email);
//       if(setAsCurrentUSer){
//         _user = createdUser;
//       }
//       return createdUser;
//     }catch (e){
//       rethrow;
//     }
    
//   }

//   Future<void> _cacheNotes() async{
//       final allNotes = await getAllNotes();
//       _notes = allNotes.toList();
//       _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updatesCount = await db.update(noteTable, {textColumn: text, isSyncedWithCloudColumn: 0,}, where: 'id = ?', whereArgs: [note.id],);
//     if(updatesCount == 0){
//       throw CouldNotUpdateNote();
//     }else{
//       final updatedNotes = await getNote(id: note.id);
//       _notes.remove((note) => note.id == updatedNotes);
//       _notes.add(updatedNotes);
//       _notesStreamController.add(_notes);
//       return updatedNotes;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async{
//     await _ensureDBlsOpen();
//     final db =_getDatabaseOrThrow();
//     final notes = await db.query(noteTable);
//     return notes.map((noteRow)=> DatabaseNote.fromRow(noteRow));
// }

//   Future<DatabaseNote> getNote({required int id}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable,limit: 1,where: 'id = ?',whereArgs: [id],);
//     if(notes.isEmpty){
//         throw CouldNotFindNote();
//     }else{
//       final note = DatabaseNote.fromRow(notes.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<int> deleteAllNotes() async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberofDeletions =  await db.delete(noteTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberofDeletions;
//   }

//   Future<void> delteNote({required int id}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//       final deletedCount = await db.delete(userTable, where: 'id = ?', whereArgs: [id]);
//       if(deletedCount != 1){
//         throw CouldNotDeleteNote();
//       }else{
//         _notes.removeWhere((note) => note.id == id);
//         _notesStreamController.add(_notes);
//       }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();

//     //make sure owner exists in the database with correct id
//     final dbUser =await getUser(email: owner.email);
//     if(dbUser != owner){
//       throw CouldNotFindUser();
//     }

//     const text = '';
//     final noteId = await db.insert(noteTable,{
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
//      if(results.isEmpty){
//       throw CouldNotFindUser();
//     }else{
//       return DatabaseUser.fromRow(results.first);
//     }

//   }

//   Future<DatabaseUser> createUSer({required String email}) async{
//     await _ensureDBlsOpen();
//     final db = _getDatabaseOrThrow();
//     final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if(results.isNotEmpty){
//       throw USerAlreadyExists();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(id: userId, email: email,);
//   }

//   Future<void> deleteUSer({required String email}) async {
//       await _ensureDBlsOpen();
//       final db = _getDatabaseOrThrow();
//       final deletedCount = await db.delete(userTable, where: 'email = ?', whereArgs: [email.toLowerCase()]);
//       if(deletedCount != 1){
//         throw CouldNotDeleteUser();
//       }
//   }

//   Database _getDatabaseOrThrow(){
//     final db = _db;
//     if(db == null){
//       throw DatabaseIsNotOpen();
//     }else{
//       return db;
//     }
//   }
  
//   Future<void> close() async{
//     final db =_db;
//     if(db == null){
//       throw DatabaseIsNotOpen();
//     }else{
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> open() async{
//     if(_db != null){
//       throw DatabaseAlreadyOpenException();
//     }
//     try{
//       final docsPath =  await getApplicationCacheDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       await db.execute(createUserTable);
//       await db.execute(createNoteTable);
//       await _cacheNotes();
//     }on MissingPlatformDirectoryException{
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }



// @immutable
// class DatabaseUser{
//   final int id;
//   final String email;
//   const DatabaseUser({required this.id,required this.email});

//   DatabaseUser.fromRow(Map<String,Object?> map): id = map[idColumn] as int, email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, ID = $id, email = $email';
  
//   @override
//   bool operator == (covariant DatabaseUser other)  => id == other.id;
  
//   @override
//   int get hashCode => id.hashCode;
  
// }

// class DatabaseNote{
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

//   DatabaseNote.fromRow(Map<String,Object?> map): id = map[idColumn] as int, 
//   userId = map[userIdColumn] as int, 
//   text = map[textColumn] as String, 
//   isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() => 'Person, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

//   @override
//   bool operator == (covariant DatabaseNote other)  => id == other.id;
  
//   @override
//   int get hashCode => id.hashCode;

// }

// const dbName = 'notes.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
// 	                               "id"	INTEGER NOT NULL,
// 	                              "email"	TEXT NOT NULL UNIQUE,
// 	                              PRIMARY KEY("id" AUTOINCREMENT)
//                               );  ''';
// const createNoteTable =''' CREATE TABLE IF NOT EXISTS "note" (
//                             "id"	INTEGER NOT NULL,
//                             "user_id"	INTEGER NOT NULL,
//                             "text"	TEXT,
//                             "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//                             PRIMARY KEY("id" AUTOINCREMENT),
//                             FOREIGN KEY("user_id") REFERENCES "user"("id")
//                            ); ''';

