import 'dart:io';

import 'package:gviz/gviz.dart';

int nextColl(int i) {
  return (i % 2 == 0 ? i / 2 : 3 * i + 1).round();
}

void step(Gviz g, String last, String curr, Map<String, List<String>> edges) {
  if (!edges.containsKey(last)) edges[last] = [];
  if (!g.nodeExists(curr)) g.addNode(curr);
  if (last != '' && !edges[last]!.contains(curr)) {
    g.addEdge(last, curr);
    edges[last]!.add(curr);
  }
}

void collatz(Gviz g, Map<String, List<String>> m, int i) {
  var last = '';
  while (i > 1) {
    final curr = i.toString();
    step(g, last, curr, m);
    last = curr;
    i = nextColl(i);
  }
  step(g, last, '1', m);
}

void main() {
  final g = Gviz();
  final m = <String, List<String>>{};
  for (var i = 0; i < 6000; i++) {
    collatz(g, m, i);
  }
  g.write(stdout);
}
