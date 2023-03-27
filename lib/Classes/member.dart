class Member {
  String uid;
  String name;
  String? pic;
  bool isOwner;
  Member(
      {required this.uid, required this.name, this.pic, this.isOwner = false});
}
