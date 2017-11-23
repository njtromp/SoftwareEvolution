module ControlFlowGraph

import IO;
import Set;
import List;
import Relation;
import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;

public alias Node = int;
public alias CFG = Graph[Node];

/**
 * Registers a new node, the 'last' element contains the number of the new node.
 */
private Node addNewNode(CFG graph) {
	return max(carrier(graph)) + 1;
}

/**
 * Adds a edge to the graph
 */
private CFG insertEdge(Node entry, Node exit, CFG graph) {
	return graph + <entry, exit>;
}

/**
 * Removes an edge.
 */
private CFG removeEdge(Node entry, Node exit, CFG graph) {
	return graph - <entry, exit>;
}

/**
 * Inserts a new node into an existing edge.
 */
private tuple[Node, CFG] insertNewNodeIntoEdge(Node entry, Node exit, CFG graph) {
	newNode = addNewNode(graph);
	return <newNode, insertEdge(newNode, exit, insertEdge(entry, newNode, removeEdge(entry, exit, graph)))>;
}

/**
 * Adds a new 'parallel' node to an existing edge.
 */
private tuple[Node, CFG] addNewNodeToEdge(Node entry, Node exit, CFG graph) {
	newNode = addNewNode(graph);
	return <newNode, insertEdge(newNode, exit, insertEdge(entry, newNode, graph))>;
}

// Handling of the statements

private CFG makeGraph(Node entry, Node exit, CFG graph, \label(_, body)) {
	return makeGraph(entry, exit, graph, body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \block(stmts)) {
	switch (size(stmts)) {
		case 0 : return graph;
		case 1 : return makeGraph(entry, exit, graph, head(stmts));
		default : {
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, graph, head(stmts)), tail(stmts));
		}
	}
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \synchronizedStatement(_, stmt)) {
	return makeGraph(entry, exit, graph, stmt);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \if(condition, ifBlock)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<ifNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, ifNode, makeGraph(entry, conditionNode, graph, condition), ifBlock);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \if(condition, ifBlock, elseBlock)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<ifNode, graph> = insertNewNodeIntoEdge(conditionNode, exit, graph);
	<elseNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, elseNode, makeGraph(conditionNode, ifNode, makeGraph(entry, conditionNode, graph, condition), ifBlock), elseBlock);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \switch(condition, cases)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	return makeGraph(conditionNode, exit, makeGraph(entry, conditionNode, graph, condition), cases);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \case(_)) {
	<_, graph> = addNewNodeToEdge(entry, exit, graph);
	return graph;
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \defaultCase()) {
	return graph;
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \for(_, _, body)) {
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \for(_, condition, _, body)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(conditionNode, newNode, makeGraph(entry, conditionNode, graph, condition), body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \foreach(_, _, body)) {
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \do(body, condition)) {
	<doNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<conditionNode, graph> = addNewNodeToEdge(doNode, exit, graph);
	return makeGraph(doNode, conditionNode, makeGraph(entry, doNode, graph, body), condition);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \while(condition, body)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<whileNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, whileNode, makeGraph(entry, conditionNode, graph, condition), body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \try(body, catches)) {
	<catchNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	return makeGraph(catchNode, exit, makeGraph(entry, catchNode, graph, body), catches);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \try(tryBody, catches, finalBody)) {
	<catchNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<finalNode, graph> = insertNewNodeIntoEdge(catchNode, exit, graph);
	return makeGraph(finalNode, exit, makeGraph(catchNode, finalNode, makeGraph(entry, catchNode, graph, tryBody), catches), finalBody);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \catch(_, body)) {
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \return(expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \bracket(expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, "&&", right)) {
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, graph, left), right);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, "||", right)) {
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, graph, left), right);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, _, right)) {
	<infixNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	return makeGraph(infixNode, exit, makeGraph(entry, infixNode, graph, left), right);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \postfix(expression, _)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \prefix(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \variable(_, _, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \qualifiedName(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \conditional(condition, ifExpr, elseExpr)) {
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<ifNode, graph> = insertNewNodeIntoEdge(conditionNode, exit, graph);
	<elseNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, elseNode, makeGraph(conditionNode, ifNode, makeGraph(entry, conditionNode, graph, condition), ifExpr), elseExpr);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \assignment(_, _, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \cast(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \fieldAccess(_, expression, _)) {
	return makeGraph(entry, exit, graph, expression);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \methodCall(_, _, args)) {
	return makeGraph(entry, exit, graph, args);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \methodCall(_, _, _, args)) {
	return makeGraph(entry, exit, graph, args);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, \expressionStatement(exprs)) {
	return makeGraph(entry, exit, graph, exprs);
}

private CFG makeGraph(Node entry, Node exit, CFG graph, Expression expression) {
	return graph;
}

private CFG makeGraph(Node entry, Node exit, CFG graph, list[Expression] exprs) {
	switch (size(exprs)) {
		case 0 : return graph;
		case 1 : return makeGraph(entry, exit, graph, head(exprs));
		default : { 
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, graph, head(exprs)), tail(exprs));
		}
	}
}

private CFG makeGraph(Node entry, Node exit, CFG graph, Statement stmt) {
	return graph;
}

private CFG makeGraph(Node entry, Node exit, CFG graph, list[Statement] stmts) {
	switch (size(stmts)) {
		case 0 : return graph;
		case 1 : return makeGraph(entry, exit, graph, head(stmts));
		default : { 
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, graph, head(stmts)), tail(stmts));
		}
	}
}

public CFG makeGraph(Statement stmt) {
	Node entry = 1;
	Node exit = 2;
	return makeGraph(entry, exit, {<entry, exit>}, stmt);
}
