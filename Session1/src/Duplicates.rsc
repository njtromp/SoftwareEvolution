module Duplicates

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;

private int MIN_DUP_SIZE = 6;

public void main() {
	set[loc] files = {|project://Session1/src/java/Duplicates.java|};
	//set[loc] files = {|project://Session1/src/java/NiftyDuplicates.java|};
	//set[loc] files = {|project://SmallSql/src/smallsql/junit/TestTokenizer.java|};
	//set[loc] files = {|project://SmallSql//src/smallsql/junit/AllTests.java|};
	//set[loc] files = {|project://SmallSql//src/smallsql/database/StoreImpl.java|};
	//set[loc] files = find(|project://Session1|, "java");
	//set[loc] files = find(|project://SmallSql|, "java");
	//set[loc] files = find(|project://HsqlDB|, "java");
	//set[loc] files = find(|project://HsqlDB/src/org/hsqldb/StatementDML.java|, "java");
	//set[loc] files = find(|project://HsqlDB/src/org/hsqldb/TransactionManagerMV2PL.java|, "java");
	
	int lineNr = 0;
	set[int] emptySet = {};
	map[list[str], set[int]] duplicateBlocks = ();
	for (f <- files) {
		// Start fresh
		list[str] codeBlock = [];
		list[int] linesInBlock = [];
		// This order of cleaning takes care of some tricky nested comments styles
		//str content = removeSingleLineComments(removeMultiLineComments(convertToNix(readFile(f))));
		str content = cleanFile(readFile(f));
		lines = split("\n", content);
		print(".");
		for (line <- lines) {
			line = trim(line);
			lineNr += 1;
			if (line != "{" && line != "}") {
				codeBlock += line;
				linesInBlock += lineNr;
				if (size(codeBlock) == MIN_DUP_SIZE) {
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
	numberOfDupLines = size(union(range(duplicateBlocks)));
	println("\nNumber of duplicate lines [<numberOfDupLines>]");
	println("SLOC [<lineNr>]");
	dupPercentage = 100 * numberOfDupLines / lineNr;
	printDuplicationRating(dupPercentage);
}

public void printDuplicationRating(int dupPercentage) {
	rating = "--";
	if (dupPercentage <= 3) {
		rating = "++";
	} else if (dupPercentage <= 5) {
		rating = " +";
	} else if (dupPercentage <= 10) {
		rating = " o";
	} else if (dupPercentage <= 20) {
		rating = " -";
	}
	println("Duplication:      <rating>");
}
