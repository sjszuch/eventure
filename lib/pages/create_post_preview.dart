import 'dart:io';

import 'package:flutter/material.dart';

class CreatePostPreview extends StatelessWidget {
  final File? imageFile;
  final String? title;
  final String? description;
  final String? location;
  final String? audience;
  final DateTime? date;
  final TimeOfDay? time;
  final String? author;
  final VoidCallback? onEdit;

  const CreatePostPreview({
    Key? key,
    this.imageFile,
    this.title,
    this.description,
    this.location,
    this.audience,
    this.date,
    this.time,
    this.author,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Event'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  imageFile!,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text('No image selected')),
              ),
            const SizedBox(height: 16),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            if (description != null)
              Text(description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (location != null)
              Text('Location: $location', style: const TextStyle(fontSize: 16)),
            if (audience != null)
              Text('Audience: $audience', style: const TextStyle(fontSize: 16)),
            if (date != null)
              Text(
                'Date: ${date!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 16),
              ),
            if (time != null)
              Text(
                'Time: ${time!.format(context)}',
                style: const TextStyle(fontSize: 16),
              ),
            if (author != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '- $author',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
