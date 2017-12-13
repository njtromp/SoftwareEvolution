module duplication::Visualization

import Set;
import Map;
import List;
import String;
import vis::Figure;
import duplication::TypeOne;
import duplication::CloneClasses;

public Figure createVisualization(list[CloneClass] cloneClasses, map[str, list[str]] files) {
	clonedFiles = sort(uniqueFiles(cloneClasses), bool(str fn1, str fn2){return size(files[fn1]) > size(files[fn2]);});
	
	Figure createFileBox(str fileName) {
		return vcat([text(head(reverse(split("/", fileName))), popup(fileName)), createCloneBoxes(fileName, size(files[fileName]), cloneClasses)]);
	}

	bla = outline([], 30, size(20,30));
	clones = [ createFileBox(fileName) | fileName <- clonedFiles];
	return hvcat(clones + bla, std(gap(10)));
}

private list[str] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}

private FProperty popup(str msg) {
	return mouseOver(box(text(msg), resizable(false)));
}

private Figure createCloneBoxes(str fileName, int maxSize, list[CloneClass] cloneClasses) {
	cloneInfo = [ CloneClass([si], cloneClass.fragment) | cloneClass <- cloneClasses, si:SourceInfo(str fn, _, _) <- cloneClass.sources, fn == fileName];
	return box(vcat([box(size(clone.sources[0].begin, clone.sources[0].end), valign(1.0*clone.sources[0].begin / maxSize), popup("<intercalate("\n", clone.fragment)>")) | clone <- cloneInfo]), size(22, maxSize));
}
