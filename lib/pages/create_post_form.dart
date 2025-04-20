import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_post_preview.dart';

class CreatePostForm extends StatefulWidget {
  final File image;
  final File originalImage;
  final List overlays;
  final Map<String, dynamic> initialFormData;

  const CreatePostForm({
    Key? key,
    required this.image,
    required this.originalImage,
    required this.overlays,
    required this.initialFormData,
  }) : super(key: key);

  @override
  _CreatePostFormState createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedAudience = 'Everyone';

  final List<String> _audiences = [
    'Everyone',
    'Friends',
    'Close Friends',
    'Circle: Book Club',
    '➕ New Circle',
  ];

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(
      text: widget.initialFormData['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialFormData['description'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialFormData['location'] ?? '',
    );
    _selectedAudience = widget.initialFormData['audience'] ?? 'Everyone';
    _selectedDate = widget.initialFormData['date'];
    _selectedTime = widget.initialFormData['time'];
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select both date and time')),
        );
        return;
      }

      final eventData = {
        'title': _eventNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'audience': _selectedAudience,
        'date': DateFormat.yMMMd().format(_selectedDate!),
        'time': _selectedTime!.format(context),
        'author': 'You',
        'image': widget.image.path,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => CreatePostPreview(
                eventData: eventData,
                imageFile: widget.image,
                onEdit: () {
                  Navigator.pop(context, {
                    'image': widget.originalImage,
                    'overlays': widget.overlays,
                    'formData': {
                      'title': _eventNameController.text,
                      'description': _descriptionController.text,
                      'location': _locationController.text,
                      'audience': _selectedAudience,
                      'date': _selectedDate,
                      'time': _selectedTime,
                    },
                  });
                },
                onConfirm:
                    () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
              ),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter event name'
                            : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter description'
                            : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Event Location'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter location'
                            : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedAudience,
                items:
                    _audiences.map((audience) {
                      return DropdownMenuItem(
                        value: audience,
                        child: Text(audience),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() {
                      _selectedAudience = value!;
                    }),
                decoration: InputDecoration(labelText: 'Who can come?'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Pick a date'
                          : DateFormat.yMMMd().format(_selectedDate!),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Select Date'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'Pick a time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: Text('Select Time'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: Text('Post Event')),
            ],
          ),
        ),
      ),
    );
  }
}
