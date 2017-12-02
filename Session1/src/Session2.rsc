module Session2

import IO;
import List;
import String;
import util::ValueUI;
import util::FileSystem;
import lang::java::jdt::m3::AST;
import util::SuffixTree;
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

	print("\nDetecting Type I clones");
	int analyzedMethods = 0;
	visit (ast) {
		case \method(_, name, _, _, body) : {
			if (linesIn(body) >= duplicationThreshold && contains(body.src.path, "Duplicates")) {
			//if (linesIn(body) >= duplicationThreshold) {
				analyzedMethods += 1;
				content = files[body.src.path];
				analyze(content[body.src.begin.line-1..body.src.end.line], body.src.begin.line, duplicationThreshold);
			}
		}
	}
	text(root);
	print("\nAnalyzed <analyzedMethods> methods");

	println("\nDone");
}

private Node root = Node([], ());

private void analyze(list[str] lines, int cloneStart, int threshold) {
	list[str] suffix = [];
	for (i <- [size(lines)-1..-1]) {
		line = trim(lines[i]);
		if (!isEmpty(line)) {
			suffix += line;
			if (size(suffix) >= threshold) {
				root = put(root, suffix, cloneStart + i);
			}
		}
	}
}

private 	int linesIn(Statement stmt) = stmt.src.end.line - stmt.src.begin.line;
