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

/*
 * This is even worse :-(. Cleaning nasty multiline comments with strings embedded within 
 * or embedded in strings failed misserably.
 * This is what we tried...
 * visit (text) {
 *	   case /<string:\".*[^\n]\">/ => "<string>"
 *	   case /\/\*([^\*]|(\*+[^\*\/]))*\*+\// => ""
 * }
 * And all kind of variantions. 
 */
public str removeMultiLineComments(str text) {
	bool insideComment = false;
	
	/*
	 * We split the text into lines and process these lines separately.
	 * Per line the positions of double-quotes and multi-line open- and close-tags
	 * are determined. Depending on the exact values and combinations of these markers
	 * the line or parts of it are removed and processed recursively. 
	 */
	str removeBastard(str text) {
		if (isEmpty(trim(text))) return text;
		
		int firstQuote = findFirst(text, "\"");
		int secondQuote = -1;
		if (firstQuote >= 0) {
			 secondQuote = findFirst(substring(text, firstQuote + 1), "\"");
			 if (secondQuote >= 0) {
			 	secondQuote = firstQuote + 1 + secondQuote;
			 }
		}
		int openTag = findFirst(text, "/*");
		int closeTag = findFirst(text, "*/");
		switch (<insideComment, firstQuote, secondQuote, openTag, closeTag>) {
			case <true, -1, -1, -1, -1> : return "";
			case <false, -1, -1, -1, -1> : return text;

			case <false, -1, -1, _, -1> : {
				insideComment = true;
				return substring(text, 0, openTag);
			}
			case <true, -1, -1, _, -1> : return "";

			case <false, -1, -1, -1, _> : return substring(text, 0, closeTag + 2) + removeBastard(substring(text, closeTag + 2));
			case <true, -1, -1, -1, _> : {
				insideComment = false;
				return removeBastard(substring(text, closeTag+2));
			}

			case <true, _, _, -1, -1> : return "";
			
			case <false, -1, -1, _, _> : {
				return substring(text, 0, openTag) + removeBastard(substring(text, closeTag + 2));
			}

			case <false, 0, -1, -1,-1> : {
				return text;
			}

			case <false, _, -1, -1,-1> :{
				if (charAt(text, firstQuote - 1) == 92) { // 92 is the ASCII value for '\'
					return substring(text, 0, firstQuote + 1) + removeBastard(substring(text, firstQuote + 1));
				} else if (charAt(text, firstQuote - 1) == 39 && charAt(text, firstQuote + 1) == 39) {
					return substring(text, 0, firstQuote + 2) + removeBastard(substring(text, firstQuote + 2));
				}
			}

			case <false, _, _, -1, -1> : {
				return substring(text, 0, secondQuote + 1) + removeBastard(substring(text, secondQuote + 1));
			}
			case <false, _, _, -1, _> : {
				if (firstQuote < closeTag && closeTag < secondQuote) {
					return substring(text, 0, secondQuote + 1) + removeBastard(substring(text, secondQuote + 1));
				}					
			}
			case <false, _, _, _, -1> : {
				if (firstQuote < openTag && openTag < secondQuote) {
					return substring(text, 0, secondQuote + 1) + removeBastard(substring(text, secondQuote + 1));
				}					
			}
			case <false, _, _, _, _> : {
				if (firstQuote < openTag && openTag < secondQuote && firstQuote < closeTag && closeTag < secondQuote) {
					return substring(text, 0, secondQuote + 1) + removeBastard(substring(text, secondQuote + 1));
				} else if (openTag < firstQuote && openTag < secondQuote && firstQuote < closeTag && secondQuote < closeTag) {
					return substring(text, 0,closeTag + 2) + removeBastard(substring(text, closeTag + 2));
				} else if (secondQuote < openTag) {
					return substring(text, 0, secondQuote + 1) + removeBastard(substring(text, secondQuote + 1));
				}
			}
		};
		println("Please check \<<insideComment>, <firstQuote>, <secondQuote>, <openTag>, <closeTag>\>\n[<text>]");
		return text;
	}
	
	list[str] removeEmptyLines(list[str] lines) = [ line | line <- lines, size(trim(line)) > 0];
	
	return intercalate("\n", removeEmptyLines([removeBastard(s) | s <- split("\n", text)]));
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
	return removeEmptyLines(removeMultiLineComments(removeSingleLineComments(convertToNix(file))));
}

test bool testCleanFile()                  = cleanFile("    	return \"\\\"\";") == "    	return \"\\\"\";";
test bool testCleanFileQuotesBetweenTags() = cleanFile(quotesBetweenTags) == quotesBetweenTags;
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

public str quotesBetweenTags = "    /** if the current array \"page\" is shared. This make sence for read only access but not if it will be write. */";
public str tagsAfterQuotes = "            try{st.execute(\"drop procedure sp_\"+tableName);}catch(Exception e){/* ignore it */}";
public str cleanedTagsAfterQuotes = "            try{st.execute(\"drop procedure sp_\"+tableName);}catch(Exception e){}";

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

str nastyEmbeddedMultiLineComment = "		final String SQL_3 = 
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
