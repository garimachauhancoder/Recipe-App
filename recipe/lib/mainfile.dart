import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(RecipeApp());
}

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<dynamic>> _recommendedRecipes;

  Future<List<dynamic>> fetchRecommendedRecipes() async {
    final response = await http.get(Uri.parse(
        'https://api.edamam.com/search?q=popular&app_id=914d341a&app_key=a9f11ff89d0431ebe5bdecbbbf1d16c9'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['hits'];
    } else {
      throw Exception('Failed to load recommended recipes');
    }
  }

  void _searchRecipes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeListScreen(searchTerm: _controller.text),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _recommendedRecipes = fetchRecommendedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Finder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter recipe name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchRecipes,
              child: Text('Search'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Recommended Recipes',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recommendedRecipes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final recipes = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      padding: EdgeInsets.all(8.0),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index]['recipe'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    recipe['image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        recipe['label'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${recipe['calories'].toStringAsFixed(0)} cal',
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                      Text(
                                        'Time: ${recipe['totalTime']} min',
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  final String searchTerm;

  RecipeListScreen({required this.searchTerm});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<dynamic>> _recipes;

  Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(Uri.parse(
        'https://api.edamam.com/search?q=${widget.searchTerm}&app_id=914d341a&app_key=a9f11ff89d0431ebe5bdecbbbf1d16c9'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['hits'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  void initState() {
    super.initState();
    _recipes = fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes for "${widget.searchTerm}"'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final recipes = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              padding: EdgeInsets.all(8.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index]['recipe'];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            recipe['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                recipe['label'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${recipe['calories'].toStringAsFixed(0)} cal',
                                style: TextStyle(fontSize: 12.0),
                              ),
                              Text(
                                'Time: ${recipe['totalTime']} min',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              recipe['image'],
              height: 200.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              recipe['label'],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              '${recipe['calories'].toStringAsFixed(0)} cal | Time: ${recipe['totalTime']} min',
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: recipe['ingredientLines'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.check),
                    title: Text(recipe['ingredientLines'][index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
