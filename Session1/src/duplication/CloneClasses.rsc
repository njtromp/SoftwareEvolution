module duplication::CloneClasses

import IO;
import List;
import Map;
import util::ValueUI;
import util::SuffixTree;

public void detectCloneClasses(Node root, int threshold) {
	list[str] empty = [];
	<_, newRoot> = prune(root);
	root = newRoot;
	println("Nr of Clones: <numberOfClones(root)>");
	//text(root);
	detect(root, 1, threshold, false, empty);
}

private bool detect(Node \node, int threshold, int level, bool bla, list[&K] fragment) {
	bool cloneDetected = false;
	for (key <- \node.next) {
		if (!detect(\node.next[key], threshold, level+1, bla, fragment + key) && level >= threshold && size(\node.values) > 1) {
			cloneDetected = true;
			println(fragment);
		}
	}
	return cloneDetected;
}

private int numberOfClones(Node \node) {
	int clones = 0;
	for (suffix <- \node.next) {
		clones += numberOfClones(\node.next[suffix]);
	}
	//return clones > 1 ? clones + size(\node.values) : size(\node.values);
	return clones + size(\node.values);
}

private tuple[bool prune, Node root] prune(Node \node) {
	bool toPrune = true;
	if (size(\node.values) < 2) {
		for (n <- \node.next) {
			<pruned, root> = prune(\node.next[n]);
			if (root == Node([], ())) {
				\node.next = delete(\node.next, n);
			} else {
				\node.next[n] = root;
			}
			toPrune = toPrune && pruned;
		}
		if (toPrune) {
			\node.values = [];
			\node.next = ();
			return <true, \node>;
		} else {
			return <false, \node>;
		}
	} else {
		return <false, \node>;
	}
}