import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'product_model.dart';

class ProductApp extends StatefulWidget {
  const ProductApp({super.key});

  @override
  State<ProductApp> createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  List<String> category = [
    'All',
    'jewelary',
    'laptops',
    'Smart Phones',
    "Men's Clothing",
    "Women's Clothing"
  ];
  String selectCat = "All";
  List<Model> models = [];
  bool isLoading = true;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchApi();
  }

  Future<void> fetchApi() async {
    final response = await http.get(Uri.parse("https://fakestoreapi.com/products"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        models = data.map((json) => Model.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load products");
    }
  }

  void addToCart(int productId) {
    setState(() {
      models = models.map((model) {
        if (model.id == productId) {
          model.addedToCart = true;
          totalPrice += model.price;
        }
        return model;
      }).toList();
    });
  }

  void removeFromCart(int productId) {
    setState(() {
      models = models.map((model) {
        if (model.id == productId) {
          model.addedToCart = false;
          totalPrice -= model.price;
        }
        return model;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Total: ₨ ${totalPrice.toStringAsFixed(2)}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
          )
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Row(
        children: [
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: category.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(category[index]),
                  selected: category[index] == selectCat,
                  onTap: () {
                    setState(() {
                      selectCat = category[index];
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.40,
                      ),
                      itemCount: models.length,
                      itemBuilder: (context, index) {
                        if (selectCat != "All" && models[index].category != selectCat) {
                          return SizedBox.shrink();
                        }
                        return Card(
                          elevation: 4,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: Get.height/5,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: models[index].image,
                                fit: BoxFit.fill,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                models[index].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${models[index].price}',
                              style: TextStyle(color: Colors.green, fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 15,
                                    ),
                                  ),
                                  Text(
                                    "${models[index].rating.rate}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "(${models[index].rating.count} Ratings)",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Get.height/80,),
                            Container(
                              width: Get.width,
                              height: 40,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: models[index].addedToCart ? Colors.red : Colors.blue,

                              ),
                              child: InkWell(
                                onTap: () {
                                  if (models[index].addedToCart) {
                                    removeFromCart(models[index].id);
                                  } else {
                                    addToCart(models[index].id);
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    models[index].addedToCart ? 'Remove' : 'Add to Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
