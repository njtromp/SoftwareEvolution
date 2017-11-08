module Session1

import IO;
import String;
import List;
import Set;
import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import DebugPrint;
import CyclomaticComplexity;

import util::StringCleaner;
import util::Metrics;

/**
 * Some very rudimentary and ugly metrics determination.
 * Just some code to get started with.
 */
 
public void determineMetrics(loc file) {
	println(createM3FromEclipseProject(file));
}

public void runMetrics() {
	determineMetrics(|project://SmallSql|);
}

public M3 testing() {
	testModel = createM3FromFile(|project://Session1/src/Rascal.java|);
	[ <methodName, linesOfCode(readFile(decl.src))> | methodName <- methods(model), decl <- model.declarations, decl.name == methodName ];
	return testModel;	
}