enum Algorithm {
  unionFind('unionfind'),
  bfs('bfs');

  final String name;

  const Algorithm(this.name);

  factory Algorithm.fromName(String name) {
    switch (name) {
      case 'unionfind':
        return unionFind;
      case 'bfs':
        return bfs;
      default:
        throw Exception('Invalid algorithm name');
    }
  }
}
