module duplication::Visualization

import IO;
import Set;
import Map;
import List;
import String;
import vis::KeySym;
import vis::Figure;
import util::Editors;
import duplication::Type1;
import duplication::CloneClasses;

alias FileName = str;
alias FileContent = list[str];

public Figure createVisualization(list[CloneClass] allCloneClasses, map[FileName, FileContent] files, map[FileName, FileContent] rawFiles) {

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
		return createGrid(cloneClasses, sort(clonedFiles), clonesPerFile);
	}
	Figure menuBar = hcat([fileSelection(), classSelection()], std(vresizable(false)), std(hresizable(false)), std(left()));
	list[FProperty] noProps = [];
	return vcat(menuBar + [scrollable(computeFigure(createFigure, noProps))]);
}

private list[FileName] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _, loc _) <- cloneClass.sources});
}

private Figure createGrid(list[CloneClass] cloneClasses, list[FileName] fileNames, map[FileName, set[CloneClass]] clonesPerFile) {
	list[Figure] clones = box(text("Classes\\Clones"), fillColor("LightBlue")) + [ box(fillColor("PowderBlue")) | _ <- cloneClasses];
	list[list[Figure]] clonesInFile = [ box(text(className(fileName)), fillColor("PowderBlue")) + [ cloneBox(cloneClass, fileName, clonesPerFile) | cloneClass <- cloneClasses ] | fileName <- fileNames];
	return grid([clones] + clonesInFile);
}

private Figure cloneBox(CloneClass cloneClass, FileName fileName, map[FileName, set[CloneClass]] clonesPerFile) {
	if (cloneClass in clonesPerFile[fileName]) {
		return box(vcat([cloneLocation(location) | SourceInfo(_, _, _, loc location) <- cloneClass.sources] + cloneFragment(cloneClass.fragment), std(vresizable(false)), top()), fillColor("FireBrick"));
	} else {
		return box(fillColor("LightSteelBlue"));
	}
}

private Figure cloneLocation(loc location) {
	return text("<className(location.path)>", onMouseDown(bool (int btn, map[KeyModifier, bool] mods) { edit(location); return true;}));
}

private Figure cloneFragment(Fragment fragment) {
	return scrollable(box(text(intercalate("\n", fragment)), fillColor("DarkRed"), onMouseDown(bool(int btn, map[KeyModifier,bool] mods){println(intercalate("\n", fragment)); return true;})), []);
}

private str className(FileName fileName) {
	return head(split(".", head(reverse(split("/", fileName)))));
}

private bool isSingleFileClone(CloneClass cloneClass) {
	return size({fileName | SourceInfo(fileName, _, _, loc _) <- cloneClass.sources}) == 1;
}

private bool isMultiFileClone(CloneClass cloneClass) {
	return size({fileName | SourceInfo(fileName, _, _, loc _) <- cloneClass.sources}) > 1;
}

private bool isSingleCloneFile(FileName fileName, map[FileName, set[CloneClass]] clonesPerFile) {
	return size(clonesPerFile[fileName]) == 1;
}

private bool isMultiCloneFile(FileName fileName, map[FileName, set[CloneClass]] clonesPerFile) {
	return size(clonesPerFile[fileName]) > 1;
}