import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:camelus/config/palette.dart';
import 'package:camelus/helpers/helpers.dart';
import 'package:camelus/models/PostContext.dart';
import 'package:camelus/services/nostr/nostr_injector.dart';
import 'package:camelus/services/nostr/nostr_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class WritePost extends StatefulWidget {
  PostContext? context;

  late NostrService _nostrService;
  WritePost({Key? key, this.context}) : super(key: key) {
    NostrServiceInjector injector = NostrServiceInjector();
    _nostrService = injector.nostrService;
  }
  @override
  State<WritePost> createState() => _WritePostState();
}

class _WritePostState extends State<WritePost> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool submitLoading = false;

  List<File> _images = [];

  _addImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      // User canceled the picker
      return;
    }

    setState(() {
      _images.add(File(result.files.single.path!));
    });
  }

  Future<String> _uploadImage(File file) async {
    final uri = Uri.parse('https://nostr.build/upload.php');
    var request = http.MultipartRequest('POST', uri);

    var bytes = await file.readAsBytes();
    var mimeType = lookupMimeType(file.path);
    var filename = file.path.split('/').last;

    final httpImage = http.MultipartFile.fromBytes("fileToUpload", bytes,
        contentType: MediaType.parse(mimeType!), filename: filename);
    request.files.add(httpImage);

    final response = await request.send();

    if (response.statusCode != 200) {
      return "";
    }

    var responseString = await response.stream.transform(utf8.decoder).join();

    // extract url https://nostr.build/i/4697.png
    // get all urls with  https://nostr.build/i/
    var urls = responseString.split("https://nostr.build/i/").toList();

    // remove everything except ending with jpg png or jpeg or gif
    urls.removeWhere((element) => !(element.contains(".jpg") ||
        element.contains(".png") ||
        element.contains(".jpeg") ||
        element.contains(".gif")));

    // find the string containing the number
    var myName = urls.last.split('"').first;

    var myUrl = "https://nostr.build/i/$myName";

    return myUrl;
  }

  _submitPost() async {
    if (_textEditingController.text == "") {
      return;
    }

    setState(() {
      submitLoading = true;
    });

    var content = _textEditingController.text;
    var tags = [];
    var firstWriteRelayKey =
        widget._nostrService.connectedRelaysWrite.keys.toList()[0];
    var firstWriteRelay = widget
        ._nostrService.connectedRelaysWrite[firstWriteRelayKey]!.connectionUrl;

    if (widget.context != null) {
      // add previous tweet tags
      for (var tag in widget.context!.replyToTweet.tags) {
        if (tag[0] == "e") {
          tags.add(tag);
        }
        if (tag[0] == "p") {
          tags.add(tag);
        }
      }

      if (!(tags.contains(widget.context!.replyToTweet.id))) {
        var tag = [
          "e",
          widget.context!.replyToTweet.id,
          firstWriteRelay,
          "reply"
        ];
        tags.add(tag);
      }
      if (!(tags.contains(widget.context!.replyToTweet.pubkey))) {
        var tag = ["p", widget.context!.replyToTweet.pubkey];
        tags.add(tag);
      }
    }

    // upload images
    List<String> imageUrls = [];
    for (var image in _images) {
      var url = await _uploadImage(image);
      if (url.isNotEmpty) {
        imageUrls.add(url);
      }
    }

    // add image urls to content
    content += "\n";
    for (var url in imageUrls) {
      content += " $url";
    }

    widget._nostrService.writeEvent(content, 1, tags);

    // wait for 1 second
    Future.delayed(const Duration(milliseconds: 200), () {
      // after 1 second, close modal
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    // focus text field
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // horizontal line fading out to both sides

        Container(
          width: double.infinity,
          //height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
          alignment: Alignment.topLeft,
          // round  corners
          decoration: const BoxDecoration(
            color: Palette.extraDarkGray,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: (() {
                      Navigator.pop(context);
                    }),
                    child: SvgPicture.asset(
                      height: 25,
                      'assets/icons/x.svg',
                      color: Palette.gray,
                    ),
                  ),
                  if (widget.context == null)
                    const Text(
                      "write a post",
                      style: TextStyle(
                        color: Palette.lightGray,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (widget.context != null)
                    Column(
                      children: [
                        // get metadata
                        FutureBuilder<Map>(
                            future: widget._nostrService.getUserMetadata(
                                widget.context!.replyToTweet.pubkey),
                            builder: (BuildContext context,
                                AsyncSnapshot<Map> snapshot) {
                              var name = "";

                              if (snapshot.hasData) {
                                name = snapshot.data?["name"] ?? "";
                              } else if (snapshot.hasError) {
                                name = "";
                              } else {
                                // loading
                                name = "...";
                              }
                              if (name.isEmpty) {
                                var pubkey =
                                    widget.context!.replyToTweet.pubkey;
                                var pubkeyHr =
                                    Helpers().encodeBech32(pubkey, "npub");
                                var pubkeyHrShort =
                                    "${pubkeyHr.substring(0, 5)}...${pubkeyHr.substring(pubkeyHr.length - 5)}";
                                name = pubkeyHrShort;
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: Text(
                                    "reply to $name",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Palette.lightGray,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }),

                        /// check if replying to multiple people
                        if ((Helpers()
                                .getPubkeysFromTags(
                                    widget.context?.replyToTweet.tags ?? [])
                                .length >
                            1))
                          Text(
                            "and ${Helpers().getPubkeysFromTags(widget.context?.replyToTweet.tags ?? []).length - 1} more",
                            style: const TextStyle(
                              color: Palette.lightGray,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  // if submitLoading is true, show spinner
                  !submitLoading
                      ? TextButton(
                          onPressed: (() {
                            _submitPost();
                          }),
                          child: SvgPicture.asset(
                            height: 25,
                            'assets/icons/paper-plane-tilt.svg',
                            color: Palette.primary,
                          ),
                        )
                      : Lottie.asset(
                          'assets/lottie/spinner.json',
                          height: 40,
                          width: 64,
                          alignment: Alignment.topCenter,
                        )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // large text field
              Container(
                //height: 200,
                padding: const EdgeInsets.only(left: 20, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  //border: Border.all(color: Palette.primary), //debug
                ),
                child: TextField(
                  focusNode: _focusNode,
                  controller: _textEditingController,
                  style: const TextStyle(color: Palette.white, fontSize: 21),
                  textInputAction: TextInputAction.newline,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: Palette.gray,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              // image preview
              if (_images.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _images[index],
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: TextButton(
                              onPressed: (() {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              }),
                              child: SvgPicture.asset(
                                height: 25,
                                'assets/icons/x.svg',
                                color: Palette.gray,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // bottom row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // add image
                      TextButton(
                        onPressed: (() {
                          _addImage();
                        }),
                        child: SvgPicture.asset(
                          height: 25,
                          'assets/icons/image.svg',
                          color: Palette.gray,
                        ),
                      ),
                      // add video

                      //TextButton(
                      //  onPressed: (() {
                      //    // _addVideo();
                      //  }),
                      //  child: SvgPicture.asset(
                      //    height: 25,
                      //    'assets/icons/file-video.svg',
                      //    color: Palette.gray,
                      //  ),
                      //),

                      // on bottom
                    ],
                  ),
                  if (_images.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: const Text(
                        "provided by nostr.build",
                        style:
                            TextStyle(color: Palette.lightGray, fontSize: 11),
                      ),
                    ),
                ],
              ),
              // to left

              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
