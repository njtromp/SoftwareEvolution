module FileIndexer

import IO;
import List;
import String;
import Set;
import Map;

import lang::java::m3::AST;
import util::StringCleaner;
import util::FileSystem;

public void parseFiles(loc location) {
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
	
	list[list[str]] duplicateLines = [];
		
	set[int] duplicateLineNumbers = {};
		
	for (str line <- index){ 
		if (size(index[line]) > 1){
			for(int i <- [0 .. size(index[line]) - 1]){
				for(int j <- [i+1 .. size(index[line])]){
					if(j != i){
						list[str] duplicates = [];
						bool duplicateBlock = true;
						int offset = 1;
						while(duplicateBlock){
							int firstIndex = index[line][i] + offset;
							int secondIndex = index[line][j] + offset;
							if (max([firstIndex, secondIndex]) < size(allLines) - 1 && allLines[firstIndex] == allLines[secondIndex]){
								duplicates = duplicates + allLines[firstIndex];
								duplicateLineNumbers = duplicateLineNumbers + firstIndex;
								duplicateLineNumbers = duplicateLineNumbers + secondIndex;
							} else{
								duplicateBlock = false;
							}
							offset = offset + 1;						
						}
						if (size(duplicates) > 5){
							duplicateLines = duplicateLines + [duplicates];
						}
					}
				}
			}
		}
	}	
	
	//println(duplicateLines);
	//print(duplicateLineNumbers);
	println("Total duplicate lines: <size(duplicateLineNumbers)>");
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
