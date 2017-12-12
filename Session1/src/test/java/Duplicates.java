package test.java;
public class Duplicates {
	public void method1() {
		int a = 1;
		int b = 2;
		int c = 3;
		int d = 4;
		int e = 5;
	}
	public void method2() {
		int a = 1;
		int b = 2;
		int c = 3;
		int d = 4;
		int e = 6;
	}
	public void method3() {
		{
		int a = 1;
		int b = 2;
		int c = 3;
		int d = 4;
		}
		int e = 6;
		int f = 7;
	}
//	public void method4() {
//		int b = 2;
//		int c = 3;
//		int d = 4;
//	}
}