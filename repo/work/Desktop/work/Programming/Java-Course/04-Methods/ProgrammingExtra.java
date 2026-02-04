public class ProgrammingExtra {
  public static void main(String[] args) {
    int a = 5.35;
    float b = 100;
    char c = ' ';
    int result = 0;
    for(int i=5 ; i>0 ; i--) {
      if(i==4) {
        result = result + (int)c;
      }
      if(i==2) {
        result = result + a;
      } else if(i==1) {
        result = result + b;
      } else {
        result = result;
      }
    }
    System.out.println(result);
  }
}