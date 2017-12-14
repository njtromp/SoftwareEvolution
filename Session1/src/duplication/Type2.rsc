module duplication::Type2

import IO;
import Map;
import Set;
import List;
import String;
import lang::java::m3::AST;
import util::SuffixTree;
import util::ASTParser;
import duplication::CloneClasses;

private int analyzedBlocks; // Used to keep track of how may blocks have been analyzed.
private int lineNr; // Needed for generating unique linenumbers
public int getAnalyzedType2BlocksCount() {
	return analyzedBlocks;
}

public SuffixTree detectType2Clones(set[Declaration] asts, int duplicationThreshold) {
	analyzedBlocks = 0;
	lineNr = 0;
	SuffixTree tree = SuffixTree(Node([], ()));
	print(".");

	void analyze(Declaration decl) {
		print("\b<stringChar(charAt("|/-\\", analyzedBlocks % 4))>");
		analyzedBlocks += 1;
		str fileName = decl.src.path;
		list[LineInfo] content = hashAST(decl);
		if (size(content) >= duplicationThreshold) {
			tree = addToSuffixTree(tree, fileName, content, lineNr, duplicationThreshold);
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

private SuffixTree addToSuffixTree(SuffixTree tree, str fileName, list[LineInfo] lines, int cloneStart, int threshold) {
	list[str] suffix = [];
	for (i <- [size(lines)-1..-1]) {
		lineNr += 1;
		line = trim(lines[i].line);
		if (!isEmpty(line)) {
			suffix = line + suffix;
			tree = put(tree, suffix, SourceInfo(fileName, cloneStart + i, cloneStart + size(lines) - 1, lines[i].lineNrs));
		}
	}
	return tree;
}
