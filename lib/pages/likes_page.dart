import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/db_service.dart';
import '../services/util_service.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  bool isLoading = false;
  List<Post> items = [];

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DBService.loadLikes().then((value) => {
          _resLoadPost(value),
        });
  }


  _dialogRemovePost(Post post) async {
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to detele this post?", false);

    if (result) {
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        _apiLoadLikes(),
      });
    }
  }

  void _resLoadPost(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DBService.likePost(post, false);
    _apiLoadLikes();
  }

  @override
  void initState() {
    super.initState();
    _apiLoadLikes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _itemOfPost(items[index]);
            },
          )
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          //#user info
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
                              image: AssetImage(
                                "assets/images/img.png",
                              ),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover)
                          : Image.network(
                              post.img_user,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fullname,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          post.date,
                          style: TextStyle(fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ],
                ),
                post.mine
                    ? IconButton(onPressed: () {
                      _dialogRemovePost(post);
                }, icon: Icon(Icons.more_horiz))
                    : SizedBox.shrink()
              ],
            ),
          ),

          //#post image
          CachedNetworkImage(
            imageUrl: post.img_post,
            width: MediaQuery.of(context).size.width,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),

          //#like share
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _apiPostUnLike(post);
                        });
                      },
                      icon: post.liked
                          ? Icon(
                              EvaIcons.heart,
                              color: Colors.red,
                            )
                          : Icon(
                              EvaIcons.heartOutline,
                              color: Colors.black,
                            )),
                  IconButton(onPressed: () {

                  }, icon: const Icon(EvaIcons.share))
                ],
              )
            ],
          ),

          //#caption
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: RichText(
              overflow: TextOverflow.visible,
              softWrap: true,
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
