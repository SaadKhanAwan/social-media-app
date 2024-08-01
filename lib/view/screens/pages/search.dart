import 'package:flutter/material.dart';
import 'package:social_media_app/helper/debouncer.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/view/widgets/progress.dart';
import 'package:social_media_app/view/widgets/searchcard.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _searchValue;
  final searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: AppBar(
        title: TextFormField(
          key: _formKey,
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Enter your text',
            prefixIcon: const Icon(Icons.account_box, color: Colors.grey),
            suffixIcon: GestureDetector(
              onTap: () {
                searchController.clear();
                setState(() {
                  _searchValue = null;
                });
              },
              child: const Icon(Icons.cancel, color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          onChanged: (val) {
            _debouncer.run(() {
              setState(() {
                _searchValue = val.trim().toLowerCase();
              });
            });
          },
        ),
      ),
      body: _searchValue == null || _searchValue!.isEmpty
          ? buildNoContent(orientation)
          : buildSearchResult(),
    );
  }

  buildNoContent(orientation) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Image.asset(
            "assets/images/search.png",
            height: orientation == Orientation.portrait ? 300 : 150,
          ),
          Center(
            child: Text(
              "Find Users",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: orientation == Orientation.portrait ? 60 : 35,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
      future: APi.searchUsers(_searchValue),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: circulaprogress(Colors.white),
          );
        }
        final searchResult = snapshot.data!.docs.map((doc) {
          final user = Users.fromJson(doc.data() as Map<String, dynamic>);
          return SearchCard(user: user);
        }).toList();
        return ListView(
          children: searchResult,
        );
      },
    );
  }
}
