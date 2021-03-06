module util::SuffixTree

import Map;
import Set;
import List;
import vis::Figure;

public data Node = Node(list[&V] values, map[&V, Node] next);
public data SuffixTree = SuffixTree(Node root);

public SuffixTree put(SuffixTree tree, list[&K] suffixes, &V val) {
	Node put(Node \node, list[&K] suffixes, &V val) {
		suffix = head(suffixes);
		remainder = tail(suffixes);
		if (isEmpty(remainder)) {
			// We are at the end of the suffix.
			if (\node.next[suffix]?) {
				// Add occurence to the existing leaf
				\node.next[suffix].values = val + \node.next[suffix].values;
			} else {
				// Add a new node and register the occurence
				\node.next += (suffix : Node([val], ()));
			}
		} else {
			// Continue down the branch
			if (!\node.next[suffix]?) {
				\node.next += (suffix : Node([], ()));
			}
			\node.next[suffix] = put(\node.next[suffix], remainder, val);
		}
		return \node;
	}

	tree.root = put(tree.root, suffixes, val);
	return tree;
}

public SuffixTree removeLinearBranches(SuffixTree tree) {
	for (n <- tree.root.next) {
		if (isUnbranched(tree.root.next[n])) {
			tree.root.next = delete(tree.root.next, n);
		}
	}
	return tree;
}

private bool isUnbranched(Node \node) {
	switch (<size(\node.values), size(\node.next)>) {
		case <1, 0> : return true;
		case <0, 1> : return isUnbranched(getOneFrom(range(\node.next)));
		default : return false;
	}
}

private bool isShortBranch(Node \node, int threshold, int depth) {
	if (depth >= threshold) {
		return false;
	} else {
		if (size(\node.values) > 0 || size(\node.next) == 0) {
			return true;
		} else {
			for (key <- \node.next) {
				if (!isShortBranch(\node.next[key], threshold, depth + 1)) {
					return false;
				}
			}
			return true;
		}
	}
}

public Figure visualizeSuffixTree(SuffixTree tree) {
	int nodeId = 0;
	list[Edge] edges = [];
	list[Figure] nodes = [];
	map[Node, int] translation = ();

	void registerNode(Node \node) {
		if (!translation[\node]?) {
			nodeId += 1;
			translation += (\node : nodeId);
		}
	}

	Figure createNode(Node \node, str val) {
		registerNode(\node);
		if (size(\node.values) > 0) {
			edges += edge("<translation[\node]>", "-<translation[\node]>", toArrow(triangle(5, fillColor("black"))));
			nodes += box(text("<intercalate("\n", \node.values)>"), vis::Figure::id("-<translation[\node]>"), gap(8));
		}
		return box(text("<val>"), vis::Figure::id("<translation[\node]>"), gap(8));
	}

	void renderNode(Node \node) {
		registerNode(\node);
		for (str v <- \node.next) {
			Node n = \node.next[v];
			registerNode(n);
			edges += edge("<translation[\node]>", "<translation[n]>", toArrow(triangle(5, fillColor("black"))));
			nodes += createNode(\node.next[v], v);
			renderNode(\node.next[v]);
		}
	}

	registerNode(tree.root);
	nodes += createNode(tree.root, "root");

	renderNode(tree.root);
	
	return graph(nodes, edges, hint("layered"), gap(20));
}