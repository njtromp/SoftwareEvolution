module FileIndexer

import IO;
import List;
import String;
import Set;
import Map;

import lang::java::m3::AST;
import util::StringCleaner;

public void parseFiles(loc location) {

	map[str, set[tuple[loc, int]]] index = ();
	for (loc file <- findAllFiles(location, "java")){
		int i = 0;
		for (line <- split("\n", cleanFile(readFile(file)))) {
			if(index[line] ?) {
				index[line] = index[line] + {<file, i>};
			} else{
				index += (line : {<file, i>});
			}
			i = i + 1; 
		}
	}
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
