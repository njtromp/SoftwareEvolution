module Session2

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import lang::java::jdt::m3::AST;
import util::StringCleaner;
import util::SuffixTree;
import duplication::TypeOne;
import duplication::CloneClasses;

public void main(loc project, int duplicationThreshold = 6) {
	println("======================");
	println("Nico Tromp & Rob Kunst");
	println("----------------------");

	print("Loading files");
	map[str,list[str]] files = ();
	map[str, int] slocPerFile = ();
	for (f <- find(project, "java")) {
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		slocPerFile += (f.path : size(removeEmptyLines(lines)));
		files += (f.path : lines);
	}
	println("\nLines of code: <sum(range(slocPerFile))>");

	print("Loading AST");
	ast = createAstsFromEclipseProject(project, true);

	print("\nDetecting Type-I clones");
	SuffixTree typeOneClones = detectTypeIClones(files, ast, duplicationThreshold);
	println("\nAnalyzed <getAnalyzedMethodsCount()> methods");
	print("Detecting clone-classes");
	detectCloneClasses(typeOneClones, duplicationThreshold);

	println("\nDone");
}
