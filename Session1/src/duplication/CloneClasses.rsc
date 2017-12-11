module duplication::CloneClasses

import IO;
import Map;
import Set;
import List;
import String;
import vis::Render;
import util::ValueUI;
import util::SuffixTree;
import duplication::TypeOne;

public alias Fragment = list[str];
public data CloneClass = CloneClass(list[SourceInfo] sources, Fragment fragment);

public list[CloneClass] detectCloneClasses(SuffixTree tree, int threshold) {
	// Just for debugging purposes!
	//text(tree.root);
	//renderSave(visualizeSuffixTree(tree), |file:///Users/nico/Desktop/suffix-tree-raw.png|);
	//render(visualizeSuffixTree(tree));

	print("\>");
	tree = removeLinearBranches(tree);
	print("\b.");
	
	print("\>");
	tree = removeShortBranches(tree, threshold);
	print("\b.");

	// Just for debugging purposes!
	//text(tree.root);
	//renderSave(visualizeSuffixTree(tree), |file:///Users/nico/Desktop/suffix-tree.png|);
	//render(visualizeSuffixTree(tree));

	print("\>");
	Fragment emptyFragment = [];
	cloneClasses = detectCloneClasses(tree.root, threshold, 1, emptyFragment);
	print("\b.");
	
	print("\>");
	cloneClasses = subsumption(cloneClasses);
	print("\b.");
	
	return cloneClasses;
}

private list[CloneClass] detectCloneClasses(Node \node, int threshold, int depth, Fragment fragment) {
	list[CloneClass] cloneClasses = [];
	for (str line <- \node.next) {
		if (size(\node.next[line].values) >= 2 && depth >= threshold) {
			// This is a clone class
			cloneClasses += CloneClass(cast(\node.next[line].values), fragment + line);
		}
		// We are some where in a branch
		if (depth > threshold && size(\node.next) > 1) {
			// We are at a split, if there are any branches leading to a single leaf
			// we can group them together.
			list[SourceInfo] singleSources = [];
			for (n <- \node.next) {
				singleSources += findSingleSources(\node.next[n]);
			}
			// Any multi leaf branches are already part of a clone class
			if (size(singleSources) >= 2) {
				cloneClasses += CloneClass(singleSources, fragment);
			}
		}
		// Check any branches further down the tree
		cloneClasses += detectCloneClasses(\node.next[line], threshold, depth + 1, fragment + line);
	}
	return cloneClasses;
}

private list[SourceInfo] findSingleSources(Node \node) {
	if (size(\node.values) > 1) {
		return [];
	} else if (size(\node.values) == 1) {
		return cast(\node.values);
	} else {
		list[SourceInfo] singleSources = [];
		for (n <- \node.next) {
			singleSources += findSingleSources(\node.next[n]);
		}
		return singleSources;
	} 
}

// Used to find overlapping classes. Overlapping classes are defined
// by the file they apear in and the last line of the block.
private data CloneInfo = CloneInfo(str source, int end);
private list[CloneClass] subsumption(list[CloneClass] cloneClasses) {

	set[CloneInfo] convertToCloneInfo(CloneClass cloneClass) {
		return {CloneInfo(src, end) | SourceInfo(src, _, end) <- cloneClass.sources};
	}

	map[set[CloneInfo], CloneClass] subsumptions = ();

	for (cloneClass <- cloneClasses) {
		cloneInfo = convertToCloneInfo(cloneClass);
		if (subsumptions[cloneInfo]?) {
			if (contains(cloneClass.sources, subsumptions[cloneInfo].sources)) {
				subsumptions[cloneInfo] = cloneClass; 
			}
		} else {
			subsumptions += (cloneInfo : cloneClass);
		}
	} 
	return toList(range(subsumptions));
}

// The current implementation is very greedy, it only check for the first entry of a list.
// When the list are sorted if should be oke, since this method is only called when there
// is a match as a map key. 
private bool contains(list[SourceInfo] candidate, list[SourceInfo] current) {
	return candidate[0].begin < current[0].begin;
}

// Ugly code to cast list[SouceInfo] to list[SourceInfo]!
// Need to find the proper way in Rascal aka make the Suffix tree more type aware...
private list[SourceInfo] cast(list[value] lst) {
	list[SourceInfo] sources = [];
	for (v <- lst) {
		switch (v) {
			case SourceInfo(source, begin, end) : {
				sources += [SourceInfo(source, begin, end)];
			}
		}
	}
	return sort(sources);
}

public str toString(list[CloneClass] cloneClasses) {
	return intercalate("\n\n", [ "<intercalate("\n", cloneClass.sources)>\n\t<intercalate("\n\t", cloneClass.fragment)>" | cloneClass <- cloneClasses ]);
}
