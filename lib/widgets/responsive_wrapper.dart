import 'package:flutter/material.dart';

/// タブレット画面でコンテンツ幅を制限するラッパーウィジェット
/// iPhone では全幅、iPad では中央に maxWidth で制限
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
