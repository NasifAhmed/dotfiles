public class Fibo {
  
  public static int adder(int a, int b, int c) {
    return a+b+c;
  }
  
  public static int asciiAdder(char firstCharacter, char secondCharacter) {
    return (int)firstCharacter+(int)secondCharacter;
  }
  
  public static void amarPrinter(String st) {
    System.out.println(st);
  }
  
  public static boolean vaagChecker(int num1, int num2) {
    if(num2%num1==0) {
      return true;
    } else {
      return false;
    }
  }
  
  public static int power(int a, int b) {
    if(b==1) {
      return a;
    } 
    else if(b==0) {
      return 1;
    } else {
      return a*power(a,b-1);
    }
    
  }
  
  
  public static void main(String[] args) {
    System.out.println(adder(3,4,5));
    System.out.println(asciiAdder('a','b'));
    System.out.println(power(2,3));
    amarPrinter("This is Metro IT");
    System.out.println(vaagChecker(4,24));
  }
}