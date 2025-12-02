class GraphemeToken {
  final String value; // ej. "sh", "a", "k"
  const GraphemeToken(this.value);
  @override
  String toString() => value;
}
