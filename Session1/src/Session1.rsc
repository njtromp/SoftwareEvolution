module Session1

import IO;
import String;
import List;

/**
 * Some very rudimentary and ugly metrics determination.
 * Just some code to get started with.
 * Should be using lang::java::m3::Core asap using createM3FromFile(|file:///...|)
 */
public void determineMetrics(loc file) {
	str fileContent = readFile(file);
	list[str] lines = split("\n", fileContent);
	
	
	
	println("Volume: <size(fileContent)> bytes.");
	println("Lines: <size(lines)>.");
}