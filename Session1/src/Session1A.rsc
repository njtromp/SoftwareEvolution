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
import SLOC;
import ControlFlowGraph;
import CyclomaticComplexity;
import Visualize;

public map[str, int] cwiStats = ();

public data MethodMetrics = MethodMetrics(int sloc, int ccfg, int ccwi);
public data Complexity = Complexity(int low, int moderate, int high, int veryHigh);

public int sloc(list[MethodMetrics] metrics) {
	return ( 0 | it + m.sloc | m <-metrics);
}

public void testing() {
	
	println("Creating ASTs");
	ast = createAstsFromEclipseProject(|project://Session1|, true);
	//ast = createAstFromFile(|project://SmallSql/src/smallsql/database/ExpressionArithmetic.java|, true);
	ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	//ast = createAstsFromEclipseProject(|project://HsqlDB|, true);
	println("ASTs created");

	println("Analysing...");
	
	list[MethodMetrics] metrics = [];
	visit (ast) {
		case m:method(_, name, _, _, stmt) : {
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += MethodMetrics(sloc(stmt), ccfg, ccwi);
			//if (name == "ifTest")
				//render(createVisualisation(makeGraph(stmt)));
			
		}
		//case constructor(name, _, _, stmt) : println("Metrics [Constructor] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexityCFG(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
		//case initializer(stmt) : println("Metrics [Init] = [loc:<sloc(stmt)>, cc:<cyclomaticComplexityCFG(stmt)> (<cyclomaticComplexityCWI(stmt)>)]");
	}
	totalSLOC = sloc(ast);

	// Volume rating
	totalMethodSLOC = ( 0 | it + m.sloc | m <- metrics);
	
	// Unit size rating
	
	// Complexity rating
	cfgComplexity = computeCFGComplexity(totalMethodSLOC, metrics);
	cwiComplexity = computeCWIComplexity(totalMethodSLOC, metrics);

	println("Analysis done.\n");
	// Reporting
	println("==================================================");
	println("Nico Tromp & Rob Kunst.");
	println("==================================================");
	printVolumeRating("M", totalMethodSLOC);	
	printVolumeRating("T", totalMethodSLOC);	
	
	println("Unit size:         ?");
		
	printComplexityRating("CFG", cfgComplexity);	
	printComplexityRating("CWI", cwiComplexity);	

	println("==================================================\n");
	println("Volume profile <totalMethodSLOC>/<totalSLOC> (methods/total) lines of code");
	println();
	println("Unit size profile(s)");
	println();

	println("Complexity profile (CFG)");
	printComplexityProfile(cfgComplexity);
	println();

	println("Complexity profile (CWI)");
	printComplexityProfile(cwiComplexity);
	println();
	
	println("Done");
}

public void printVolumeRating(str name, int sloc) {
	rating = "--";
	if (sloc < 66000) {
		rating = "++";
	} else if (sloc < 246000) {
		rating = " +";
	} else if (sloc < 665000) {
		rating = " o";
	} else if (sloc < 1310000) {
		rating = " -";
	}
	println("Volume (<name>):       <rating>");
}

public Complexity computeCFGComplexity(int totalSLOC, list[MethodMetrics] metrics) {
	list[MethodMetrics] lowRiskMethods = [];
	list[MethodMetrics] moderateRiskMethods = [];
	list[MethodMetrics] highRiskMethods = [];
	list[MethodMetrics] veryHighRiskMethods = [];
	for (m <- metrics) {
		if (m.ccfg <= 10) {
			lowRiskMethods += m;
		} else if (m.ccfg <= 20) {
			moderateRiskMethods += m;
		} else if (m.ccfg <= 50) {
			highRiskMethods += m;
		} else  {
			veryHighRiskMethods += m;
		}
	}
	return Complexity(sloc(lowRiskMethods) * 100 / totalSLOC,
		sloc(moderateRiskMethods) * 100 / totalSLOC,
		sloc(highRiskMethods) * 100 / totalSLOC,
		sloc(veryHighRiskMethods) * 100 / totalSLOC
	);	
}

public Complexity computeCWIComplexity(int totalSLOC, list[MethodMetrics] metrics) {
	list[MethodMetrics] lowRiskMethods = [];
	list[MethodMetrics] moderateRiskMethods = [];
	list[MethodMetrics] highRiskMethods = [];
	list[MethodMetrics] veryHighRiskMethods = [];
	for (m <- metrics) {
		if (m.ccwi <= 10) {
			lowRiskMethods += m;
		} else if (m.ccwi <= 20) {
			moderateRiskMethods += m;
		} else if (m.ccwi <= 50) {
			highRiskMethods += m;
		} else  {
			veryHighRiskMethods += m;
		}
	}
	return Complexity(sloc(lowRiskMethods) * 100 / totalSLOC,
		sloc(moderateRiskMethods) * 100 / totalSLOC,
		sloc(highRiskMethods) * 100 / totalSLOC,
		sloc(veryHighRiskMethods) * 100 / totalSLOC
	);	
}

public void printComplexityRating(str name,Complexity complexity) {
	str rating = "--";
	if (complexity.veryHigh == 0 && complexity.high == 0 && complexity.moderate <= 25) {
		rating = "++";
	} else if (complexity.veryHigh == 0 && complexity.high <= 5 && complexity.moderate <= 30) {
		rating = "+";
	} else if (complexity.veryHigh == 0 && complexity.high <= 10 && complexity.moderate <= 40) {
		rating = "o";
	} else if (complexity.veryHigh <= 5 && complexity.high <= 15 && complexity.moderate <= 50) {
		rating = "-";
	}
	println("Complexity (<name>): <rating>");
}

public void printComplexityProfile(Complexity complexity) {
	println("Very High: <complexity.veryHigh>");
	println("High:      <complexity.high>");
	println("Mod:       <complexity.moderate>");
	println("Low:       <complexity.low>");
}
