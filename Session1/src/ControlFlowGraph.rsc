module ControlFlowGraph

import IO;
import List;
import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;
import DebugPrint;

public alias Node = int;
public alias GraphInfo = tuple[Node last, Graph[Node] graph];

/**
 * Registers a new node, the 'last' element contains the number of the new node.
 */
public GraphInfo addNewNode(GraphInfo info) {
	<lastNode, graph> = info;
	return <lastNode+1, graph>;
}

/**
 * Adds a edge to the graph
 */
public GraphInfo insertEdge(Node entry, Node exit, GraphInfo info) {
	<lastNode, graph> = info;
	graph += <entry, exit>;
	return <lastNode, graph>;
}

/**
 * Removes an edge.
 */
public GraphInfo removeEdge(Node entry, Node exit, GraphInfo info) {
	<lastNode, graph> = info;
	graph -= <entry, exit>;
	return <lastNode, graph>;
}

/**
 * Inserts a new node into an existing edge.
 */
public GraphInfo insertNewNodeIntoEdge(Node entry, Node exit, GraphInfo info) {
	<newNode, graph> = addNewNode(info);
	return insertEdge(entry, newNode, insertEdge(newNode, exit, removeEdge(entry, exit, <newNode, graph>)));
}

/**
 * Adds a new 'parallel' node to an existing edge.
 */
public GraphInfo addNewNodeToEdge(Node entry, Node exit, GraphInfo info) {
	<newNode, graph> = addNewNode(info);
	return insertEdge(entry, newNode, insertEdge(newNode, exit, <newNode, graph>));
}

// Handling of the statements

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \label(_, body)) {
	return makeGraph(entry, exit, info, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \block(stmts)) {
	//dprintln("Block");
	switch (size(stmts)) {
		case 0 : return info;
		case 1 : return makeGraph(entry, exit, info, head(stmts));
		default : {
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, <newNode, graph>, head(stmts)), tail(stmts));
		}
	}
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \synchronizedStatement(_, stmt)) {
	dprintln("Synchronized");
	return makeGraph(entry, exit, info, stmt);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \if(condition, ifBlock)) {
	dprintln("If");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<ifNode, graph> = addNewNodeToEdge(conditionNode, exit, <conditionNode, graph>);
	return makeGraph(conditionNode, ifNode, makeGraph(entry, conditionNode, <ifNode, graph>, condition), ifBlock);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \if(condition, ifBlock, elseBlock)) {
	dprintln("If-Else");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<ifNode, graph> = insertNewNodeIntoEdge(conditionNode, exit, <conditionNode, graph>);
	<elseNode, graph> = addNewNodeToEdge(conditionNode, exit, <ifNode, graph>);
	return makeGraph(elseNode, exit, makeGraph(ifNode, exit, makeGraph(entry, conditionNode, <elseNode, graph>, condition), ifBlock), elseBlock);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \switch(condition, cases)) {
	dprintln("Switch");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	return makeGraph(conditionNode, exit, makeGraph(entry, conditionNode, <conditionNode, graph>, condition), cases);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \case(_)) {
	dprintln("Case");
	return addNewNodeToEdge(entry, exit, info);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \defaultCase()) {
	dprintln("Default");
	return info;
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \for(_, _, body)) {
	dprintln("For");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \for(_, condition, _, body)) {
	dprintln("For-Conditional");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<newNode, graph> = addNewNodeToEdge(entry, exit, <conditionNode, graph>);
	return makeGraph(conditionNode, newNode, makeGraph(entry, conditionNode, <newNode, graph>, condition), body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \foreach(_, _, body)) {
	dprintln("Foreach");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \do(body, condition)) {
	dprintln("Do");
	<doNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<conditionNode, graph> = addNewNodeToEdge(doNode, exit, <doNode, graph>);
	return makeGraph(doNode, conditionNode, makeGraph(entry, doNode, <conditionNode, graph>, body), condition);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \while(condition, body)) {
	dprintln("While");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<whileNode, graph> = addNewNodeToEdge(conditionNode, exit, <conditionNode, graph>);
	return makeGraph(conditionNode, whileNode, makeGraph(entry, conditionNode, <whileNode, graph>, condition), body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \try(body, catches)) {
	dprintln("Try");
	<catchNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(catchNode, exit, makeGraph(entry, catchNode, <catchNode, graph>, body), catches);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \try(tryBody, catches, finalBody)) {
	dprintln("Try-Final");
	<catchNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	<finalNode, graph> = insertNewNodeIntoEdge(catchNode, exit, <catchNode, graph>);
	return makeGraph(finalNode, exit, makeGraph(catchNode, finalNode, makeGraph(entry, catchNode, <finalNode, graph>, tryBody), catches), finalBody);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \catch(_, body)) {
	dprintln("Catch");
	<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \return(expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \bracket(expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, infix(left, "&&", right)) {
	dprintln("Infix-&&");
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, info); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, <leftNode, graph>);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, <rightNode, graph>, left), right);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, infix(left, "||", right)) {
	dprintln("Infix-||");
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, info); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, <leftNode, graph>);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, <rightNode, graph>, left), right);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, infix(left, _, right)) {
	dprintln("Infix");
	<infixNode, graph> = insertNewNodeIntoEdge(entry, exit, info); 
	return makeGraph(infixNode, exit, makeGraph(entry, infixNode, <infixNode, graph>, left), right);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \postfix(expression, _)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \prefix(_, expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \variable(_, _, expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \qualifiedName(_, expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \conditional(condition, ifExpr, elseExpr)) {
	dprintln("Infix-||");
	<ifNode, graph> = addNewNodeToEdge(entry, exit, removeEdge(entry, exit, info));
	<elseNode, graph> = addNewNodeToEdge(entry, exit, <ifNode, graph>);
	return makeGraph(entry, elseNode, makeGraph(entry, ifNode, <elseNode, graph>, ifExpr), elseExpr);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \assignment(_, _, expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \cast(_, expression)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \fieldAccess(_, expression, _)) {
	return makeGraph(entry, exit, info, expression);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \methodCall(_, _, args)) {
	return makeGraph(entry, exit, info, args);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \methodCall(_, _, _, args)) {
	return makeGraph(entry, exit, info, args);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, Expression expression) {
	//dprintln("Unhandled expression [<expression>]");
	return info;
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, list[Expression] exprs) {
	switch (size(exprs)) {
		case 0 : return info;
		case 1 : return makeGraph(entry, exit, info, head(exprs));
		default : { 
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, <newNode, graph>, head(exprs)), tail(exprs));
		}
	}
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, Statement stmt) {
	//dprintln("Unhandled statement [<stmt>]");
	return info;
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, list[Statement] stmts) {
	switch (size(stmts)) {
		case 0 : return info;
		case 1 : return makeGraph(entry, exit, info, head(stmts));
		default : { 
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, <newNode, graph>, head(stmts)), tail(stmts));
		}
	}
}

public Graph[Node] makeGraph(Statement stmt) {
	dprintln("Making graph");
	GraphInfo info = makeGraph(1, 2, <2, {<1,2>}>, stmt);
	//iprintln(info.graph);
	return info.graph;
}


