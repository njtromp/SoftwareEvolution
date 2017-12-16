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

private list[CloneClass] allCloneClasses; // Unmodified
private list[CloneClass] cloneClasses; // Holds active selection

public Figure createVisualization(list[CloneClass] newCloneClasses, map[FileName, FileContent] files) {
	allCloneClasses = newCloneClasses;

	cloneClasses = allCloneClasses;	
	clonedFiles = uniqueFiles(cloneClasses);
	map[FileName, set[CloneClass]] clonesPerFile = ();
	set[CloneClass] emptySet = {};
	for (cloneClass <- cloneClasses, source <- cloneClass.sources) {
		clonesPerFile[source.fileName]? emptySet += {cloneClass};
	}
	
	Figure classSelection() {
		return hcat([text("Clone classes"), combo(["All", "Single file", "Multiple files"], selectCloneClasses)], std(hresizable(false)));
	}
	
	Figure createFigure() {
		cloneGrid = createGrid(sort(clonedFiles), clonesPerFile);
		menuBar = hcat([classSelection()], vresizable(false));
		return vcat(menuBar + [scrollable(cloneGrid)]);
	}

	list[FProperty] noProps = [];
	return computeFigure(createFigure, noProps);
}

private list[FileName] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}

private void selectCloneClasses(str selection) {
	switch (selection) {
		case "All" : cloneClasses = allCloneClasses;
		case "Single file" : cloneClasses = [ cloneClass | cloneClass <- allCloneClasses, size({fileName | SourceInfo(fileName, _, _) <- cloneClass.sources}) == 1];
		case "Multiple files" : cloneClasses = [ cloneClass | cloneClass <- allCloneClasses, size({fileName | SourceInfo(fileName, _, _) <- cloneClass.sources}) > 1];
	}
}

private Figure createGrid(list[FileName] fileNames, map[FileName, set[CloneClass]] clonesPerFile) {
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
