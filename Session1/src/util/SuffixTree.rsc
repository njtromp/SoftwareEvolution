module util::SuffixTree

import Map;
import Set;
import List;
import vis::Figure;
import vis::Render;

public data Node = Node(list[&V] values, map[&V, Node] next);
public data SuffixTree = SuffixTree(Node root);

public SuffixTree getNewSuffixTree() {
	return SuffixTree(Node([], ()));	
}

public SuffixTree startNewSuffix(SuffixTree tree) {
	return tree;
}
 
public SuffixTree put(SuffixTree tree, list[&K] suffixes, &V val) {
	Node put(Node \node, list[&K] suffixes, &V val) {
		suffix = head(suffixes);
		remainder = tail(suffixes);
		if (isEmpty(remainder)) {
			// At the end of the suffix.
			if (\node.next[suffix]?) {
				\node.next[suffix].values = val + \node.next[suffix].values;
			} else {
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
	tree.root = removeLinearBranches(tree.root);
	return tree;
}

public Node removeLinearBranches(Node \node) {
	for (n <- \node.next) {
		if (isUnbranched(\node.next[n])) {
			\node.next = delete(\node.next, n);
		}
	}
	return \node;
}

private bool isUnbranched(Node root) {
	switch (<size(root.values), size(root.next)>) {
		case <1, 0> : return true;
		case <0, 1> : return isUnbranched(getOneFrom(range(root.next)));
		default : return false;
	}
}

public void visualizeSuffixTree(SuffixTree tree) {
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
			return box(text("<val>\n\n<intercalate("\n", \node.values)>"), vis::Figure::id("<translation[\node]>"), gap(8));
		} else {
			return box(text("<val>"), vis::Figure::id("<translation[\node]>"), gap(8));
		}
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

	//renderSave(graph(nodes, edges, hint("layered"), gap(20)), |file:///Users/nico/Desktop/suffix-tree.png|);
	render(graph(nodes, edges, hint("layered"), gap(20)));
}