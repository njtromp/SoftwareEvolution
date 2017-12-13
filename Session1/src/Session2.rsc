module Session2

import IO;
import Map;
import Set;
import List;
import String;
import vis::Render;
import util::Math;
import util::FileSystem;
import lang::java::jdt::m3::AST;
import util::StringCleaner;
import util::SuffixTree;
import duplication::Type1;
import duplication::Type2;
import duplication::CloneClasses;
import duplication::Visualization;

public void main(loc project, int duplicationThreshold = 6, loc cloneClass1File = |home:///Desktop/clone-classes-1.txt|, loc cloneClass2File = |home:///Desktop/clone-classes-2.txt|, bool generateVisuals = true ) {
	println("======================");
	println("Nico Tromp & Rob Kunst");
	println("----------------------");

	print("Loading files");
	map[str,list[str]] files = ();
	int sloc = 0;
	for (f <- find(project, "java")) {
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		sloc += size(removeEmptyLines(lines));
		files += (f.path : lines);
	}
	println(".\nLines of code: <sloc>.");

	print("Loading AST");
	ast = createAstsFromEclipseProject(project, true);

	print(".\nDetecting Type-1 clones");
	SuffixTree type1Clones = detectType1Clones(files, ast, duplicationThreshold);
	println("\nAnalyzed <getAnalyzedType1BlocksCount()> blocks.");
	list[CloneClass] cloneClasses = detectClones(type1Clones, duplicationThreshold, sloc, cloneClass1File);
	if (generateVisuals) {
		render("Type-1 clones (<project.authority>)", createVisualization(cloneClasses, files));
	}
	
	print(".\nDetecting Type-2 clones");
	SuffixTree type2Clones = detectType2Clones(ast, duplicationThreshold);
	println("\nAnalyzed <getAnalyzedType2BlocksCount()> blocks.");
	cloneClasses = detectClones(type2Clones, duplicationThreshold, sloc, cloneClass2File);
	if (generateVisuals) {
		render("Type-2 clones (<project.authority>)", createVisualization(cloneClasses, files));
	}
	
	println("Done");
}

private list[CloneClass] detectClones(SuffixTree clones, int duplicationThreshold, int sloc, loc cloneClassFile) {
	print("Detecting clone-classes");
	list[CloneClass] cloneClasses = detectCloneClasses(clones, duplicationThreshold);
	int clonedLines = sum([0] + [size(cc.sources) * size(cc.fragment) | cc <- cloneClasses]);
	println("\nFound <size(cloneClasses)> clone classes.");
	println("Containing <clonedLines> lines (<round(1000.0*clonedLines/sloc)/10.0>%).");
	println("-----------------------------------------------------------------");
	println("Biggest (occur) clone class:\n<duplication::CloneClasses::toString([head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size(cl1.sources) > size(cl2.sources);}))])>");
	println("-----------------------------------------------------------------");
	println("Biggest (files) clone class:\n<duplication::CloneClasses::toString([head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size({s.fileName | s <- cl1.sources}) > size({s.fileName | s <- cl2.sources});}))])>");
	println("-----------------------------------------------------------------");
	println("Biggest (lines) clone class:\n<duplication::CloneClasses::toString([head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size(cl1.fragment) > size(cl2.fragment);}))])>");
	println("-----------------------------------------------------------------");

	writeFile(cloneClassFile, duplication::CloneClasses::toString(cloneClasses));

	return cloneClasses;
}