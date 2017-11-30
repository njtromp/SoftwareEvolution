module duplication::TypeOne

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;

public data LineInfo = LineInfo(str fileName, int actual, int logical)
					 | LineInfo(str fileName, int actual, int logical, LineInfo other);

public void detectDuplicates(set[loc] files, int duplicationThreshold) {
	map[str, list[LineInfo]] uniqueLines = ();
	list[LineInfo] emptyLineInfo = [];
	int logicalNr = 0;
	for (f <- files) {
		int lineNr = 0;
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		for (line <- lines) {
			lineNr += 1;
			line = trim(line);
			if (!isEmpty(line)) {
				logicalNr += 1;
				if (uniqueLines[line]?) {
					lineInfo = LineInfo(split("/", f.path)[4], lineNr, logicalNr, uniqueLines[line][0]);
					uniqueLines[line] += [lineInfo];
				} else {
					lineInfo = LineInfo(split("/", f.path)[4], lineNr, logicalNr);
					uniqueLines += (line:[lineInfo]);
				}
			}
		}
	}
	println("-------------------------------------------------------");
	println("Unique line info");	
	println(uniqueLines);

	duplicatedLines = [ lineInfo | line <- uniqueLines, lineInfo:LineInfo(_, _, _, _) <- uniqueLines[line], size(uniqueLines[line]) > 1];
	println("-------------------------------------------------------");
	println("Duplicated lines");
	println(duplicatedLines);
	
	duplicatedLines = sort(dup(duplicatedLines), bool(LineInfo a, LineInfo b) { return a.logical < b.logical;	});
	println("-------------------------------------------------------");
	println("Duplicated lines (sorted)");
	println(duplicatedLines);
	
	fragments = detectFragments(duplicatedLines);
	println("-------------------------------------------------------");
	println("Fragments");
	println(fragments);
	
	fragments = [fragment | fragment <- fragments, size(fragment) >= duplicationThreshold];
	println("-------------------------------------------------------");
	println("Fragments (large enough)");
	println(fragments);

}

public list[list[LineInfo]] detectFragments(list[LineInfo] lines) {
	if (size(lines) > 1) {
		int next = 1;
		while (next < size(lines) && lines[next - 1].logical + 1 == lines[next].logical && lines[next - 1].other.logical + 1 == lines[next].other.logical) next += 1;
		if (next == size(lines)) {
			return [lines];
		} else {
			return [lines[0..next]] + detectFragments(lines[next..]);
		}
	} else {
		return [lines];
	}
}
