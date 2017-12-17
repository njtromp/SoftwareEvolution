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

public void main(loc project, int duplicationThreshold = 6, loc cloneClass1File = |home:///Desktop/clone-classes-1.txt|, loc cloneClass2File = |home:///Desktop/clone-classes-2.txt|, bool createVisuals = true, bool detectType1 = true, bool detectType2 = false) {
	println("======================");
	println("      Nico Tromp");
	println("----------------------");

	print("Loading files");
	map[str,list[str]] files = ();
	map[str,list[str]] rawFiles = ();
	int sloc = 0;
	for (f <- find(project, "java")) {
		rawFiles += (f.path : readFileLines(f));
		list[str] lines = removeSingleLineComments(removeMultiLineComments(rawFiles[f.path]));
		sloc += size(removeEmptyLines(lines));
		files += (f.path : lines);
	}
	println(".\nLines of code: <sloc>.");

	print("Loading AST");
	ast = createAstsFromEclipseProject(project, true);

	if (detectType1) {
		print(".\nDetecting Type-1 clones");
		SuffixTree type1Tree = detectType1Clones(files, ast, duplicationThreshold);
		println("\nAnalyzed <getAnalyzedType1BlocksCount()> blocks.");
		print("Detecting clone-classes");
		list[CloneClass] cloneClasses = detectCloneClasses(type1Tree, duplicationThreshold);
		printCloneSummary(project, rawFiles, cloneClasses, duplicationThreshold, sloc, cloneClass1File);
		if (createVisuals) {
			render("Type-1 clones (<project.authority>)", createVisualization(project, cloneClasses, files));
		}
	}
	
	if (detectType2) {
		print(".\nDetecting Type-2 clones");
		SuffixTree type2Tree = detectType2Clones(ast, duplicationThreshold);
		println("\nAnalyzed <getAnalyzedType2BlocksCount()> blocks.");
		print("Detecting clone-classes");
		cloneClasses = detectCloneClasses(type2Tree, duplicationThreshold);
		cloneClasses = removeFragments(cloneClasses);
		printCloneSummary(project, rawFiles, cloneClasses, duplicationThreshold, sloc, cloneClass2File);
		if (createVisuals) {
			render("Type-2 clones (<project.authority>)", createVisualization(project, cloneClasses, files));
		}
	}
	
	println("Done");
}

private void printCloneSummary(loc project, map[str, list[str]] files, list[CloneClass] cloneClasses, int duplicationThreshold, int sloc, loc cloneClassFile) {
	if (size(cloneClasses) > 0) {
		int clonedLines = sum([0] + [size(cc.sources) * size(cc.fragment) | cc <- cloneClasses]);
		println("\nFound <size(cloneClasses)> clone classes.");
		println("Containing <clonedLines> lines (<round(1000.0*clonedLines/sloc)/10.0>%).");
		println("-----------------------------------------------------------------");
		println("Biggest (occur) clone class:");
		printCloneClass(project, [head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size(cl1.sources) > size(cl2.sources);}))], files);
		println("-----------------------------------------------------------------");
		println("Biggest (files) clone class:");
		printCloneClass(project, [head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size({s.fileName | s <- cl1.sources}) > size({s.fileName | s <- cl2.sources});}))], files);
		println("-----------------------------------------------------------------");
		println("Biggest (lines) clone class:");
		printCloneClass(project, [head(sort(cloneClasses, bool(CloneClass cl1, CloneClass cl2){ return size(cl1.fragment) > size(cl2.fragment);}))], files);
		println("-----------------------------------------------------------------");
	
		writeFile(cloneClassFile, duplication::CloneClasses::toString(cloneClasses));
	} else {
		println("\nNo clones detected!");
	}
}

private list[CloneClass] removeFragments(list[CloneClass] cloneClasses) {
	return [ CloneClass(sources, []) | CloneClass(sources, _) <- cloneClasses];
}

private void printCloneClass(loc project, list[CloneClass] cloneClasses, map[str, list[str]] files) {
	for (line <- toStrings(project, cloneClasses, files)) println(line);
}
