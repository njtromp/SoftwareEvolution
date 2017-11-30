module Session2

import IO;
import duplication::TypeOne;

public void main(int duplicationThreshold = 3) {
	detectDuplicates({|project://Session1/src/test/java/Duplicates.java|}, duplicationThreshold);
	//detectDuplicates({|project://Session1/src/test/java/Duplicates.java|, |project://Session1/src/test/java/Duplicated.java|}, duplicationThreshold);
}