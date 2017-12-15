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
	
	cloneGrid = createGrid(cloneClasses, sort(clonedFiles), clonesPerFile);
	menuBar = hcat([combo(["All", "Single file", "Most files", "Largest"], void(str s){ println(s);})], vresizable(false));
	return vcat(menuBar + [scrollable(cloneGrid)]);
}

private list[FileName] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}

private Figure createGrid(list[CloneClass] cloneClasses, list[FileName] fileNames, map[FileName, set[CloneClass]] clonesPerFile) {
	list[Figure] clones = text("Classes\\Clones") + [ box(fillColor("PowderBlue")) | _ <- cloneClasses];
	list[list[Figure]] clonesInFile = [ text(className(fileName)) + [ box( getColor(cloneClass, clonesPerFile, fileName) ) | cloneClass <- cloneClasses ] | fileName <- fileNames];

	return grid([clones] + clonesInFile);
}

private FProperty getColor(CloneClass cloneClass, map[FileName, set[CloneClass]] clonesPerFile, FileName fileName) {
	return cloneClass in clonesPerFile[fileName] ? fillColor("FireBrick") : fillColor("White");
}

private str className(FileName fileName) {
	return head(split(".", head(reverse(split("/", fileName)))));
}