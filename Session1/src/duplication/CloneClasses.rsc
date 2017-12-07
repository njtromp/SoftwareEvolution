module duplication::CloneClasses

import IO;
import Map;
import Set;
import List;
import String;
import util::ValueUI;
import util::SuffixTree;
import duplication::TypeOne;

public alias Fragment = list[str];
public data CloneClass = CloneClass(Fragment fragment, list[SourceInfo] sources);

public void detectCloneClasses(SuffixTree tree, int threshold) {
	//text(tree.root);
	//visualizeSuffixTree(tree);

	print(".");
	tree = removeLinearBranches(tree);
	print("\b+");

	//text(tree.root);
	visualizeSuffixTree(tree);

	print(".");
	Fragment emptyFragment = [];
	cloneClasses = detectCloneClasses(tree.root, threshold, 0, emptyFragment);
	text(cloneClasses);
	print("\b+");

}

private list[CloneClass] detectCloneClasses(Node \node, int threshold, int level, Fragment fragment) {
	list[CloneClass] cloneClasses = [];
	for (str k <- \node.next) {
		if (size(\node.next[k].values) > 1) {
			// k points to a leaf
			if (level >= threshold) {
				cloneClasses += CloneClass(fragment + k, cast(\node.next[k].values));
			}
		} else {
			cloneClasses += detectCloneClasses(\node.next[k], level + 1, threshold, fragment + k);
		}
	}
	return cloneClasses;
}

private list[SourceInfo] cast(list[value] lst) {
	list[SourceInfo] sources = [];
	for (v <- lst) {
		switch (v) {
			case SourceInfo(source, begin, end) : {
				sources += [SourceInfo(source, begin, end)];
			}
		}
	}
	return sources;
}
