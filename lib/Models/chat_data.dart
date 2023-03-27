import "message.dart";

List<Message> data = [
  Message(
    id: 0,
    senderId: "2",
    partyId: 1,
    time: "20221105T151002",
    content: "Hello!",
    previousId: null,
  ),
  Message(
    id: 1,
    senderId: "1",
    partyId: 1,
    time: "20221105T151035",
    content: "Hey what's up?",
    previousId: 0,
  ),
  Message(
    id: 2,
    senderId: "2",
    partyId: 1,
    time: "20221105T151059",
    content: "Not much wby",
    previousId: 1,
  ),
  Message(
    id: 3,
    senderId: "1",
    partyId: 1,
    time: "20221105T151125",
    content: "Just buying some items!",
    previousId: 2,
  ),
  Message(
    id: 4,
    senderId: "0",
    partyId: 1,
    time: "20221105T151310",
    content: "Don't forget milk!",
    previousId: 3,
  ),
];
