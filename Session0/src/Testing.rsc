module Testing

import List;
import IO;

// Just for testing :-).

public str typeOf(value v) {
	switch(v) {
		case str s : return "It\'s a String";
		case bool b : return "It\'s a Boolean";
		default : return "It\'s samething else!";
	} 
}

public str volgendeRegel = "Hier zit een\nlinebreak in";

public str geenVolgendeRegel(bool waar) {
	if (waar) 
		return volgendeRegel;
	else
		return "NIKS";
}

public str switchError(int choice) {
	switch (choice) {
		case 1  : return volgendeRegel;
		case 2  : return "Hier zit ook\neen volgende\' regel in...";
		default : return "Anders";
	}
} 

public void printDemo() {
	println("Dit staat \n op de volgende regel.");
}

public data Color = red(int level) | blue(int level);

public list[value] lijst = ["Nico", "Evelie", 0, false];

public map[int, str] hexdigits = (0:"0", 1:"1", 2:"2", 3:"3", 4:"4", 5:"5", 6:"6", 7:"7", 8:"8", 9:"9", 10:"A", 11:"B", 12:"C", 13:"d", 14:"E", 15:"F");

public data ColoredTree =
      leaf(int N)
    | red(ColoredTree left, ColoredTree right)
    | black(ColoredTree left, ColoredTree right);
    
public ColoredTree CT = red(black(leaf(1), red(leaf(2),leaf(3))), black(leaf(3), leaf(4)));  

public void printTree(ColoredTree tree) {
	switch (tree){
	case red(left, right): {
	     print("Red(");
	     printTree(left);
	     print(", ");
	     printTree(right);
	     println(")");
     }
	case black(left, right): {
	     print("Black(");
	     printTree(left);
	     print(", ");
	     printTree(right);
	     println(")");
	}
	case leaf(int v):
	     print("<v>");
	}
}

public int double(int x) { return 2 * x; }

public int triple(int x) { return 3 * x; }

public int power(int b, int p) {
	if (p == 0) {
		return 1;
	} else {
		return b * power(b, p-1);
	}
}

public int Power(int b, 0) { return 1; }
public default int Power(int b, int p) {return b * Power(b, p-1);} 

public int f(int x, int (int) multi){ return multi(x); }

public bool isPalindrome(list[str] words){ 
	return words == reverse(words); 
}

bool IsSorted(list[int] lijst) {
	//return all(int i <- [1..size(lijst)], lijst[i-1] <= lijst[i]);
	return !any(int i <- [1..size(lijst)], lijst[i-1] > lijst[i]);
}

public lrel[int,int,int] niceTriangles(int n) {
	return [<a,b,c> | int a <- [1..n], int b <- [a+1..n], int c <- [b+1..n], a*a + b*b == c*c];
}

public list[int] sort2(list[int] numbers){
  switch(numbers){
    case [*int nums1, int p, int q, *int nums2]:
       if(p > q){
          return sort2(nums1 + [q, p] + nums2);
       } else {
       	  fail;
       }
     default: return numbers;
   }
}

public str squaresTemplate(int N) 
  = "Table of squares from 1 to <N>
    '<for (int I <- [1 .. N + 1]) {>
    '  <I> squared = <I * I><}>
    ";
    
public void FizzBuzz() {
	for (i <- [1..101]) {
		switch (<i % 3, i % 5>) {
			case <0, 0> : println("FizzBuzz");
			case <0, _> : println("Fizz");
			case <_, 0> : println("Buzz");
			default     : println(i);
		}
	}
}

public int fact (int n) {
    if (n <= 1) {
	return 1;
    } else {
	return n * fact (n-1);
    }
}


public void rashadTest() {
	for (<ii,jj> <- [<i,j> | int i <- [0..5], int j <- [0..5]]) {
	    	bool b = ii < jj;
		println("<ii> lt <jj> = <b>");
	    	b = ii == jj;
		println("<ii> eq <jj> = <b>");
	    	b = ii > jj;
		println("<ii> gt <jj> = <b>");
	    b = ii < jj || ii == jj || ii > jj;
		println("<ii> true <jj> = <b>");
	}
}

public bool allwaysTrue(int i, int j) {
	return i < j || i == j || i > j;
}