module duplication::TypeOne

import IO;
import Map;
import Set;
import List;
import String;
import util::ValueUI;
import util::FileSystem;
import lang::java::m3::AST;
import util::SuffixTree;
import util::StringCleaner;

private int analyzedMethods;

public data SourceInfo = SourceInfo(str fileName, int begin, int end);

public SuffixTree detectTypeIClones(map[str,list[str]] files, set[Declaration] asts, int duplicationThreshold) {
	analyzedMethods = 0;
	SuffixTree tree = getNewSuffixTree();
	print(".");

	void analyze(Statement body) {
		print("\b<stringChar(charAt("|/-\\", analyzedMethods % 4))>");
		// Just for debugging purposes
		//if (linesIn(body) >= duplicationThreshold && contains(body.src.path, "Duplicate")) {
		if (linesIn(body) >= duplicationThreshold) {
			analyzedMethods += 1;
			str fileName = body.src.path;
			content = files[fileName];
			tree = analyze(tree, split("/", fileName)[4], content[body.src.begin.line-1..body.src.end.line], body.src.begin.line, duplicationThreshold);
		}
	}

	visit (asts) {
		case \initializer(body)          : analyze(body);
		case \constructor(_, _, _, body) : analyze(body);
		case \method(_, _, _, _, body)   : analyze(body);
	}	
	
	print("\b.");
	return tree;
}

public int getAnalyzedMethodsCount() {
	return analyzedMethods;
}

private SuffixTree analyze(SuffixTree tree, str fileName, list[str] lines, int cloneStart, int threshold) {
	list[str] suffix = [];
	tree = startNewSuffix(tree);
	for (i <- [size(lines)-1..-1]) {
		line = trim(lines[i]);
		if (!isEmpty(line)) {
			suffix = line + suffix;
			tree = put(tree, suffix, SourceInfo(fileName, cloneStart + i, cloneStart + size(lines) - 1));
		}
	}
	return tree;
}

private 	int linesIn(Statement stmt) = stmt.src.end.line - stmt.src.begin.line;
