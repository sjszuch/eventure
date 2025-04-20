import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class CreatePostPreview extends StatefulWidget {
  final Map<String, String> eventData;
  final File imageFile;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  CreatePostPreview({
    required this.eventData,
    required this.imageFile,
    required this.onEdit,
    required this.onConfirm,
  });

  @override
  _CreatePostPreviewState createState() => _CreatePostPreviewState();
}

class _CreatePostPreviewState extends State<CreatePostPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _confirmPost() {
    _confettiController.play();
    Future.delayed(Duration(seconds: 2), () {
      widget.onConfirm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = _controller.value * pi;
    final isBack = _controller.value >= 0.5;
    return Scaffold(
      appBar: AppBar(title: Text('Preview'), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleFlip,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final transform =
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle);
                    return Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child:
                          isBack ? _buildBack(context) : _buildFront(context),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: widget.onEdit,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                    ),
                    child: Icon(Icons.edit),
                  ),
                  SizedBox(width: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: -pi / 2,
                        emissionFrequency: 0.6,
                        numberOfParticles: 20,
                        maxBlastForce: 10,
                        minBlastForce: 5,
                        shouldLoop: false,
                      ),
                      ElevatedButton(
                        onPressed: _confirmPost,
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Icon(Icons.check),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        widget.imageFile,
        key: ValueKey(widget.imageFile.path),
        width: 300,
        height: 500,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      width: 300,
      height: 500,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.eventData['title'] ?? '',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "${widget.eventData['date']} @ ${widget.eventData['time']}",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            widget.eventData['location'] ?? '',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.eventData['description'] ?? '',
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "- ${widget.eventData['author'] ?? ''}",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
