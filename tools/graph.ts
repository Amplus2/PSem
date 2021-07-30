import * as path from "https://deno.land/std/path/mod.ts";
import * as gviz from "https://deno.land/x/graphviz/mod.ts";

function CollatzStep(i: number) {
  return i % 2 == 0 ? i / 2 : 3 * i + 1;
}

function graphStep(
  graph: gviz.Digraph,
  last: string,
  current: string,
  edges: Map<string, string[]>,
) {
  if (!edges.has(last)) edges.set(last, []);
  if (!graph.existNode(current)) graph.createNode(current);
  if (last != '' && !edges.get(last)!.includes(current)) {
    const a = graph.getNode(last);
    const b = graph.getNode(current);
    // console.log(a);
    // console.log(b);
    graph.createEdge([a!, b!]);
    edges.get(last)!.push(current);
  }
}

function graphCreate(collatzMax: number) {
  return gviz.digraph(undefined, (graph) => {
    const edges: Map<string, string[]> = new Map();
    for (let i1 = 0; i1 < collatzMax; i1++) {
      let last = "";
      let i2 = i1;
      while (i2 > 1) {
        const current = i2.toString();
        graphStep(graph, last, current, edges);
        last = current;
        i2 = CollatzStep(i2);
      }
      graphStep(graph, last, '1', edges);
    }
  });
}

if (Deno.args.length < 1) {
  console.log("usage: deno run --allow-write --allow-run <src_file> <file> <max:Int>");
  Deno.exit(1);
}

let max = 5000;
if (Deno.args.length >= 2) {
  max = Number(Deno.args[1]);
  if (isNaN(max) || max <= 1 || max % 1 != 0) {
    console.error('expected positive integer above 1 as a second argument');
    Deno.exit(1);
  }
}

const graph = graphCreate(max);

const __dirname = Deno.cwd();
await gviz.renderDot(graph, path.resolve(__dirname, Deno.args[0]), {
  format: 'svg',
});
