import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import '../general/profile_avatar.dart';
import '../../utils/two_letter_name.dart';
import '../general/phone_tile.dart';
import '../general/email_tile.dart';
import '../app/app_bottom_bar.dart';
import '../general/list_widget.dart';

class ImportContactsScreen extends StatefulWidget {
  @override
  ImportContactsScreenState createState() => ImportContactsScreenState();
}

class ImportContactsScreenState extends State<ImportContactsScreen> {
  List<ContactSelect> _contacts;
  @override
  void initState() {
    // Get all contacts
    _loadContacts();
    super.initState();
  }

  void _loadContacts() async {
    var contacts = await ContactsService.getContacts();
    final _items = contacts
        .map((Contact item) => ContactSelect(contact: item, selected: false))
        .toList();
    setState(() {
      _contacts = _items;
    });
    _updateCount();
  }

  void _viewContact(BuildContext context, {Contact contact}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => _ContactDetailsScreen(contact: contact)),
    );
  }

  void _selectAll({bool deselect = false}) {
    if (_contacts != null && _contacts.isNotEmpty)
      for (var _item in _contacts) {
        setState(() {
          if (deselect) {
            _item?.selected = false;
          } else {
            _item?.selected = true;
          }
        });
      }
    _updateCount();
  }

  int _selectedContacts = 0;
  void _updateCount() {
    int _count = 0;
    if (_contacts != null && _contacts.isNotEmpty)
      for (var _item in _contacts) {
        if (_item?.selected == true) {
          _count++;
        }
      }
    setState(() {
      _selectedContacts = _count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool _allSelected = _selectedContacts == _contacts?.length;
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Contacts"),
      ),
      body: ListWidget(
          items: _contacts,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  _getLabelText(all: _allSelected, count: _selectedContacts),
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  final _item = _contacts[index];
                  final _contact = _item.contact;
                  final _selected = _item?.selected ?? false;
                  return ListTile(
                    selected: _item?.selected,
                    leading: AvatarWidget(
                      imageURL: "",
                      noImageText: convertNamesToLetters(
                        _contact?.givenName,
                        _contact?.familyName,
                      ),
                    ),
                    title: Text(_contact?.displayName),
                    trailing: IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () => _viewContact(context, contact: _contact),
                    ),
                    onTap: () {
                      setState(() {
                        _item?.selected = !_selected;
                      });
                      _updateCount();
                    },
                    onLongPress: () => _viewContact(context, contact: _contact),
                  );
                },
              ),
            ],
          )),
      bottomNavigationBar: AppBottomBar(
        showSort: false,
        buttons: [
          IconButton(
            tooltip: _allSelected ? "Deselect All" : "Select All",
            icon: Icon(
              Icons.select_all,
              color: _allSelected ? Colors.blue : null,
            ),
            onPressed: () =>
                _allSelected ? _selectAll(deselect: true) : _selectAll(),
          ),
        ],
      ),
    );
  }

  String _getLabelText({bool all, int count}) {
    if (all) return "All Contacts Selected";
    if (count == 0) return "No Contacts Selected";
    if (count == 1) return "Contact $count Selected";
    return "Contacts $count Selected";
  }
}

class ContactSelect {
  final Contact contact;
  bool selected;
  ContactSelect({this.contact, this.selected = false});
}

class _ContactDetailsScreen extends StatelessWidget {
  final Contact contact;
  _ContactDetailsScreen({this.contact});
  @override
  Widget build(BuildContext context) {
    var _details = <Widget>[
      ListTile(
        leading: Icon(Icons.person),
        title: Text(
          contact?.displayName,
        ),
      ),
    ];
    if (contact?.phones != null && contact.phones.isNotEmpty) {
      var _phones = getPhones(context, items: contact.phones.toList());
      _details.addAll(_phones);
    }
    if (contact?.emails != null && contact.emails.isNotEmpty) {
      var _emails = getEmails(context, items: contact.emails.toList());
      _details.addAll(_emails);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _details,
        ),
      ),
    );
  }

  List<Widget> getPhones(BuildContext context, {@required List<Item> items}) {
    var _widgets = <Widget>[];
    for (var _item in items) {
      _widgets.add(buildPhoneTile(
        context,
        label: _item?.label,
        number: _item?.value,
        icon: getIcon(_item?.label ?? ""),
      ));
    }
    return _widgets;
  }

  List<Widget> getEmails(BuildContext context, {@required List<Item> items}) {
    var _widgets = <Widget>[];
    for (var _item in items) {
      _widgets.add(buildEmailTile(
        context,
        label: _item?.label,
        email: _item?.value,
      ));
    }
    return _widgets;
  }

  IconData getIcon(String name) {
    if (name.contains("mobile")) return Icons.phone;
    if (name.contains("work")) return Icons.work;
    if (name.contains("fax")) return Icons.print;
    if (name.contains("home")) return Icons.home;
    return Icons.phone;
  }
}
