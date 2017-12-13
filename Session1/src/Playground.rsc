module Playground

import IO;
import Node;
import List;
import String;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import util::ValueUI;
import util::ASTParser;
import util::SuffixTree;
import util::StringCleaner;


public void play() {
	//ast = createAstFromFile(|project://Session1/src/test/java/Duplicates.java|, true);
	ast = createAstFromFile(|project://Session1/src/test/java/SimpleJava.java|, true);
	//ast = createAstsFromEclipseProject(|project://SmallSql|, true);
	
	//println(ast.src.path);
	//list[str] lines = removeSingleLineComments(removeMultiLineComments(readFileLines(ast.src)));
	visit (ast) {
		case e:\enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body):{
			list[str] hashes = ["enum" + name] + hashAST(implements) + hashAST(constants) + hashAST(body);
		}
		case e:\enumConstant(str name, list[Expression] arguments, Declaration class):{
			list[str] hashes = ["enumConstant" + name] + hashAST(arguments) + hashAST(class);
		}
		case e:\enumConstant(str name, list[Expression] arguments):{
			list[str] hashes = ["enumConstant" + name] + hashAST(arguments);
		}
		case c:\class(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
			list[str] hashes = ["class"];// + hashAST(extends) + hashAST(implements) + hashAST(body);
		}
		case c:\class(list[Declaration] body):{
			list[str] hashes = ["unnamedclass"] + hashAST(body);
		}
		case c:\interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body):{
			list[str] hashes = ["interface-" + name] + hashAST(extends) + hashAST(implements) + hashAST(body);
		}
		//case f:\field(Type type, list[Expression] fragments):{
		//	list[str] hashes = // todo
		//}
		case i:\initializer(Statement initializerBody): {
			list[str] hashes = hashAST(initializerBody);
		}
	    case m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl)): {
	    		//println("hashing method <name>");
	    		
			//println("\n<m.src.path>.<name>(): (<b.src.begin.line>, <b.src.end.line>)");
	    		
			list[str] hashes = hashAST(m);
			
			println("--------Method <name> hashed--------");
			for (line <- hashes){
				println(line);
				println();
			}
			//println(hashes);
			println("------------------------------------");
		}
		
	    case m:\method(Type returnType, str name, list[Declaration] parameters, list[Expression] exceptions): {
			list[str] hashes = ["method(" + intercalate(",", hashAST(parameters)) + ")"];
		}
		
		case c:\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, b:\block(impl)): {
			list[str] hashes = ["constructor(" + intercalate(",", hashAST(parameters)) + ")"] + hashAST(impl);
		}
	 //   case v:\variables(Type \type, list[Expression] \fragments){
		//	// todo
		//}
	 //   case t:\typeParameter(str name, list[Type] extendsList){
		//	// todo
		//}
	    case p:\parameter(Type \type, str name, int extraDimensions): {
			list [str] hashes = ["param"];
		}
	 //   case v:\vararg(Type \type, str name): {
		//	//todo
	
		//}
	}
}
