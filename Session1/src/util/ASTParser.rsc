module util::ASTParser

import IO;
import Node;
import List;
import String;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import util::ValueUI;

public list[str] hashAST(m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl))) {
	return ["method(" + intercalate(",", hashAST(parameters)) + ")"] + hashAST(impl);
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[str] hashAST(Statement stmt) {
	println("unhandled statement: <getName(stmt)>");

	return [getName(stmt)];
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[str] hashAST(Expression expression) {
	println("unhandled expression: <getName(expression)>");

	return [getName(expression)];
}

/**
 * This method will simply return the name as a hash (of a declaration that is not handled yet)
 */
public list[str] hashAST(Declaration declaration) {
	println("unhandled declaration: <getName(declaration)>");

	return [getName(declaration)];
}


public list[str] hashAST(list[Statement] stmts) {

	list[str] result = [];

	for (Statement stmt <- stmts) {
		result += hashAST(stmt);
	}

	// return a list with all hashes of the statements in the list
	return result;
}

public list[str] hashAST(list[Expression] expressions) {
	list[str] result = [];

	for (expression <- expressions) {
		result += hashAST(expression);
	}

	// return a list with all hashes of the expressions in the list
	return result;
}

public list[str] hashAST(list[Declaration] declarations) {
	list[str] result = [];

	for (declaration <- declarations) {
		result += hashAST(declaration);
	}

	// return a list with all hashes of the declarations in the list
	return result;
}

public list[str] hashAST(list[Type] types){
	return ["list of types (unhandled)"];
}

public list[str] hashAST(\simpleName(str name)){
	return ["variable"];
}

public list[str] hashAST(\number(str numberValue)){
	return ["number"];
}

public list[str] hashAST(\parameter(Type \type, str name, int extraDimensions)){
	return ["param"];
}

public list[str] hashAST(\variables(Type \type, list[Expression] \fragments)){
	return hashAST(\fragments);
}

public list[str] hashAST(\variable(str name, int extraDimensions)){
	return ["variable"];
}

public list[str] hashAST(\variable(str name, int extraDimensions, Expression \initializer)){
	return ["variable"];
}

public list[str] hashAST(\postfix(Expression operand, str operator)){
	return [intercalate("", hashAST(operand)) + operator];
}

public list[str] hashAST(\newObject(Expression expr, Type \type, list[Expression] args, Declaration class)){
	return ["new Object(" + intercalate(" ", hashAST(args)) + ")"];
}

public list[str] hashAST(\newObject(Expression expr, Type \type, list[Expression] args, Declaration class)){
	return ["new Object(" + intercalate(" ", hashAST(args)) + ")"];
}

public list[str] hashAST(\newObject(Type \type, list[Expression] args, Declaration class)){
	return ["new Object(" + intercalate(" ", hashAST(args)) + ")"];
}

public list[str] hashAST(\newObject(Type \type, list[Expression] args)){
	return ["new Object(" + intercalate(" ", hashAST(args)) + ")"];
}

public list[str] hashAST(\declarationExpression(Declaration decl)){
	return ["declaration(" + intercalate(" ", hashAST(decl)) + ")"];
}

public list[str] hashAST(\methodCall(bool isSuper, str name, list[Expression] arguments)){
	// build the method hash by adding name and arguments and starting with a 'method' keyword for readability.
	hash = "methodCall(" + intercalate(" ", hashAST(arguments)) + ")";

	return [hash];
}

public list[str] hashAST(\methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)){
	//create a hash from the boolean literal keyword and append the actual value
	hash = "methodCall(" + intercalate(" ", hashAST(arguments)) + ")";
	
	// return the hash and append the hash list of the arguments
	return [hash];// + intercalate(" ", hashAST(arguments))];
}

public list[str] hashAST(\foreach(Declaration parameter, Expression collection, Statement body)){
	hash = "foreach " + intercalate(" ", hashAST(parameter) + hashAST(collection));

	// return the hash of the foreach statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + ["end foreach"];
}

public list[str] hashAST(\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)){
	hash = "for " + intercalate("; ", hashAST(initializers) + hashAST(condition) + hashAST(updaters));

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + ["end for"];
}

