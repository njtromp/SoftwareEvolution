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
import util::FileSystem;

import SLOC;
import Report;
import Metrics;
import Duplicates;
import Testability;
import ControlFlowGraph;
import CyclomaticComplexity;

import util::StringCleaner;
import util::Visualize;

public void main() {
	
	print("Analysing ");

	//projectUnderTest = |project://Session1|;
	//testFolders = {"/src/rascal/test/"};

	projectUnderTest = |project://SmallSql|;
	testFolders = {"/src/smallsql/junit/"};

	//projectUnderTest = |project://HsqlDB|;
	//testFolders = {"/src/org/hsqldb/test/"};
		
	set[loc] files = find(projectUnderTest, "java");
	print(".");
	
	ast = createAstsFromEclipseProject(projectUnderTest, true);
	print(".");

	// Volume and duplicates
	slocDup = determineDuplicates(files);
	totalSLOC = slocDup.sloc;
	print(".");
	
	list[MethodMetrics] metrics = [];
	className = "";
	isTest = false;
	// Analyse AST
	top-down visit (ast) {
		case cl:class(_, _, _, _) : {
			className = cl.decl.path;
			isTest = isATest(cl.src.path, testFolders);
		}
		case ctor:constructor(name, _, _, stmt) : {
			msloc = sloc(ctor);
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += metric = MethodMetrics("<ctor.src.path>/<name>", isTest, msloc, ccfg, ccwi);
		}
		case init:initializer(stmt) : {
			msloc = sloc(init);
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += metric = MethodMetrics("<init.src.path>/init()", isTest, msloc, ccfg, ccwi);
		}
		case mtd:method(_, name, _, _, stmt) : {
			msloc = sloc(mtd);
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			if (isTest) {
				metrics += MethodMetrics("<mtd.src.path>/<name>", isTest, msloc, ccfg, ccwi, countAsserts(stmt));
			} else {
				metrics += MethodMetrics("<mtd.src.path>/<name>", isTest, msloc, ccfg, ccwi);
			}
		}
	}
	print(".");

	// Unit size rating
	unitSizes = computeUnitSize(totalSLOC, metrics);
	print(".");
	
	// Complexity rating
	int cfgCC(MethodMetrics m) = m.ccfg;
	cfgComplexity = computeComplexity(metrics, cfgCC);
	print(".");
	int cwiCC(MethodMetrics m) = m.ccwi;
	cwiComplexity = computeComplexity(metrics, cwiCC);
	print(".");
	unitSizes = computeUnitSize(totalSLOC, metrics);
	
	Ratings ratings = Ratings(
		slocRating(totalSLOC),
		duplicationRating(slocDup),
		distributionRating(unitSizes),
		distributionRating(cfgComplexity),
		distributionRating(cwiComplexity),
		testabilityRating(totalSLOC, metrics)
	);

	println("\nAnalysis done.\n");
	
	// Reporting
	println("==================================================");
	println("Nico Tromp & Rob Kunst.");
	println("--------------------------------------------------");
	println("<projectUnderTest>");
	println("==================================================");
	printProjectRating(ratings);
	println("--------------------------------------------------");
	
	printVolumeRating(ratings.volume);	

	printDuplicationRating(ratings.duplication);

	printUnitSizeRating(ratings.unitSize);
		
	printComplexityRating("CFG", ratings.ccfg);	
	printComplexityRating("CWI", ratings.ccwi);	
	
	printTestabilityRating(ratings.testability);

	println("==================================================\n");
	println("Volume profile");
	printVolumeProfile(totalSLOC);
	println();

	println("Duplication profile");
	printDuplicationProfile(slocDup);
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

	println("Testability profile");
	printTestabilityProfile(metrics);
	println();	
	
	println("Done");
}