import "package:flutter/material.dart";
import 'package:runo_music/Widgets/messenger.dart';
import 'package:audioplayers/audioplayers.dart';

import '../Data/fetch_data.dart';

class favouriteItemsProvider extends ChangeNotifier {
  Map<String, List<dynamic>> favourite_items = new Map();

  void addToFavourite({required String id, required List<dynamic> details}) {
    favourite_items[id] = details;
    notifyListeners();
  }

  void removeFromFavourite({required String id}) {
    favourite_items.remove(id);
    print(favourite_items);
    notifyListeners();
  }

  bool checkInFav({required String id}) {
    if (favourite_items.containsKey(id)) return true;
    return false;
  }

  void toggleFavourite({ required String id, required List<
      dynamic> details, required BuildContext context}) {
    if (checkInFav(id: id)) {
      removeFromFavourite(id: id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: removedSnackbarContent()),
      );
    } else {
      addToFavourite(id: id, details: details);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: addedSnackbarContent()),
      );
    }
  }
}



class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<dynamic> _items = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoop = false;
  bool _isLoading = false;
  double _volume = 1.0;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  bool openMiniPlayer = false;

  void setminiplayer()
  {
    openMiniPlayer = true;
    notifyListeners();
  }

  // Getters
  List<dynamic> get items => _items;

  int get currentIndex => _currentIndex;

  bool get isPlaying => _isPlaying;

  bool get isLoop => _isLoop;

  bool get isLoading => _isLoading;

  double get volume => _volume;

  Duration get currentPosition => _currentPosition;

  Duration get duration => _duration;

  // Current Track Details
  String? get trackId => _items.isNotEmpty ? _items[_currentIndex][0] : null;

  String? get trackName => _items.isNotEmpty ? _items[_currentIndex][1] : null;

  String? get trackImageUrl =>
      _items.isNotEmpty ? _items[_currentIndex][2] : null;

  String? get artistId => _items.isNotEmpty ? _items[_currentIndex][3] : null;

  String? get artistName => _items.isNotEmpty ? _items[_currentIndex][4] : null;

  String? get albumId => _items.isNotEmpty ? _items[_currentIndex][5] : null;

  String? get albumName => _items.isNotEmpty ? _items[_currentIndex][6] : null;

  AudioProvider() {
    _initializePlayer();
  }

  void _initializePlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((Duration d) {
      _duration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      _currentPosition = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_isLoop) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.resume();
      } else {
        nextTrack();
      }
    });
  }

  Future<void> loadAudio({required List<dynamic> trackList,required int index}) async {
    _items = trackList;
    _currentIndex = index;
    _isLoading = true;
    notifyListeners();

    await _playCurrentTrack();
  }

  Future<void> _playCurrentTrack() async {
    if (_items.isEmpty) return;

    final track = _items[_currentIndex];
    final trackId = track[0];
    final urlData = await fetchData(path: 'tracks/$trackId');
    final previewUrl = urlData['tracks'][0]['previewURL'];

    try {
      await _audioPlayer.setSourceUrl(previewUrl);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.resume();
      _isPlaying = true;
    } catch (e) {
      print("Error playing audio: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void seekTo(double value) {
    final newPosition = Duration(
        milliseconds: (_duration.inMilliseconds * value).round());
    _audioPlayer.seek(newPosition);
  }

  Future<void> nextTrack() async {
    if (_currentIndex < _items.length - 1) {
      _currentIndex++;
      _isLoading = true;
      notifyListeners();
      await _playCurrentTrack();
    }
  }

  Future<void> previousTrack() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _isLoading = true;
      notifyListeners();
      await _playCurrentTrack();
    }
  }

  void toggleLoop() {
    _isLoop = !_isLoop;
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    _audioPlayer.setVolume(_volume);
    notifyListeners();
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
