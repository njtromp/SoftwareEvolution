module duplication::TypeOne

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;

public void detectDuplicates(set[loc] files, int duplicationThreshold) {
	print(".");
	int lineNr = 0;
	set[tuple[str, int]] emptySet = {};
	map[list[str], set[tuple[str, int]]] duplicateBlocks = ();
	for (f <- files) {
		print("\b<stringChar(charAt("|/-\\", lineNr % 4))>");
		// Start fresh
		lineNr = 0;
		list[str] codeBlock = [];
		list[tuple[str, int]] linesInBlock = [];
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		for (line <- lines) {
			lineNr += 1;
			line = trim(line);
			if (size(line) >= 0) {
				codeBlock += line;
				linesInBlock += <f.path, lineNr>;
				if (size(codeBlock) == duplicationThreshold) {
					set[tuple[str, int]] bla = toSet(linesInBlock);
 					duplicateBlocks[codeBlock] ? emptySet += bla;
					codeBlock = tail(codeBlock);
					linesInBlock = tail(linesInBlock);
				}
			}
		}
	}
	dups = sort(toList(union({ dups | dups <- range(duplicateBlocks), size(dups) > duplicationThreshold})));	
	print("\b.");

	str currentFile = "";	
	for (<fileName, l> <- dups) {
		if (currentFile != fileName){
			currentFile = fileName;
			println(fileName);
		}
		println(l);
	}
}
