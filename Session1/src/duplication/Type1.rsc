module duplication::Type1

import IO;
import Map;
import Set;
import List;
import String;
import lang::java::m3::AST;
import util::SuffixTree;
import util::StringCleaner;
import duplication::CloneClasses;

private int analyzedBlocks; // Used to keep track of how may blocks have been analyzed.
public int getAnalyzedType1BlocksCount() {
	return analyzedBlocks;
}

public SuffixTree detectType1Clones(map[str,list[str]] files, set[Declaration] asts, int duplicationThreshold) {
	analyzedBlocks = 0;
	SuffixTree tree = SuffixTree(Node([], ()));
	print(".");

	// Analyze fields
	void analyze(Expression field) {
		print("\b<stringChar(charAt("|/-\\", analyzedBlocks % 4))>");
		analyzedBlocks += 1;
		str fileName = field.src.path;
		content = files[fileName];
		tree = addToSuffixTree(tree, fileName, content[field.src.begin.line-1..field.src.end.line], field.src.begin.line, duplicationThreshold);
	}

	// Analyze initialzer, constructors and methods
	void analyze(Statement body) {
		if (linesIn(body) >= duplicationThreshold) {
			print("\b<stringChar(charAt("|/-\\", analyzedBlocks % 4))>");
			analyzedBlocks += 1;
			str fileName = body.src.path;
			content = files[fileName];
			tree = addToSuffixTree(tree, fileName, content[body.src.begin.line-1..body.src.end.line], body.src.begin.line, duplicationThreshold);
		}
	}

	visit (asts) {
		case f:\field(_, list[Expression] fragments) : {
			if (linesIn(f) >= duplicationThreshold) {
				for (fragment <- fragments) analyze(fragment);
			}
		}
		case \initializer(body)          : analyze(body);
		case \constructor(_, _, _, body) : analyze(body);
		case \method(_, _, _, _, body)   : analyze(body);
	}
	
	print("\b.");
	return tree;
}

private SuffixTree addToSuffixTree(SuffixTree tree, str fileName, list[str] lines, int cloneStart, int threshold) {
	list[str] suffix = [];
	for (i <- [size(lines)-1..-1]) {
		line = trim(lines[i]);
		if (!isEmpty(line)) {
			suffix = line + suffix;
			tree = put(tree, suffix, SourceInfo(fileName, cloneStart + i, cloneStart + size(lines) - 1));
		}
	}
	return tree;
}

private 	int linesIn(Statement stmt) = stmt.src.end.line - stmt.src.begin.line + 1;
private 	int linesIn(Declaration decl) = decl.src.end.line - decl.src.begin.line + 1;
