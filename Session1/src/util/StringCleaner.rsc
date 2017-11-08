module util::StringCleaner

import IO;

public str removeEmptyLines(str text) {
	return visit(text) {
		case /^\s*\n/ => ""
		case /(\s*\n)+/ => "\n"
	};
}

public str removeMultiLineComments(str text) {
	return visit(text) {
		case /\/\*([^\*]|(\*+[^*\/]))*\*+\// => ""
	}
}

public str removeSingleLineComments(str text) {
	return visit(text) {
		case /\/\/.*/ => ""
	};
}

public str convertToNix(str text) {
	return visit (text) {
		case /\r/ => "\n"
	};
}

public str cleanFile(str file) {
	return removeEmptyLines(removeMultiLineComments(removeSingleLineComments(convertToNix(file))));
}
