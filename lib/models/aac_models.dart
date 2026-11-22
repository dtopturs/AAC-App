import 'package:flutter/material.dart';

enum ButtonAction { speak, navigate, special }

class ImageAsset {
  final String id;
  final String path;

  const ImageAsset({required this.id, required this.path});

  factory ImageAsset.fromJson(Map<String, dynamic> json) {
    return ImageAsset(id: json['id'] as String, path: json['path'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'path': path};

  ImageAsset copyWith({String? id, String? path}) {
    return ImageAsset(id: id ?? this.id, path: path ?? this.path);
  }
}

class AACButton {
  final String id;
  final String label;
  final String? vocalization;
  final String? imageId;
  final Color? backgroundColor;
  final ButtonAction action;
  final String? loadBoardId;
  final String? specialAction;

  const AACButton({
    required this.id,
    required this.label,
    this.vocalization,
    this.imageId,
    this.backgroundColor,
    required this.action,
    this.loadBoardId,
    this.specialAction,
  });

  factory AACButton.fromJson(Map<String, dynamic> json) {
    return AACButton(
      id: json['id'] as String,
      label: json['label'] as String,
      vocalization: json['vocalization'] as String?,
      imageId: json['imageId'] as String?,
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'] as int)
          : null,
      action: ButtonAction.values.byName(json['action'] as String),
      loadBoardId: json['loadBoardId'] as String?,
      specialAction: json['specialAction'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    if (vocalization != null) 'vocalization': vocalization,
    if (imageId != null) 'imageId': imageId,
    if (backgroundColor != null) 'backgroundColor': backgroundColor!.value,
    'action': action.name,
    if (loadBoardId != null) 'loadBoardId': loadBoardId,
    if (specialAction != null) 'specialAction': specialAction,
  };

  AACButton copyWith({
    String? id,
    String? label,
    String? vocalization,
    String? imageId,
    Color? backgroundColor,
    ButtonAction? action,
    String? loadBoardId,
    String? specialAction,
  }) {
    return AACButton(
      id: id ?? this.id,
      label: label ?? this.label,
      vocalization: vocalization ?? this.vocalization,
      imageId: imageId ?? this.imageId,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      action: action ?? this.action,
      loadBoardId: loadBoardId ?? this.loadBoardId,
      specialAction: specialAction ?? this.specialAction,
    );
  }
}

class Board {
  final String id;
  final String name;
  final List<List<String?>> order; // [row][col] → buttonId or null
  final Map<String, AACButton> buttons;

  const Board({
    required this.id,
    required this.name,
    required this.order,
    required this.buttons,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order'] as List<dynamic>;
    final order = orderJson
        .map((row) => (row as List<dynamic>).map((e) => e as String?).toList())
        .toList();

    final buttonsJson = json['buttons'] as Map<String, dynamic>;
    final buttons = buttonsJson.map(
      (key, value) =>
          MapEntry(key, AACButton.fromJson(value as Map<String, dynamic>)),
    );

    return Board(
      id: json['id'] as String,
      name: json['name'] as String,
      order: order,
      buttons: buttons,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
    'buttons': buttons.map((key, value) => MapEntry(key, value.toJson())),
  };

  Board copyWith({
    String? id,
    String? name,
    List<List<String?>>? order,
    Map<String, AACButton>? buttons,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      buttons: buttons ?? this.buttons,
    );
  }

  AACButton? buttonAt(int row, int col) {
    if (row < 0 || row >= order.length) return null;
    if (col < 0 || col >= order[row].length) return null;
    final id = order[row][col];
    return id == null ? null : buttons[id];
  }
}

class AACData {
  final int gridRows;
  final int gridColumns;
  final String rootBoardId;
  final Map<String, Board> boards;
  final Map<String, ImageAsset>? images;

  const AACData({
    required this.gridRows,
    required this.gridColumns,
    required this.rootBoardId,
    required this.boards,
    this.images,
  });

  factory AACData.fromJson(Map<String, dynamic> json) {
    final boardsJson = json['boards'] as Map<String, dynamic>;
    final boards = boardsJson.map(
      (key, value) =>
          MapEntry(key, Board.fromJson(value as Map<String, dynamic>)),
    );

    Map<String, ImageAsset>? images;
    if (json['images'] != null) {
      final imagesJson = json['images'] as Map<String, dynamic>;
      images = imagesJson.map(
        (key, value) =>
            MapEntry(key, ImageAsset.fromJson(value as Map<String, dynamic>)),
      );
    }

    return AACData(
      gridRows: json['gridRows'] as int,
      gridColumns: json['gridColumns'] as int,
      rootBoardId: json['rootBoardId'] as String,
      boards: boards,
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
    'gridRows': gridRows,
    'gridColumns': gridColumns,
    'rootBoardId': rootBoardId,
    'boards': boards.map((key, value) => MapEntry(key, value.toJson())),
    if (images != null)
      'images': images!.map((key, value) => MapEntry(key, value.toJson())),
  };

  AACData copyWith({
    int? gridRows,
    int? gridColumns,
    String? rootBoardId,
    Map<String, Board>? boards,
    Map<String, ImageAsset>? images,
  }) {
    return AACData(
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
      rootBoardId: rootBoardId ?? this.rootBoardId,
      boards: boards ?? this.boards,
      images: images ?? this.images,
    );
  }

  Board? get rootBoard => boards[rootBoardId];
  Board? boardById(String id) => boards[id];
}

class AACNavigator {
  final AACData data;

  String _currentBoardId;
  final List<String> _history = [];

  AACNavigator(this.data) : _currentBoardId = data.rootBoardId;

  Board get currentBoard => data.boards[_currentBoardId]!;

  String get currentBoardId => _currentBoardId;

  bool get canGoBack => _history.isNotEmpty;

  void goTo(String boardId) {
    if (!data.boards.containsKey(boardId)) return;
    if (boardId == _currentBoardId) return;

    _history.add(_currentBoardId);
    _currentBoardId = boardId;
  }

  void goBack() {
    if (_history.isEmpty) return;
    _currentBoardId = _history.removeLast();
  }

  void goHome() {
    if (_currentBoardId == data.rootBoardId) return;
    _history.clear();
    _currentBoardId = data.rootBoardId;
  }

  void handleSpecial(String? specialAction) {
    switch (specialAction) {
      case 'home':
        goHome();
        break;
      case 'back':
        goBack();
        break;
    }
  }
}
