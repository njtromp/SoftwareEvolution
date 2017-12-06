module ASTParser

import IO;
import List;
import Node;
import Set;
import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

import util::ValueUI;
import util::StringCleaner;

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

	visit(ast){
		case \compilationUnit(_, types): hash = hashAST(types);
		case \compilationUnit(_, _, types): hash = hashAST(types);
		case m:\method(_, name, parameters, exceptions, b:\block(stmts)): {
			println("creating hash");
			println(hashAST(stmts));
		}
		case e:\enum(name, _, _, _): {
			print("enum");
			println(name);
		}
		case \enum(_, _, tree1, tree2): hashAST(tree1 + tree2);
		case \enumConstant(_, tree): hashAST(tree);
		case \enumConstant(_, tree1, tree2): hashAST(tree1 + tree2);
		case v:\variables(\type, fragments): {
			print("variables ");
			print(\type);
			println(fragments);
		}
		case \class(_, extends, implements, body): hashAST(extends + implements + body);
		case \class(body): hashAST(body);
		case \interface(_, extends, implements, body): hashAST(extends + implements + body);
		
		case \field(_, tree): hashAST(tree);

		case \constructor(_, params, expression, _): hashAST(params + expression);
		case \variables(_, tree): hashAST(tree);
		
		case \annotationType(_, tree): hashAST(tree);
		case \parameter(t, name, val):  {
			print("parameter");
			print(t);
			print(name);
			println(val);
		}
		case \vararg(t, name):{
			print("vararg");
			print(t);
			print(name);
		}
		
	}
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
	compareAST(|project://Session1/src/test/java/SimpleTest.java|);
}

public str hashAST(list[Statement] stmts) {
	return intercalate("+", [ hashAST(stmt) | node stmt <- stmts]);
}

public str hashAST(list[Declaration] declarations) {
	return intercalate("+", [ hashAST(declaration) | node declaration <- declarations]);
}

// todo
public str hashAST(list[Expression] expressions) {
	return intercalate("+", [ hashAST(expression) | node expression <- expressions]);
}

public str hashAST(node tree) {
	return "<getName(tree)>_<intercalate("", [hashAST(child) | node child <- getChildren(tree)])>";
}

public str hashAST(Statement statement) {
	return "<getName(statement)>_<intercalate("", [hashAST(child) | node child <- getChildren(tree)])>";
}

public str hashAST(Expression expression) {
	// todo
}

public str hashAST(Declaration declaration) {
	return "<getName(declaration)>_<intercalate("", [hashAST(child) | node child <- getChildren(tree)])>";
}