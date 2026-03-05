public class ArrayTest2 {
  public static void main(String[] args) {
    int[] a = {1,2,5,10,4,2,2,1};
    printArray(a);
    largestNum(a);
    smallestNum(a);
    arrayAdder(a);
    sortArray(a);
    findIndex(4,a);
  }
  
  public static void printArray(int[] a) {
    for(int i=0 ; i<a.length ; i++) {
      System.out.print(a[i]);
      if(i<a.length-1) {
        System.out.print(",");
      } else {
        System.out.println();
      }
    }
  }

  public static void largestNum(int[] b) {
    int largest = b[0];
    for(int i=0 ; i<b.length ; i++) {
      if(b[i] > largest) {
        largest = b[i];
      }
    }
    System.out.println("Largest number : "+largest);
  }
 
   public static void smallestNum(int[] b) {
    int smallest = b[0];
    for(int i=0 ; i<b.length ; i++) {
      if(b[i] < smallest) {
        smallest = b[i];
      }
    }
    System.out.println("Smallest number : "+smallest);
  }
   
   
   public static void arrayAdder(int[] a) {
     int sum = 0;
     for(int i=0; i<a.length ; i++) {
       sum = sum + a[i];
     } 
     System.out.println("Sum is : "+sum);
   }
   

   
   public static void sortArray(int[] a) {
    for (int i = 0; i < a.length - 1; i++) {
        int smallestIndex = i;
        for (int j = i + 1; j < a.length; j++) {
            if (a[j] < a[smallestIndex]) {
                smallestIndex = j;
            }
        }
        int temp = a[i];
        a[i] = a[smallestIndex];
        a[smallestIndex] = temp;
    }
    printArray(a);
}
   
   
   
   
   
   
   
   public static void findIndex(int n, int[] a) {
     for(int i=0 ; i<a.length ; i++) {
       if(a[i] == n) {
         System.out.println("Found at "+i);
         break;
       }
     }
   }
   
   
   
   
}