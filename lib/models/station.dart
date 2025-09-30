class Station {
  final String name;
  final String url;
  const Station(this.name, this.url);

  // JSON serialization
  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
  };

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      (json['name'] ?? '').toString(),
      (json['url'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Station && runtimeType == other.runtimeType && name == other.name && url == other.url;

  @override
  int get hashCode => Object.hash(name, url);
}
