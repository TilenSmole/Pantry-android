class ListItem {
  int id;
  bool checked;
  int userId;
  String? amount;
  String? ingredient;

  ListItem({
    required this.id,
     required this.checked,
    required this.userId,
    this.amount,
    this.ingredient,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'],
      checked: json['checked'],
      userId: json['userId'],
      amount: json['amount'],
      ingredient: json['ingredient'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checked': checked,
      'userId': userId,
      'amount': amount,
      'ingredient': ingredient,
    };
  }

@override
  String toString() {
    return 'ListItem(id: $id, amount: $amount, ingredient: $ingredient,  userId: $userId)';
  }

}

