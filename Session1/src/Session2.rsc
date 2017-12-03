module Session2

import IO;
import List;
import String;
import util::ValueUI;
import util::FileSystem;
import lang::java::jdt::m3::AST;
import util::StringCleaner;
import duplication::TypeOne;

public void main(loc project, int duplicationThreshold = 6) {
	println("======================");
	println("Nico Tromp & Rob Kunst");
	println("----------------------");

	print("Loading files");
	map[str,list[str]] files = ();
	for (f <- find(project, "java")) {
		files += (f.path:removeSingleLineComments(removeMultiLineComments(readFileLines(f))));
	}

	print("\nLoading AST");
	ast = createAstsFromEclipseProject(project, true);

	print("\nDetecting Type-I clones");
	detectTypeIClones(files, ast, duplicationThreshold);
	print("\nAnalyzed <getAnalyzedMethodsCount()> methods");

	println("\nDone");
}
