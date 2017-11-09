module Session1A

import IO;
import Set;
import List;
import String;
import util::ValueUI;
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import demo::McCabe; // :-)

// Calculates the SLOC for a method
public int sloc(Statement body) {
	set[int] methodLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			methodLines += {l.begin.line, l.end.line};
		}
	};
	return size(methodLines);
}

// Calculates the SLOC for a class
public int sloc(list[Declaration] body) {
	set[int] classLines = {};
	visit(body) {
		case /loc l : if (l.scheme == "project") {
			classLines += {l.begin.line, l.end.line};
		}
	};
	return size(classLines);
}

public void testing() {
	//ast = createAstsFromEclipseProject(|project://Session1|, true);
	ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	int totalLines = 0;
	visit (ast) {
		case class(name, _, _, body) : {
			totalLines += sloc(body);
		}
	};
	println("Total LOC [<totalLines>]");
	visit (ast) {
		case method(_, name, _, _, stmt) : println("[<name>] = <sloc(stmt)>");
		case constructor(name, _, _, stmt) : println("[Constructor] = <sloc(stmt)>");
		case initializer(stmt) : println("[Init] = <sloc(stmt)>");
	}
}
