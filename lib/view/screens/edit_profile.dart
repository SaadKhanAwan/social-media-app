import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view/widgets/progress.dart';
import 'package:social_media_app/view/widgets/textfield.dart';

class EditProfile extends StatefulWidget {
  final Users me;
  const EditProfile({super.key, required this.me});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? _image;
  final _globalkey = GlobalKey<FormState>();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Edit Profile"),
          actions: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.check)),
            SizedBox(
              width: mwidth * .03,
            ),
          ],
        ),
        body: Form(
          key: _globalkey,
          child: Padding(
            padding: EdgeInsets.only(
                top: mheight * .01, left: mwidth * .05, right: mwidth * .05),
            child: ListView(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mheight * .4),
                                child: Image.file(
                                  File(_image!),
                                  height: mheight * 0.23,
                                  width: mwidth * 0.45,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mheight * .4),
                                child: CachedNetworkImage(
                                  height: mheight * .23,
                                  width: mwidth * .45,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.me.photoUrl.toString(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(CupertinoIcons.person),
                                ),
                              ),
                        Positioned(
                            bottom: mheight * .01,
                            right: mwidth * .02,
                            child: GestureDetector(
                              onTap: () {
                                _showbuttonsheet();
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: mheight * .07,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.person,
                      hintText: "Enter user name",
                      initaialValue: widget.me.username,
                      onsave: (val) => APi.me.username = val ?? "",
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your user name';
                        }
                        final words = value.trim();
                        if (words.length < 3) {
                          return 'User name must have at least 3 words';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: mheight * .07,
                    ),
                    CustomTextField(
                      prefixIcon: Icons.notes,
                      hintText: "Enter user name",
                      initaialValue: widget.me.bio,
                      onsave: (val) => APi.me.bio = val ?? "",
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        if (value.length > 100) {
                          return 'Bio must be less than 100 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: mheight * .07,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(mwidth * .7, mheight * .07),
                          backgroundColor: Colors.blue),
                      onPressed: () async {
                        setState(() {
                          isloading = true;
                        });
                        if (_globalkey.currentState!.validate()) {
                          _globalkey.currentState!.save();
                          await APi.updateUSer();
                          if (_image != null) {
                            await APi.uploadProfilePicture(
                                File(_image.toString()));
                          }
                          setState(() {
                            isloading = false;
                          });
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully')));
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, APi.me);
                        }
                      },
                      label: isloading
                          ? circulaprogress(Colors.white)
                          : const Text(
                              "Edit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            ),
                      icon: isloading
                          ? null
                          : const Icon(
                              Icons.edit,
                              size: 30,
                              color: Colors.white,
                            ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
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
                        // ignore: use_build_context_synchronously
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
                        // ignore: use_build_context_synchronously
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
}
