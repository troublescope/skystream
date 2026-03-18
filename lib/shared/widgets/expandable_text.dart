import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 4,
    this.style,
    this.textAlign,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(
              _isExpanded ? 'Show less' : 'Read more',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: (widget.style?.fontSize ?? 14) * 0.9,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
