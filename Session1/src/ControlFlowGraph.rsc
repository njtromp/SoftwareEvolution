module ControlFlowGraph

import IO;
import Set;
import List;
import Relation;
import lang::java::jdt::m3::AST;
import analysis::graphs::Graph;
import DebugPrint;

public alias Node = int;
public alias CFG = Graph[Node];

/**
 * Registers a new node, the 'last' element contains the number of the new node.
 */
public Node addNewNode(CFG graph) {
	return size(carrier(graph)) + 1;
}

/**
 * Adds a edge to the graph
 */
public CFG insertEdge(Node entry, Node exit, CFG graph) {
	return graph + <entry, exit>;
}

/**
 * Removes an edge.
 */
public CFG removeEdge(Node entry, Node exit, CFG graph) {
	return graph - <entry, exit>;
}

/**
 * Inserts a new node into an existing edge.
 */
public tuple[Node, CFG] insertNewNodeIntoEdge(Node entry, Node exit, CFG graph) {
	newNode = addNewNode(graph);
	return <newNode, insertEdge(newNode, exit, insertEdge(entry, newNode, removeEdge(entry, exit, graph)))>;
}

/**
 * Adds a new 'parallel' node to an existing edge.
 */
public tuple[Node, CFG] addNewNodeToEdge(Node entry, Node exit, CFG graph) {
	newNode = addNewNode(graph);
	return <newNode, insertEdge(newNode, exit, insertEdge(entry, newNode, graph))>;
}

// Handling of the statements

public CFG makeGraph(Node entry, Node exit, CFG graph, \label(_, body)) {
	return makeGraph(entry, exit, graph, body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \block(stmts)) {
	//dprintln("Block");
	switch (size(stmts)) {
		case 0 : return graph;
		case 1 : return makeGraph(entry, exit, graph, head(stmts));
		default : {
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, graph, head(stmts)), tail(stmts));
		}
	}
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \synchronizedStatement(_, stmt)) {
	dprintln("Synchronized");
	return makeGraph(entry, exit, graph, stmt);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \if(condition, ifBlock)) {
	dprintln("If");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<ifNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, ifNode, makeGraph(entry, conditionNode, graph, condition), ifBlock);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \if(condition, ifBlock, elseBlock)) {
	dprintln("If-Else");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<ifNode, graph> = insertNewNodeIntoEdge(conditionNode, exit, graph);
	<elseNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(elseNode, exit, makeGraph(ifNode, exit, makeGraph(entry, conditionNode, graph, condition), ifBlock), elseBlock);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \switch(condition, cases)) {
	dprintln("Switch");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	return makeGraph(conditionNode, exit, makeGraph(entry, conditionNode, graph, condition), cases);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \case(_)) {
	dprintln("Case");
	// TODO check this!! 
	// Why is the new node forgotton?
	<_, graph> = addNewNodeToEdge(entry, exit, graph);
	return graph;
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \defaultCase()) {
	dprintln("Default");
	return graph;
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \for(_, _, body)) {
	dprintln("For");
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \for(_, condition, _, body)) {
	dprintln("For-Conditional");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(conditionNode, newNode, makeGraph(entry, conditionNode, graph, condition), body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \foreach(_, _, body)) {
	dprintln("Foreach");
	<newNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \do(body, condition)) {
	dprintln("Do");
	<doNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<conditionNode, graph> = addNewNodeToEdge(doNode, exit, graph);
	return makeGraph(doNode, conditionNode, makeGraph(entry, doNode, graph, body), condition);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \while(condition, body)) {
	dprintln("While");
	<conditionNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<whileNode, graph> = addNewNodeToEdge(conditionNode, exit, graph);
	return makeGraph(conditionNode, whileNode, makeGraph(entry, conditionNode, graph, condition), body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \try(body, catches)) {
	dprintln("Try");
	<catchNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(catchNode, exit, makeGraph(entry, catchNode, graph, body), catches);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \try(tryBody, catches, finalBody)) {
	dprintln("Try-Final");
	<catchNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<finalNode, graph> = insertNewNodeIntoEdge(catchNode, exit, graph);
	return makeGraph(finalNode, exit, makeGraph(catchNode, finalNode, makeGraph(entry, catchNode, graph, tryBody), catches), finalBody);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \catch(_, body)) {
	dprintln("Catch");
	<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	return makeGraph(entry, newNode, graph, body);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \return(expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \bracket(expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, "&&", right)) {
	dprintln("Infix-&&");
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, graph, left), right);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, "||", right)) {
	dprintln("Infix-||");
	<leftNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	<rightNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, rightNode, makeGraph(entry, leftNode, graph, left), right);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, infix(left, _, right)) {
	dprintln("Infix");
	<infixNode, graph> = insertNewNodeIntoEdge(entry, exit, graph); 
	return makeGraph(infixNode, exit, makeGraph(entry, infixNode, graph, left), right);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \postfix(expression, _)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \prefix(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \variable(_, _, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \qualifiedName(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \conditional(condition, ifExpr, elseExpr)) {
	dprintln("Infix-||");
	<ifNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
	<elseNode, graph> = addNewNodeToEdge(entry, exit, graph);
	return makeGraph(entry, elseNode, makeGraph(entry, ifNode, graph, ifExpr), elseExpr);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \assignment(_, _, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \cast(_, expression)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \fieldAccess(_, expression, _)) {
	return makeGraph(entry, exit, graph, expression);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \methodCall(_, _, args)) {
	return makeGraph(entry, exit, graph, args);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, \methodCall(_, _, _, args)) {
	return makeGraph(entry, exit, graph, args);
}

public CFG makeGraph(Node entry, Node exit, CFG graph, Expression expression) {
	//dprintln("Unhandled expression [<expression>]");
	return graph;
}

public CFG makeGraph(Node entry, Node exit, CFG graph, list[Expression] exprs) {
	switch (size(exprs)) {
		case 0 : return graph;
		case 1 : return makeGraph(entry, exit, graph, head(exprs));
		default : { 
			<newNode, graph> = insertNewNodeIntoEdge(entry, exit, graph);
			return makeGraph(newNode, exit, makeGraph(entry, newNode, graph, head(exprs)), tail(exprs));
		}
	}
}

public CFG makeGraph(Node entry, Node exit, CFG graph, Statement stmt) {
	//dprintln("Unhandled statement [<stmt>]");
	return graph;
}

public CFG makeGraph(Node entry, Node exit, CFG graph, list[Statement] stmts) {
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
	dprintln("Making graph");
	Node entry = 1;
	Node exit = 2;
	CFG graph = {<entry, exit>};
	return makeGraph(entry, exit, graph, stmt);
}
