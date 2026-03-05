public class SaturdayClass {
  public static void main(String[] args) {
    int[] a = {9, 7, 6, 2, 100, 500, 3, 1};
    //second smallest
    System.out.println(secondSmallestFinder(a));
    System.out.println(secondSmallestFinder2(a));
  }
  
  public static int secondSmallestFinder(int[] arr) {
    
    // Find smallest
    int smallest = arr[0];
    for(int i=0 ; i<arr.length ; i++) {
      if(arr[i] < smallest) {
        smallest = arr[i];

      }
    }
    
    // Find second smallest
    int secondSmallest =arr[0];
    for(int i=0 ; i<arr.length ; i++) {
      if(arr[i] == smallest) {
        continue;
      }
      if(arr[i] < secondSmallest) {
        secondSmallest = arr[i];
      }
    }
    
    return secondSmallest;
  }
  
  
  
  public static int secondSmallestFinder2(int[] arr) {
    
    int smallest = arr[0];
    int secondSmallest = arr[0];
    for(int i=0 ; i<arr.length ; i++) {
      if(arr[i] < smallest) {
        secondSmallest = smallest;
        smallest = arr[i];
      } else if (arr[i] < secondSmallest && arr[i] != smallest) {
        secondSmallest = arr[i]; 
      }
    }
    
    return secondSmallest;
  }
}


