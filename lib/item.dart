class Item {
  int? id;
  String name;
  int quantity;
  double price;

  Item({this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': quantity * price,
    };
  }

}