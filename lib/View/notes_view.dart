import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Services/crud/notes_service.dart';
import 'package:mynotes/enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
    late final NotesService _notesService;
     String get userEmail => AuthService.firebase().currentUSer!.email!;

    @override
    void initState(){
      _notesService = NotesService();
      super.initState();
    }

    @override
    void dispose(){
      _notesService.close();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
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
      body:FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.done:
                  return StreamBuilder(
                      stream: _notesService.allNotes,
                      builder: (context, snapshot){
                        switch(snapshot.connectionState){
                          case ConnectionState.waiting:
                            return const Text('Waiting for all notes....');
                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                  );
                default:
                  return const CircularProgressIndicator();
              }

          },),
      );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog(
  context: context,
  builder: (context){
    return AlertDialog(
      title:const Text('Log Out'),
      content: const Text('Are you sure you want to Log out?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop(false);
        },child: const Text('Cancel'),),
        TextButton(onPressed: (){
          Navigator.of(context).pop(true);
        },child: const Text('Log out'),),
      ],
    );
  }
  ).then((value) => value ?? false);
}