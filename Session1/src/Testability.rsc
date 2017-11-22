module Testability

import Set;
import String;
import lang::java::m3::AST;

public bool isATest(str path, set[str] testDirs) {
	for (testDir <- testDirs) {
		if (contains(path, testDir)) return true;
	}
	return false;
}

public int countAsserts(Statement stmt) {
	asserts = 0;
	top-down visit(stmt) {
		case \methodCall(_, name, _) : {
			if (startsWith(name, "assert")) {
				asserts += 1;
			}
		}
		case \methodCall(_, _, name, _) : {
			if (startsWith(name, "assert")) {
				asserts += 1;
			}
		}
	}
	return asserts;
}

