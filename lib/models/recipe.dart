import 'package:flutter/material.dart';
import 'ingredient.dart';
import '../utils/constants.dart';

class Recipe {
  final String id;
  final String title;
  final String? description;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final int? preparationTime; // in minutes
  final int? cookingTime; // in minutes
  final int? servings;
  final String? imageUrl;
  final double? rating;
  final String? source;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.ingredients,
    required this.instructions,
    this.preparationTime,
    this.cookingTime,
    this.servings,
    this.imageUrl,
    this.rating,
    this.source,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final dynamic stepsRaw = json['instructions'] ??
        json['steps'] ??
        json['directions'] ??
        json['method'] ??
        json['Hazırlanış'] ??
        json['hazırlanış'] ??
        json['hazirlanis'] ??
        json['hazırlama'];
    List<String> steps = [];
    if (stepsRaw is List) {
      steps = stepsRaw.map((e) => e.toString()).toList();
    } else if (stepsRaw is String) {
      steps = stepsRaw
          .split(RegExp(r'(\r?\n)+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
      title: (json['title'] as String?) ?? 'İsimsiz Tarif',
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient(
                    name: e['name'] as String? ?? '',
                    amount: (e['amount'] as num?)?.toDouble(),
                    unit: e['unit'] as String?,
                    isAvailable: true,
                  ))
              .toList() ??
          [],
      instructions: steps,
      preparationTime: ((json['prepTime'] ?? json['preparationTime']) as int?) ?? AppConstants.defaultPrepTime,
      cookingTime: ((json['cookTime'] ?? json['cookingTime']) as int?) ?? AppConstants.defaultCookTime,
      servings: json['servings'] as int?,
      imageUrl: json['imageUrl'] as String?,
      rating: 0.0, // Default rating
      source: json['cuisine'] as String?, // Using cuisine as source
      isFavorite: false, // Default to not favorite
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      if (preparationTime != null) 'preparationTime': preparationTime,
      if (cookingTime != null) 'cookingTime': cookingTime,
      if (servings != null) 'servings': servings,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (rating != null) 'rating': rating,
      if (source != null) 'source': source,
      'isFavorite': isFavorite,
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    int? preparationTime,
    int? cookingTime,
    int? servings,
    String? imageUrl,
    double? rating,
    String? source,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      preparationTime: preparationTime ?? this.preparationTime,
      cookingTime: cookingTime ?? this.cookingTime,
      servings: servings ?? this.servings,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Helper method to get total time (prep + cooking)
  int? get totalTime {
    if (preparationTime == null && cookingTime == null) return null;
    return (preparationTime ?? 0) + (cookingTime ?? 0);
  }

  // Helper method to format time
  String? get formattedTime {
    if (totalTime == null) return null;
    final hours = totalTime! ~/ 60;
    final minutes = totalTime! % 60;
    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    }
    return '$minutes min';
  }

  // Helper method to get missing ingredients
  List<Ingredient> get missingIngredients {
    return ingredients.where((ingredient) => !ingredient.isAvailable).toList();
  }

  // Helper method to get available ingredients
  List<Ingredient> get availableIngredients {
    return ingredients.where((ingredient) => ingredient.isAvailable).toList();
  }
}
