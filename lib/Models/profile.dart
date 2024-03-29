class Profile {
  int? partyId;
  String uid;
  String email;
  String firstName;
  String lastName;
  String provider;
  String? middleName;
  String? pic;
  bool showMiddleName;
  bool firstNameFirst;
  bool isOwner;
  Profile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.provider,
    this.middleName,
    this.partyId,
    this.pic,
    this.showMiddleName = false,
    this.firstNameFirst = true,
    this.isOwner = false,
  });

  toMap() {
    return {
      "partyId": partyId,
      "uid": uid,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "provider": provider,
      "middleName": middleName,
      "pic": pic,
      "showMiddleName": showMiddleName,
      "firstNameFirst": firstNameFirst,
      "isOwner": isOwner,
    };
  }
}
