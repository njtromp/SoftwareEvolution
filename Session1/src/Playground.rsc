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
	//println(ast.src.path);
	list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(ast.src)));
	visit (ast) {
		case u:\compilationUnit(list[Declaration] imports, list[Declaration] types): {
			list[str] hashes = hashAST(imports) + hashAST(types);
		}
		case u:\compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types): {
			list[str] hashes = hashAST(package) + hashAST(imports) + hashAST(types);
		}
		case e:\enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body):{
			list[str] hashes = ["enum" + name] + hashAST(implements) + hashAST(constants) + hashAST(body);
		}
		case e:\enumConstant(str name, list[Expression] arguments, Declaration class):{
			list[str] hashes = ["enumConstant" + name] + hashAST(arguments) + hashAST(class);
		}
		case e:\enumConstant(str name, list[Expression] arguments):{
			list[str] hashes = ["enumConstant" + name] + hashAST(arguments);
		}
		case c:\class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
			list[str] hashes = ["class-" + name] + hashAST(extends) + hashAST(implements) + hashAST(body);
		}
		case c:\class(list[Declaration] body):{
			list[str] hashes = ["unnamedclass"] + hashAST(body);
		}
		case c:\interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
			list[str] hashes = ["interface-" + name] + hashAST(extends) + hashAST(implements) + hashAST(body);
		}
		//case f:\field(Type type, list[Expression] fragments):{
		//	list[str] hashes = // todo
		//}
		case i:\initializer(Statement initializerBody): {
			list[str] hashes = hashAST(initializerBody);
		}

	    case m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl)): {
	    		println("hashing method <name>");
	    		
			//println("\n<m.src.path>.<name>(): (<b.src.begin.line>, <b.src.end.line>)");
	    	
	    		println(hashAST(impl));
	    		
			list[str] hashes = ["method-(" + intercalate(",", hashAST(parameters)) + ")"] + hashAST(impl);
			
			println(hashes);
			//createSuffixTree(hashes);			
		}
		
	    case m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions): {
			//list[str] hashes = ["method-(" + intercalate(",", hashAST(parameters)) + ")"];
			println("method");
		}
		
		case c:\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl)): {
			println("constructor");
			//list[str] hashes = ["constructor-(" + intercalate(",", hashAST(parameters)) + ")"] + hashAST(impl);
		}
		//case i:\import(str name): {
		//	//todo
		//}
		//case p:\package(str name): {
		//	//todo
		//}
	 //   case p:\package(Declaration parentPackage, str name){
		//	//todo
		//}
	 //   case v:\variables(Type \type, list[Expression] \fragments){
		//	// todo
		//}
	 //   case t:\typeParameter(str name, list[Type] extendsList){
		//	// todo
		//}
	 //   case a:\annotationType(str name, list[Declaration] body){
		//	// todo
		//}
	 //   case a:\annotationTypeMember(Type \type, str name){
		//	//todo
		//}
	 //   case a:\annotationTypeMember(Type \type, str name, Expression defaultBlock){
		//	//todo
		//}
	    case p:\parameter(Type \type, str name, int extraDimensions): {
			list [str] hashes = ["param"];
		}
	 //   case v:\vararg(Type \type, str name): {
		//	//todo
		//}
	}
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[str] hashAST(Statement stmt) {
	print("unhandled type: ");
	println(getName(stmt));

	return [getName(stmt)];
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[str] hashAST(Expression expression) {
	print("unhandled type (expression): ");

	println(expression);

	return [getName(expression)];
}

/**
 * This method will simply return the name as a hash (of a declaration that is not handled yet)
 */
public list[str] hashAST(Declaration declaration) {
	print("unhandled type: ");

	println(getName(declaration));

	return [getName(declaration)];
}


public list[str] hashAST(list[Statement] stmts) {
	println("handling list of statements");

	list[str] result = [];

	for (stmt <- stmts) {
		result += [intercalate("", hashAST(stmt))];
	}

	println("finished handling list of statements");

	// return a list with all hashes of the statements in the list
	return result;
}

public list[str] hashAST(list[Expression] expressions) {
	println("handling list of expressions");

	list[str] result = [];

	for (expression <- expressions) {
		result += [intercalate("", hashAST(expression))];
	}

	// return a list with all hashes of the expressions in the list
	return result;
}

public list[str] hashAST(list[Declaration] declarations) {
	println("handling list of declarations");

	list[str] result = [];

	for (declaration <- declarations) {
		result += [intercalate("", hashAST(declaration))];
	}

	// return a list with all hashes of the declarations in the list
	return result;
}

public list[str] hashAST(\methodCall(bool isSuper, str name, list[Expression] arguments)){
	println("handling method call");

	// build the method hash by adding name and arguments and starting with a 'method' keyword for readability.
	hash = "method-" + name + intercalate("", arguments);

	return [hash];
}

public list[str] hashAST(\methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)){
	println("handling method call with reciever");

	//create a hash from the boolean literal keyword and append the actual value
	hash = "methodCall" + name + intercalate("", hashAST(receiver)) + "isSuper" + (isSuper ? "true" : "false");

	println("finished handling method call with reciever");
	
	println(hash);

	// return the hash and append the hash list of the arguments
	return [hash];// + intercalate("", hashAST(arguments))];
}

