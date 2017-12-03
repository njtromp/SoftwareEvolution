module duplication::TypeOne

import IO;
import Map;
import Set;
import List;
import String;
import lang::java::m3::AST;
import util::FileSystem;
import util::SuffixTree;
import util::StringCleaner;

private Node root = Node([], ());
private int analyzedMethods;

public data CloneInfo = CloneInfo(str, int);

public void detectTypeIClones(map[str,list[str]] files, set[Declaration] asts, int duplicationThreshold) {
	analyzedMethods = 0;
	root = Node([], ());
	visit (asts) {
		case \method(_, name, _, _, body) : {
			//if (linesIn(body) >= duplicationThreshold && contains(body.src.path, "Duplicates")) {
			if (linesIn(body) >= duplicationThreshold) {
				analyzedMethods += 1;
				str fileName = body.src.path;
				content = files[fileName];
				analyze(split("/", fileName)[4], content[body.src.begin.line-1..body.src.end.line], body.src.begin.line, duplicationThreshold);
			}
		}
	}
	//text(root);
}

public int getAnalyzedMethodsCount() {
	return analyzedMethods;
}

private void analyze(str fileName, list[str] lines, int cloneStart, int threshold) {
	list[str] suffix = [];
	for (i <- [size(lines)-1..-1]) {
		line = trim(lines[i]);
		if (!isEmpty(line)) {
			suffix = line + suffix;
			if (size(suffix) >= threshold) {
				root = put(root, suffix, CloneInfo(fileName ,cloneStart + i));
			}
		}
	}
}

private 	int linesIn(Statement stmt) = stmt.src.end.line - stmt.src.begin.line;
