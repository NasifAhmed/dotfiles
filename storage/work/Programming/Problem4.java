public class Problem4 {
  public static void main(String[] args) {
    int limit = 100;
    int count = 1;
    while(true) {
      if(count>=limit) {
        break;
      }
      for(int i=0 ; i<count ; i++) {
        System.out.print('*');
      }
      System.out.print("\n");
      count++;
    }
  }
}