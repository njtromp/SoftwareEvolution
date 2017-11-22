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
import Metrics;
import util::FileSystem;
import ControlFlowGraph;
import Duplicates;
import CyclomaticComplexity;
import util::StringCleaner;
import util::Visualize;

private bool isATest(str path, set[str] testDirs) {
	for (testDir <- testDirs) {
		if (contains(path, testDir)) return true;
	}
	return false;
}

private int countAsserts(Statement stmt) {
	asserts = 0;
	top-down visit(stmt) {
		case m:\methodCall(_, name, _) : {
			if (startsWith(name, "assert")) {
				asserts += 1;
			}
		}
		case \methodCall(_, _, name, _) : {
			if (startsWith(name, "assert")) {
				asserts += 1;
			}
		}
	}
	return asserts;
}

public void main() {
	
	print("Analysing ");

	//projectUnderTest = |project://Session1|;
	//testFolders = {"/src/rascal/test/"};

	//projectUnderTest = |project://Session1/src/java/Duplicates.java|;
	projectUnderTest = |project://SmallSql|;
	testFolders = {"/src/smallsql/junit/"};

	//projectUnderTest = |project://HsqlDB|;
	//testFolders = {"/src/org/hsqldb/test/"};
	
	//set[loc] files = {|project://Session1/src/java/SimpleTest.java|};
	//set[loc] files = {|project://Session1/src/java/NiftyDuplicates.java|};
	//set[loc] files = {|project://SmallSql/src/smallsql/junit/TestTokenizer.java|};
	//set[loc] files = {|project://SmallSql//src/smallsql/junit/AllTests.java|};
	//set[loc] files = {|project://SmallSql//src/smallsql/database/StoreImpl.java|};
	//set[loc] files = {|project://HsqlDB/src/org/hsqldb/StatementDML.java|};
	//set[loc] files = {|project://HsqlDB/src/org/hsqldb/TransactionManagerMV2PL.java|};
	
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
	numberOfAsserts = 0;
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
			metrics += metric = MethodMetrics(isTest, msloc, ccfg, ccwi);
			//println("[<className>/<className>()] [<msloc>]");
		}
		case init:initializer(stmt) : {
			msloc = sloc(init);
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			metrics += metric = MethodMetrics(isTest, msloc, ccfg, ccwi);
			//println("[<className>/{}] [<msloc>]");
		}
		case mtd:method(_, name, _, _, stmt) : {
			msloc = sloc(mtd);
			ccfg = cyclomaticComplexityCFG(stmt);
			ccwi = cyclomaticComplexityCWI(stmt);
			if (isTest) {
				numberOfAsserts += countAsserts(stmt);
			};
			metrics += metric = MethodMetrics(isTest, msloc, ccfg, ccwi);
			//println("[<className>/<name>()] [<msloc>]");
		}
	}
	print(".");

	// Unit size rating
	unitSizes = computeUnitSize(totalSLOC, metrics);
	print(".");
	
	// Complexity rating
	int cfgCC(MethodMetrics m) = m.ccfg;
	cfgComplexity = computeComplexity(totalSLOC, metrics, cfgCC);
	print(".");
	int cwiCC(MethodMetrics m) = m.ccwi;
	cwiComplexity = computeComplexity(totalSLOC, metrics, cwiCC);
	print(".");

	println("\nAnalysis done.\n");
	
	// Reporting
	println("==================================================");
	println("Nico Tromp & Rob Kunst.");
	println("==================================================");
	printVolumeRating(totalSLOC);	

	printDuplicationRating(slocDup);

	printUnitSizeRating(unitSizes);
		
	printComplexityRating("CFG", cfgComplexity);	
	printComplexityRating("CWI", cwiComplexity);	

	println("==================================================\n");
	println("Volume profile, lines of code [<totalSLOC>]");
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
	
	println("Lines (test/production) <sloc([m|m<-metrics,m.isTest])*100/sloc([m|m<-metrics,!m.isTest])>%");
	println("Number of asserts [<numberOfAsserts>]");
	
	println("\nDone");
}