public list[str] hashAST(\for(list[Expression] initializers, list[Expression] updaters, Statement body)){
	hash = "for " + intercalate("; ", hashAST(initializers) + hashAST(updaters));

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + ["end for"];
}

public list[str] hashAST(\block(list[Statement] statements)) {

	//println("handling block: <hashAST(statements)>");

	// simply return a hash of the statements
	return hashAST(statements);
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch)){
	// build a hash for the if statement
	hash = "if" + intercalate(" ", hashAST(condition));

	// add the hash to a list and append the hash of the body
	return [hash] + hashAST(thenBranch) + ["end if"];
}

public list[str] hashAST(\if(Expression condition, Statement thenBranch, Statement elseBranch)){

	// build a hash for the if statement
	hash = "if " + intercalate(" ", hashAST(condition));
	
	println("Handling if-else <hash>");
	
	println([hash] + hashAST(thenBranch));

	// add the hash to a list and append the hash of the then and else branch
	return [hash] + hashAST(thenBranch) + ["else"] + hashAST(elseBranch) + ["end if"];
}

// \label(str name, Statement body)

public list[str] hashAST(\return(Expression expression)){
	// append return keyword to the intercalated hash of the expression
	hash = "return " + intercalate(" ", hashAST(expression));

	return [hash];
}

public list[str] hashAST(\return()){
	// simply use the return keyword as a hash
	return ["return"];
}


public list[str] hashAST(\switch(Expression expression, list[Statement] statements)){
	// use the combined expression and statements as a hash
	hash = intercalate(" ", hashAST(expression) + hashAST(statements));

	return [hash];
}

public list[str] hashAST(\case(Expression expression)){
	// simply return the hash of the expression and prepend the case keyword
	return ["case" + intercalate(" ", hashAST(expression))];
}

public list[str] hashAST(\defaultCase()){
	// simply use the default keyword as a hash
	return ["default"];
}

//\synchronizedStatement(Expression lock, Statement body)
//\throw(Expression expression)

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses)){
	// return a hash for the try keyword and append the hashes for the body and catchClauses
	return ["try"] + hashAST(body) + hashAST(catchClauses);
}

public list[str] hashAST(\try(Statement body, list[Statement] catchClauses, Statement finallyStatement)){
	// return a hash for the try keyword and append the hashes for the body, catchClauses, and finally statement
	return ["try"] + hashAST(body) + hashAST(catchClauses) + hashAST(finallyStatement);
}

public list[str] hashAST(\catch(Declaration exception, Statement body)){

	// prepend the catch keyword to the exception hash
	hash = "catch " + intercalate(" ", hashAST(exception));

	return [hash] + hashAST(body);
}

public list[str] hashAST(\declarationStatement(Declaration declaration)){
	// prepend the declarationStatement keyword to the declaration hash
	hash = "declarationStatement " + intercalate(" ", hashAST(declaration));

	return [hash];
}

public list[str] hashAST(\while(Expression condition, Statement body)){
	// add while keyword to the condition
	hash = ["while " + intercalate(" ", hashAST(condition))];

	// append the hash list of the body to the hash
	return hash + hashAST(body) + ["end while"];
}

public list[str] hashAST(\expressionStatement(Expression statement)){

	// prepend the declarationStatement keyword to the statement hash
	hash = intercalate(" ", hashAST(statement));

	return [hash];
}

//\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)
//\constructorCall(bool isSuper, list[Expression] arguments)

//expressions
public list[str] hashAST(\infix(Expression lhs, str operator, Expression rhs)){
	// build the hash based on the left hand side , operator and right hand side
	list[str] hashList = hashAST(lhs) + [operator] + hashAST(rhs);

	// get the string value
	str hash = intercalate(" ", hashList);

	return [hash];
}

public list[str] hashAST(\booleanLiteral(bool boolValue)){
	//create a hash from the boolean literal keyword and append the actual value
	hash = "booleanLiteral: " + (boolValue ? "true" : "false");

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