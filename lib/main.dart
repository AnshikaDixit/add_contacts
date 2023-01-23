import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/new-contact': (context) => const NewContactView(),
      },
    );
  }
}

class Contact {
  final String name;
  const Contact({required this.name});
}

class ContactBook {
  //singleton - one instance in entire app
  ContactBook._sharedInstance(); //private const.
  static final ContactBook _shared = ContactBook._sharedInstance();

  factory ContactBook() => _shared;

  //storage for contacts
  final List<Contact> _contacts = [];

  int get length => _contacts.length;

  void add({required Contact contact}) {
    _contacts.add(contact);
  }

  void remove({required Contact contact}) {
    _contacts.remove(contact);
  }

  //return contact using its index
  Contact? contact({required int atIndex}) =>
      _contacts.length > atIndex ? _contacts[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //instance of ContactBook() to display contacts
    final contactBook = ContactBook();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: ListView.builder(
          itemCount: contactBook.length,
          itemBuilder: (context, index) {
            final contact = contactBook.contact(atIndex: index)!;
            return ListTile(
              //for every contact we want to display the ListTile and for that we will use contact atindex function defined above to create contact
              title: Text(contact.name),
            );
          }),

      //FAB to add new contacts to the list to be displayed
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/new-contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//to actually add contacts we need to create a stateful widget
class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  late final TextEditingController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Contact'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter a new Contact name here..',
            ),
          ),
          TextButton(
              onPressed: () {
                final contact = Contact(name: _controller.text);
                ContactBook().add(contact: contact);
                Navigator.of(context).pop();
              },
              child: const Text('Add Contact'))
        ],
      ),
    );
  }
}
