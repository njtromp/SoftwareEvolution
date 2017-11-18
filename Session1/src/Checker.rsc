module Checker

import IO;
import List;
import String;
import util::FileSystem;
import util::ValueUI;
import util::StringCleaner;

public void main() {
	set[loc] files = {|project://SmallSql/src/smallsql/junit/TestTokenizer.java|};
	//set[loc] files = find(|project://SmallSql|, "java");
	//set[loc] files = find(|project://HsqlDB|, "java");
	
	for (f <- files) {
		str context = readFile(f);
		print(".");
		cleanContext = split("\n", cleanFile(context));
		print("\b+");
		list[str] lines = [];
		for (line <- split("\n", removeMultiLineComments(convertToNix(context)))) {
			line = trim(line);
			if (!isEmpty(line) && !startsWith(line, "//")) {
				lines += line;
			}
		}
		print("\b*");
		if (size(cleanContext) != size(lines)) {
			println("\nFound a difference with [<f>] Cleaned [<size(cleanContext)>] Lines [<size(lines)>]\n");
			//writeFile(|file:///Users/nico/Desktop/Clean.java|, intercalate("\n", cleanContext));
			//writeFile(|file:///Users/nico/Desktop/Lines.java|, intercalate("\n", lines));
		}
	}
	
}