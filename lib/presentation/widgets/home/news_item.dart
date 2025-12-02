import 'package:flutter/material.dart';

class NewsItem extends StatelessWidget {
  final String title;

  const NewsItem({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading:  Icon(Icons.article,
        color: theme.colorScheme.secondary,
      ),
      title: Text(title,style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 20,
      )),
      subtitle:  Text('Este es un artículo de noticias',style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 18,
      )),
      onTap: () {},
    );
  }
}
