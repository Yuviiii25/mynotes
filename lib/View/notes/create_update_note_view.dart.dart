import 'package:flutter/material.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/Utilities/dialogs/cannot_share_empty_dialog.dart';
import 'package:mynotes/Utilities/generics/get_arguments.dart';
import 'package:mynotes/Services/cloud/cloud_note.dart';
import 'package:share_plus/share_plus.dart';
//import 'package:mynotes/Services/cloud/cloud_storage_constants.dart';
//import 'package:mynotes/Services/cloud/cloud_storage_exceptions.dart';


class  CreateUpdateNoteView extends StatefulWidget {
  const  CreateUpdateNoteView({super.key});

  @override
  State< CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State< CreateUpdateNoteView> {

  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
      _notesService = FirebaseCloudStorage();
      _textController = TextEditingController();
      super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async{

    final widgetNote = context.getArgument<CloudNote>();

    if(widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if(existingNote != null){
      return existingNote;
    }

    final currentUSer = AuthService.firebase().currentUSer!;
    final userId = currentUSer.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId!);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty(){
      final note =_note;
      if(_textController.text.isEmpty && note != null){
        _notesService.deleteNote(documentId: note.documentId);
      }
  }

  void _saveNoteIfTextNotEmpty() async{
    final note = _note;
    final text = _textController.text;
    if(note != null && text.isNotEmpty){
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () async{
            final text = _textController.text;
            if(_note == null || text.isEmpty){
              await showCannotShareEmptyNoteDialog(context);
            }else{
              Share.share(text);
            }
          }, icon: const Icon(Icons.share)),
        ],
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your notes....',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        }
        ),
    );
  }
}