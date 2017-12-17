module duplication::CloneClasses

import IO;
import Map;
import Set;
import List;
import String;
import vis::Render;
import util::ValueUI;
import util::SuffixTree;
import duplication::Type1;

public alias Fragment = list[str];
public data SourceInfo = SourceInfo(str fileName, int begin, int end)
                       | SourceInfo(str fileName, int begin, int end, set[int] lineNrs);
public data CloneClass = CloneClass(list[SourceInfo] sources, Fragment fragment)
                       | CloneClass(list[SourceInfo] sources, list[loc] locations, Fragment fragment);

public list[CloneClass] detectCloneClasses(SuffixTree tree, int threshold) {
	print("\>");
	tree = removeLinearBranches(tree);
	print("\b.");
	
	print("\>");
	Fragment emptyFragment = [];
	cloneClasses = detectCloneClasses(tree.root, threshold, 1, emptyFragment);
	print("\b.");
	
	print("\>");
	cloneClasses = subsumption(cloneClasses);
	print("\b.");
				
	print("\>");
	cloneClasses = convertSourceInfo(cloneClasses);
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

private list[CloneClass] convertSourceInfo(list[CloneClass] cloneClasses) {
	return [CloneClass([convertSourceInfo(source) | source <- sources], fragment) | CloneClass(sources, fragment) <- cloneClasses];
}

private SourceInfo convertSourceInfo(s:SourceInfo(_ ,_ ,_)) {
	return s;
}

private SourceInfo convertSourceInfo(SourceInfo(fileName, _, _, lineNrs)) {
	sortedLineNrs = sort(toList(lineNrs));
	return SourceInfo(fileName, head(sortedLineNrs), head(reverse(sortedLineNrs)));
}

// The current implementation is very greedy, it only check for the first entry of a list.
// When the lists are sorted if should be oke, since this method is only called when there
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
			case SourceInfo(source, begin, end, lineNrs) : {
				sources += [SourceInfo(source, begin, end, lineNrs)];
			}
		}
	}
	return sort(sources);
}

public str toString(list[CloneClass] cloneClasses) {
	return intercalate("\n\n", [ "<intercalate("\n", cloneClass.sources)>\n\t<intercalate("\n\t", cloneClass.fragment)>" | cloneClass <- cloneClasses ]);
}

public list[str] toStrings(loc project, list[CloneClass] cloneClasses, map[str, list[str]] files) {
	list[str] asString = ["--- Clone class ---"];
	for (cloneClass <- cloneClasses) {
		for (source <- cloneClass.sources) {
			loc location = toLocation(project, source, size(cloneClass.fragment), files);			
			asString += "<location>";
		}
		asString += cloneClass.fragment;
	}
	return asString;
}

private loc toLocation(loc project, SourceInfo source, int fragmentSize, map[str, list[str]] files) {
	loc adjustForEmptyLines(loc location) {
		int line = location.begin.line - 1;
		endLine = location.begin.line - 1;
		while (fragmentSize > 0) {
			if (!isEmpty(trim(files[source.fileName][line]))) {
				fragmentSize -= 1;
			}
			endLine += 1;
			line += 1;
		}
		location.end.line = endLine;
		return location;
	}
	
	location = createCloneLocation(project, source);
	// The fragment only holds non-empty lines so we need to adjust the end line for this.
	location = adjustForEmptyLines(location);
	location.offset = length(files[source.fileName][0 .. location.begin.line - 1]);
	location.length = length(files[source.fileName][location.begin.line - 1 .. location.end.line]);
	return location;
}

private loc createCloneLocation(loc project, SourceInfo source) {
	loc location = |project://Dummy|(0,0,<0,1>,<0,1>);
	location.authority = project.authority;
	location.path = source.fileName;
	location.end.line = source.end;
	location.begin.line = source.begin;
	return location;
}

private int length(list[str] lines) {
	return sum([size(line) + 1 | line <- lines]);
}
