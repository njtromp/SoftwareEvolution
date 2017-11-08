module demo::common::ColoredTrees


// Define ColoredTrees with red and black nodes and integer leaves

data ColoredTree = leaf(int N)      
                 | red(ColoredTree left, ColoredTree right) 
                 | black(ColoredTree left, ColoredTree right);
          
// Count the number of red nodes
          
public int cntRed(ColoredTree t){
   int c = 0;
   visit(t) {
     case red(_,_): c = c + 1;      
   };
   return c;
}

// Compute the sum of all integer leaves

public int addLeaves(ColoredTree t){
   int c = 0;
   visit(t) {
     case leaf(int N): c = c + N;   
   };
   return c;
}

// Add green nodes to ColoredTree

data ColoredTree = green(ColoredTree left, ColoredTree right); 

// Transform red nodes into green nodes

public ColoredTree makeGreen(ColoredTree t){
   return visit(t) {
     case red(l, r) => green(l, r)   
   };
}