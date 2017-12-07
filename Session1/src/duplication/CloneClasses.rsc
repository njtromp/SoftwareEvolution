module duplication::CloneClasses

import IO;
import Map;
import Set;
import List;
import String;
import util::ValueUI;
import util::SuffixTree;

public void detectCloneClasses(SuffixTree tree, int threshold) {
	//text(tree.root);
	visualizeSuffixTree(tree);

	print(".");
	tree = removeLinearBranches(tree);
	print("\b+");

	//text(tree.root);
	//visualizeSuffixTree(tree);

	list[str] empty = [];
	print(".");
	detect(tree, 1, threshold, false, empty);
	print("\b+");

}

private bool detect(SuffixTree tree, int threshold, int level, bool bla, list[&K] fragment) {
	bool cloneDetected = false;
	//for (key <- \node.next) {
	//	if (!detect(\node.next[key], threshold, level+1, bla, fragment + key) && level >= threshold && size(\node.values) > 1) {
	//		cloneDetected = true;
	//		//println(fragment);
	//	}
	//}
	return cloneDetected;
}
