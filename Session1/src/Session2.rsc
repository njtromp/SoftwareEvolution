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
	int sloc = 0;
	for (f <- find(project, "java")) {
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		sloc += size(removeEmptyLines(lines));
		files += (f.path : lines);
	}
	println(".\nLines of code: <sloc>.");

	print("Loading AST");
	ast = createAstsFromEclipseProject(project, true);

	print(".\nDetecting Type-I clones");
	SuffixTree typeOneClones = detectTypeIClones(files, ast, duplicationThreshold);
	println("\nAnalyzed <getAnalyzedBlocksCount()> blocks.");
	print("Detecting clone-classes");
	cloneClasses = detectCloneClasses(typeOneClones, duplicationThreshold);
	
	println("\nDone");
}
