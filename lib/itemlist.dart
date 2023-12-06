import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'DatabaseHelper.dart';
import 'item.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});


  @override
  _ItemListScreenState createState() => _ItemListScreenState();

}

class _ItemListScreenState extends State<ItemListScreen>{
  List<Map<String, dynamic>> items = [];
  List<Item> itemList = [];

  @override
    void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> itemList = await db.query('items');

    setState(() {
      items = itemList;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddItemDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Row
          const Padding(
            padding: EdgeInsets.only(left: 8,right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text('No.'),
                ),
                // Item Name
                Expanded(
                  flex: 3,
                  child: Text('Name'),
                ),
                // Quantity
                Expanded(
                  flex: 1,
                  child: Text('Qut'),
                ),
                // Item Price
                Expanded(
                  flex: 2,
                  child: Text('Price'),
                ),
                // Total
                Expanded(
                  flex: 2,
                  child: Text('Total'),
                ),
                Expanded(
                  flex: 1,
                  child: Text(''),
                ),
              ],
            ),
          ),
          // Divider line
          const Divider(),
          // Item List
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text('${index + 1}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(items[index]['name'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(items[index]['quantity'].toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(items[index]['price'].toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text((items[index]['quantity'] * items[index]['price']).toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteItem(items[index]['id']);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(int itemId) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // Check the user's choice
    if (confirmDelete == true) {
      // Proceed with deletion
      Database db = await DatabaseHelper.instance.database;
      await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
      _fetchItems(); // Refresh the list after deletion
    }
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    String itemName = '';
    String itemQuantity = '';
    String itemPrice = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: SizedBox(
            child: AlertDialog(
              title: const Text('Add Item'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Item Name TextField
                    TextField(
                      onChanged: (value) {
                        itemName = value;
                      },
                      decoration: const InputDecoration(labelText: 'Item Name'),
                    ),
                    const SizedBox(height: 10),

                    // Item Quantity TextField
                    TextField(
                      onChanged: (value) {
                        itemQuantity = value;
                      },
                      decoration: const InputDecoration(labelText: 'Item Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // Item Price TextField
                    TextField(
                      onChanged: (value) {
                        itemPrice = value;
                      },
                      decoration: const InputDecoration(labelText: 'Item Price'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                // Done Button
                ElevatedButton(
                  onPressed: () async {
                    if (itemName.isNotEmpty && itemQuantity.isNotEmpty && itemPrice.isNotEmpty) {
                      Item newItem = Item(
                          name: itemName,
                          quantity: int.parse(itemQuantity),
                          price: double.parse(itemPrice)
                      );

                      setState(() {
                        itemList.add(newItem);
                      });
                      Database db = await DatabaseHelper.instance.database;

                      try {
                        await db.insert('items', newItem.toMap());
                      } catch (e) {
                        print('Error inserting item: $e');
                      }
                      _fetchItems();
                      print("items: ${itemList.length}");
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Done'),
                ),

                // Close Button
                ElevatedButton(
                  onPressed: () {
                    // Handle the close button action
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}