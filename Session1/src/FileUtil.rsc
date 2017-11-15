module FileUtil

import IO;
import String;

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

