import 'dart:io';

import 'package:digital_memories/helpers/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' as pathfinder;
import 'package:path_provider/path_provider.dart';

import 'package:digital_memories/details_filling.dart';
import 'package:open_file/open_file.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thumbnails/thumbnails.dart';

enum OrderOptions { orderaz, orderza }
var defaultOrder = OrderOptions.orderaz;

enum SharedMediaType { IMAGE, VIDEO, FILE }

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
      theme: ThemeData(primaryColor: Colors.teal, accentColor: Colors.teal),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DetailsHelper dbhelper = DetailsHelper();
  StreamSubscription _intentDataStreamSubscription;
  // List<SharedMediaFile> _sharedFiles;
  // String _sharedText;
  List<Details> detailsArray = [];

  Future<void> openFile(String filePath) async {
    final _result = await OpenFile.open(filePath);
    print(_result.message);
  }

  @override
  void initState() {
    super.initState();
    _getAllDetails();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      // setState(() {
      print(value.length);
      for (var i = 0; i < value.length; i++) {
        print(value[i].thumbnail);
        _showDetailsFillingPage(
            path: value[i].path,
            thumbnail: value[i].thumbnail,
            type: EnumToString.convertToString(value[i].type));
      }
      //  });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      // setState(() {
      print(value.length);
      for (var i = 0; i < value.length; i++) {
        print(value[i].thumbnail);
        _showDetailsFillingPage(
            path: value[i].path,
            thumbnail: value[i].thumbnail,
            type: EnumToString.convertToString(value[i].type));
      }
      //  });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      // setState(() {
      if (value != null && value != "") {
        _showDetailsFillingPage(type: "URL", url: value);
      }
      // });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      // setState(() {
      if (value != null && value != "") {
        _showDetailsFillingPage(type: "URL", url: value);
      }
      //  });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.teal,
        toolbarHeight: 60,
        title: Text(
          'Online  Memories',
          style: GoogleFonts.dancingScript(
              color: Colors.teal, fontSize: 26, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 6,
        actionsIconTheme: IconThemeData(color: Colors.teal),
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            elevation: 10,
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text(
                  'Newest to Oldest',
                  style: TextStyle(color: Colors.teal),
                ),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text(
                  'Oldest to Newest',
                  style: TextStyle(color: Colors.teal),
                ),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: detailsArray.length == 0
          ? Container(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.teal,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
                  child: Text(
                    "Share links, images, videos or files from other apps like youtube, instagram, tiktok or from your phone memory\n\nAfter pressing share look for \"Online Memories\" app and then save it here",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.josefinSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3,
                        wordSpacing: 6),
                  ),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: detailsArray.length,
                  itemBuilder: _detailsCard),
            ),
    );
  }

  Widget _detailsCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (detailsArray[index].filetype != "URL")
                GestureDetector(
                    onTap: () => openFile(detailsArray[index].path),
                    child: Stack(alignment: Alignment.bottomLeft, children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          //shape: BoxShape.circle,

                          image: DecorationImage(
                            image: detailsArray[index].filetype != "FILE"
                                ? FileImage(File(detailsArray[index].thumbnail))
                                : AssetImage('assets/icon/file.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (detailsArray[index].filetype == "FILE")
                        Container(
                          color: Colors.white,
                          height: 40,
                          width: 80,
                          child: Text(
                            pathfinder.basename(detailsArray[index].path),
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 11),
                          ),
                        )
                    ])),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: 200,
                          child: Text(
                            detailsArray[index].time ?? '',
                            textAlign: TextAlign.end,
                            softWrap: true,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Card(
                          elevation: 0.3,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(detailsArray[index].description ?? '',
                                softWrap: true,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ),
                      if (detailsArray[index].texturl != "" &&
                          detailsArray[index].texturl != null)
                        Flexible(
                          child: GestureDetector(
                            onTap: () async =>
                                await launch(detailsArray[index].texturl),
                            child: Card(
                              elevation: 0.3,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(detailsArray[index].texturl ?? '',
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline)),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.teal, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _editDetails(details: detailsArray[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        if (detailsArray[index].filetype != "URL") {
                          File(detailsArray[index].path).delete();
                        }
                        dbhelper.deletedetails(detailsArray[index].id);
                        setState(() {
                          detailsArray.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editDetails({Details details}) {
    _showDetailsFillingPage(
        id: details.id,
        path: details.path,
        thumbnail: details.thumbnail,
        type: details.filetype,
        url: details.texturl,
        description: details.description,
        time: details.time);
  }

  void _showDetailsFillingPage(
      {int id,
      String path,
      String url,
      String type,
      String thumbnail,
      String description,
      String time}) async {
    print("I am called");
    Details details = Details();

    details.id = id;
    details.time = time;
    details.description = description;
    details.path = path;
    details.filetype = type;
    details.texturl = url;
    details.thumbnail = thumbnail;
    if (type == "IMAGE") {
      details.thumbnail = path;
    }
    final savedDetails = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => DetailsPage(details: details)));

    if (savedDetails != null) {
      if (savedDetails.time != null) {
        await dbhelper.updatedetails(savedDetails);
      } else {
        if (path != "" && path != null) {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = pathfinder.basename(path);
          final directory = appDir.path;
          File file = File(path);
          File copiedFile = await file.copy("$directory/$fileName");
          //print('${contact.img} and ${copiedFile.path}');
          savedDetails.path = copiedFile.path;
        }
        if (type == "IMAGE") {
          savedDetails.thumbnail = path;
        }
        if (type == "VIDEO") {
          final appDir = await getApplicationDocumentsDirectory();
          String thumb = await Thumbnails.getThumbnail(
              thumbnailFolder: '${appDir.path}/Thumbnails',
              videoFile: details.path,
              imageType: ThumbFormat.PNG,
              quality: 30);
          savedDetails.thumbnail = thumb;
        }
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        String time = dateFormat.format(DateTime.now());
        savedDetails.time = time;
        await dbhelper.savedetails(savedDetails);
      }
      _getAllDetails();
    }
  }

  void _getAllDetails() {
    dbhelper.getAlldetailss().then((list) {
      setState(() {
        detailsArray = list;
        _orderList(OrderOptions.orderaz);
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderza:
        detailsArray.sort((a, b) {
          return a.time.compareTo(b.time);
        });
        break;
      case OrderOptions.orderaz:
        detailsArray.sort((a, b) {
          return b.time.compareTo(a.time);
        });
        break;
    }
    setState(() {});
  }
}
