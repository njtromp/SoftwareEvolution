/*
 * Licence
 */
package rascal;

/**
*
*/
public class Rascal {
	
	public Rascal() {
		if (true) {
			System.out.println();
		}
	}
	
	 static {
	 	System.out.println("There we go...");
	 }
	 
    public void nothing(int i) {
         if (i < 10) {
         	java.lang.System.out.println("Klein");
         }
         if (i < 10) {
         	java.lang.System.out.println("Klein");
         } else {
         	java.lang.System.out.println("Groot");
         	java.lang.System.out.println("Groot");
         }
         for (int j = 0; j < 10; j++) {
         	System.out.println();
         }

        	System.out.println();

         try {
         	System.out.println();
         } finally {
         	System.out.println();
         }

         try {
         	System.out.println();
         } catch (Exception e) {
         	System.out.println();
         }

         try {
         	System.out.println();
         } catch (Exception e) {
         	System.out.println();
         } finally {
         	System.out.println();
         }
         /*
          * Multiline comment
          */
         String[] namen = {"Nico", "Rob"};
         for (String naam : namen) {
         	System.out.println(naam);
         }
         switch (i) {
         	case 1 : System.out.println();
         	case 2 : System.out.println();
         	default : System.out.println();
         }
    }

    public static boolean containsLetter(String s) {
        for (int i = 0; i < s.length(); i++) {
                if (Character.isLetter(s.charAt(i))) {
                        return true;
                }
        }
        return false;
	}

	  // other member fields... 
    private boolean isVerified;
    private int noOfA;
    private int noOfB;

    /*
     * bla
     */
    // other member methods... 
    public int getNumberOfDependents()
    {
        this.noOfB = this.noOfA;

        if (this.isVerified)
        {
            this.noOfB++;
        }

        if (this.noOfB > 4)
        {
            this.noOfB = 4;
        }

        return this.noOfB;
    }

    /*
     * bla
     */
    public void anotherCCTest(int a, int b) {
    	if (a > 10) {
    		if (b > 10) {
    			System.out.println();
    		} else {
    			System.out.println();
    		}
    	}
		System.out.println();
    }
}