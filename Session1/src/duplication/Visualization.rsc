module duplication::Visualization

import IO;
import Set;
import Map;
import List;
import String;
import vis::Figure;
import duplication::Type1;
import duplication::CloneClasses;

alias FileName = str;
alias FileContent = list[str];

public Figure createVisualization(list[CloneClass] cloneClasses, map[FileName, FileContent] files) {
	clonedFiles = uniqueFiles(cloneClasses);
	map[FileName, set[CloneClass]] clonesPerFile = ();
	set[CloneClass] emptySet = {};
	for (cloneClass <- cloneClasses, source <- cloneClass.sources) {
		clonesPerFile[source.fileName]? emptySet += {cloneClass};
	}
	
	return createGrid(cloneClasses, sort(clonedFiles), clonesPerFile);
}

private list[FileName] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}

private Figure createGrid(list[CloneClass] cloneClasses, list[FileName] fileNames, map[FileName, set[CloneClass]] clonesPerFile) {
	list[Figure] fileNameLabels = text("Clone classes") + [ text(head(reverse(split("/", fileName))), textAngle(-90)) | fileName <- fileNames];
	list[list[Figure]] cloneInFile = [ box(fillColor("PowderBlue")) + [ box( getColor(cloneClass, clonesPerFile, fileName) ) | fileName <- fileNames ] | cloneClass <- cloneClasses];
	return grid([fileNameLabels] + cloneInFile);
}

private FProperty getColor(CloneClass cloneClass, map[FileName, set[CloneClass]] clonesPerFile, FileName fileName) {
	return cloneClass in clonesPerFile[fileName] ? fillColor("Red") : fillColor("White");
}