import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
  final String id; //to identify contacts using uuid package
  final String name;
  Contact({required this.name}) : id = const Uuid().v4();
}

//homepage doesnt know how to display the contacts so for that we make the use of valuenotifier
class ContactBook extends ValueNotifier<List<Contact>> {
  //singleton - one instance in entire app
  ContactBook._sharedInstance()
      : super([]); //private const. and we will manage a empty list here
  static final ContactBook _shared = ContactBook._sharedInstance();

  factory ContactBook() => _shared;

  //change contactbook to value notifier beacuse we are having values now
  int get length => value.length;

  //instead of using _contact.add we will use value.add and notifylisteners
  void add({required Contact contact}) {
    // value.add(contact);
    // notifyListeners();
    final contacts = value;
    contacts.add(contact);
    notifyListeners();
  }

  void remove({required Contact contact}) {
    // value.remove(contact);
    // notifyListeners();
    final contacts = value;
    if (contacts.contains(contact)) {
      contacts.remove(contact);
      notifyListeners();
    }
  }

  //return contact using its index
  Contact? contact({required int atIndex}) =>
      value.length > atIndex ? value[atIndex] : null;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //instance of ContactBook() to display contacts
    // final contactBook = ContactBook();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),

      //change listview.builder to valuelistenablebuilder
      body: ValueListenableBuilder(
          valueListenable: ContactBook(),
          builder: (contact, value, child) {
            final contacts = value as List<Contact>;
            return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  // final contact = contactBook.contact(atIndex: index)!;
                  final contact = contacts[index];
                  return Dismissible(
                    onDismissed: ((direction) {
                      ContactBook().remove(contact: contact);
                    }),
                    key: ValueKey(contact.id),
                    child: Material(
                      color: Colors.white,
                      elevation: 6.0,
                      child: ListTile(
                        //for every contact we want to display the ListTile and for that we will use contact atindex function defined above to create contact
                        title: Text(contact.name),
                      ),
                    ),
                  );
                });
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
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
