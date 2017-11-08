module demo::lang::Exp::Concrete::WithLayout::Syntax

layout Whitespace = [\t-\n\r\ ]*; 

lexical IntegerLiteral = [0-9]+;

start syntax Exp
  = IntegerLiteral
  | bracket "(" Exp ")"
  > left Exp "*" Exp
  > left Exp "+" Exp
  ;