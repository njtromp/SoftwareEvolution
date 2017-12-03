module ASTParser

import IO;
import List;
import Set;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public void parseFiles(loc location) {
	
	//ast = createAstsFromEclipseProject(location, true);
	
	ast = createAstFromFile(location, true);

	list[Declaration] methods = [];
	
	list[tuple[int, str]] astHashTable = [];
	
	
	// todo: parse the line number from the location
	int lineNumber = 1;
	
	visit (ast) {
		case m:\method(_, name, parameters, exceptions, implementation): {
			
			println(m.src);
			
			for (expression <- implementation) { 
				astHashTable += [<lineNumber, parseExpression(expression)>];
			}
		}
		case i:\import(name): {
			astHashTable += [<lineNumber, "import:" + name>];
		}
		case c:\class(name): {
			astHashTable += [<lineNumber, "class:" + name>];
		}
		case h:\interface(name): {
			astHashTable += [<lineNumber, "interface:" + name>];
		}
		//case p:\parameter(type, name, extraDimensions): {
		//	astHashTable += [<lineNumber, "param:" + type>];
		//}
	}
	
	println(astHashTable);
	
	//visit (ast.nodes) {
	//	case node n: println(n);
	//}
}

public void compareAST(loc location) {
	
	ast = createAstFromFile(location, true);

	for(x <- ast){
		for(y <- ast){
			compareNode(a, b);
		}
	}
	
}

public void compareNode(node a, node b){
	print("a: ");
	println(a.n);
	print("b: ");
	println(b.n);
}

public str parseExpression(expression){
	visit (expression) {
		case c:\methodCall(isSuper, name, arguments): {
			print("Method call: ");
			print(name); println(arguments);
			return "methodCall:" + name;
			break;
		}
		case infix:\infix(lhs, operator, righthandside): {
			print("Infix: ");
			println(operator);
			return "infix:" + operator;
			break;
		}
		case statement:\assignment(lhs, operator, righthandside): {
			print("Assignment: ");
			println(operator);
			return "assignment:" + operator;
			break;
		}
	}
}

public void detectClones(set[Declaration] ast) {
	for (a <- ast) {
		for (b <- ast) {
			// to be implemented
			println(a == b);
		}
	}
}

public void astTest() {
	//parseFiles(|project://SmallSql|);
	parseFiles(|project://Session1/src/test/java/Duplicates.java|);
}


public void astTest2() {
	compareAST(|project://Session1/src/test/java/Duplicates.java|);
}