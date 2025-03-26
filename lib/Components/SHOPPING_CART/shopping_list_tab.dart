import 'package:flutter/material.dart';
import '../../../Classes/ListItem.dart';

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
        children: [
          Center(
            child: Column(
              children: [
                Column(
                  children: [
                    if (!checked) _buildAddItemTile(),
                    SizedBox(
                      height: 10000,
                      child: 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        
                        child: ListView.builder(
                          
                          shrinkWrap: true,
                          itemCount: shoppingCart.length ,
                          itemBuilder: (context, index) {
                            if (!checked) {
                              print('checked is false');
                            }
                            if (index == shoppingCart.length) {
                              if (!checked) {
                                return _buildAddItemTile();
                              } else {
                                return null;
                              }
                            }

                            final item = shoppingCart[index];
                            print(item);
                            if (!item.checked && !checked) {
                              return _buildShoppingCartItem(item, index);
                            } else if (item.checked && checked) {
                              // return _buildShoppingCartItem(item, index);
                              /*9var divided = item['item'].split(",");
                                      var amount = divided[0].trim().split(" ");
                                      amount = amount[1].split('"');
                                      var ingredient =
                                          divided[1].trim().split(" ");*/
                              return ListTile(
                                title: Row(
                                  children: [
                                    Text("${item.amount} ${item.ingredient}",
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough)),
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
                    ),
                  ],
                ),
              ],
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
                padding: const EdgeInsets.only(left: 20),
                child: Text("Click here to add a new item"),
              ),
            ),
          if (openInput)
            Row(
              children: [
                SizedBox(
                  width: 60,
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
                    width: 190,
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
        ],
      ),
    );
  }

  Widget _buildNewItemInputs() {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: TextFormField(
            controller: newQtntyItemController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Qnty',
            ),
          ),
        ),
        SizedBox(
          width: 190,
          child: TextFormField(
            controller: newItemController,
            focusNode: focusNode,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Item',
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
