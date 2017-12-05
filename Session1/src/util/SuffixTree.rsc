module util::SuffixTree

import Map;
import List;
import vis::Figure;
import vis::Render;

public data Node = Node(list[&V] values, map[&k, Node] next);

public Node put(Node root, list[&K] suffixes, &V val) {
	suffix = head(suffixes);
	remainder = tail(suffixes);
	if (isEmpty(remainder)) {
		if (root.next[suffix]?) {
			root.next[suffix].values += [val];
		} else {
			root.next += (suffix : Node([val], ()));
		}
	} else {
		if (!root.next[suffix]?) {
			root.next += (suffix : Node([], ()));
		}
		root.next[suffix] = put(root.next[suffix], remainder, val);
	}
	return root;
}

public void visualizeSuffixTree(Node root) {
	int nodeId = 0;
	list[Edge] edges = [];
	list[Figure] nodes = [];
	map[Node, int] translation = ();

	void registerNode(Node root) {
		if (!translation[root]?) {
			nodeId += 1;
			translation += (root : nodeId);
		}
	}

	Figure createNode(Node root, str val) {
		if (size(root.values) > 0) {
			return box(text("<val>\n<intercalate("\n", root.values)>"), vis::Figure::id("<translation[root]>"), gap(8));
		} else {
			return box(text("<val>"), vis::Figure::id("<translation[root]>"), gap(8));
		}
	}

	void renderNode(Node root) {
		for (str n <- root.next) {
			Node nn = root.next[n];
			registerNode(nn);
			edges += edge("<translation[root]>", "<translation[nn]>", toArrow(triangle(5, fillColor("black"))));
			nodes += createNode(root.next[n], n);
			renderNode(root.next[n]);
		}
	}

	registerNode(root);
	nodes += createNode(root, "");

	renderNode(root);

	render(graph(nodes, edges, hint("layered"), gap(20)));
}