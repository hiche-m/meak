class Message {
  int id;
  String senderId;
  int partyId;
  String time;
  String content;
  int? previousId;
  Message(
      {required this.id,
      required this.senderId,
      required this.partyId,
      required this.time,
      required this.content,
      this.previousId});
}
