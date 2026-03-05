public class Test2 {
  public static void main(String[] args) {
    int[] myNum = {5,3,2,6,7};
    
    int largest = 0;
    for(int i=0 ; i<myNum.length ; i++) {
      if(myNum[i] > largest) {
        largest = myNum[i];
      }
    }
    System.out.println(largest);
  }
}