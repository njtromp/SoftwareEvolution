module Duplicates

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;
import Metrics;

private int MIN_DUP_SIZE = 6;

public SlocDup determineDuplicates(set[loc] files) {
	int lineNr = 0;
	set[int] emptySet = {};
	map[list[str], set[int]] duplicateBlocks = ();
	print(".");
	for (f <- files) {
		// Start fresh
		list[str] codeBlock = [];
		list[int] linesInBlock = [];
		str content = cleanFile(readFile(f));
		lines = split("\n", content);
		print("\b<stringChar(charAt("|/-\\", lineNr % 4))>");
		for (line <- lines) {
			line = trim(line);
			lineNr += 1;
			codeBlock += line;
			linesInBlock += lineNr;
			if (size(codeBlock) >= MIN_DUP_SIZE) {
				if (	duplicateBlocks[codeBlock]?) {
					duplicateBlocks[codeBlock] += toSet(linesInBlock);
				} else {
					duplicateBlocks += (codeBlock:toSet(linesInBlock));
				}
				codeBlock = tail(codeBlock);
				linesInBlock = tail(linesInBlock);
			}
		}
	}
	set[int] dupLines  = {};
	for (key <- domain(duplicateBlocks)) {
		s = size(duplicateBlocks[key]);
		dupLines += s > MIN_DUP_SIZE ? duplicateBlocks[key] : {};
	}
	numberOfDupLines = size(dupLines);
	
	print("\b.");
	return SlocDup(lineNr, numberOfDupLines);
}
