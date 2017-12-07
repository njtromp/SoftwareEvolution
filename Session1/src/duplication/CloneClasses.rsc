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
public data CloneClass = CloneClass(list[SourceInfo] sources, Fragment fragment);

public list[CloneClass] detectCloneClasses(SuffixTree tree, int threshold) {
	//text(tree.root);
	//visualizeSuffixTree(tree);

	print(".");
	tree = removeLinearBranches(tree);
	print("\b*");

	//text(tree.root);
	//visualizeSuffixTree(tree);

	print(".");
	Fragment emptyFragment = [];
	cloneClasses = detectCloneClasses(tree.root, threshold, 1, emptyFragment);
	print("\b*");
	
	print(".");
	cloneClasses = subsumption(cloneClasses);
	print("\b*");

	//text(cloneClasses);
	writeFile(|file:///Users/nico/Desktop/clone-classes.txt|, cloneClasses);
	writeFile(|file:///Users/nico/Desktop/clone-classes.txt|, intercalate("\n\n", [ "<intercalate("\n", cloneClass.sources)>\n\t<intercalate("\n\t", cloneClass.fragment)>" | cloneClass <- cloneClasses ]));
	println("\nFound <size(cloneClasses)> clone classes.");
	println("Duplicates lines <sum([0] + [ss.end - ss.begin + 1 | cc <- cloneClasses, ss <- cc.sources])>");
	
	return cloneClasses;
}

private list[CloneClass] detectCloneClasses(Node \node, int threshold, int level, Fragment fragment) {
	list[CloneClass] cloneClasses = [];
	for (str line <- \node.next) {
		if (size(\node.next[line].values) > 1) {
			// line is the key for a leaf
			if (level >= threshold) {
				cloneClasses += CloneClass(cast(\node.next[line].values), fragment + line);
			}
		} else {
			cloneClasses += detectCloneClasses(\node.next[line], threshold, level + 1, fragment + line);
		}
	}
	return cloneClasses;
}

private data CloneInfo = CloneInfo(str source, int end);
private list[CloneClass] subsumption(list[CloneClass] cloneClasses) {
	set[CloneInfo] convertToCloneInfo(CloneClass cloneClass) {
		return {CloneInfo(src, end) | SourceInfo(src, _, end) <- cloneClass.sources};
	}
	map[set[CloneInfo], CloneClass] subsumptions = ();

	for (cloneClass <- cloneClasses) {
		cloneInfo = convertToCloneInfo(cloneClass);
		if (subsumptions[cloneInfo]?) {
			if (cloneClass.sources[0].begin < subsumptions[cloneInfo].sources[0].begin) {
				subsumptions[cloneInfo] = cloneClass; 
			}
		} else {
			subsumptions += (cloneInfo : cloneClass);
		}
	} 
	return toList(range(subsumptions));
}

// Ugly code to cast list[SouceInfo] to list[SourceInfo]!
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
