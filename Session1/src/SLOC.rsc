module SLOC

import IO;
import Set;
import List;
import String;
import lang::java::m3::AST;
import Metrics;
import util::StringCleaner;

public int sloc(Statement stmt) {
	return countLines(stmt);
}

public int sloc(list[Statement] stmts) {
	return ( 0 | it + countLines(stmt) | stmt <- stmts);
}

public int sloc(Declaration decl) {
	return countLines(decl);
}

public int sloc(list[Declaration] decls) {
	return ( 0 | it + countLines(decl) | decl <- decls);
}

public int sloc(set[Declaration] decls) {
	return ( 0 | it + countLines(decl) | decl <- decls);
}

public int sloc(set[loc] files) = sum([ linesOfCode(readFile(file)) | file <- files]);

public int linesOfCode(str text) {
	return size(split("\n", cleanFile(text)));
}

private int countLines(value body) {
    set[int] methodLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			methodLines += {l.begin.line};
			methodLines += {l.end.line};
		}
	}
	return size(methodLines);
}
