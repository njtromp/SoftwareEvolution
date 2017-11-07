module CyclomaticComplexity

import List;
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
		for (clazz <- model.types) {
			classComplexities += analyseClass(clazz);
		}
	}
	return classComplexities;
}

private tuple[str, list[MethodComplexity]] analyseClass(Declaration clazz) {
	dprintln("Class = <clazz.name>");

	list[MethodComplexity] methodComlexities = [];
	
	for (aMethod <- clazz.body, \method(_, name, _, _, statements) := aMethod || \constructor(name, _, _, statements) := aMethod) {
		dprintln("Method = [<name>]");
		int complexity = cyclomaticComplexity(statements);
		dprintln("Cyclomatic Complexity = [<complexity>]");
		methodComlexities += <name, complexity>;
	}

	return <clazz.name, methodComlexities>;
}
// For more see: http://tutor.rascal-mpl.org/Rascal/Rascal.html#/Rascal/Libraries/lang/java/m3/AST/Declaration/Declaration.html
private int cyclomaticComplexity(Statement statements) {
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
		case \try(_, exceptions) : {
			cc += size(exceptions);
			dprintln("Try-Catch-(<size(exceptions)>)");
		}
		case \try(_, exceptions, finallyBlock) : {
			cc += size(exceptions);
			switch (<size(exceptions), isEmpty(finallyBlock.statements)>) {
				case <0, true>  : dprintln("Try");
				case <0, false> : dprintln("Try-Finally");
				case <_, true>  : dprintln("Try-Catch-(<size(exceptions)>). Usually handled by separatly!");
				case <_, false> : dprintln("Try-Catch-(<size(exceptions)>)-Finally");
			}
		}
		case \catch(_, _) : { 
			dprintln("Catch"); // Already counted with Try 
		}
	}
	return cc;
}
