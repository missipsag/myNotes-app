import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserId),
      );

  void createNewNote({required String ownerId}) async {
    await notes.add({ownerUserIdFieldName: ownerId, textFieldName: ''});
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerId)
          .get()
          .then(
            (value) => value.docs.map((doc) {
              return CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                text: doc.data()[textFieldName] as String,
              );
            }),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteExceptions();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  static final _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
