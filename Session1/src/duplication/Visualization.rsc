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

public Figure createVisualization(list[CloneClass] allCloneClasses, map[FileName, FileContent] files) {

	allClonedFiles = uniqueFiles(allCloneClasses);
	clonedFiles = allClonedFiles;
	cloneClasses = allCloneClasses;	

	map[FileName, set[CloneClass]] clonesPerFile = ();
	set[CloneClass] emptySet = {};
	for (cloneClass <- cloneClasses, source <- cloneClass.sources) {
		clonesPerFile[source.fileName]? emptySet += {cloneClass};
	}
	
	Figure fileSelection() {
		return hcat([text("File(s)"), combo(["All", "Single clone", "Multiple clones"], selectFiles)], std(hresizable(false)), std(left()));
	}

	void selectFiles(str selection) {
		switch (selection) {
			case "All" : clonedFiles = allClonedFiles;
			case "Single clone" : clonedFiles = [ clonedFile | clonedFile <- allClonedFiles, isSingleCloneFile(clonedFile, clonesPerFile)];
			case "Multiple clones" : clonedFiles = [ clonedFile | clonedFile <- allClonedFiles, isMultiCloneFile(clonedFile, clonesPerFile)];
		}
	}
	
	Figure classSelection() {
		return hcat([text("Clone classes"), combo(["All", "Single file", "Multiple files"], selectCloneClasses)], std(hresizable(false)), std(left()));
	}
	
	void selectCloneClasses(str selection) {
		switch (selection) {
			case "All" : cloneClasses = allCloneClasses;
			case "Single file" : cloneClasses = [ cloneClass | cloneClass <- allCloneClasses, isSingleFileClone(cloneClass)];
			case "Multiple files" : cloneClasses = [ cloneClass | cloneClass <- allCloneClasses, isMultiFileClone(cloneClass)];
		}
	}
	
	Figure createFigure() {
		cloneGrid = createGrid(cloneClasses, sort(clonedFiles), clonesPerFile);
		menuBar = hcat([fileSelection(), classSelection()], std(vresizable(false)), std(hresizable(false)), std(left()));
		return vcat(menuBar + [scrollable(cloneGrid)]);
	}

	list[FProperty] noProps = [];
	return computeFigure(createFigure, noProps);
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

private bool isSingleFileClone(CloneClass cloneClass) {
	return size({fileName | SourceInfo(fileName, _, _) <- cloneClass.sources}) == 1;
}

private bool isMultiFileClone(CloneClass cloneClass) {
	return size({fileName | SourceInfo(fileName, _, _) <- cloneClass.sources}) > 1;
}

private bool isSingleCloneFile(FileName fileName, map[FileName, set[CloneClass]] clonesPerFile) {
	return size(clonesPerFile[fileName]) == 1;
}

private bool isMultiCloneFile(FileName fileName, map[FileName, set[CloneClass]] clonesPerFile) {
	return size(clonesPerFile[fileName]) > 1;
}