import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/contact_model.dart';
import 'edit.dart';
import 'view.dart';
import '../../../data/classes/unify/contact_group.dart';

class ContactGroupsScreen extends StatefulWidget {
  final ContactModel model;

  ContactGroupsScreen({
    this.model,
  });

  @override
  ContactGroupsScreenState createState() {
    return new ContactGroupsScreenState();
  }
}

class ContactGroupsScreenState extends State<ContactGroupsScreen> {
  List<ContactGroup> _groups = [];

  void _editGroup(BuildContext context,
      {bool isNew = true, ContactGroup item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditContactGroup(
                isNew: isNew,
                groupName: item?.name,
                id: item?.id,
              ),
          fullscreenDialog: true),
    ).then((value) {
      if (value != null) {
        final ContactGroup _group = value;
        widget.model
            .editContactGroup(
          context,
          isNew: isNew,
          model: ContactGroup(name: _group?.name, id: _group?.id),
        )
            .then((_) {
          setState(() {
            _groups.clear();
          });
          // Navigator.pop(context, true);
        });
      }
    });
  }

  void _viewList(BuildContext context, {ContactGroup item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContactGroupList(groupName: item?.name, id: item?.id),
      ),
    ).then((value) {
      if (value != null) {
        final ContactGroup _group = value;
        widget.model
            .editContactGroup(
          context,
          isNew: false,
          model: ContactGroup(name: _group?.name, id: _group?.id),
        )
            .then((_) {
          setState(() {
            _groups.clear();
          });
          // Navigator.pop(context, true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text("Contact Groups"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => widget.model.loadContactGroups(context),
        ),
        IconButton(
          icon: Icon(Icons.group_add),
          onPressed: () => _editGroup(context, isNew: true),
        ),
      ],
    );
    if (_groups == null || _groups.isEmpty) {
      widget.model.loadContactGroups(context).then((_) {
        setState(() {
          _groups = widget.model?.groups ?? [];
        });
      });
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: widget.model?.groups?.length,
        itemBuilder: (BuildContext context, int index) {
          final _group = widget.model?.groups[index];
          return SafeArea(
            child: WrapItem(
              _group,
              true,
              index: index,
              onTap: () => _viewList(context, item: _group),
              onLongPressed: () =>
                  _editGroup(context, isNew: false, item: _group),
            ),
          );
        },
      ),
    );
  }
}

class WrapItem extends StatelessWidget {
  const WrapItem(
    this.item,
    this.isSource, {
    this.index = 0,
    this.onTap,
    this.onLongPressed,
  }) : size = isSource ? 40.0 : 50.0;
  final bool isSource;
  final double size;
  final int index;
  final ContactGroup item;
  final VoidCallback onTap, onLongPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => SidekickTeamBuilder.of<Item>(context).move(item),
      onTap: onTap,
      onLongPress: onLongPressed,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: size - 4,
          width: size - 4,
          decoration: new BoxDecoration(
              color: _getColor(index),
              borderRadius: new BorderRadius.all(const Radius.circular(60.0))),
          child: Center(
            child: Text(item?.name ?? "No Name Found",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Color _getColor(int index) {
    switch (index % 4) {
      // case 0:
      //   return Colors.blueGrey;
      // case 1:
      //   return Colors.red;
      // case 2:
      //   return Colors.purple;
      // case 3:
      //   return Colors.green;
    }
    return Colors.blueGrey;
  }
}
