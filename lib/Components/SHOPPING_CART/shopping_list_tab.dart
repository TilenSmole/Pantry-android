import 'package:flutter/material.dart';
import '../../Classes/list_item.dart';

// ignore: must_be_immutable
class ShoppingCartView extends StatelessWidget {
  final List<ListItem> shoppingCart;
  final bool openText;
  final bool openInput;
  final TextEditingController newQtntyItemController;
  final TextEditingController newItemController;
  final ScrollController scrollController;
  final FocusNode focusNode;
  final Function openInputTypingField;
  final Function closeTypingField;
  final Function bought;
  final Function delete;
  final String name;
  final bool checked;
  Map<int, TextEditingController> controllersQTY = {};
  Map<int, TextEditingController> controllersITM = {};
  Map<int, FocusNode> focusNodesQTY = {};
  Map<int, FocusNode> focusNodesITM = {};
  Map<int, LayerLink> layerLinks = {};
  LayerLink newLayerController = LayerLink();

  ShoppingCartView({
    required this.shoppingCart,
    required this.openText,
    required this.openInput,
    required this.newQtntyItemController,
    required this.newItemController,
    required this.scrollController,
    required this.focusNode,
    required this.openInputTypingField,
    required this.closeTypingField,
    required this.bought,
    required this.delete,
    required this.name,
    required this.checked,
    required this.controllersQTY,
    required this.controllersITM,
    required this.focusNodesQTY,
    required this.focusNodesITM,
    required this.layerLinks,
    required this.newLayerController,
  });

  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
  scrollDirection: Axis.vertical,
  child: Column(
    mainAxisSize: MainAxisSize.min, // Ensures the column only takes up necessary space
    children: [
      if (!checked) _buildAddItemTile(),
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true, // Important: Allows ListView to take only required space
          physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling conflict
          itemCount: shoppingCart.length,
          itemBuilder: (context, index) {
            final item = shoppingCart[index];

            if (!item.checked && !checked) {
              return _buildShoppingCartItem(item, index);
            } else if (item.checked && checked) {
              return ListTile(
                title: Row(
                  children: [
                    Text("${item.amount} ${item.ingredient}",
                        style: TextStyle(decoration: TextDecoration.lineThrough)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        delete(item.id, index);
                      },
                    ),
                  ],
                ),
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    ],
  ),
);

  }

  Widget _buildAddItemTile() {
    return ListTile(
      title: Row(
        children: [
          if (openText)
            InkWell(
              onTap: () {
                openInputTypingField();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text("Click here to add a new item"),
              ),
            ),
          if (openInput)
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: newQtntyItemController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Qnty',
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: 220,
                      child: CompositedTransformTarget(
                        link: newLayerController,
                        child: GestureDetector(
                          onTap: () {
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: TextFormField(
                            controller: newItemController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Item',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      closeTypingField();
                    },
                    padding: EdgeInsets.only(left: 25),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildShoppingCartItem(ListItem item, int index) {
    return ListTile(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.check_box_outline_blank),
              onPressed: () {
                bought(item.id, index);
              },
            ),
            SizedBox(
              width: 350,
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      controller: controllersQTY[item.id],
                      focusNode: focusNodesQTY[item.id],
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: CompositedTransformTarget(
                      link: layerLinks[item.id]!,
                      child: TextFormField(
                        controller: controllersITM[item.id],
                        focusNode: focusNodesITM[item.id],
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => delete(item.id, index),
              padding: EdgeInsets.only(left: 0),
            ),
          ],
        ),
      ),
    );
  }
}
