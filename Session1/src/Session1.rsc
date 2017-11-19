module Session1

import IO;
import String;
import List;
import Set;
import DateTime;
import analysis::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import DebugPrint;
import CyclomaticComplexity;
import FileIndexer;

import util::StringCleaner;
import Metrics;

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

public void findDuplicates() {
	parseFiles(|project://SmallSql|);
	//parseFiles(|project://Session1|);
}

public int sloc(set[loc] files) = sum({ linesOfCode(readFile(file)) | file <- files});

public lrel[loc,int,lrel[loc,int]] slocForMethodsPerClass() {
	model = createM3FromFile(|project://Session1/src/java/SimpleTest.java|);
	return [ <cl, linesOfCode(readFile(cdl.src)), [ <m, linesOfCode(readFile(mdl.src))> | m <- model.containment[cl], isMethod(m), mdl <- model.declarations, mdl.name == m]> | cl <- classes(model), cdl <- model.declarations, cdl.name == cl];
}

public lrel[loc,lrel[loc,int, set[loc]],int] testing() {
	model = createM3FromEclipseProject(|project://Session1|);
	return [ <cl, [ <m, sloc(model.declarations[m]), model.declarations[m]> | m <- model.containment[cl], isMethod(m)], sloc(model.declarations[cl])> | cl <-classes(model)];	
}

public void testing2() {
	visit(head(createAstFromFile(|project://Session1/src/java/SimpleTest.java|, true).types)) { 
		case /\method(_, name, _, _, stmt) : println("[<name>] [<cyclomaticComplexity(stmt)>]");
		//case /\constructor(_, name, _, _, stmt) : println("[<name>] [stmt]");
		//case /\bracket(_) : println("Bracket");
		//case /\class(name, _, _, body) : {
		//	println("Class [<name>]");
		//	visit (body) {
		//		case \catch(_, _) : { 
		//			dprintln("Catch"); // Already counted with Try 
		//		}
		//	};
		//}
	};
}

//public int cc(set[loc] methods) {
//	createAstFromEclipseFile();
//}

public lrel[loc,lrel[loc,int],int] testSmallSql() {
	//strt = now();

	model = createM3FromEclipseProject(|project://SmallSql|);
	//metrics = [ <cl, [ <m, sloc(model.declarations[m]), model.declarations[m]> | m <- model.containment[cl], isMethod(m)], sloc(model.declarations[cl])> | cl <-classes(model)];
	metrics = [ <cl, [ <m, sloc(model.declarations[m])> | m <- model.containment[cl], isMethod(m)], sloc(model.declarations[cl])> | cl <-classes(model)];

	//println("It took <now()-strt> to analyze SmallSql.");

	return metrics;
}
