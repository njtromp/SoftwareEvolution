module Session1A

import IO;
import Set;
import List;
import String;
import Relation;
import util::Math;
import util::ValueUI;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::graphs::Graph;
import ControlFlowGraph;
import SLOC;
import CyclomaticComplexity;
import Metrics;
import Visualize;

private bool isATest(str path, set[str] testDirs) {
	for (testDir <- testDirs) {
		if (contains(path, testDir)) return true;
	}
	return false;
}

public void testing() {
	
	println("Creating ASTs");

	//ast = createAstsFromEclipseProject(|project://RascalTest|, true);
	//testDirs = {"/src/rascal/test/"};

	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionArithmetic.java|, true);
	//testDirs = {"/src/smallsql/junit/"};

	ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	testDirs = {"/src/smallsql/junit/"};

	//ast = createAstsFromEclipseProject(|project://HsqlDB|, true);
	//testDirs = {"/src/org/hsqldb/test/"};
	println("ASTs created");

	print("Analysing");
	
	list[MethodMetrics] metrics = [];
	bool isTest = false;
	packageName = "";
	className = "";
	visit (ast) {
		case \package(name) : packageName = name;
		case \package(_, name) : packageName = name;
		case c:class(name, _, _, _) : {
			className = name;
			println("[<packageName>/<className>]");
			isTest = isATest(c.src.path, testDirs);
		}
		case m:method(_, name, _, _, stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(isTest, sloc(stmt), ccfg, ccwi);
			//if (name == "ifTest")
				//render(createVisualisation(makeGraph(stmt)));
			
		}
		case c:constructor(name, _, _, stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(isTest, sloc(stmt), ccfg, ccwi);
		}
		case i:initializer(stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(isTest, sloc(stmt), ccfg, ccwi);
		}
	}
	print(".");
	totalSLOC = sloc(ast);
	print(".");

	// Volume rating
	totalMethodSLOC = ( 0 | it + m.sloc | m <- metrics);
	print(".");
	
	// Unit size rating
	unitSizes = computeUnitSize(totalMethodSLOC, metrics);
	print(".");
	
	// Complexity rating
	int cfgCC(MethodMetrics m) = m.ccfg;
	cfgComplexity = computeComplexity(totalMethodSLOC, metrics, cfgCC);
	print(".");
	int cwiCC(MethodMetrics m) = m.ccwi;
	cwiComplexity = computeComplexity(totalMethodSLOC, metrics, cwiCC);
	print(".");

	println("\nAnalysis done.\n");
	
	println("Lines (test/production) <sloc([m|m<-metrics,m.isTest])*100/sloc([m|m<-metrics,!m.isTest])>%");
	
	//printReport();
	
	println("Done");
}

private void printReport() {
	// Reporting
	println("==================================================");
	println("Nico Tromp & Rob Kunst.");
	println("==================================================");
	printVolumeRating("M", totalMethodSLOC);	
	printVolumeRating("T", totalMethodSLOC);	

	printUnitSizeRating(unitSizes);	
		
	printComplexityRating("CFG", cfgComplexity);	
	printComplexityRating("CWI", cwiComplexity);	

	println("==================================================\n");
	println("Volume profile <totalMethodSLOC>/<totalSLOC> (methods/total) lines of code");
	println();
	println("Unit size profile(s)");
	println();

	println("Unit size profile");
	printComplexityProfile(unitSizes);
	println();

	println("Complexity profile (CFG)");
	printComplexityProfile(cfgComplexity);
	println();

	println("Complexity profile (CWI)");
	printComplexityProfile(cwiComplexity);
	println();
}