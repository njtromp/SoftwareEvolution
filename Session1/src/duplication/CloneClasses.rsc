module duplication::CloneClasses

import IO;
import Map;
import Set;
import List;
import String;
import util::ValueUI;
import util::SuffixTree;

public void detectCloneClasses(Node root, int threshold) {
	//text(root);
	//visualizeSuffixTree(root);

	root = removeLinearBranches(root);
	print(".");
	root = removeSmallClones(root, threshold);
	print(".");

	text(root);
	visualizeSuffixTree(root);

	println("\nNr of Clones: <numberOfClones(root)>");
	list[str] empty = [];
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
