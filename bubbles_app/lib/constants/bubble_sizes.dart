class BubbleSize {
  final String name;
  final double radius;
  final int index;
  final double markSize;

  const BubbleSize(this.name, this.radius, this.index, this.markSize);

  static const BubbleSize veryLarge = BubbleSize('Very Large', 1000.0, 5, 400);
  static const BubbleSize large = BubbleSize('Large', 500.0, 6, 300);
  static const BubbleSize medium = BubbleSize('Medium', 250.0, 7, 200);
  static const BubbleSize small = BubbleSize('Small', 100.0, 8, 100);

  static List<BubbleSize> get values => [veryLarge, large, medium, small];

  static double? getSizeMarkByIndex(int index) {
    for (var size in values) {
      if (size.index == index) {
        return size.markSize;
      }
    }
    return null;
  }

  static String getNameByIndex(int index) {
    for (var size in values) {
      if (size.index == index) {
        return size.name;
      }
    }
    throw Exception('Invalid BubbleSize index');
  }
}
