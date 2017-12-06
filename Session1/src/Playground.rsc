module Playground

import IO;
import Node;
import List;
import String;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import util::ValueUI;
import util::SuffixTree;
import util::StringCleaner;


public void play() {
	//ast = createAstFromFile(|project://Session1/src/test/java/Duplicates.java|, true);
	ast = createAstFromFile(|project://Session1/src/test/java/SimpleJava.java|, true);
	println(ast.src.path);
	list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(ast.src)));
	visit (ast) {
		case m:\method(_, name, _, _, b:\block(stmts)) : {
			println("\n<m.src.path>.<name>(): (<b.src.begin.line>, <b.src.end.line>)");
			list[str] hashes = hashAST(stmts);
			println("Hashed tree for method <name>()");
			for (line <- hashes) {
				println(line);
			}
		}
	}
}

/* The signature should most likely be changed to list[str]. This will make it possible
 * to generate a separate hash for every level in the tree.
 */ 
public list[str] hashAST(list[Statement] stmts) {
	list[str] result = [];
	for (node stmt <- stmts) {
		result += hashAST(stmt); 
	}
	return result;
}


public list[str] hashAST(block(list[Statement] stmts)) {
	return hashAST(stmts);
}

public list[str] hashAST(node tree) {
	list[str] result = [];
	for (node child <- getChildren(tree)) {
		result += hashAST(child); 
	}
	return getName(tree) + result;
}
public void createSuffixTree() {
	list[str] example = ["a", "a", "b", "x", "y", "a", "a", "b", "$"];
	list[str] suffix = [];
	Node root = Node(());
	for (i <- [size(example)-1..-1]) {
		suffix = example[i] + suffix;
		root = put(root, suffix, i+1);
	}    
    visualizeSuffixTree(root);
}
