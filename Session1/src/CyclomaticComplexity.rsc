module CyclomaticComplexity

import IO;
import Set;
import List;
import String;
import Relation;
import util::Math;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import demo::McCabe; // :-) Lets see what we can do with it...
import ControlFlowGraph;

public int cyclomaticComplexityCFG(Statement stmt) {
	return cyclomaticComplexity(makeGraph(stmt));
}

public int cyclomaticComplexityCWI(Statement stmt) {
	// From: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
	// See authors :-)
    int cc = 1;
    visit (stmt) {
        case \if(_,_) : cc += 1;
        case \if(_,_,_) : cc += 1;
        case \case(_) :  cc += 1;
        case \do(_,_) :  cc += 1;
        case \while(_,_) :  cc += 1;
        case \for(_,_,_) :  cc += 1;
        case \for(_,_,_,_) : cc += 1;
        case foreach(_,_,_) : cc += 1;
        case \catch(_,_): cc += 1;
        case \conditional(_,_,_) : cc += 1;
        case infix(_,"&&",_) : cc += 1;
        case infix(_,"||",_) : cc += 1;
    }
    return cc;
} 
