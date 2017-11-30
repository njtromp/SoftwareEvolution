module Session2

import IO;
import util::FileSystem;
import duplication::TypeOne;

public void main(int duplicationThreshold = 6) {
	//detectDuplicates({|project://Session1/src/test/java/Duplicates.java|}, duplicationThreshold);
	detectDuplicates({|project://Session1/src/test/java/Duplicates.java|, |project://Session1/src/test/java/Duplicated.java|}, duplicationThreshold);
	//detectDuplicates(find(|project://SmallSql|, "java"), duplicationThreshold);
}