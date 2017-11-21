module \test::util::StringCleaner

import IO;
import List;
import String;

import util::StringCleaner;

test bool testCleanFile()                  = cleanFile("    	return \"\\\"\";") == "    	return \"\\\"\";";
test bool testCleanFileQuotesBetweenTags() = cleanFile(quotesBetweenTags) == "";
test bool testCleanFileTagsAfterQuotes()   = cleanFile(tagsAfterQuotes) == cleanedTagsAfterQuotes;

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

test bool testRemoveMultiLineCommentsSimple()          = removeMultiLineComments(simpleMultiLineComment) == "";
test bool testRemoveMultiLineComments()                = removeMultiLineComments(multiLineComment) == cleanMultiLineComment;
test bool testRemoveMultiLineCommentsWithString()      = removeMultiLineComments(multiLineCommentWithString) == cleanMultiLineCommentWithString;
test bool testRemoveMultiLineCommentsEmbedded()        = removeMultiLineComments(multiLineEmbedded)             == cleanMultiLineEmbedded;
test bool testRemoveNastyMultiLineComments()           = removeMultiLineComments(nastyEmbeddedMultiLineComment) == nastyEmbeddedMultiLineComment;
test bool testRemoveMultiLineWithEmbedEndTagInString() = removeMultiLineComments(nestedEndTagInString) == "";
test bool testRemoveMultiLineCommentsEmbeddedTags()    = removeMultiLineComments("if (line.equals(\"/*\") || line.equals(\"*/\")) {") == "if (line.equals(\"/*\") || line.equals(\"*/\")) {";
test bool testRemoveMuliLineCommentsNestedString()     = removeMultiLineComments(quotesBetweenTags) == "";
test bool testRemoveMultiLineCommentsFunkyConstruct()  = removeMultiLineComments("                + pref + \"\\\"org.hsqldb.test.BlaineTrig\'\", expect);") == "                + pref + \"\\\"org.hsqldb.test.BlaineTrig\'\", expect);";

test bool testSizeTestTokenizerCleaning()          = size(split("\n", cleanFile(readFile(|project://SmallSql/src/smallsql/junit/TestTokenizer.java|)))) == 105;

test bool testRemoveSingleLineComments1() = removeSingleLineComments("//")                   == "";
test bool testRemoveSingleLineComments2() = removeSingleLineComments("// Junk")              == "";
test bool testRemoveSingleLineComments3() = removeSingleLineComments("// Junk\nclass")       == "class";
test bool testRemoveSingleLineComments4() = removeSingleLineComments("public// Junk\nclass") == "public\nclass";
test bool testRemoveSingleLineCommentWithURL()     = removeSingleLineComments("String HTTPS = \"https://\";") == "String HTTPS = \"https://\";";
test bool testRemoveSingleLineCommentAfterString() = removeSingleLineComments("        addKeyWord( \"EXEC\",     EXECUTE); // alias for EXECUTE;") == "        addKeyWord( \"EXEC\",     EXECUTE); ";

test bool testRNConvertToNix()    = convertToNix("\r\n")     == "\n\n";
test bool testRNRConvertToNix()   = convertToNix("\r\n\r")   == "\n\n\n";
test bool testNRConvertToNix()    = convertToNix("\n\r")     == "\n\n";
test bool testNRNConvertToNix()   = convertToNix("\n\r\n")   == "\n\n\n";
test bool test_RN_ConvertToNix()  = convertToNix("_\r\n_")   == "_\n\n_";
test bool test_RNR_ConvertToNix() = convertToNix("_\r\n\r_") == "_\n\n\n_";
test bool test_NR_ConvertToNix()  = convertToNix("_\n\r_")   == "_\n\n_";
test bool test_NRN_ConvertToNix() = convertToNix("_\n\r\n_") == "_\n\n\n_";

public str quotesBetweenTags = "    /** if the current array \"page\" is shared. This make sence for read only access but not if it will be write. */";
str tagsAfterQuotes = "            try{st.execute(\"drop procedure sp_\"+tableName);}catch(Exception e){/* ignore it */}";
str cleanedTagsAfterQuotes = "            try{st.execute(\"drop procedure sp_\"+tableName);}catch(Exception e){}";

str simpleMultiLineComment = "/**
' * this will
' * be gone
' */";

str multiLineComment = " int a = 1;
' /**
' * this will
' * be gone
' */
' int b = 2;";
str cleanMultiLineComment = " int a = 1;
' int b = 2;";

str multiLineCommentWithString = " int a = 1;
' /**
' * this will
' */
' String name = \"RegEx\";
' /**
' * be gone
' */
' int b = 2;";
str cleanMultiLineCommentWithString = " int a = 1;
' String name = \"RegEx\";
' int b = 2;";


str multiLineEmbedded = "		final String SQL_3 = 
'           /* This must be removed*/
'           /** This must also be removed*/
'			\"SELECT 10/2 /* this should stay */ \";
";
str cleanMultiLineEmbedded = "		final String SQL_3 = 
'			\"SELECT 10/2 /* this should stay */ \";";

public str nastyEmbeddedMultiLineComment = "		final String SQL_3 = 
'			\"SELECT 10/2 /* this shoud be untouched \";
'		failureTest(SQL_3, 
'				\"Even with this nasty */ string.\";";

str toBeCleaned = "
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

str cleaned = "package java;
'public class DummyClass {
'        private void dummyMethod() {
'            if (true) {
'                int a = 1;
'            } else {
'                int a = -1;
'            }
'        }
'}";

str cleanDuplicate = "package java;
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

public str nestedEndTagInString = "        /**
'         * we read the lines from the start of one section of the script \"/*\"
'         */";
