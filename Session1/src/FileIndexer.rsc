module FileIndexer

import IO;
import List;
import String;
import Set;
import Map;

import lang::java::m3::AST;
import util::StringCleaner;
import util::FileSystem;
import DateTime;

public void parseFiles(loc location) {
	
	//println(now());
	
	S = now(); 

	int i = 0;
	list[str] allLines = [];

	map[str, list[int]] index = ();
	for (loc file <- find(location, "java")){
		for (line <- split("\n", cleanFile(readFile(file)))) {
			allLines = allLines + line;
			if(index[line] ?) {
				index[line] = index[line] + i;
			} else{
				index += (line : [i]);
			}
			i = i + 1; 
		}
	}
	
	set[int] duplicateLineNumbers = {};
	
	// iterate over all lines that have at least 1 duplicate
	for (str line <- index){ 
		if (size(index[line]) > 1){
		
			// compare all duplicate lines with eachother
			for(int i <- [0 .. size(index[line]) - 1]){
				for(int j <- [i+1 .. size(index[line])]){
					if(j != i){
					
						// always add the first line to our potential duplicate block
						set[int] lineNumbers = {index[line][i], index[line][j]};
						bool duplicateBlock = true;
						int offset = 1;
						
						// while the next lines in our comparison are equal we add them to the potential blcok as well
						while(duplicateBlock){
							// get the line numbers
							int firstIndex = index[line][i] + offset;
							int secondIndex = index[line][j] + offset;
							// if in range of the file and the lines are equal, copy the line to the potential block
							// @todo Make sure we do not compare a line that is actually part of another file, because allLines contains all the files
							if (max([firstIndex, secondIndex]) < size(allLines) - 1 && allLines[firstIndex] == allLines[secondIndex]){
								lineNumbers = lineNumbers + {firstIndex, secondIndex};
							} else{
								duplicateBlock = false;
							}
							offset = offset + 1;						
						}
						// because lineNumbers contains both 'sets' that are duplicate, 
						//if this set is larger than 11 we are dealing with a duplicate block of at least 6 lines
						if (size(lineNumbers) > 11){
							// if so, add it to the total number of lines
							duplicateLineNumbers = duplicateLineNumbers + lineNumbers;
						}
					}
				}
			}
		}
	}	


	// we now have all duplicate lines that occur in a block of 6 or higher
	println("Total duplicate lines: <size(duplicateLineNumbers)>");
	E = now();
	println(createDuration(S,E));
	
}

/**
 * Finds all files with a given extension in all the subdirectories of a given folder.
 */
public set[loc] findAllFiles(loc baseDir, str extension) {
    set[loc] files = {};
	for (str entry <- listEntries(baseDir)) {
		loc location = baseDir + entry;
 		if (isDirectory(location)) {
 			files += findAllFiles(location, extension);
 		} else if (isFile(location)) {
 			if (endsWith(location.path, extension))
 				files += location;
 		} else {
 			println("Unknown location [<location>]");
 		}
	}
	return files;
} 
