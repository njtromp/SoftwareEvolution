package test.java;
public class Duplicates {
	public void method1() {
		int a = 1;
		method2();
	}
	
	public void method2() {
		int a = 1;
		
		if(a == 1) {
			int b = 2;			
		}
		
		if(b == 2) {
			int c = 3;			
		} else {
			int c = 4;
		}
		
		int b = 2;
	}
}