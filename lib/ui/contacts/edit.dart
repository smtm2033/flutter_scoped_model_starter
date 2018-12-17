import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

import '../../data/classes/contacts/contact_details.dart';
import '../../data/classes/contacts/contact_row.dart';
import '../../data/classes/general/address.dart';
import '../../data/classes/general/phone.dart';
import '../../data/classes/unify/contact_group.dart';
import '../../data/models/auth_model.dart';
import '../../data/models/contact_model.dart';
import '../../ui/contacts/groups/manage.dart';
import '../general/address_tile.dart';
import '../general/phone_tile.dart';

class ContactItemEdit extends StatefulWidget {
  final ContactRow item;
  final ContactModel model;
  final AuthModel auth;
  final ContactDetails details;

  ContactItemEdit({
    this.item,
    @required this.model,
    this.details,
    @required this.auth,
  });
  @override
  _ContactItemEditState createState() =>
      _ContactItemEditState(details: details);
}

class _ContactItemEditState extends State<ContactItemEdit> {
  _ContactItemEditState({this.details});
  bool _isDisposed = false;
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  TextEditingController _firstName, _lastName, _email;
  bool _isNew = false;

  ContactDetails details;

  Phone _cell, _home, _office;
  // Address _address;

  Address get address => details?.address;
  List<ContactGroup> _groups;

  @override
  void initState() {
    // _updateView(contactDetails: widget.details);
    _loadItemDetails();
    super.initState();
  }

  void _loadItemDetails() async {
    if ((widget?.item?.id ?? "").toString().isEmpty) {
      if (!_isDisposed)
        setState(() {
          _isNew = true;
        });
    }
    print("Passed => " + details?.toJson().toString());
    _updateView(contactDetails: details);
  }

  void _getDetails(BuildContext context, {ContactModel model}) async {
    var _contact = await model.getDetails(context, id: widget?.item?.id);
    if (!_isDisposed)
      setState(() {
        details = _contact;
      });
    _updateView(contactDetails: _contact);
  }

