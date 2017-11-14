module SLOC

import Set;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

alias SLOCInfo = tuple[str name, int sloc];

public bool orderSlocs(SLOCInfo si1, SLOCInfo si2) {
	switch (<si1.sloc > si2.sloc, si1.name > si2.name>) {
		case <true, _> : return true;
		case <false, true> : return true;
		default : return false;
	} 
}

public int sloc(Statement stmt) {
	return countLines(stmt);
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

public int countLines(value body) {
	set[int] methodLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			methodLines += {l.begin.line};
			methodLines += {l.end.line};
		}
	}
	return size(methodLines);
}

