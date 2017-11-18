/*
 * Licence
 */
package java;

import java.io.IOException;

/**
*
*/
public class SimpleJava {
	
	public SimpleJava() {
		if (true) {
			System.out.println();
		}
	}
	
	 static {
	 	System.out.println("There we go...");
	 }
	 
//	 static {
//		 System.out.println("Nog een keer...");
//	 }
//	 
//    public void nothing(int i) {
//         if (i < 10) {
//         	java.lang.System.out.println("Klein");
//         }
//         if (i < 10) {
//         	java.lang.System.out.println("Klein");
//         } else {
//         	java.lang.System.out.println("Groot");
//         	java.lang.System.out.println("Groot");
//         }
//         for (int j = 0; j < 10; j++) {
//         	System.out.println();
//         }
//
//        	System.out.println();
//
//         try {
//         	System.out.println();
//         } finally {
//         	System.out.println();
//         }
//
//         try {
//          	throw new IOException("bla");
//         } catch (IOException e) {
//         	System.out.println();
//         } finally {
//         	System.out.println();
//         }
//         /*
//          * Multiline comment
//          */
//         String[] namen = {"Nico", "Rob"};
//         for (String naam : namen) {
//         	System.out.println(naam);
//         }
//         switch ((int)(Math.random()*10)) {
//         	case 1 : System.out.println();
//         		break;
//         	case 2 : System.out.println();
//         		break;
//         	default : System.out.println();
//         }
//    }
//
//    public static boolean containsLetter(String s) {
//        for (int i = 0; i < s.length(); i++) {
//                if (Character.isLetter(s.charAt(i))) {
//                        return true;
//                }
//        }
//        return false;
//	}
//
//	  // other member fields... 
//    private boolean isVerified;
//    private int noOfA;
//    private int noOfB;
//
//    /*
//     * bla
//     */
//    // other member methods... 
//    public int getNumberOfDependents()
//    {
//        this.noOfB = this.noOfA;
//
//        if (this.isVerified)
//        {
//            this.noOfB++;
//        }
//
//        if (this.noOfB > 4)
//        {
//            this.noOfB = 4;
//        }
//
//        return this.noOfB;
//    }
//
//    /*
//     * bla
//     */
//    public void anotherCCTest(int a, int b) {
//	    	if (a > 10) {
//	    		if (b > 10) {
//	    			System.out.println();
//	    		} else {
//	    			System.out.println();
//	    		}
//	    	}
//		System.out.println();
//    }
//    
//    public void ifTest() {
//    		if (true) {
//    			System.out.println(1);
//    		} else if (false) {
//    			System.out.println(2);
//    		} else if (false) {
//    			System.out.println(3);
//    		} else {
//    			System.out.println(4);
//    		}
//    }
//    
//    public void infix(int a, int b) {
//    		if (a < 0 && b > 0) {
//    			System.out.println("Hello");
//    		}
//    }
//    
//    public void switchCC3(int a) {
//        switch (a) {
//	     	case 1 : break;
//	     	case 2 : break;
//	     	default :
//	     }
//    }
//    
//    public void ifElseIfElseCC3(int a) {
//    		if (a == 1) {
//    		} else if (a == 2) {
//    		} else {
//    		}
//    }
//    
    public void checkIfIfGraph(int a, int b) {
    		if (a < b) {
    			System.out.println("Kleiner");
    		}
    		if (a > b) {
    			System.out.println("Groter");
    		}
    }
    
    public void graphCheck(int a) {
//    		if (a != 0) {
//    			for (int i = 0; i < 10; i++) {
//  				System.out.println(i);
//    			}
//    		} else {
    			while (a < 0) {
    				a++;
    			}
//    		}
//    		try {
//    			new FileInputStream("");
//    		} catch (IOException e) {
//    			e.printStackTrace();
//    		} catch (IOException e) {
//    			e.printStackTrace();
//    		}
    }
    
}