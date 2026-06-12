import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GYM Tracker'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, _) {
          if (provider.categories.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Henüz kategori yok',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Eklemek için + bas',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) =>
                _CategoryTile(category: provider.categories[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: const Color(0xFFBB86FC),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kategori Ekle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Kategori adı (örn: Omuz)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFBB86FC)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFBB86FC)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isEmpty) return;
                context.read<CategoryProvider>().add(name);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        if (category.id == null) return;
        context.read<CategoryProvider>().delete(category.id!);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            category.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryScreen(category: category),
            ),
          ),
        ),
      ),
    );
  }
}
