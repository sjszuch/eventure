import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'create_post_form.dart';
import 'create_post_preview.dart';

class CreatePostStart extends StatefulWidget {
  final File? initialImage;
  final List<_TextOverlay>? initialOverlays;
  final Map<String, dynamic>? formData;

  CreatePostStart({this.initialImage, this.initialOverlays, this.formData});

  @override
  _CreatePostStartState createState() => _CreatePostStartState();
}

class _CreatePostStartState extends State<CreatePostStart>
    with TickerProviderStateMixin {
  File? _image;
  List<_TextOverlay> _textOverlays = [];
  Map<String, dynamic> _formData = {
    'title': '',
    'description': '',
    'location': '',
    'audience': 'Everyone',
    'date': null,
    'time': null,
  };

  final _picker = ImagePicker();
  Offset? _draggingPosition;
  _TextOverlay? _draggingOverlay;
  final GlobalKey _flyerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _image = widget.initialImage;
    } else {
      _pickImage();
    }
    _textOverlays = widget.initialOverlays ?? [];
    if (widget.formData != null) {
      _formData = widget.formData!;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _addTextOverlay() {
    setState(() {
      _textOverlays.add(
        _TextOverlay(text: 'Tap to edit', offset: Offset(100, 100)),
      );
    });
  }

  Future<void> _navigateToNext() async {
    if (_image == null) return;

    try {
      RenderRepaintBoundary boundary =
          _flyerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image flyerImage = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await flyerImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      final buffer = byteData!.buffer;
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/edited_flyer_${DateTime.now().millisecondsSinceEpoch}.png';
      final renderedFile = await File(filePath).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );

      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => CreatePostForm(
                key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                image: renderedFile,
                originalImage: _image!,
                overlays: _textOverlays,
                initialFormData: _formData,
              ),
        ),
      );

      if (result is Map &&
          result.containsKey('image') &&
          result.containsKey('overlays') &&
          result.containsKey('formData')) {
        setState(() {
          _image = result['image'];
          _textOverlays = List<_TextOverlay>.from(result['overlays']);
          _formData = result['formData'];
        });

        await Future.delayed(Duration(milliseconds: 300));
        _navigateToNext();
      }
    } catch (e) {
      print("Error rendering flyer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final trashZone = MediaQuery.of(context).size.height - 120;

    return Scaffold(
      body:
          _image == null
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: Container(
                  width: 300,
                  height: 500,
                  child: RepaintBoundary(
                    key: _flyerKey,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                        ),
                        ..._textOverlays.map(
                          (overlay) => Positioned(
                            left: overlay.offset.dx,
                            top: overlay.offset.dy,
                            child: Draggable<_TextOverlay>(
                              data: overlay,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildOverlayText(overlay.text),
                              ),
                              childWhenDragging: Container(),
                              onDragStarted: () {
                                setState(() {
                                  _draggingOverlay = overlay;
                                });
                              },
                              onDraggableCanceled: (_, offset) {
                                if (_draggingOverlay != null &&
                                    _draggingPosition != null) {
                                  setState(() {
                                    if (_draggingPosition!.dy > trashZone) {
                                      _textOverlays.remove(_draggingOverlay);
                                    } else {
                                      final renderBox =
                                          context.findRenderObject()
                                              as RenderBox;
                                      final localOffset = renderBox
                                          .globalToLocal(offset);
                                      final containerOffset = Offset(
                                        localOffset.dx -
                                            (MediaQuery.of(context).size.width -
                                                    300) /
                                                2,
                                        localOffset.dy -
                                            (MediaQuery.of(
                                                      context,
                                                    ).size.height -
                                                    500) /
                                                2,
                                      );
                                      _draggingOverlay!.offset =
                                          containerOffset;
                                    }
                                    _draggingOverlay = null;
                                  });
                                }
                              },
                              onDragUpdate: (details) {
                                setState(() {
                                  _draggingPosition = details.globalPosition;
                                });
                              },
                              child: GestureDetector(
                                onTap: () async {
                                  final newText = await _editTextDialog(
                                    context,
                                    overlay.text,
                                  );
                                  if (newText != null) {
                                    setState(() {
                                      overlay.text = newText;
                                    });
                                  }
                                },
                                child: _buildOverlayText(overlay.text),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'add_text',
              mini: true,
              onPressed: _addTextOverlay,
              child: Icon(Icons.text_fields),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              heroTag: 'next',
              onPressed: _navigateToNext,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index != 2) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildOverlayText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 24,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    );
  }

  Future<String?> _editTextDialog(
    BuildContext context,
    String currentText,
  ) async {
    TextEditingController controller = TextEditingController(text: currentText);
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Text'),
            content: TextField(controller: controller, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text('Save'),
              ),
            ],
          ),
    );
  }
}

class _TextOverlay {
  String text;
  Offset offset;

  _TextOverlay({required this.text, required this.offset});
}
