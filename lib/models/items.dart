class ListItem {
  late int id;
  late int idList;
  late String name;
  late String quantity;
  late String note;

  ListItem(this.id, this.idList, this.name, this.quantity, this.note);

  Map<String, dynamic> toMap() {
    return {
      'id': (id==0)?null: id,
      'idList': idList,
      'name': name,
      'quantity': quantity,
      'note': note
    };
  }
}