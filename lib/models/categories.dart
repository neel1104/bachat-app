import 'package:flutter/material.dart';

class CategoryModel {
  final String val;
  IconData? iconData = Icons.payment;

  CategoryModel({required this.val, this.iconData});
}

class CategoryService {
  List<CategoryModel> _categories = [];

  CategoryService(){
    // Essentials
    _categories.add(CategoryModel(val: "groceries", iconData: Icons.shopping_cart));
    _categories.add(CategoryModel(val: "rent", iconData: Icons.house));
    _categories.add(CategoryModel(val: "utilities", iconData: Icons.payment));
    _categories.add(CategoryModel(val: "transportation", iconData: Icons.train));
    _categories.add(CategoryModel(val: "insurance", iconData: Icons.payment));
    // Lifestyle
    _categories.add(CategoryModel(val: "dining_out", iconData: Icons.restaurant));
    _categories.add(CategoryModel(val: "entertainment", iconData: Icons.confirmation_num));
    _categories.add(CategoryModel(val: "shopping", iconData: Icons.shopping_bag));
    _categories.add(CategoryModel(val: "fitness", iconData: Icons.fitness_center));
    // Financial Obligations
    _categories.add(CategoryModel(val: "payments", iconData: Icons.payment));
    _categories.add(CategoryModel(val: "investments", iconData: Icons.savings));
    _categories.add(CategoryModel(val: "taxes", iconData: Icons.payment));
    // Health and Wellness
    _categories.add(CategoryModel(val: "medical", iconData: Icons.medical_services));
    _categories.add(CategoryModel(val: "personal", iconData: Icons.spa));
    // Education and Self-Development
    _categories.add(CategoryModel(val: "tuition", iconData: Icons.self_improvement));
    _categories.add(CategoryModel(val: "courses", iconData: Icons.self_improvement));
    _categories.add(CategoryModel(val: "books", iconData: Icons.book));
    // Travel
    _categories.add(CategoryModel(val: "tickets", iconData: Icons.flight));
    _categories.add(CategoryModel(val: "accommodation"));
    _categories.add(CategoryModel(val: "travel", iconData: Icons.travel_explore));
    // Family and Relationships
    _categories.add(CategoryModel(val: "childcare", iconData: Icons.child_care));
    _categories.add(CategoryModel(val: "family", iconData: Icons.family_restroom));
    _categories.add(CategoryModel(val: "pet", iconData: Icons.pets));
    // misc
    _categories.add(CategoryModel(val: "donations", iconData: Icons.payment));
    _categories.add(CategoryModel(val: "others", iconData: Icons.payment));
  }


}