import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/Controller/services/geolocator.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view/widgets/progress.dart';

class UploadScreen extends StatefulWidget {
  final Users users;
  const UploadScreen({super.key, required this.users});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  void initState() {
    super.initState();
  }

  final captionCcontroller = TextEditingController();
  final locationCcontroller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _image;
  bool isPosting = false;
  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplashScreen() : buildUploadform();
  }

  buildSplashScreen() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.6),
      child: Column(
        children: [
          Image.asset(
            "assets/images/upload.png",
            height: 450,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () {
                  _showbuttonsheet();
                },
                child: const Text(
                  "Upload Image",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }

  void _showbuttonsheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20, bottom: 50),
            children: [
              const Text(
                " Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // for picking image from camera
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 150)),
                    child: Image.asset("assets/images/camera.png"),
                  ),
                  // for picking image from gallery
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 150)),
                    child: Image.asset("assets/images/gallery.png"),
                  )
                ],
              )
            ],
          );
        });
  }

  buildUploadform() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              setState(() {
                _image = null;
              });
            },
            child: const Icon(Icons.arrow_back_ios_sharp)),
        title: const Text(
          "Caption Post",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          GestureDetector(
            onTap: isPosting ? null : () => handleSubmit(),
            child: Text("Post",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPosting ? Colors.grey : Colors.blue)),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: postbody(),
    );
  }

  postbody() {
    return ListView(children: [
      isPosting ? linearprogress() : const Text(""),
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Image.file(
          File(_image!),
          fit: BoxFit.cover, // Adjust fit as needed
          width: 100, // Adjust width as needed
          height: 280,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: CachedNetworkImageProvider(
                  APi.user.photoURL.toString(),
                ),
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: TextFormField(
              focusNode: _focusNode,
              maxLines: null,
              // key: _formKey,
              controller: captionCcontroller,
              decoration: const InputDecoration(
                  hintText: 'Enter Caption...', border: InputBorder.none),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              onFieldSubmitted: (val) {
                // setState(() {
                //   _searchValue = val.trim();
                // });
              },
            ),
          ),
        ),
      ),
      const Divider(
        color: Colors.black,
        thickness: 0.8,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: TextFormField(
              focusNode: _focusNode,
              maxLines: null,
              // key: _formKey,
              controller: locationCcontroller,
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on_sharp,
                    color: Colors.orange,
                  ),
                  hintText: 'Peshawar, KPK, Pakistan...',
                  border: InputBorder.none),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 18.0, left: 18),
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, minimumSize: const Size(80, 70)),
            onPressed: () async {
              handleCurrentLocation();
            },
            icon: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
            label: const Text(
              "Use Current Location",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
      )
    ]);
  }

  // for clicking on  post
  handleSubmit() async {
    _focusNode.unfocus();
    setState(() {
      isPosting = true;
    });
    final imageUrl = await APi.uploadImageToFirebase(File(_image!));
    await APi.createPost(
      imageUrl,
      locationCcontroller.text,
      captionCcontroller.text,
    ).then((value) {
      locationCcontroller.clear();
      captionCcontroller.clear();
      setState(() {
        _image = null;
        isPosting = false;
      });
    });
  }

  // for getting current location

  handleCurrentLocation() async {
    String? location = await GetLocation.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        locationCcontroller.text = location;
      });
    } else {
      setState(() {
        locationCcontroller.text = "location not avalible";
      });
    }
  }
}
