import 'dart:io';
import 'package:flutter/material.dart';
import 'create_post_preview.dart';

class CreatePostForm extends StatefulWidget {
  final File image;
  final File originalImage;
  final List overlays;
  final Map<String, dynamic> initialFormData;

  const CreatePostForm({
    required this.image,
    required this.originalImage,
    required this.overlays,
    required this.initialFormData,
    Key? key,
  }) : super(key: key);

  @override
  _CreatePostFormState createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  String audience = 'Everyone';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.initialFormData['title'],
    );
    descriptionController = TextEditingController(
      text: widget.initialFormData['description'],
    );
    locationController = TextEditingController(
      text: widget.initialFormData['location'],
    );
    audience = widget.initialFormData['audience'];
    selectedDate = widget.initialFormData['date'];
    selectedTime = widget.initialFormData['time'];
  }

  void _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDate = date;
      selectedTime = time;
    });
  }

  void _goToPreview() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date and time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CreatePostPreview(
              imageFile: widget.image,
              title: titleController.text,
              description: descriptionController.text,
              location: locationController.text,
              audience: audience,
              date: selectedDate!,
              time: selectedTime!,
              author: "Author Name",
              onEdit: () {
                Navigator.pop(context, {
                  'image': widget.originalImage,
                  'overlays': widget.overlays,
                  'formData': {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'location': locationController.text,
                    'audience': audience,
                    'date': selectedDate,
                    'time': selectedTime,
                  },
                });
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: audience,
              items:
                  ['Everyone', 'Friends', 'Close Friends']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
              onChanged: (value) => setState(() => audience = value!),
              decoration: InputDecoration(labelText: 'Who Can Come'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                selectedDate == null || selectedTime == null
                    ? 'Select Date & Time'
                    : '${selectedDate!.toLocal().toString().split(' ')[0]} @ ${selectedTime!.format(context)}',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.arrow_forward),
              label: Text('Continue to Preview'),
              onPressed: _goToPreview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
