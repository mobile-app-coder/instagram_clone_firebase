import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../models/post_model.dart';

class MyFeedPage extends StatefulWidget {
  final PageController? pageController;

  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;

  List<Post> items = [
    Post("shahriyor turayev flutter and native android developer",
        "https://images.unsplash.com/photo-1712262825783-c0b5ef123959?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwxNnx8fGVufDB8fHx8fA%3D%3D",),

  ];

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
                                image:
                                    AssetImage("assets/images/img.png"),
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
                    ? IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))
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
                        } else {}
                      },
                      icon: post.liked
                          ? const Icon(
                              EvaIcons.heart,
                              color: Colors.red,
                            )
                          : const Icon(
                              EvaIcons.heart,
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
