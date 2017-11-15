module util::StringCleaner

public str removeEmptyLines(str text) {
	return visit(text) {
		case /^\s*\n/ => ""
		case /(\s*\n)+/ => "\n"
	};
}

public str removeLeadingSpaces(str text) {
	return visit(text) {
		case /^\s+/ => ""
	}
}

public str removeMultiLineComments(str text) {
	return visit(text) {
		case /\/\*([^\*]|(\*+[^*\/]))*\*+\// => ""
	}
}

public str removeSingleLineComments(str text) {
	return visit(text) {
		case /\/\/.*/ => ""
	};
}

public str convertToNix(str text) {
	return visit (text) {
		case /\r/ => "\n"
	};
}

public str cleanFile(str file) {
	return removeEmptyLines(removeMultiLineComments(removeSingleLineComments(convertToNix(file))));
}

// Ugly test names
test bool testRemoveEmptyLines1() = removeEmptyLines("")                      == "";
test bool testRemoveEmptyLines2() = removeEmptyLines("\npublic")              == "public";
test bool testRemoveEmptyLines3() = removeEmptyLines("\n\npublic")            == "public";
test bool testRemoveEmptyLines4() = removeEmptyLines("public\n\n class")      == "public\n class";
test bool testRemoveEmptyLines5() = removeEmptyLines("public\n \n class")     == "public\n class";
test bool testRemoveEmptyLines6() = removeEmptyLines("public \n \t \n class") == "public\n class";
test bool testRemoveEmptyLines7() = removeEmptyLines("public\n \t \nclass")   == "public\nclass";
test bool testRemoveEmptyLines8() = removeEmptyLines("public\n\n\nclass")     == "public\nclass";

// TODO add tests for multiline comments

test bool testRemoveSingleLineComments1() = removeSingleLineComments("//")                   == "";
test bool testRemoveSingleLineComments2() = removeSingleLineComments("// Junk")              == "";
test bool testRemoveSingleLineComments3() = removeSingleLineComments("// Junk\nclass")       == "\nclass";
test bool testRemoveSingleLineComments4() = removeSingleLineComments("public// Junk\nclass") == "public\nclass";

test bool testRNConvertToNix()    = convertToNix("\r\n")     == "\n\n";
test bool testRNRConvertToNix()   = convertToNix("\r\n\r")   == "\n\n\n";
test bool testNRConvertToNix()    = convertToNix("\n\r")     == "\n\n";
test bool testNRNConvertToNix()   = convertToNix("\n\r\n")   == "\n\n\n";
test bool test_RN_ConvertToNix()  = convertToNix("_\r\n_")   == "_\n\n_";
test bool test_RNR_ConvertToNix() = convertToNix("_\r\n\r_") == "_\n\n\n_";
test bool test_NR_ConvertToNix()  = convertToNix("_\n\r_")   == "_\n\n_";
test bool test_NRN_ConvertToNix() = convertToNix("_\n\r\n_") == "_\n\n\n_";

test bool testRemoveLeadingSpaces() = removeLeadingSpaces(" a\n  b") == "a\nb";
