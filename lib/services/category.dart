import 'package:flutter/material.dart';

import 'package:bachat/models/category.dart';

class CategoryService {
  List<Category> _categories = [];

  CategoryService(){
    // Essentials
    _categories.add(Category(val: "groceries", iconData: Icons.shopping_cart));
    _categories.add(Category(val: "rent", iconData: Icons.house));
    _categories.add(Category(val: "utilities", iconData: Icons.payment));
    _categories.add(Category(val: "transportation", iconData: Icons.train));
    _categories.add(Category(val: "insurance", iconData: Icons.payment));
    // Lifestyle
    _categories.add(Category(val: "dining_out", iconData: Icons.restaurant));
    _categories.add(Category(val: "entertainment", iconData: Icons.confirmation_num));
    _categories.add(Category(val: "shopping", iconData: Icons.shopping_bag));
    _categories.add(Category(val: "fitness", iconData: Icons.fitness_center));
    // Financial Obligations
    _categories.add(Category(val: "payments", iconData: Icons.payment));
    _categories.add(Category(val: "investments", iconData: Icons.savings));
    _categories.add(Category(val: "taxes", iconData: Icons.payment));
    // Health and Wellness
    _categories.add(Category(val: "medical", iconData: Icons.medical_services));
    _categories.add(Category(val: "personal", iconData: Icons.spa));
    // Education and Self-Development
    _categories.add(Category(val: "tuition", iconData: Icons.self_improvement));
    _categories.add(Category(val: "courses", iconData: Icons.self_improvement));
    _categories.add(Category(val: "books", iconData: Icons.book));
    // Travel
    _categories.add(Category(val: "tickets", iconData: Icons.flight));
    _categories.add(Category(val: "accommodation", iconData: Icons.hotel));
    _categories.add(Category(val: "travel", iconData: Icons.travel_explore));
    // Family and Relationships
    _categories.add(Category(val: "childcare", iconData: Icons.child_care));
    _categories.add(Category(val: "family", iconData: Icons.family_restroom));
    _categories.add(Category(val: "pet", iconData: Icons.pets));
    // misc
    _categories.add(Category(val: "donations", iconData: Icons.payment));
    _categories.add(Category(val: "others", iconData: Icons.payment));
  }

  List<Category> fetchAll() {
    return _categories;
  }

  Category findByVal(String val){
    return _categories.firstWhere((category) => category.val == val, orElse: () => Category(val: "others", iconData: Icons.payment));
  }
}