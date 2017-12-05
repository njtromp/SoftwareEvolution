module Session2

import IO;
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
	for (f <- find(project, "java")) {
		files += (f.path : removeSingleLineComments(removeMultiLineComments(readFileLines(f))));
	}

	print("\nLoading AST");
	ast = createAstsFromEclipseProject(project, true);

	print("\nDetecting Type-I clones");
	Node typeOneClones = detectTypeIClones(files, ast, duplicationThreshold);
	println("\nAnalyzed <getAnalyzedMethodsCount()> methods");
	print("Detecting clone-classes\n");
	detectCloneClasses(typeOneClones, duplicationThreshold);

	println("\nDone");
}
