import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/address.dart';
import 'package:lojavirtual/models/cart_manager.dart';
import 'package:lojavirtual/models/cart_product.dart';

enum Status {canceled, preparing, transporting, delivered}

class Order {
  
  Order.fromCartManager(CartManager cartManager){
    items = List.from(cartManager.items);
    price = cartManager.totalPrice;
    userId = cartManager.user.id;
    address = cartManager.address;
    status = Status.preparing;
  }

  Order.fromDocument(DocumentSnapshot doc){
    orderId = doc.documentID;
    items = (doc.data['items'] as List<dynamic>).map((e){
      return CartProduct.fromMap(e as Map<String, dynamic>);
    }).toList();
    price = doc.data['price'] as num;
    userId = doc.data['user'] as String;
    address = Address.fromMap(doc.data['address'] as Map<String, dynamic>);
    date = doc.data['date'] as Timestamp;

    status = Status.values[doc.data['status'] as int];
  }

  final Firestore firestore = Firestore.instance;
  DocumentReference get firestoreRef =>
      firestore.collection('orders').document(orderId);

  String orderId;

  List<CartProduct> items;
  num price;
  String userId;
  Address address;

  Status status;

  Timestamp date;

  String get formattedId => '#${orderId.padLeft(6, '0')}';

  String get statusText => getStatusText(status);


  Future<void> save() async {
    firestoreRef.setData(
      {
        'items': items.map((e) => e.toOrderItemMap()).toList(),
        'price': price,
        'user': userId,
        'address': address.toMap(),
        'status': status.index,
        'date': Timestamp.now(),
      }
    );
  }

  void updateFromDocument(DocumentSnapshot doc) {
    status = Status.values[doc.data['status'] as int];
  }

  static String getStatusText(Status status){
    switch(status){
      case Status.canceled:
        return 'Cancelado';
      case Status.preparing:
        return 'Em Separação';
      case Status.transporting:
        return 'Em Transporte';
      case Status.delivered:
        return 'Entregue';
      default:
        return '';
    }
  }

  Function() get back {
    if(status.index >= Status.transporting.index){
      return (){
        status = Status.values[status.index - 1];
        firestoreRef.updateData({'status': status.index});
      };
    }
    return null;
  }

  Function() get advance {
    if(status.index <= Status.transporting.index){
      return (){
        status = Status.values[status.index + 1];
        firestoreRef.updateData({'status': status.index});
      };
    }
    return null;
  }

  void cancel() {
    status = Status.canceled;
    firestoreRef.updateData({'status': status.index});
  }




}