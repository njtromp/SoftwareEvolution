module duplication::Type2

import IO;
import Map;
import Set;
import List;
import String;
import lang::java::m3::AST;
import util::SuffixTree;
import duplication::CloneClasses;

public SuffixTree detectType2Clones(set[Declaration] asts, int duplicationThreshold) {
	return SuffixTree(Node([], ()));
}
