module util::Metrics

import String;
import List;

import util::StringCleaner;

public int countLines(str text) {
	return size(split("\n", text));
}

public int linesOfCode(str text){
	return countLines(cleanFile(text));
}
 