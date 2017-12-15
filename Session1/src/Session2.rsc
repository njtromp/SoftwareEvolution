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
			render("Type-1 clones (<project.authority>)", createVisualization(cloneClasses, files));
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
			render("Type-2 clones (<project.authority>)", createVisualization(cloneClasses, files));
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

private list[str] toStrings(loc project, list[CloneClass] cloneClasses, map[str, list[str]] files) {
	list[str] asString = ["--- Clone class ---"];
	for (cloneClass <- cloneClasses) {
		if (size(cloneClass.fragment) == 0) {
			// Type 2 clone handling
			for (source <- cloneClass.sources) {
				location = createCloneLocation(project, source);
				location.offset = sum([size(line) + 1 | line <- files[source.fileName][0 .. source.begin-1]]);
				location.length = sum([size(line) + 1 | line <- files[source.fileName][source.begin-1 .. source.end]]);
				asString += "<location>";
				asString += files[source.fileName][source.begin-1 .. source.end];
			}
		} else {
			// Type 1 clone handling (empty lines)
			for (source <- cloneClass.sources) {
				// By placing it here we have access to everything we need without passing everything as a parameter
				loc adjustForEmptyLines(loc location) {
					int line = location.begin.line - 1;
					endLine = location.begin.line - 1;
					lineCount = size(cloneClass.fragment);
					while (lineCount > 0) {
						if (!isEmpty(trim(files[source.fileName][line]))) {
							lineCount -= 1;
						}
						endLine += 1;
						line += 1;
					}
					location.end.line = endLine;
					return location;
				}
				
				location = createCloneLocation(project, source);
				location = adjustForEmptyLines(location);
				location.offset = sum([size(line) + 1 | line <- files[source.fileName][0 .. location.begin.line - 1]]);
				location.length = sum([size(line) + 1 | line <- files[source.fileName][location.begin.line - 1 .. location.end.line]]);
				asString += "<location>";
			}
			asString += cloneClass.fragment;
		}
	}
	return asString;
}

private loc createCloneLocation(loc project, SourceInfo source) {
	loc location = |project://Dummy|(0,0,<0,1>,<0,1>);
	location.authority = project.authority;
	location.path = source.fileName;
	location.end.line = source.end;
	location.begin.line = source.begin;
	return location;
}