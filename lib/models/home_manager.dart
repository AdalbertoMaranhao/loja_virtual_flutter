import 'package:cloud_firestore/cloud_firestore.dart';

class HomeManager {

  HomeManager(){
    _loadSections();
  }

  final Firestore firestore = Firestore.instance;

  Future<void> _loadSections() async {
    firestore.collection('home').snapshots().listen((snapshot) {
      for(final DocumentSnapshot document in snapshot.documents){
        
      }
    });
  }

}