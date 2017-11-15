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

public void testing() {
	
	println("Creating ASTs");
	//ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionArithmetic.java|, true);
	ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstsFromEclipseProject(|project://HsqlDB|, true);
	println("ASTs created");

	print("Analysing");
	
	list[MethodMetrics] metrics = [];
	visit (ast) {
		case m:method(_, name, _, _, stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(sloc(stmt), ccfg, ccwi);
			//if (name == "ifTest")
				//render(createVisualisation(makeGraph(stmt)));
			
		}
		case c:constructor(name, _, _, stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(sloc(stmt), ccfg, ccwi);
		}
		case i:initializer(stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(sloc(stmt), ccfg, ccwi);
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
	
	println("Done");
}
