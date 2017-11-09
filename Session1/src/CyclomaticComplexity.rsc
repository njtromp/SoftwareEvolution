module CyclomaticComplexity

import IO;
import List;
import String;

import lang::java::m3::AST;

import DebugPrint;

alias Class = str;
alias Method = str;
alias Complexity = int;
alias MethodComplexity = tuple[Method, Complexity];
alias ClassComplexity = tuple[Class, list[MethodComplexity]];

public list[ClassComplexity] analyseComplexity(set[Declaration] models) {
	list[ClassComplexity] classComplexities = [];
	for (model <- models) {
		readFile(model.src);
		for (clazz <- model.types) {
			classComplexities += analyseClass(clazz);
		}
	}
	return sort(classComplexities, classComplexityOrder);
}

public tuple[str, list[MethodComplexity]] analyseClass(Declaration clazz) {
	dprintln("Class = <clazz.name>");

	str classSource = readFile(clazz.src);
	list[str] lines = split("\n", classSource);
	int msloc = size(lines);
	dprintln("Class-SLOC [<msloc>]");

	list[MethodComplexity] methodComplexities = [];
	
	for (aMethod <- clazz.body, \method(_, name, _, _, statements) := aMethod || \constructor(name, _, _, statements) := aMethod) {
		dprintln("Method = [<name>]");

		//str methodSource = readFile(aMethod.src);
		//list[str] lines = split("\n", methodSource);
		//int msloc = size(lines);
		//dprintln("Method-SLOC [<msloc>]");

		int complexity = cyclomaticComplexity(statements);
		dprintln("Cyclomatic Complexity = [<complexity>]");
		methodComplexities += <name, complexity>;
	}
	methodComplexities = sort(methodComplexities, methodComplexityOrder);
	return <clazz.name, methodComplexities>;
}

// For more see: http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html
//public int cyclomaticComplexity(Statement statements) {
public int cyclomaticComplexity(value statements) {
	int cc = 1;
	top-down visit(statements) {
		case \if(_, _) : {
			cc += 1;
			dprintln("If"); 
		}
		case \if(_, _, _) : { 
			cc += 1;
			dprintln("If-Else"); 
		}
		case \switch(_, cases) : { 
			cc += size(cases) / 2;
			dprintln("Switch"); 
		}
		case \do(_, _) : { 
			cc += 1;
			dprintln("Do");
		}
		case \while(_, _) : { 
			cc += 1;
			dprintln("While");
		}
		case \for(_, _, _) : {
			cc += 1;
			dprintln("For"); 
		}
		case \for(_, _, _, _) : {
			cc += 1;
			dprintln("For-With-Condition"); 
		}
		case \foreach(_, _, _) : { 
			cc += 1;
			dprintln("Foreach"); 
		}
		//case \try(_, exceptions) : {
		//	cc += size(exceptions);
		//	dprintln("Try-Catch-(<size(exceptions)>)");
		//}
		//case \try(_, exceptions, finallyBlock) : {
		//	cc += size(exceptions);
		//	switch (<size(exceptions), isEmpty(finallyBlock.statements)>) {
		//		case <0, true>  : dprintln("Try");
		//		case <0, false> : dprintln("Try-Finally");
		//		case <_, true>  : dprintln("Try-Catch-(<size(exceptions)>). Usually handled by separatly!");
		//		case <_, false> : dprintln("Try-Catch-(<size(exceptions)>)-Finally");
		//	}
		//}
		case \catch(_, _) : { 
			cc += 1;
			dprintln("Catch"); // Already counted with Try 
		}
	}
	return cc;
}

private bool methodComplexityOrder(MethodComplexity mc1, MethodComplexity mc2){
	enterDebug(false);
	dprintln("<mc1> <mc2>");
	int order = mc1[1] - mc2[1];
	if (order == 0) {
		order = mc1[0] < mc2[0] ? -1 : (mc1[0] > mc2[0] ? 1 : 0);
	}
	leaveDebug();
	return order > 0;
}

private bool classComplexityOrder(ClassComplexity cc1, ClassComplexity cc2 ) {
	enterDebug(false);
	dprintln("<cc1[0]> <cc2[0]>");
	int order;
	switch (<isEmpty(cc1[1]), isEmpty(cc2[1])>) {
		case <false, false> : order = head(cc1[1])[1] - head(cc2[1])[1];
		case <false, true>  : order = 1;
		case <true, false>  : order = -1;
		case <true, true>   : order = cc1[0] < cc2[0] ? -1 : (cc1[0] > cc2[0] ? 1 : 0);
	}
	leaveDebug();
	return order > 0;
}
