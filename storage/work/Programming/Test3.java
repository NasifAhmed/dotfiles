public class Test3 {
  public static void main(String[] args) {
    reverse(1234135);
  }
  
  public static void reverse(int a) {
    int sum = 0;
    int lastDigit = 0;
    for(int i=0 ; a>0 ; i++) {
      lastDigit = a % 10;
      sum = sum + lastDigit;
      a = a/10;
    }
    System.out.println(sum);
  }
}