public list[str] hashAST(\foreach(Declaration parameter, Expression collection, Statement body)){
	println("handling foreach");

	hash = intercalate("", hashAST(parameter) + hashAST(collection));

	// return the hash of the foreach statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body);
}

public list[str] hashAST(\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)){
	println("handling for1");

	hash = intercalate("", hashAST(initializers) + hashAST(condition) + hashAST(updaters));

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body);
}

public list[str] hashAST(\for(list[Expression] initializers, list[Expression] updaters, Statement body)){
	println("handling for2");

	hash = intercalate("", hashAST(initializers) + hashAST(updaters));

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body);
}

public list[str] hashAST(\block(list[Statement] statements)) {
	println("handling block");

	// simply return a hash of the statements
	return [hashAST(statements)];
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch)){
	println("Handling if");

	// build a hash for the if statement
	hash = "if" + intercalate("", hashAST(condition));

	// add the hash to a list and append the hash of the body
	return [hash] + hashAST(thenBranch);
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch, Statement elseBranch)){
	println("Handling if-else");

	// build a hash for the if statement
	hash = "ifelse" + intercalate("", hashAST(condition));

	// add the hash to a list and append the hash of the then and else branch
	return [hash] + hashAST(thenBranch) + hashAST(elseBranch);
}

// \label(str name, Statement body)

public list[str] hashAST(\return(Expression expression)){
	println("handling return");
	// append return keyword to the intercalated hash of the expression
	hash = "return" + intercalate("", hashAST(expression));

	return [hash];
}

public list[str] hashAST(\return()){
	println("handling return");
	// simply use the return keyword as a hash
	return ["return"];
}


public list[str] hashAST(\switch(Expression expression, list[Statement] statements)){
	println("handling switch");

	// use the combined expression and statements as a hash
	hash = intercalate("", hashAST(expression) + hashAST(statements));

	return [hash];
}

public list[str] hashAST(\case(Expression expression)){
	
	println("handling case");
	// simply return the hash of the expression and prepend the case keyword
	return ["case" + intercalate("", hashAST(expression))];
}

public list[str] hashAST(\defaultCase()){
	println("handling default case");
	// simply use the default keyword as a hash
	return ["default"];
}

//\synchronizedStatement(Expression lock, Statement body)
//\throw(Expression expression)

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses)){
	println("handling try");
	// return a hash for the try keyword and append the hashes for the body and catchClauses
	return ["try"] + hashAST(body) + hashAST(catchClauses);
}

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses, Statement finallyStatement)){
	// return a hash for the try keyword and append the hashes for the body, catchClauses, and finally statement
	return ["try"] + hashAST(body) + hashAST(catchClauses) + hashAST(finallyStatement);
}

public list[str] hashAST(\catch(Declaration exception, Statement body)){

	// prepend the catch keyword to the exception hash
	hash = "catch" + intercalate("", hashAST(exception));

	return [hash] + hashAST(body);
}

public list[str] hashAST(\declarationStatement(Declaration declaration)){
	// prepend the declarationStatement keyword to the declaration hash
	hash = "declarationStatement" + intercalate("", hashAST(declaration));

	return [hash];
}

public list[str] hashAST(\while(Expression condition, Statement body)){
	println("Handling while");

	// add while keyword to the condition
	hash = ["while"] + intercalate("", hashAST(condition));

	// append the hash list of the body to the hash
	return [hash] + hashAST(body);
}

public list[str] hashAST(\expressionStatement(Expression statement)){

	// prepend the declarationStatement keyword to the statement hash
	hash = "expressionStatement" + intercalate("", hashAST(statement));

	return [hash];
}

//\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)
//\constructorCall(bool isSuper, list[Expression] arguments)

//expressions
public list[str] hashAST(\infix(Expression lhs, str operator, Expression rhs)){
	print("handling infix: ");

	// build the hash based on the left hand side , operator and right hand side
	list[str] hashList = hashAST(lhs) + [operator] + hashAST(rhs);

	// get the string value
	str hash = intercalate("", hashList);

	return [hash];
}

public list[str] hashAST(\booleanLiteral(bool boolValue)){
	//create a hash from the boolean literal keyword and append the actual value
	hash = "booleanLiteral" + boolValue ? "true" : "false";

	return [hash];
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

public void createSuffixTree(list[str] hashList) {
	list[str] example = ["a", "a", "b", "x", "y", "a", "a", "b", "$"];
	print("hashList and example");
	
	println(hashList);
	println(example);
	
	list[str] suffix = [];
	Node root = Node(());
	for (i <- [size(hashList)-1..-1]) {
		suffix = hashList[i] + suffix;
		root = put(root, suffix, i+1);
	}
    visualizeSuffixTree(root);
}