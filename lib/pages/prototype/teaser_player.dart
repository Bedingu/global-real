import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Player simples para reproduzir um teaser (vídeo curto) a partir de uma URL.
/// Usa video_player + chewie (já presentes no projeto).
class TeaserPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const TeaserPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<TeaserPlayer> createState() => _TeaserPlayerState();
}

class _TeaserPlayerState extends State<TeaserPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _videoController = controller;
      await controller.initialize();
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio == 0
            ? 9 / 16
            : controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFFFC107),
          handleColor: const Color(0xFFFFC107),
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_error) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Não foi possível carregar o vídeo.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else if (_chewieController != null &&
        _videoController!.value.isInitialized) {
      body = Chewie(controller: _chewieController!);
    } else {
      body = const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 15)),
      ),
      body: Center(child: body),
    );
  }
}
