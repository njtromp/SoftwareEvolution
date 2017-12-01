module Playground

import IO;
import Node;
import List;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import util::ValueUI;
import util::StringCleaner;

public void play() {
	ast = createAstFromFile(|project://Session1/src/test/java/Duplicates.java|, true);
	println(ast.src.path);
	list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(ast.src)));
	visit (ast) {
		case m:\method(_, name, _, _, b:\block(stmts)) : {
			println("\n<m.src.path>.<name>(): (<b.src.begin.line>, <b.src.end.line>)");
			println("Hashed tree [<hashAST(stmts)>]");
		}
	}
}

/* The signature should most likely be changed to list[str]. This will make it possible
 * to generate a separate hash for every level in the tree.
 */ 
public str hashAST(list[Statement] stmts) {
	return intercalate("+", [ hashAST(stmt) | node stmt <- stmts]);
}

public str hashAST(node tree) {
	return "<getName(tree)>_<intercalate("", [hashAST(child) | node child <- getChildren(tree)])>";
}