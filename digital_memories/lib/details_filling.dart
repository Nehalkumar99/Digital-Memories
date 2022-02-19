import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:digital_memories/helpers/db.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsPage extends StatefulWidget {
  final Details details;
  DetailsPage({this.details});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  // final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _userEdited = false;
  Details _editedDetails;

  @override
  void initState() {
    super.initState();
    if (widget.details == null) {
      _editedDetails = Details();
    } else {
      _editedDetails = Details.fromMap(widget.details.toMap());
    }
    if (_editedDetails.filetype == null) _editedDetails.filetype = "URL";
    print(widget.details.toMap());
    print(Details.fromMap(widget.details.toMap()));
    _nameController.text = _editedDetails.description;
    _emailController.text = _editedDetails.texturl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.teal),
          actionsIconTheme: IconThemeData(color: Colors.teal),
          elevation: 6,
          toolbarHeight: 50,
          title: Text('Create a Memory',
              style: GoogleFonts.dancingScript(
                  color: Colors.teal,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_editedDetails.description != null &&
              _editedDetails.description.isNotEmpty) {
            Navigator.pop(context, _editedDetails);
          } else {
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            if (_editedDetails.filetype != "URL")
              GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      //shape: BoxShape.circle,

                      image: DecorationImage(
                        image: _editedDetails.thumbnail != null &&
                                _editedDetails.thumbnail != ""
                            ? FileImage(File(_editedDetails.thumbnail))
                            : AssetImage('assets/icon/file.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                setState(() {
                  _editedDetails.description = value;
                });
              },
            ),
            if (_editedDetails.texturl != null)
              TextField(
                controller: _emailController,
                // focusNode: _nameFocus,
                decoration: InputDecoration(labelText: 'Url'),
                onChanged: (value) {
                  setState(() {
                    _editedDetails.description = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
