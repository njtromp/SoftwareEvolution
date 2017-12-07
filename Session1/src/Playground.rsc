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
			//println("\n<m.src.path>.<name>(): (<b.src.begin.line>, <b.src.end.line>)");
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
	
	println("handling list of statements");
	
	list[str] result = [];
	for (stmt <- stmts) {
		result += hashAST(stmt); 
	}
	return result;
}



public list[str] hashAST(\methodCall(bool isSuper, str name, list[Expression] arguments)){
	println("handling method call");
	return [];
}

public list[str] hashAST(Statement stmt) {
	print("unhandled type: ");
	println(getName(stmt));
	return [];
	//return hashAST(stmt);
}

public list[str] hashAST(Expression expression) {
	print("unhandled type: ");
	println(getName(expression));
	return [];
	//return hashAST(stmt);
}

public list[str] hashAST(list[Expression] expressions) {
	println("handling list of expressions");
	
	list[str] result = [];
	for (expression <- expressions) {
		result += hashAST(expression); 
	}
	return result;
}

//public list[str] hashAST(\assert(Expression expression, Expression message)
//public list[str] hashAST(\assert(Expression expression, Expression message)
//public list[str] hashAST(\assert(Expression expression, Expression message)
//public list[str] hashAST(\break()
//public list[str] hashAST(\break(str label)
//public list[str] hashAST(\continue()
//public list[str] hashAST(\continue(str label)
//public list[str] hashAST(\do(Statement body, Expression condition)
//public list[str] hashAST(\empty()

public list[str] hashAST(\foreach(Declaration parameter, Expression collection, Statement body)){
	println("handling foreach");
	return [];
}

public list[str] hashAST(\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)){
	println("handling for1");
	
	hashAST(initializers);
	
	hashAST(condition);
	
	hashAST(updaters);
	
	hashAST(body);
	
	return [];
}

public list[str] hashAST(\for(list[Expression] initializers, list[Expression] updaters, Statement body)){
	println("handling for2");
	
	hashAST(updaters);
	
	hashAST(body);

	return [];
}

public list[str] hashAST(\block(list[Statement] statements)) {
	println("handling block");
	
	hashAST(statements);
	
	return [];
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch)){
	println("Handling if");
	
	hashAST(condition);
	
	hashAST(thenBranch);

	return [];
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch, Statement elseBranch)){
	println("Handling if-else");
	
	hashAST(condition);
	
	hashAST(thenBranch);
	
	hashAST(elseBranch);
	
	println("end of if-else");
	
	return [];
}

// \label(str name, Statement body)

public list[str] hashAST(\return(Expression expression)){
	println("Handling return with expression");
	
	hashAST(expression);
	
	return [];
}

public list[str] hashAST(\return()){
	println("Handling return");
	return [];
}

public list[str] hashAST(\switch(Expression expression, list[Statement] statements)){
	println("Handling switch");
	
	hashAST(expression);
	
	hashAST(statements);
	
	return [];
}

public list[str] hashAST(\case(Expression expression)){
	println("Handling case");
	
	hashAST(expression);
	
	return [];
}

public list[str] hashAST(\defaultCase()){
	println("Handling default case");
	return [];
}

//\synchronizedStatement(Expression lock, Statement body)
//\throw(Expression expression)

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses)){
	println("Handling try");
	
	hashAST(body);
	
	hashAST(catchClauses);
	
	return [];
}

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses, Statement \finally)){
	println("Handling try finally");
	return [];
}

public list[str] hashAST(\catch(Declaration exception, Statement body)){
	println("Handling catch");
	return [];
}

public list[str] hashAST(\declarationStatement(Declaration declaration)){
	println("Handling declaration statement");
	return [];
}

public list[str] hashAST(\while(Expression condition, Statement body)){
	println("Handling while");
	return [];
}

public list[str] hashAST(\expressionStatement(Expression stmt)){
	println("Handling expression statement");
	
	hashAST(stmt);
	
	return [];
}

//\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)
//\constructorCall(bool isSuper, list[Expression] arguments)


//expressions
public list[str] hashAST(\infix(Expression lhs, str operator, Expression rhs)){
	println("handling infix");
	return [];
}

public list[str] hashAST(\booleanLiteral(bool boolValue)){
	println("handling boolean literal");
	return [];
}


public list[str] hashAST(\methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)){
	println("handling method call 2");
	return [];
}

public list[str] hashAST(node tree) {
	println("hashing node");
	list[str] result = [];
	for (node child <- getChildren(tree)) {
		println(getName(child));
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
