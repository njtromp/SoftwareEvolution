module util::ASTParser

import IO;
import Set;
import Node;
import List;
import String;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import util::ValueUI;

public set[str] unhandled = {}; 

public alias LineInfo = tuple[str line, set[int] lineNrs]; 

public list[LineInfo] hashAST(m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl))) {
	list[LineInfo] hashed = hashAST(parameters);
	return [<"method(" + lines(", ", hashed) + ")", lineNrs(hashed)>] + hashAST(impl);
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[LineInfo] hashAST(Statement stmt) {
	unhandled += {"unhandled statement: <getName(stmt)>"};
	return [<"<getName(stmt)>", lineNrs(stmt)>];
}

/**
 * This method will simply return the name as a hash (of an expression that is not handled yet)
 */
public list[LineInfo] hashAST(Expression expression) {
	unhandled += {"unhandled expression: <getName(expression)>"};
	return [<"<getName(expression)>", lineNrs(expression)>];
}

/**
 * This method will simply return the name as a hash (of a declaration that is not handled yet)
 */
public list[LineInfo] hashAST(Declaration declaration) {
	println("unhandled declaration: <getName(declaration)>");
	return [<getName(declaration), lineNrs(declaration)>];
}

public list[LineInfo] hashAST(list[Statement] stmts) {
	list[LineInfo] result = [];

	for (Statement stmt <- stmts) {
		result += hashAST(stmt);
	}

	// return a list with all hashes of the statements in the list
	return result;
}

public list[LineInfo] hashAST(list[Expression] expressions) {
	list[LineInfo] result = [];

	for (Expression expression <- expressions) {
		result += hashAST(expression);
	}

	// return a list with all hashes of the expressions in the list
	return result;
}

public list[LineInfo] hashAST(list[Declaration] declarations) {
	list[LineInfo] result = [];

	for (Declaration declaration <- declarations) {
		result += hashAST(declaration);
	}

	// return a list with all hashes of the declarations in the list
	return result;
}

public list[LineInfo] hashAST(list[Type] types){
	return [<"list of types (unhandled)", lineNrs(types)>];
}

public list[LineInfo] hashAST(sn:\simpleName(str name)){
	return [<"variable", lineNrs(sn)>];
}

public list[LineInfo] hashAST(n:\number(str numberValue)){
	return [<"number", lineNrs(n)>];
}

public list[LineInfo] hashAST(p:\parameter(Type \type, str name, int extraDimensions)){
	return [<"param", lineNrs(p)>];
}

public list[LineInfo] hashAST(\variables(Type \type, list[Expression] \fragments)){
	return hashAST(\fragments);
}

public list[LineInfo] hashAST(v:\variable(str name, int extraDimensions)){
	return [<"variable", lineNrs(v)>];
}

public list[LineInfo] hashAST(v:\variable(str name, int extraDimensions, Expression \initializer)){
	return [<"variable", lineNrs(v)>];
}

public list[LineInfo] hashAST(p:\prefix(str operator, Expression operand)){
	list[LineInfo] hashed = hashAST(operand);
	return [<"<operator> <lines(" ", hashed)>", lineNrs(p) + lineNrs(hashed)>];
}

public list[LineInfo] hashAST(p:\postfix(Expression operand, str operator)){
	list[LineInfo] hashed = hashAST(operand);
	return [<lines("", hashed) + operator, lineNrs(p) + lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\qualifiedName(Expression qualifier, Expression expression)){
	return hashAST(expression);
}

public list[LineInfo] hashAST(n:\null()){
	return [<"null", lineNrs(n)>];
}

public list[LineInfo] hashAST(sl:\stringLiteral(str stringValue)){
	return [<"variable", lineNrs(sl)>];
}

public list[LineInfo] hashAST(b:\break()){
	return [<"break", lineNrs(b)>];
}

public list[LineInfo] hashAST(b:\break(str label)){
	return [<"break label", lineNrs(b)>];
}

public list[LineInfo] hashAST(c:\continue()){
	return [<"continue", lineNrs(c)>];
}

public list[LineInfo] hashAST(c:\continue(str label)){
	return [<"continue label", lineNrs(c)>];
}

public list[LineInfo] hashAST(cl:\characterLiteral(str charValue)){
	return [<"character", lineNrs(cl)>];
}

public list[LineInfo] hashAST(\arrayAccess(Expression array, Expression index)){
	hashedArray = hashAST(array);
	hashedIndex = hashAST(index);
	return [<lines(" ", hashedArray) + "[" + lines(" ", hashedIndex) + "]", lineNrs(hashedArray) + lineNrs(hashedIndex)>];
}

public list[LineInfo] hashAST(fa:\fieldAccess(bool isSuper, str name)){
	return [<"fieldAccess", lineNrs(fa)>];
}

public list[LineInfo] hashAST(fa:\fieldAccess(bool isSuper, Expression expression, str name)){
	return [<"fieldAccess", lineNrs(fa)>];
}

public list[LineInfo] hashAST(d:\do(Statement body, Expression condition)){
	hashed = hashAST(condition);
	return [<"Do", lineNrs(d)>] + hashAST(body) + [<"While " + lines(" ", hashed), lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newArray(Type \type, list[Expression] dimensions, Expression init)){
	hashedDims = hashAST(dimensions);
	hashedInit = hashAST(init);
	return [<"new array(" + lines(", ", hashedDims) + ") = " + lines(" ", hashedInit), lineNrs(hashedDims) + lineNrs(hashedInit)>];
}

public list[LineInfo] hashAST(\newArray(Type \type, list[Expression] dimensions)){
	hashed = hashAST(dimensions);
	return [<"new array(" + lines(", ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\arrayInitializer(list[Expression] elements)){
	hashed = hashAST(elements);
	return [<lines(", ", hashed), lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newObject(Expression expr, Type \type, list[Expression] args, Declaration class)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newObject(Expression expr, Type \type, list[Expression] args, Declaration class)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newObject(Type \type, list[Expression] args, Declaration class)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newObject(Type \type, list[Expression] args)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}


public list[LineInfo] hashAST(\newObject(Type \type, list[Expression] args)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\newObject(Type \type, list[Expression] args)){
	hashed = hashAST(args);
	return [<"new Object(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\assignment(Expression lhs, str operator, Expression rhs)){
	hashedLhs = hashAST(lhs);
	hashedRhs = hashAST(rhs);
	return [<lines(" ", hashedLhs) + " " + operator + " " +  lines(" ", hashedRhs), lineNrs(hashedLhs) + lineNrs(hashedRhs)>];
}

public list[LineInfo] hashAST(l:\label(str name, Statement body)){
	return [<"label", lineNrs(l)>] + hashAST(body);
}

public list[LineInfo] hashAST(\cast(Type \type, Expression expression)){
	hashed = hashAST(expression);
	return [<"cast " + lines(" ", hashed), lineNrs(hashed)>];
}

public list[LineInfo] hashAST(s:\synchronizedStatement(Expression lock, Statement body)){
	return [<"synchronized", lineNrs(s)>] + hashAST(body) + [<"end synchronized", lineNrs(s)>];
}

//todo
public list[LineInfo] hashAST(m:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)){
	return [<"method", lineNrs(m)>];
}

public list[LineInfo] hashAST(\bracket(Expression expression)){
	//todo do we have to do anything with this bracket???
	return hashAST(expression);
}

public list[LineInfo] hashAST(\assert(Expression expression)){
	hashed = hashAST(expression);
	return [<"assert " + lines("", hashed), lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\assert(Expression expression, Expression message)){
	//unhandled += {"assert " + intercalate("", hashAST(expression))};
	hashed = hashAST(expression);
	return [<"assert " + lines("", hashed), lineNrs(hashed)>];
}

public list[LineInfo] hashAST(t:\this()){
	return [<"this", lineNrs(t)>];
}
public list[LineInfo] hashAST(t:\this(Expression thisExpression)){
	return [<"this", lineNrs(t)>] + hashAST(thisExpression);
}

public list[LineInfo] hashAST(\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)){
	//todo
	return [];	
}
public list[LineInfo] hashAST(\constructorCall(bool isSuper, list[Expression] arguments)){
	//todo
	return [];
}

public list[LineInfo] hashAST(t:\type(Type \type)){
	return [<"type", lineNrs(t)>];
}
public list[LineInfo] hashAST(\instanceof(Expression leftSide, Type rightSide)){
	hashedLhs = hashAST(leftSide);
	hashedRhs = hashAST(leftSide);
	return [<lines(" ", hashedLhs) + " instanceOf " + lines(" ", hashedRhs), lineNrs(hashedLhs) + lineNrs(hashedRhs)>];
}

public list[LineInfo] hashAST(\declarationExpression(Declaration decl)){
	hashed = hashAST(decl);
	return [<"declaration(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\methodCall(bool isSuper, str name, list[Expression] arguments)){
	// build the method hash by adding name and arguments and starting with a 'method' keyword for readability.
	hashed = hashAST(arguments);
	return [<"methodCall(" + lines(" ", hashed) + ")", lineNrs(hashed)>];
}

public list[LineInfo] hashAST(\methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)){
	//create a hash from the boolean literal keyword and append the actual value
	hashed = hashAST(arguments);
	hash = <"methodCall(" + lines(" ", hashed) + ")", lineNrs(hashed)>;
	
	// return the hash and append the hash list of the arguments
	return [hash];// + intercalate(" ", hashAST(arguments))];
}

public list[LineInfo] hashAST(fe:\foreach(Declaration parameter, Expression collection, Statement body)){
	hashedParams = hashAST(parameter);
	hashedColls = hashAST(collection);
	hash = <"foreach " + lines(" ", hashedParams + hashedColls), lineNrs(hashedParams) + lineNrs(hashedColls)>;

	// return the hash of the foreach statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + [<"end foreach", lineNrs(fe)>];
}

public list[LineInfo] hashAST(f:\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)){
	hashedInit = hashAST(initializers);
	hashedCond = hashAST(condition);
	hashedUpdate = hashAST(updaters);
	hash = <"for " + lines("; ", hashedInit + hashedCond + hashedUpdate), lineNrs(hashedInit) + lineNrs(hashedCond) + lineNrs(hashedUpdate)>;

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + [<"end for", lineNrs(f)>];
}

public list[LineInfo] hashAST(f:\for(list[Expression] initializers, list[Expression] updaters, Statement body)){
	hashedInit = hashAST(initializers);
	hashedUpdate = hashAST(updaters);
	hash = <"for " + lines("; ", hashedInit + hashedUpdate), lineNrs(hashedInit) + lineNrs(hashedUpdate)>;

	// return the hash of the for statement and append the hash of the body (because this could be a separate list).
	return [hash] + hashAST(body) + [<"end for", lineNrs(f)>];
}

public list[LineInfo] hashAST(\block(list[Statement] statements)) {
	// simply return a hash of the statements
	return hashAST(statements);
}

public list[LineInfo] hashAST(i:\if(Expression condition, Statement thenBranch)){
	// build a hash for the if statement
	hashedCond = hashAST(condition);
	hash = <"if" + lines(" ", hashedCond), lineNrs(i) + lineNrs(hashedCond)>;

	// add the hash to a list and append the hash of the body
	hashedThen = hashAST(thenBranch);
	return [hash] + hashedThen + [<"end if", {}>];
}

public list[LineInfo] hashAST(i:\if(Expression condition, Statement thenBranch, Statement elseBranch)){

	hashedCond = hashAST(condition);
	// build a hash for the if statement
	hash = <"if " + lines(" ", hashedCond), lineNrs(i) + lineNrs(hashedCond)>;
	
	// add the hash to a list and append the hash of the then and else branch
	return [hash] + hashAST(thenBranch) + [<"else", {}>] + hashAST(elseBranch) + [<"end if", lineNrs(i)>];
}

//todo?
// \label(str name, Statement body)

public list[LineInfo] hashAST(\return(Expression expression)){
	// append return keyword to the intercalated hash of the expression
	list[LineInfo] hashed = hashAST(expression);
	hash = <"return " + lines(" ", hashed), lineNrs(hashed)>;

	return [hash];
}

public list[LineInfo] hashAST(r:\return()){
	// simply use the return keyword as a hash
	return [<"return", lineNrs(r)>];
}


public list[LineInfo] hashAST(s:\switch(Expression expression, list[Statement] statements)){
	// use the combined expression and statements as a hash
	hashed = hashAST(expression);
	return [<lines(" ", hashed), lineNrs(s) + lineNrs(hashed)>] + hashAST(statements);
}

public list[LineInfo] hashAST(c:\case(Expression expression)){
	// simply return the hash of the expression and prepend the case keyword
	hashed = hashAST(expression);
	return [<"case" + lines(" ", hashed), lineNrs(c) + lineNrs(hashed)>];
}

public list[LineInfo] hashAST(d:\defaultCase()){
	// simply use the default keyword as a hash
	return [<"default", lineNrs(d)>];
}

//\throw(Expression expression)

public list[LineInfo] hashAST(t:\try(Statement body, list[Statement] catchClauses)){
	// return a hash for the try keyword and append the hashes for the body and catchClauses
	return [<"try", lineNrs(t)>] + hashAST(body) + hashAST(catchClauses);
}

public list[LineInfo] hashAST(t:\try(Statement body, list[Statement] catchClauses, Statement finallyStatement)){
	// return a hash for the try keyword and append the hashes for the body, catchClauses, and finally statement
	return [<"try", lineNrs(t)>] + hashAST(body) + hashAST(catchClauses) + hashAST(finallyStatement);
}

public list[LineInfo] hashAST(c:\catch(Declaration exception, Statement body)){

	// prepend the catch keyword to the exception hash
	hashed = hashAST(exception);
	hash = <"catch " + lines(" ", hashed), lineNrs(c) + lineNrs(hashed)>;

	return [hash] + hashAST(body);
}

public list[LineInfo] hashAST(\declarationStatement(Declaration declaration)){
	// prepend the declarationStatement keyword to the declaration hash
	hashed = hashAST(declaration);
	hash = <"declarationStatement " + lines(" ", hashed), lineNrs(hashed)>;

	return [hash];
}

public list[LineInfo] hashAST(w:\while(Expression condition, Statement body)){
	// add while keyword to the condition
	hashed = hashAST(condition);
	hash = [<"while " + lines(" ", hashed), lineNrs(w) + lineNrs(hashed)>];

	// append the hash list of the body to the hash
	return hash + hashAST(body) + [<"end while", lineNrs(w)>];
}

public list[LineInfo] hashAST(\expressionStatement(Expression statement)){

	// prepend the declarationStatement keyword to the statement hash
	hashed = hashAST(statement);
	hash = <lines(" ", hashed), lineNrs(hashed)>;

	return [hash];
}

//\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)
//\constructorCall(bool isSuper, list[Expression] arguments)

//expressions
public list[LineInfo] hashAST(i:\infix(Expression lhs, str operator, Expression rhs)){
	// build the hash based on the left hand side , operator and right hand side
	list[LineInfo] hashed = hashAST(lhs) + [<operator, lineNrs(i)>] + hashAST(rhs);

	// get the string value
	hash = <lines(" ", hashed), lineNrs(hashed)>;

	return [hash];
}

public list[LineInfo] hashAST(b:\booleanLiteral(bool boolValue)){
	return [<"boolean", lineNrs(b)>];
}

// Helpers

private str lines(str cons, list[LineInfo] lines) {
	return intercalate(cons, [ l.line | l <- lines]);
}

private set[int] lineNrs(list[LineInfo] lines) {
	return union({ l.lineNrs | l <- lines});
}

// List handling

private set[int] lineNrs(list[Type] types) {
	return union({ lineNrs(t) | t <- types});
}

private set[int] lineNrs(list[Expression] exprs) {
	return union({{expr.src.begin.line, expr.src.end.line} | expr <- exprs});
}

private set[int] lineNrs(Statement stmt) {
	return {stmt.src.begin.line, stmt.src.end.line};
}

private set[int] lineNrs(Declaration decl) {
	return {decl.src.begin.line, decl.src.end.line};
}

private set[int] lineNrs(Expression expr) {
	println("------------------------------------");
	println(expr);
	return {expr.src.begin.line, expr.src.end.line};
}

private set[int] lineNrs(Type t) {
	return {t.src.begin.line, t.src.end.line};
}

