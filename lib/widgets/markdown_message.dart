import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownMessage extends StatelessWidget {
  final String content;
  final bool isUser;
  final TextStyle? textStyle;

  const MarkdownMessage({
    super.key,
    required this.content,
    required this.isUser,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: textStyle ?? TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.4,
        ),
        strong: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        em: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
        code: TextStyle(
          color: isUser ? Colors.white : Colors.black87,
          backgroundColor: isUser 
              ? Colors.white.withOpacity(0.2) 
              : Colors.grey.withOpacity(0.2),
          fontSize: 13,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: isUser 
              ? Colors.white.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        blockquote: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isUser ? Colors.white : Colors.grey,
              width: 3,
            ),
          ),
        ),
        listBullet: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        h1: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        a: TextStyle(
          color: isUser ? Colors.lightBlue : Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.parse(href);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
    );
  }
}
