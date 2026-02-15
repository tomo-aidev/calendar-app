import 'package:flutter/material.dart';
import '../../config/colors.dart';

class TitleInputScreen extends StatefulWidget {
  final String initialValue;
  final List<String> history;

  const TitleInputScreen({
    super.key,
    this.initialValue = '',
    this.history = const [],
  });

  @override
  State<TitleInputScreen> createState() => _TitleInputScreenState();
}

class _TitleInputScreenState extends State<TitleInputScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('タイトルを入力'),
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _controller.text),
            child: const Text(
              '保存',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.warmBrown,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'タイトルを入力してください',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.gold, width: 2),
                ),
              ),
            ),
          ),
          if (widget.history.isNotEmpty) ...[
            Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '入力履歴',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.warmBrown.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.history.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 16,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.history,
                      size: 18,
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                    title: Text(
                      widget.history[index],
                      style: const TextStyle(
                        color: AppColors.warmBrown,
                        fontSize: 14,
                      ),
                    ),
                    dense: true,
                    onTap: () {
                      _controller.text = widget.history[index];
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