  void _saveInfo(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      var _phones = <Phone>[];
      if (_cell != null && _cell.raw().isNotEmpty) _phones.add(_cell);
      if (_home != null && _home.raw().isNotEmpty) _phones.add(_home);
      if (_office != null && _office.raw().isNotEmpty) _phones.add(_office);
      //if (!_isDisposed) setState(() {
      //   _address = details?.address;
      // });
      print("Address => " + address?.raw());

      ContactDetails _contact = ContactDetails(
        firstName: _firstName?.text ?? "",
        lastName: _lastName?.text ?? "",
        email: _email?.text ?? "",
        address: address,
        // phones: _phones,
      );

      print(_contact.toJson());

      Navigator.pop(context, _contact);
    }
  }

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showInSnackBar(Widget child) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: child));
  }

  void _updateView({Contact phoneContact, ContactDetails contactDetails}) {
    if (phoneContact == null || details == null) {
      _firstName = TextEditingController(text: widget?.item?.firstName ?? "");
      _lastName = TextEditingController(text: widget?.item?.lastName ?? "");
      _email = TextEditingController(text: widget?.item?.email ?? "");

      if (!_isDisposed)
        setState(() {
          _cell = widget?.item?.cellPhone;
          _home = widget?.item?.homePhone;
          _office = widget?.item?.officePhone;
        });
    } else {
      if (phoneContact != null) {
        if (!_isDisposed)
          setState(() {
            details = ContactDetails.fromPhoneContact(phoneContact);
            print(details.toJson().toString());
            print(details.address.toJson().toString());
          });
      } else if (contactDetails != null) {
        if (!_isDisposed)
          setState(() {
            details = contactDetails;
          });
      }

      // -- Load Info from Phone Contact --
      _firstName = TextEditingController(text: details?.firstName ?? "");
      _lastName = TextEditingController(text: details?.lastName ?? "");
      _email = TextEditingController(text: details?.email ?? "");

      // var _phones = details?.phones ?? [];
      // for (var _phone in _phones) {
      //   if (_phone.label.contains("home")) {
      //    if (!_isDisposed) setState(() {
      //       _home = _phone;
      //     });
      //   }
      //   if (_phone.label.contains("office")) {
      //    if (!_isDisposed) setState(() {
      //       _office = _phone;
      //     });
      //   }
      //   if (_phone.label.contains("cell") || _phone.label.contains("mobile")) {
      //    if (!_isDisposed) setState(() {
      //       _cell = _phone;
      //     });
      //   }
      // }
    }

    //if (!_isDisposed) setState(() {
    //   _formKey.currentState.validate();
    // });
  }

  void _manageContactGroups(BuildContext context, {ContactModel model}) async {
    if (model.groups == null || model.groups.isEmpty) {
      await model.loadContactGroups(context, auth: widget.auth);
    }

    var _source = model.groups;
    var _inital = _groups;

    if (_inital != null && _source != null) {
      for (var _item in _inital) {
        if (_source.contains(_item)) {
          _source.remove(_item);
        }
      }
    }

    // Navigator.pushNamed(context, "manage_groups");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactGroupManageContact(
              source: _source,
              inital: _inital,
            ),
      ),
    ).then((value) {
      if (value != null) {
        final List<ContactGroup> _items = value;
        if (!_isDisposed)
          setState(() {
            _groups = _items;
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final _model = ScopedModel.of<ContactModel>(context, rebuildOnChange: true);
    final _model = widget.model;
    if (details == null) _getDetails(context, model: _model);
    final String _type = ContactFields.objectType;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isNew ? Text("New $_type") : Text("Edit $_type"),
        actions: <Widget>[
          IconButton(
            tooltip: "Import Contact",
            icon: Icon(Icons.import_contacts),
            onPressed: () =>
                Navigator.pushNamed(context, "/import_single").then((value) {
                  if (value != null) _updateView(phoneContact: value);
                }),
          ),
          IconButton(
            tooltip: "Contact Groups",
            icon: Icon(Icons.group),
            onPressed: () => _manageContactGroups(context, model: widget.model),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              ListTile(
                title: TextFormField(
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: ContactFields.first_name),
                  controller: _firstName,
                  keyboardType: TextInputType.text,
                  validator: (val) => val.isEmpty
                      ? 'Please enter a ${ContactFields.first_name}'
                      : null,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration:
                      InputDecoration(labelText: ContactFields.last_name),
                  controller: _lastName,
                  keyboardType: TextInputType.text,
                  validator: (val) => val.isEmpty
                      ? 'Please enter a ${ContactFields.last_name}'
                      : null,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(labelText: ContactFields.email),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              ExpansionTile(
                title: Text("Phone"),
                children: <Widget>[
                  PhoneInputTile(
                    label: "Cell Phone",
                    number: _cell,
                    numberChanged: (Phone value) {
                      if (!_isDisposed)
                        setState(() {
                          _cell = value;
                        });
                    },
                  ),
                  PhoneInputTile(
                    label: "Home Phone",
                    number: _home,
                    numberChanged: (Phone value) {
                      if (!_isDisposed)
                        setState(() {
                          _home = value;
                        });
                    },
                  ),
                  PhoneInputTile(
                    showExt: true,
                    label: "Office Phone",
                    number: _office,
                    numberChanged: (Phone value) {
                      if (!_isDisposed)
                        setState(() {
                          _office = value;
                        });
                    },
                  ),
                  Container(height: 5.0),
                ],
              ),
              ExpansionTile(
                title: Text("Address"),
                children: <Widget>[
                  AddressInputTile(
                    label: "Current Address",
                    address: details?.address,
                    addressChanged: (Address value) {
                      if (!_isDisposed)
                        setState(() {
                          details.address = value;
                        });
                    },
                  ),
                  Container(height: 5.0),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    child: Text(
                      _isNew ? "Add $_type" : "Save $_type",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _saveInfo(context),
                  ),
                ],
              ),
              Container(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
