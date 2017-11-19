module Duplicates

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;

private int MIN_DUP_SIZE = 6;

private str cleanFileContent(str text) {
	return removeMultiLineComments(removeSingleLineComments(convertToNix(text)));
}

public void main() {
	//set[loc] files = {|project://Session1/src/java/Duplicates.java|};
	//set[loc] files = {|project://SmallSql/src/smallsql/junit/TestTokenizer.java|};
	set[loc] files = find(|project://SmallSql|, "java");
	//set[loc] files = find(|project://HsqlDB|, "java");
	
	int lineNr = 0;
	list[str] codeBlock = [];
	list[int] linesInBlock = [];
	map[list[str], set[int]] duplicateBlocks = ();
	set[int] emptySet = {};
	for (f <- files) {
		str context = removeMultiLineComments(readFile(f));
		//println(context);
		print(".");
		for (line <- split("\n", context)) {
			line = trim(line);
			//if (!startsWith(line, "import ") && !startsWith(line, "package ") && !isEmpty(line)) {
			//if (!startsWith(line, "import ") && !startsWith(line, "package ")) {
			if (!isEmpty(line) && !startsWith(line, "//")) {
				lineNr += 1;
				codeBlock += line;
				linesInBlock += lineNr;
				if (lineNr > MIN_DUP_SIZE) {
					codeBlock = tail(codeBlock);
					linesInBlock = tail(linesInBlock);
					if (	duplicateBlocks[codeBlock]?) {
						duplicateBlocks[codeBlock] += toSet(linesInBlock);
					} else {
						duplicateBlocks += (codeBlock:emptySet);
					}
				}
			}
		}
	}
	//iprintln(duplicateBlocks);
	set[int] dupLines  = {};
	for (key <- domain(duplicateBlocks)) {
		dupLines += duplicateBlocks[key];
	}
	//println(sort(toList(dupLines)));
	println("\nNumber of duplicate lines [<size(dupLines)>]");
	println("SLOC [<lineNr>]");
}
