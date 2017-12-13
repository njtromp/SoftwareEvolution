module duplication::Type2

import IO;
import Map;
import Set;
import List;
import String;
import lang::java::m3::AST;
import util::SuffixTree;
import duplication::CloneClasses;

private int analyzedBlocks; // Used to keep track of how may blocks have been analyzed.
public int getAnalyzedType2BlocksCount() {
	return analyzedBlocks;
}

private list[str] hashAST(value blah) {
	return ["if var \< 10","else", "end-if"];
}

public SuffixTree detectType2Clones(set[Declaration] asts, int duplicationThreshold) {
	analyzedBlocks = 0;
	SuffixTree tree = SuffixTree(Node([], ()));
	print(".");

	void analyze(Declaration decl) {
		print("\b<stringChar(charAt("|/-\\", analyzedBlocks % 4))>");
		analyzedBlocks += 1;
		str fileName = decl.src.path;
		content = hashAST(decl);
		if (size(content) >= duplicationThreshold) {
			tree = addToSuffixTree(tree, fileName, content, decl.src.begin.line, duplicationThreshold);
		}
	}

	visit (asts) {
		case fild:\field(_, _)             : analyze(fild);
		case init:\initializer(_)          : analyze(init);
		case ctor:\constructor(_, _, _, _) : analyze(ctor);
		case meth:\method(_, _, _, _, _)   : analyze(meth);
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
