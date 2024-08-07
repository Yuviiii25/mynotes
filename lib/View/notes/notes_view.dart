import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Services/cloud/cloud_note.dart';
import 'package:mynotes/Services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/Utilities/dialogs/Logout_dialog.dart';
import 'package:mynotes/View/notes/notes_list_view.dart';
import 'package:mynotes/enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
    late final FirebaseCloudStorage _notesService;
     String? get userId => AuthService.firebase().currentUSer!.id;

    @override
    void initState(){
      _notesService = FirebaseCloudStorage();
      super.initState();
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(onPressed: (){
              Navigator.of(context).pushNamed(createorUpdateNoteRoute);
          }, 
          icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(onSelected: (value) async{
            switch(value){
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if(shouldLogout){
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false,);
                }
            }
          },itemBuilder: (context){
            return const[
            const PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child:Text('Log Out')),
          ];
          },
        )
        ],
      ),
      body:StreamBuilder(
                      stream: _notesService.allNotes(ownerUserId: userId!),
                      builder: (context, snapshot){
                        switch(snapshot.connectionState){
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if(snapshot.hasData){
                              final allNotes = snapshot.data as Iterable<CloudNote>;
                              return MyNotesListView(notes: allNotes, onDeleteNote: (note) async{
                                await _notesService.deleteNote(documentId: note.documentId);
                              },
                                onTap: (note) {
                                  Navigator.of(context).pushNamed(createorUpdateNoteRoute,arguments: note,);
                                },
                              );
                            }else{
                              return const CircularProgressIndicator();
                            }
                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                  ),
      );
  }
}

