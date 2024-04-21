import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/services/db_service.dart';

import '../models/member_model.dart';
import '../models/post_model.dart';
import '../services/http_service.dart';
import '../services/util_service.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;

  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;

  List<Post> items = [];

  Future<void> _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DBService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  _apiLoadFeeds() {
    setState(() {
      isLoading = true;
    });
    DBService.loadFeeds().then((value) => {
          _resLoadFeeds(value),
        });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DBService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });

    var owner = await DBService.getOwner(post.uid);
    sendNotificationToFollowedMember(owner);
  }

  void sendNotificationToFollowedMember(Member someone) async {
    Member me = await DBService.loadMember();
    await Network.POST(Network.API_SEND_NOTIF, Network.NotifyLike(me, someone));
  }

  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Instagram", "Do you want to detele this post?", false);

    if (result) {
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
            _apiLoadFeeds(),
          });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Instagram",
            style: TextStyle(
                color: Colors.black, fontSize: 39, fontFamily: "Billabong")),
        actions: [
          IconButton(
              onPressed: () {
                widget.pageController!.animateToPage(2,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn);
              },
              icon: Icon(Icons.camera_alt))
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                return _itemPost(items[index]);
              })
        ],
      ),
    );
  }

  Widget _itemPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          //user info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: post.img_user.isEmpty
                            ? const Image(
                                image: AssetImage("assets/images/img.png"),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                post.img_user,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullname,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          post.date,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(
                        onPressed: () {
                          _dialogRemovePost(post);
                        },
                        icon: Icon(Icons.more_horiz))
                    : const SizedBox.shrink()
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //like share
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        if (!post.liked) {
                          _apiPostLike(post);
                        } else {
                          _apiPostUnLike(post);
                        }
                      },
                      icon: post.liked
                          ? const Icon(
                              EvaIcons.heart,
                              color: Colors.red,
                            )
                          : const Icon(
                              EvaIcons.heartOutline,
                              color: Colors.black,
                            )),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      EvaIcons.shareOutline,
                    ),
                  ),
                ],
              )
            ],
          ),

          //caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  text: "${post.caption}",
                  style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}
