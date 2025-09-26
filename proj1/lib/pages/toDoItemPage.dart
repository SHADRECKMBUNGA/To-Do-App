

class TodoItem {
  final String id;
  final String text;
  bool isDone;

  TodoItem(this.text, {this.id = '', this.isDone = false});

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      // Support multiple column names: 'title' (your table) or 'text'
      (map['title'] ?? map['text'] ?? '') as String,
      id: (map['id'] ?? '').toString(),
      // Support 'is_complete' (your table), 'is_completed', or 'is_done'
      isDone: (map['is_complete'] ?? map['is_completed'] ?? map['is_done'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': text,
      'is_complete': isDone,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': text,
      'is_complete': isDone,
    };
  }
}
