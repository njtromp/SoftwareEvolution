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

public int sloc(str text) = linesOfCode(text);

public lrel[loc,int,lrel[loc,int]] slocForMethodsPerClass() {
	model = createM3FromFile(|project://Session1/src/java/SimpleTest.java|);
	return [ <cl, sloc(readFile(cdl.src)), [ <m, sloc(readFile(mdl.src))> | m <- model.containment[cl], isMethod(m), mdl <- model.declarations, mdl.name == m]> | cl <- classes(model), cdl <- model.declarations, cdl.name == cl];
}

public M3 testing() {
	model = createM3FromFile(|project://Session1/src/java/SimpleTest.java|);
	//[ <methodName, linesOfCode(readFile(decl.src))> | methodName <- methods(model), decl <- model.declarations, decl.name == methodName ];
	//[ <cl,me> | cl <- classes(smallModel), me <- methods(smallModel)]
	//[ <cl,linesOfCode(readFile(cldecl.src)), [ <m, linesOfCode(readFile(mdecl.src))> | m <- smallModel.containment[cl], isMethod(m), mdecl <- smallModel.declarations, mdecl.name == m]> | cl <- classes(smallModel), cldecl <- smallModel.declarations, cldecl.name == cl]
	return model;	
}

public lrel[loc,int,lrel[loc,int]] slocForMethodsPerClassSmallSql() {
	model = createM3FromEclipseProject(|project://SmallSql|);
	return [ <cl, sloc(readFile(cdl.src)), [ <m, sloc(readFile(mdl.src))> | m <- model.containment[cl], isMethod(m), mdl <- model.declarations, mdl.name == m]> | cl <- classes(model), cdl <- model.declarations, cdl.name == cl];
}

