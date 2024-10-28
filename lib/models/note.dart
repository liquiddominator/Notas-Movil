class Note {
  final int? id;
  final String title;
  final String content;
  final String dateCreated;
  final int userId;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateCreated': dateCreated,
      'userId': userId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      dateCreated: map['dateCreated'],
      userId: map['userId'],
    );
  }
}