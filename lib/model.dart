import 'dart:math';

// 布局实体
class Board {
  final int row;
  final int column;
  int score;

  Board(this.row, this.column);

  List<List<Tile>> _boardTiles;

  void initBoard() {
    _boardTiles = List.generate(
      4,
      (r) => List.generate(
        4,
        (c) => Tile(row: r, column: c, value: 0, isNew: false, canMerge: false),
      ),
    );

    score = 0;
    resetCanMerge();

    // 初始化时填充块
    randomEmptyTile();
    randomEmptyTile();
  }

  // 合并左滑
  void moveLeft() {
    if (!canMoveLeft()) {
      return;
    }

    for (int r = 0; r < row; r++) {
      for (int c = 0; c < column; c++) {
        mergeLeft(r, c);
      }
    }
    // 随机填充新的块
    randomEmptyTile();
    resetCanMerge();
  }

  // 合并右滑
  void moveRight() {
    if (!canMoveRight()) {
      return;
    }

    for (int r = 0; r < row; r++) {
      for (int c = column - 2; c >= 0; c--) {
        mergeRight(r, c);
      }
    }
    // 随机填充新的块
    randomEmptyTile();
    resetCanMerge();
  }

  // 合并上滑
  void moveUp() {
    if (!canMoveUp()) {
      return;
    }

    for (int r = 0; r < row; r++) {
      for (int c = 0; c < column; c++) {
        mergeUp(r, c);
      }
    }
    // 随机填充新的块
    randomEmptyTile();
    resetCanMerge();
  }

  // 合并下滑
  void moveDown() {
    if (!canMoveDown()) {
      return;
    }

    for (int r = row - 2; r >= 0; r--) {
      for (int c = 0; c < column; c++) {
        mergeDown(r, c);
      }
    }
    // 随机填充新的块
    randomEmptyTile();
    resetCanMerge();
  }

  // 判断是否可以左滑
  bool canMoveLeft() {
    for (int r = 0; r < row; r++) {
      for (int c = 1; c < column; c++) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c - 1])) {
          return true;
        }
      }
    }
    return false;
  }

  // 判断是否可以右滑
  bool canMoveRight() {
    for (int r = 0; r < row; r++) {
      for (int c = column - 2; c >= 0; c--) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  // 判断是否可以上滑
  bool canMoveUp() {
    for (int r = 1; r < row; r++) {
      for (int c = 0; c < column; c++) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r - 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  // 判断是否可以下滑
  bool canMoveDown() {
    for (int r = row - 2; r >= 0; r--) {
      for (int c = 0; c < column; c++) {
        if (canMerge(_boardTiles[r][c], _boardTiles[r + 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  // 合并左边
  void mergeLeft(int r, int col) {
    while (col > 0) {
      merge(_boardTiles[r][col], _boardTiles[r][col - 1]);
      col--;
    }
  }

  // 合并右边
  void mergeRight(int r, int col) {
    while (col < column - 1) {
      merge(_boardTiles[r][col], _boardTiles[r][col + 1]);
      col++;
    }
  }

  // 合并上
  void mergeUp(int r, int col) {
    while (r > 0) {
      merge(_boardTiles[r][col], _boardTiles[r - 1][col]);
      r--;
    }
  }

  // 合并下
  void mergeDown(int r, int col) {
    while (r < row - 1) {
      merge(_boardTiles[r][col], _boardTiles[r + 1][col]);
      r++;
    }
  }

  // 判断是否可以合并两个块
  bool canMerge(Tile a, Tile b) {
    return !a.canMerge &&
        ((b.isEmpty() && !a.isEmpty()) || (!a.isEmpty() && a == b));
  }

  // 合并两个块
  void merge(Tile a, Tile b) {
    if (!canMerge(a, b)) {
      if (!a.isEmpty() && !b.canMerge) {
        b.canMerge = true;
      }
      return;
    }

    if (b.isEmpty()) {
      b.value = a.value;
      a.value = 0;
    } else if (a == b) {
      b.value = b.value * 2;
      a.value = 0;
      score += b.value;
      b.canMerge = true;
    } else {
      b.canMerge = true;
    }
  }

  bool gameOver() {
    return !canMoveLeft() && !canMoveRight() && !canMoveUp() && !canMoveDown();
  }

  // 获取指定块
  Tile getTile(int row, int column) {
    return _boardTiles[row][column];
  }

  // 填充新的Tile
  void randomEmptyTile() {
    List<Tile> empty = List<Tile>();
    _boardTiles.forEach((rows) {
      empty.addAll(rows.where((tile) => tile.isEmpty()));
    });

    if (empty.isEmpty) {
      return;
    }

    Random rng = Random();
    // for (int i = 0; i < 4; i++) {
    int index = rng.nextInt(empty.length);
    empty[index].value = rng.nextInt(9) == 0 ? 4 : 2;
    empty[index].isNew = true;
    empty.removeAt(index);
    // }
  }

  // 重置所有块的可合并状态
  void resetCanMerge() {
    _boardTiles.forEach((rows) {
      rows.forEach((tile) {
        tile.canMerge = false;
      });
    });
  }
}

// 每个块的实体
class Tile {
  int row, column;
  int value;
  bool canMerge;
  bool isNew;

  Tile({this.row, this.column, this.value = 0, this.canMerge, this.isNew});

  bool isEmpty() => value == 0;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(other) {
    return other is Tile && value == other.value;
  }
}
