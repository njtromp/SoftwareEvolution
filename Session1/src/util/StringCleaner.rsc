module util::StringCleaner

import IO;
import List;
import String;

public str removeEmptyLines(str text) {
	cleanedText = visit(text) {
		case /^[ \t]*\n/ => ""
		case /(\s*\n)+/ => "\n"
	};
	// Dirty hack :-(
	return endsWith(cleanedText, "\n") ? substring(cleanedText, 0, size(cleanedText) - 1) : cleanedText; 
}

public str removeMultiLineComments(str text) {
	return visit(text) {
		case /<string:\".*[^\n]\">/ => "<string>"
		case /\/\*([^\*]|(\*+[^\*\/]))*\*+\// => ""
	}
}

public str removeSingleLineComments(str text) {
	return visit(text) {
		case /\/\/.*/ => ""
	};
}

public str convertToNix(str text) {
	return replaceAll(text, "\r", "\n");
}

public str cleanFile(str file) {
	return removeEmptyLines(removeSingleLineComments(removeMultiLineComments(convertToNix(file))));
}

// Ugly test names ;-)
test bool testRemoveEmptyLines1()  = removeEmptyLines("")                       == "";
test bool testRemoveEmptyLines2()  = removeEmptyLines("\npublic")               == "public";
test bool testRemoveEmptyLines3()  = removeEmptyLines("\n\npublic")             == "public";
test bool testRemoveEmptyLines4()  = removeEmptyLines("public\n\n class")       == "public\n class";
test bool testRemoveEmptyLines5()  = removeEmptyLines("public\n \n class")      == "public\n class";
test bool testRemoveEmptyLines6()  = removeEmptyLines("public \n \t \n class")  == "public\n class";
test bool testRemoveEmptyLines7()  = removeEmptyLines("public\n \t \nclass")    == "public\nclass";
test bool testRemoveEmptyLines8()  = removeEmptyLines("public\n\n\nclass")      == "public\nclass";
test bool testRemoveEmptyLines9()  = removeEmptyLines("public\n\n\nclass")      == "public\nclass";
test bool testRemoveEmptyLines10() = removeEmptyLines("public\n\n\nclass\n\n")  == "public\nclass";
test bool testRemoveEmptyLines11() = removeEmptyLines(toBeCleaned)              == cleaned;

test bool testCleanFile() = cleanFile(toBeCleaned) == veryClean;

test bool testRemoveSimpleMultiLineComments()      = removeMultiLineComments(simpleMultiLineComment) == "";
test bool testRemoveMultiLineComments()            = removeMultiLineComments(multiLineComment) == cleanMultiLineComment;
test bool testRemoveMultiLineCommentsWithString()  = removeMultiLineComments(multiLineCommentWithString) == cleanMultiLineCommentWithString;
test bool testRemoveEmbeddedMultiLineComments()    = removeMultiLineComments(multiLineEmbedded)             == cleanMultiLineEmbedded;
test bool testRemoveNastyMultiLineComments()       = removeMultiLineComments(nastyEmbeddedMultiLineComment) == nastyEmbeddedMultiLineComment;
test bool testSizeTestTokenizerCleaning()          = size(split("\n", cleanFile(readFile(|project://SmallSql/src/smallsql/junit/TestTokenizer.java|)))) == 105;

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

public str simpleMultiLineComment = "/**
' * this will
' * be gone
' */";

public str multiLineComment = " int a = 1;
' /**
' * this will
' * be gone
' */
' int b = 2;";
public str cleanMultiLineComment = " int a = 1;
' 
' int b = 2;";

public str multiLineCommentWithString = " int a = 1;
' /**
' * this will
' */
' String name = \"RegEx\";
' /**
' * be gone
' */
' int b = 2;";
public str cleanMultiLineCommentWithString = " int a = 1;
'  
' String name = \"RegEx\";
'  
' int b = 2;";


public str multiLineEmbedded = "		final String SQL_3 = 
'           /* This must be removed*/
'           /** This must also be removed*/
'			\"SELECT 10/2 /* this should stay */ \";
";
public str cleanMultiLineEmbedded = "		final String SQL_3 = 
'           
'           
'			\"SELECT 10/2 /* this should stay */ \";
";

public str nastyEmbeddedMultiLineComment = "		final String SQL_3 = 
'			\"SELECT 10/2 /* this shoud be untouched \";
'		failureTest(SQL_3, 
'				\"Even with this nasty */ string.\";
'";

public str toBeCleaned = "
'package java;
'
'public class DummyClass {
'
'        private void dummyMethod() {
'
'            if (true) {
'                int a = 1;
'            } else {
'                int a = -1;
'
'            }
'
'        }
'
'}
";

public str cleaned = "package java;
'public class DummyClass {
'        private void dummyMethod() {
'            if (true) {
'                int a = 1;
'            } else {
'                int a = -1;
'            }
'        }
'}";

public str veryClean = "package java;
'public class DummyClass {
'private void dummyMethod() {
'if (true) {
'int a = 1;
'} else {
'int a = -1;
'}
'}
'}";

public str cleanDuplicate = "package java;
'public class Duplicates {
'public void method1() {
'int a = 1;
'int b = 2;
'int c = 3;
'int d = 4;
'}
'public void method2() {
'int a = 1;
'int b = 2;
'int c = 3;
'}
'public void method3() {
'int b = 2;
'int c = 3;
'int d = 4;
'}
'}"; 
