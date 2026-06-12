import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/exercise.dart';
import '../providers/exercise_provider.dart';

class CategoryScreen extends StatelessWidget {
  final Category category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Sıfırla'),
          ),
        ],
      ),
      body: Consumer<ExerciseProvider>(
        builder: (context, provider, _) {
          final exercises = provider.forCategory(category.id!);
          if (exercises.isEmpty) {
            return const Center(
              child: Text('Henüz hareket eklenmedi.\nAşağıdaki + ile ekle.'),
            );
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) =>
                _ExerciseTile(exercise: exercises[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sıfırla'),
        content: Text('"${category.name}" kategorisindeki tüm tickler sıfırlansın mı?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExerciseProvider>().resetCategory(category.id!);
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hareket Ekle',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Hareket adı'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: weightCtrl,
              decoration: const InputDecoration(labelText: 'Kilo (kg)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final weight = double.tryParse(weightCtrl.text.trim()) ?? 0;
                if (name.isEmpty) return;
                context
                    .read<ExerciseProvider>()
                    .add(name, weight, category.id!);
                Navigator.pop(ctx);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatefulWidget {
  final Exercise exercise;
  const _ExerciseTile({required this.exercise});

  @override
  State<_ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<_ExerciseTile> {
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
        text: widget.exercise.weight.toString());
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    return Dismissible(
      key: ValueKey(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (e.id == null) return;
        context.read<ExerciseProvider>().delete(e.id!);
      },
      child: ListTile(
        leading: Checkbox(
          value: e.isDone,
          onChanged: (_) =>
              context.read<ExerciseProvider>().toggleDone(e),
        ),
        title: Text(
          '${e.name} / ${e.weight} kg',
          style: e.isDone
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                )
              : null,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(context, e),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Exercise e) {
    _weightCtrl.text = e.weight.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(e.name),
        content: TextField(
          controller: _weightCtrl,
          decoration: const InputDecoration(labelText: 'Yeni kilo (kg)'),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final w = double.tryParse(_weightCtrl.text.trim());
              if (w == null) return;
              context.read<ExerciseProvider>().updateWeight(e, w);
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
