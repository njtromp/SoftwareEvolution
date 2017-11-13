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

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \if(expression, ifBlock)) {
	dprintln("If");
	//<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info);
	//<ifNode, graph> = addNewNodeToEdge(newNode, exit, info);
	//return makeGraph(newNode, ifNode, makeGraph(entry, newNode, <newNode, graph>, expression), ifBlock);
	<ifNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(ifNode, exit, makeGraph(entry, ifNode, <ifNode, graph>, expression), ifBlock);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \if(_, ifBlock, elseBlock)) {
	dprintln("If-Else");
	<ifNode, graph> = addNewNodeToEdge(entry, exit, removeEdge(entry, exit, info));
	<elseNode, graph> = addNewNodeToEdge(entry, exit, <ifNode, graph>);
	return makeGraph(entry, elseNode, makeGraph(entry, ifNode, <elseNode, graph>, ifBlock), elseBlock);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \switch(_, cases)) {
	dprintln("Switch");
	return makeGraph(entry, exit, info, cases);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \case(_)) {
	dprintln("Case");
	return addNewNodeToEdge(entry, exit, info);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \defaultCase()) {
	dprintln("Default");
	//return addNewNodeToEdge(entry, exit, info);
	return info;
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \for(_, _, body)) {
	dprintln("For");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \for(_, _, _, body)) {
	dprintln("For-Conditional");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \foreach(_, _, body)) {
	dprintln("Foreach");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \do(body, _)) {
	dprintln("Do");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \while(_, body)) {
	dprintln("While");
	<newNode, graph> = addNewNodeToEdge(entry, exit, info);
	return makeGraph(entry, newNode, <newNode, graph>, body);
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


public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, infix(left, "&&", right)) {
	dprintln("Infix-&&");
	<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info); 
	return makeGraph(newNode, exit, makeGraph(entry, newNode, <newNode, graph>, left), right);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, infix(left, "||", right)) {
	dprintln("Infix-||");
	<newNode, graph> = insertNewNodeIntoEdge(entry, exit, info); 
	return makeGraph(newNode, exit, makeGraph(entry, newNode, <newNode, graph>, left), right);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, \conditional(condition, ifExpr, elseExpr)) {
	dprintln("Infix-||");
	<ifNode, graph> = addNewNodeToEdge(entry, exit, removeEdge(entry, exit, info));
	<elseNode, graph> = addNewNodeToEdge(entry, exit, <ifNode, graph>);
	return makeGraph(entry, elseNode, makeGraph(entry, ifNode, <elseNode, graph>, ifExpr), elseExpr);
}

public GraphInfo makeGraph(Node entry, Node exit, GraphInfo info, Expression expression) {
	return info;
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
			return makeGraph(entry, newNode, makeGraph(newNode, exit, <newNode, graph>, tail(stmts)), head(stmts));
		}
	}
}

public Graph[Node] makeGraph(Statement stmt) {
	dprintln("Making graph");
	GraphInfo info = makeGraph(1, 2, <2, {<1,2>}>, stmt);
	//iprintln(info.graph);
	return info.graph;
}


