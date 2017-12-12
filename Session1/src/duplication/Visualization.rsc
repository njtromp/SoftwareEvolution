module duplication::Visualization

import Set;
import Map;
import List;
import vis::Figure;
import duplication::TypeOne;
import duplication::CloneClasses;

public Figure createVisualization(list[CloneClass] cloneClasses, map[str, list[str]] files) {
	clonedFiles = sort(uniqueFiles(cloneClasses), bool(str fn1, str fn2){return size(files[fn1]) > size(files[fn2]);});
	
	return hvcat([ text(file) | file <- clonedFiles], std(gap(10)));
}

private list[str] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}