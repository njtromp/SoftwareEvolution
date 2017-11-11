module DebugPrint

import IO;
import List;

private bool debug = false;
private list[bool] stack = [];

public void enterDebug(bool debugOn) {
	stack = push(debug, stack);
	debug = debugOn;
}

public void exitDebug() {
	<debug, stack> = pop(stack);
}

public void dprint(value msg) {
	if (debug) print(msg);
}

public void dprintln(value msg) {
	if (debug) println(msg);
}