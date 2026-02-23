import 'package:flutter/material.dart';
import 'package:side_project/feature/profile/models/post_model.dart';

class PostDetailScreen extends StatelessWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage('https://picsum.photos/200')),
            title: Text('ALEX_VISION', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Hero(
              tag: post.id,
              child: PageView.builder(
                itemCount: post.media.length,
                itemBuilder: (context, index) =>
                    InteractiveViewer(child: Image.network(post.media[index], fit: BoxFit.contain)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 30),
                SizedBox(width: 20),
                Icon(Icons.chat_bubble_outline, size: 30),
                Spacer(),
                Icon(Icons.bookmark_border, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
