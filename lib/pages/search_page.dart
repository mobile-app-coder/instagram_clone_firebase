import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/services/http_service.dart';

import '../models/member_model.dart';
import '../services/db_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isLoading = false;
  var searchController = TextEditingController();
  List<Member> items = [];

  void _apiFollowMember(Member someone) async {
    setState(() {
      isLoading = true;
    });
    await DBService.followMember(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });
    DBService.storePostsToMyFeed(someone);

    sendNotificationToFollowedMember(someone);
  }

  void _apiUnFollowMember(Member someone) async {
    setState(() {
      isLoading = true;
    });
    await DBService.unfollowMember(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });
    DBService.removePostsFromMyFeed(someone);
  }

  void sendNotificationToFollowedMember(Member someone) async {
    Member me = await DBService.loadMember();
    await Network.POST(Network.API_SEND_NOTIF, Network.paramsNotify(me, someone));
  }

  void _apiSearchMembers(String keyword) {
    setState(() {
      isLoading = true;
    });
    DBService.searchMembers(keyword).then((users) => {
          debugPrint(users.length.toString()),
          _resSearchMembers(users),
        });
  }

  _resSearchMembers(List<Member> members) {
    setState(() {
      items = members;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiSearchMembers("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Search",
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontFamily: "Billabong"),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                //#search member
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(7)),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                        hintText: "Search",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                        icon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                        )),
                  ),
                ),

                //#member list
                Expanded(
                    child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, index) {
                    return _itemOfMember(items[index]);
                  },
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _itemOfMember(Member member) {
    return Container(
      height: 90,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70),
                border: Border.all(
                    width: 1.5, color: Color.fromRGBO(193, 53, 132, 1))),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(22.5),
                child: member.img_url.isEmpty
                    ? const Image(
                        image: AssetImage("assets/images/img.png"),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        member.img_url,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      )),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  member.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (member.followed) {
                      _apiUnFollowMember(member);
                    } else {
                      _apiFollowMember(member);
                    }
                  });
                },
                child: Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Center(
                    child: member.followed ? Text("Following") : Text("Follow"),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
