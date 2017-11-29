module duplication::TypeOne

import IO;
import Map;
import Set;
import List;
import String;
import util::FileSystem;
import util::StringCleaner;

public data LineInfo = LineInfo(str fileName, int actual, int logical);

public void detectDuplicates(set[loc] files, int duplicationThreshold) {
	map[list[str], list[LineInfo]] duplicateBlocks = ();
	list[LineInfo] emptyLineInfo = [];
	int logicalNr = 0;
	for (f <- files) {
		// Start fresh
		int lineNr = 0;
		list[str] codeBlock = [];
		list[LineInfo] linesInBlock = [];
		list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(f)));
		for (line <- lines) {
			lineNr += 1;
			line = trim(line);
			if (!isEmpty(line)) {
				logicalNr += 1;
				codeBlock += line;
				linesInBlock += LineInfo(f.path, lineNr, logicalNr);
				//linesInBlock += LineInfo("", lineNr, logicalNr);
				if (size(codeBlock) == duplicationThreshold) {
 					duplicateBlocks[codeBlock] ? emptyLineInfo += linesInBlock;
					codeBlock = tail(codeBlock);
					linesInBlock = tail(linesInBlock);
				}
			}
		}
	}
	dups = (block : duplicateBlocks[block] | block <- duplicateBlocks, size(duplicateBlocks[block]) > duplicationThreshold);
	//println(dups);

	blockInfos = [duplicateBlocks[block] | block <- dups];
	//println(blockInfos);
	
	classSets = sort({ logical | blockInfo <- blockInfos, LineInfo(_, _, logical) <- blockInfo[duplicationThreshold..]});
	//println(classSets);

	fragments = detectFragments(classSets, duplicationThreshold);
	println(fragments);

	blas = sort(range(dups));
	tuple[LineInfo, LineInfo] findOccurences(int logical) {
		for (bla <- blas) {
			int i = duplicationThreshold;
			while (i < size(bla) && bla[i].logical != logical) i += 1;
			if (i < size(bla)) {
				return <bla[i % duplicationThreshold], bla[i]>;
			}
		}
	}
	for (fragment <- fragments) {
		println("Clones");
		for (logical <- fragment) {
			<first, second> = findOccurences(logical);
			println("<first.fileName>:<first.actual>, <second.fileName>:<second.actual>");
		}
	}	
}

public list[list[int]] createSlidingBlocks(list[int] fragment, int duplicationThreshold) {
	return [fragment[startt..startt + duplicationThreshold] | startt <- [0..size(fragment)-duplicationThreshold+1]];
}

public list[list[int]] detectFragments(list[int] lines, int threshold) {
	if (size(lines) > threshold) {
		int next = threshold - 1;
		while (next < size(lines) && lines[next - 1] + 1 == lines[next]) next += 1;
		if (next == size(lines)) {
			return [lines];
		} else {
			return [lines[0..next]] + detectFragments(lines[next..], threshold);
		}
	} else {
		return [lines];
	}
}
