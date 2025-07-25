// import 'dart:async';
// import 'dart:developer' as devtools show log;

// import 'package:flutter/foundation.dart';
// import 'package:mynotes/extensions/list/filter.dart';
// import 'package:mynotes/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// class NotesService {
//   Database? _db;
//   List<DatabaseNote> _notes = [];
//   DatabaseUser? _user;

//   static final NotesService _shared = NotesService._sharedInstance();
//   NotesService._sharedInstance() {
//     _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _notesStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NotesService() => _shared;

//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _notesStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
        
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(
//       id: note.id,
//     ); // just because it throws an Exception CouldNotFindNote
//     final updatesCount = await db.update(
//       notesTable,
//       {textColumn: text, isSyncWithCloudColumn: 0},
//       where: 'id = ?',
//       whereArgs: [note.id],
//     );
//     if (updatesCount == 0) {
//       throw CouldNotUpdateNote();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _notesStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final allNotes = await db.query(notesTable);

//     final result = allNotes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//     return result;
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(
//       notesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) {
//       throw CouldNotFindNote();
//     }

//     final note = DatabaseNote.fromRow(notes.first);
//     _notes.removeWhere((note) => note.id == id);
//     _notes.add(note);
//     _notesStreamController.add(_notes);
//     return note;
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletedNotes = await db.delete(notesTable);
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return numberOfDeletedNotes;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final deletedNote = await db.delete(
//       notesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (deletedNote == 0) {
//       throw CouldNotDeleteNote();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _notesStreamController.add(_notes);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final dbUser = await getUser(email: owner.email);
//     if (dbUser != owner) {
//       throw CouldNotFindUser();
//     }
//     const text = '';
//     final noteId = await db.insert(notesTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncWithCloudColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       text: text,
//       userId: owner.id,
//       isSyncWithCloud: true,
//     );
//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(result.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isNotEmpty) {
//       throw UserAlreadyExists();
//     }

//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });
//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedUser = await db.delete(
//       userTable,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (deletedUser != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;

//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {}
//   }

//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }

//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       await db.execute(createUserTable);
//       devtools.log("created user table");
//       await db.execute(createNoteTable);
//       devtools.log("created notes table");
//       _db = db;

//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({required this.id, required this.email});

//   DatabaseUser.fromRow(Map<String, Object?> map)
//     : id = map[idColumn] as int,
//       email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person : id : $id, email : $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// @immutable
// class DatabaseNote {
//   final int id;
//   final String text;
//   final int userId;
//   final bool isSyncWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.text,
//     required this.userId,
//     required this.isSyncWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//     : id = map[idColumn] as int,
//       text = map[textColumn] as String,
//       userId = map[userIdColumn] as int,
//       isSyncWithCloud = (map[isSyncWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Note : id = $id, text = $text, user_id = $userId, is_sync_with_the_cloud = $isSyncWithCloud';

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// // const dbName = 'mynotes.db';
// // const notesTable = 'note';
// // const userTable = 'user';
// // const idColumn = 'id';
// // const emailColumn = 'email';
// // const userIdColumn = 'user_id';
// // const textColumn = 'text';
// // const isSyncWithCloudColumn = 'is_sync_with_the_cloud';
// // const createUserTable = '''
// //         CREATE TABLE IF NOT EXISTS user (
// //             id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
// //             email TEXT NOT NULL UNIQUE
// //         );
// //       ''';

// // const createNoteTable = '''
// //         CREATE TABLE IF NOT EXISTS note (
// //           id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
// //           user_id INTEGER  NOT NULL UNIQUE,
// //           text TEXT NOT NULL,
// //           is_sync_with_the_cloud INTEGER NOT NULL DEFAULT 0,
// //           FOREIGN KEY('user_id') REFERENCES "user"('id')
// //           );
// //     ''';

// const dbName = 'notes.db';
// const notesTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncWithCloudColumn = 'is_synced_with_cloud';
// String createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//         "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
//         "email" TEXT NOT NULL UNIQUE
//       );
//     ''';
// String createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
//         "user_id" INTEGER NOT NULL, "text" TEXT, 
//         "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0, 
//         FOREIGN KEY("user_id") REFERENCES "user"("id")
//       );
//     ''';
