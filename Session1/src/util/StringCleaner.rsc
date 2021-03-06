module util::StringCleaner

import IO;
import List;
import String;

public str removeEmptyLines(str text) {
	return intercalate("\n", removeEmptyLines(split("\n", text)));
}

public list[str] removeEmptyLines(list[str] lines) {
	return [ line | line <- lines, size(trim(line)) > 0];
}

/*
 * This is even worse :-(. Cleaning nasty multiline comments with strings embedded within 
 * or embedded in strings failed misserably.
 * This is what we tried...
 * visit (text) {
 *	   case /<string:\".*[^\n]\">/ => "<string>"
 *	   case /\/\*([^\*]|(\*+[^\*\/]))*\*+\// => ""
 *	   case /\/\*[\s\S]*?\*\//  => ""
 * }
 * And all kind of variantions. 
 */
public str removeMultiLineComments(str text) {	
	return intercalate("\n", removeMultiLineComments(split("\n", text)));
}

public list[str] removeMultiLineComments(list[str] lines) {
	bool insideComment = false;
	
	str removeMultiLine(str text) {
		if (insideComment) {
			int closeTag = findFirst(text, "*/");
			if (closeTag == -1) {
				// Plain line of comment
				return "";
			} else {
				// There is a closing tag
				int firstQuote = findFirst(text, "\"");
				if (firstQuote == -1 || firstQuote > closeTag) {
					// No double-quote before the closing tag, so we continue after the closing tag
					insideComment = false;
					return removeMultiLine(substring(text, closeTag + 2));
				} else {
					 // There is at least 1 double-quote bofore the close tag. Now we must be carefull....
					 list[int] quotes = findAll(text, "\"");
					 if (size(quotes) >= 2) {
					 	if (quotes[1] < closeTag) {
					 		insideComment = false;
					 		return removeMultiLine(substring(text, closeTag + 2));
					 	} else {
					 		return substring(text, 0, quotes[1] + 1) + removeMultiLine(substring(text, quotes[1] + 1));
					 	}
					 }
				}
			}
		} else {
			int openTag = findFirst(text, "/*");
			if (openTag == -1) {
				// No open tag so nothing to do
				return text;
			} else {
				// There is a open tag
				int firstQuote = findFirst(text, "\"");
				if (firstQuote == -1 || firstQuote > openTag) {
					// No double-quote in front of the open tag
					insideComment = true;
					return substring(text, 0, openTag) + removeMultiLine(substring(text, openTag + 2));
				} else {
					// There is at least 1 double-quote bofore the open tag. Now we must be carefull....
					 list[int] quotes = findAll(text, "\"");
					 if (size(quotes) >= 2) {
					 	if (quotes[1] < openTag) {
					 		insideComment = true;
					 		return substring(text, 0, openTag) + removeMultiLine(substring(text, openTag + 2));
					 	} else {
					 		return substring(text, 0, quotes[1] + 1) + removeMultiLine(substring(text, quotes[1] + 1));
					 	}
					 }
				}
			}
		}
		println("Please have a closer look at multi-line comment handling of:\n[<text>]");
		return text;
	}
	
	return [ removeMultiLine(line) | line <- lines];
}

public str removeSingleLineComments(str text) {
	return intercalate("\n", removeSingleLineComments(split("\n", text)));
}

public list[str] removeSingleLineComments(list[str] lines) {
	str removeSingleLine(str text) {
	 	marker = findFirst(text, "//");
		if (marker == -1) {
			return text;
		} else {
			if (isEmpty(trim(substring(text, 0, marker)))) {
				return "";
			} else {
				firstQuote = findFirst(text, "\"");
				if (firstQuote == -1) {
					return substring(text, 0, marker);
				} else if (firstQuote > marker) {
					return substring(text, 0, marker);
				} else {
					secondQuote = findFirst(substring(text, firstQuote + 1), "\"");
					if (secondQuote >= 0) {
					 	secondQuote = firstQuote + 1 + secondQuote;
					}
					if (firstQuote < marker && marker < secondQuote) {
						return substring(text, 0, secondQuote + 1) + removeSingleLine(substring(text, secondQuote + 1));
					} else if (secondQuote < marker) {
						return substring(text, 0, marker);
					}
				}
			}
		}
		println("Please have a closer look at single-line comment handling of:\n[<text>]");
		return text;
	}
	return [removeSingleLine(line) | line <- lines];
}

public str convertToNix(str text) {
	return replaceAll(text, "\r", "\n");
}

public str cleanFile(str file) {
	return removeEmptyLines(removeSingleLineComments(removeMultiLineComments(convertToNix(file))));
}

public list[str] cleanFile(list[str] file) {
	return removeEmptyLines(removeSingleLineComments(removeMultiLineComments(file)));
}
