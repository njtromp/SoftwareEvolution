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

/**
 * Some very rudimentary and ugly metrics determination.
 * Just some code to get started with.
 */
 
public void determineMetrics(loc file) {
	println(createM3FromEclipseProject(file));
}

public void runMetrics() {
	testModel = createM3FromFile(|project://Session1/src/Rascal.java|);
	determineMetrics(|project://SmallSql|);
}