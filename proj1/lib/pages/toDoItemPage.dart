

class TodoItem {
  final String id;
  final String text;
  bool isDone;

  TodoItem(this.text, {this.id = '', this.isDone = false});

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      map['text'] as String? ?? '',
      id: (map['id'] ?? '').toString(),
      isDone: map['is_done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'text': text,
      'is_done': isDone,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'text': text,
      'is_done': isDone,
    };
  }
}
