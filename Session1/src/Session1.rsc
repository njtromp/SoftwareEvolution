module Session1

import IO;
import String;
import List;
import Set;

import analysis::m3::Core;

import lang::java::m3::Core;
import lang::java::m3::AST;

import DebugPrint;
import CyclomaticComplexity;

/**
 * Some very rudimentary and ugly metrics determination.
 * Just some code to get started with.
 */
 
 private set[int] registerLOC(set[int] linesOfCode, loc src) {
 	//linesOfCode += src.begin.line;
 	//linesOfCode += src.end.line;
 	return linesOfCode;
 }
 
public void determineMetrics(loc file) {
	str fileContent = readFile(file);
	list[str] lines = split("\n", fileContent);

	M3 model = createM3FromFile(file);
	
	ms = methods(model);
	println("Number of methods <size(ms)>");
	
	ast = createAstFromFile(file, false, javaVersion = "1.8");
	set[int] linesOfCode = {};
	visit (ast) {
		case /Declaration decl : linesOfCode = registerLOC(linesOfCode, decl.src);
		case /Expression expr : linesOfCode = registerLOC(linesOfCode, expr.src);
	}
	
	println("Volume: <size(fileContent)> bytes.");
	println("Lines: <size(lines)>.");
	println("LOC: <size(linesOfCode)>.");
	
	set[Declaration] models = {};
	models += ast;
	println(analyseComplexity(models));
}

public void runMetrics() {
	enterDebug(false);
	determineMetrics(|home:///Rascal.java|);

	//smallModels = createAstsFromDirectory(|home:///Projects/smallsql/src|, false);
	//println("SmallSQL #classes = <size(smallModels)>");
	//println(analyseComplexity(smallModels));
	
	//hsqlModels = createAstsFromDirectory(|home:///Projects/hsqldb/src|, false);
	//println("HslDb #classes = <size(hsqlModels)>");
	//println(analyseComplexity(hsqlModels));
	enterDebug(false);
}