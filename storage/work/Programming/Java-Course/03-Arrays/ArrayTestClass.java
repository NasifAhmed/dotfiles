public class TestClass {
  public static void main(String[] args) {
    System.out.println("Hello");
    int [] a = {500, 12, 55, 212, 123, 1, 41412, 3};
    // 1.A function that traverse and prints elements with loop
    printAll(a);
    // 2.A function that give sum of all elements in an array
    addAll(a);
    // 3.A function that finds the largest element in an array
    findLarge(a);
    // 4.A function that finds the largest element in an array
    findSmall(a);
    // 5.A function that sorts an array from small to large
    sortArray(a)
    // 6.A function that sorts an array from large to small
    sortArrayDec(a);
  }
  
  public static void print(String s) {
    System.out.println(s);
  }
  
  public static void printAll(int[] arr) {
    for(int i=0 ; i<arr.length ; i++) {
      print("Element "+i+" : "+arr[i]);
    }
  }
  
  public static void addAll(int[] arr) {
    int sum = 0;
    for(int i=0 ; i<arr.length ; i++) {
      sum = sum + arr[i];
    }
    print("Sum is "+sum);
  }
  
  public static void findLarge(int[] arr) {
    int largest = arr[0];
    for(int i=0 ; i<arr.length ; i++) {
      if(arr[i]>largest) {
        largest = arr[i];
      }
    }
    print("Largest is "+largest);
  }
  
  public static void findSmall(int[] arr) {
    int smallest = arr[0];
    for(int i=0 ; i<arr.length ; i++) {
      if(arr[i]<smallest) {
        smallest = arr[i];
      }
    }
    print("Smallest is "+smallest);
  }
  
  // Sort array smallest to largest
  public static void sortArray(int[] arr) {
    for(int j=0 ; j<arr.length ; j++) {
      int smallestIndex = j;
      
      //find the smallest
      for(int i=j+1 ; i<arr.length ; i++) {
        if(arr[i]<arr[smallestIndex]) {
          smallestIndex = i;
        }
      }
      
      // swapping
      int temp = arr[j];
      arr[j] = arr[smallestIndex];
      arr[smallestIndex] = temp;
    }
    
    printAll(arr);
  }
  
  // Sort array largest to smallest
  public static void sortArrayDec(int[] inputArray) {
    
    for(int j=0 ; j<inputArray.length ; j++) {
      int largestIndex = j;
      for(int i=j+1 ; i<inputArray.length ; i++) {
        if(inputArray[i] > inputArray[largestIndex] ) {
          largestIndex = i;
        }
      }
     int temp = inputArray[j];
     inputArray[j] = inputArray[largestIndex];
     inputArray[largestIndex] = temp;
    }
    printAll(inputArray);
    System.out.println();
  }
}