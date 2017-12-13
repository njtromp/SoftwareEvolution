module duplication::Visualization

import Set;
import Map;
import List;
import String;
import vis::Figure;
import duplication::Type1;
import duplication::CloneClasses;

public Figure createVisualization(list[CloneClass] cloneClasses, map[str, list[str]] files) {
	clonedFiles = sort(uniqueFiles(cloneClasses), bool(str fn1, str fn2){return size(files[fn1]) > size(files[fn2]);});
	
	Figure createFileBox(str fileName) {
		return vcat([text(head(reverse(split("/", fileName))), popup(fileName)), createCloneBoxes(fileName, size(files[fileName]))]);
	}

	Figure createCloneBoxes(str fileName, int maxSize) {
		cloneInfo = [ CloneClass([si], cloneClass.fragment) | cloneClass <- cloneClasses, si:SourceInfo(str fn, _, _) <- cloneClass.sources, fn == fileName];
		return box(vcat([box(size(20, clone.sources[0].end - clone.sources[0].begin + 1), valign(1.0*clone.sources[0].begin / maxSize), showCloneInfo(clone)) | clone <- cloneInfo]), size(22, maxSize));
	}

	return hvcat([ createFileBox(fileName) | fileName <- clonedFiles], std(gap(10)));
}

private list[str] uniqueFiles(list[CloneClass] cloneClasses) {
	return toList({ fileName | cloneClass <- cloneClasses, SourceInfo(fileName, _, _) <- cloneClass.sources});
}

private FProperty showCloneInfo(CloneClass clone) {
	return popup("Lines (<clone.sources[0].begin>, <clone.sources[0].end>)\n\n<intercalate("\n", clone.fragment)>");
}
private FProperty popup(str msg) {
	return mouseOver(box(text(msg), resizable(false), right()));
}

