
public class ArrayTest {
  public static void main(String[] args) {
    int[] numArray = {12, 156, 30, 201, 10000, 7, 100, 20, 78};
    
//    findGreatest(numArray);
    // 10000 print korbe
    
//    findSmallest(numArray);
    // 7 print korbe
    
//    getOddNumbers(numArray);
    
//    arrayPrinter(numArray);
    
    arrayDivider(numArray);
  }
  
  public static void findGreatest(int[] a) {
    int large = 0;
    for(int i=0 ; i<a.length ; i++) {
      if(a[i]>large) {
        large = a[i];
      }
    }
    System.out.println(large);
  }
  
  public static void findSmallest(int[] a) {
    int small = a[0];
    for(int i=0 ; i<a.length ; i++) {
      if(a[i]<small) {
        small = a[i];
      }
    }
    System.out.println(small);
  }
  
  public static void getOddNumbers(int[] a) {
    for(int i=0 ; i<a.length ; i++) {
      if(a[i]%2!=0) {
        System.out.println(a[i]);
      }
    }
  }
  
  public static void arrayPrinter(int[] a) {
    for(int i=0 ; i<a.length ; i++) {
      System.out.print(a[i]);
      if(i!=a.length-1){
        System.out.print(", ");
      } else {
        System.out.println();
      }
    }
  }
  
  public static void arrayDivider(int[] a) {
    int[] firstHalf = new int[a.length/2+1];
    int[] secondHalf = new int[a.length/2+1];
    
    for(int i=0 ; i<a.length/2 ; i++) {
      firstHalf[i] = a[i];
    }
    
    int k=0;
    for(int j=a.length/2 ; j<a.length ; j++) {
      secondHalf[k] = a[j];
      
      k++;
    }
    
    arrayPrinter(firstHalf);
    arrayPrinter(secondHalf);
  }
  
}