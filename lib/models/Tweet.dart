import 'package:flutter/material.dart';

class Tweet {
  String id;
  String pubkey;
  String userFirstName;
  String userUserName;
  String userProfilePic;
  String content;
  List<String> imageLinks;
  int tweetedAt;
  int likesCount;
  int commentsCount;
  int retweetsCount;
  List<dynamic> tags;
  List<dynamic> replies;
  bool isReply = false;

  Tweet(
      {required this.id,
      required this.pubkey,
      required this.userFirstName,
      required this.userUserName,
      required this.userProfilePic,
      required this.content,
      required this.imageLinks,
      required this.tweetedAt,
      required this.tags,
      required this.likesCount,
      required this.commentsCount,
      required this.retweetsCount,
      required this.replies,
      this.isReply = false});

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
        id: json['id'],
        pubkey: json['pubkey'],
        userFirstName: json['userFirstName'],
        userUserName: json['userUserName'],
        userProfilePic: json['userProfilePic'],
        content: json['tweet'],
        imageLinks: json['imageLinks'].cast<String>(),
        tweetedAt: json['tweetedAt'],
        tags: json['tags'],
        replies: json['replies'],
        likesCount: json['likesCount'],
        commentsCount: json['commentsCount'],
        retweetsCount: json['retweetsCount'],
        isReply: json['isReply']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pubkey': pubkey,
        'userFirstName': userFirstName,
        'userUserName': userUserName,
        'userProfilePic': userProfilePic,
        'tweet': content,
        'imageLinks': imageLinks,
        'tweetedAt': tweetedAt,
        'tags': tags,
        'replies': replies,
        'likesCount': likesCount,
        'commentsCount': commentsCount,
        'retweetsCount': retweetsCount,
        'isReply': isReply
      };
}

List tweets = [
  Tweet(
    id: '1',
    pubkey: "pubkey",
    userFirstName: 'Lute',
    userUserName: 'Lute100',
    userProfilePic: 'assets/images/profile.webp',
    content: 'I still don\'t understand why... lorem ipsum',
    imageLinks: ['assets/images/content.png'],
    tweetedAt: 0,
    tags: [],
    replies: [],
    likesCount: 2,
    commentsCount: 3,
    retweetsCount: 5,
  ),
  Tweet(
      id: '2',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/profile.webp',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/CaptainJackSparrow.jpg'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '3',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/profile.webp',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: [],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '4',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '5',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '6',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '7',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '8',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '9',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
  Tweet(
      id: '10',
      pubkey: "pubkey",
      userFirstName: 'Lute',
      userUserName: 'Lute100',
      userProfilePic: 'assets/images/CaptainJackSparrow.jpg',
      content: 'I still don\'t understand why... lorem ipsum',
      imageLinks: ['assets/images/content.png'],
      tweetedAt: 0,
      tags: [],
      replies: [],
      likesCount: 2,
      commentsCount: 3,
      retweetsCount: 5),
];
