import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController searchController = TextEditingController();

  List<String> searchHistory = [

  ];

  void performSearch(String value) {
    if (value.isEmpty) return;

    setState(() {
      searchHistory.remove(value);
      searchHistory.insert(0, value);

      if (searchHistory.length > 5) {
        searchHistory.removeLast();
      }
      searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onSubmitted: performSearch,
                        decoration: const InputDecoration(
                          hintText: "Search medicines, doctors...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => performSearch(searchController.text),
                      icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// SEARCH HISTORY
              const Text(
                "Search History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: searchHistory.map((item) {
                  return ActionChip(
                    label: Text(item),
                    avatar: const Icon(Icons.history, size: 16, color: Colors.blue),
                    onPressed: () => searchController.text = item,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}