public class Hello {
 public static void main(String[] args) {
  int[] array = { 1, 3, 5, 8, 10, 11, 12, 13, 15, 100, 200 };
  // Search for 15 in this array
  // Binary search

  int lo = 0;
  int hi = array.length-1;
  int mid = (lo+hi)/2;

  int target = 15;

  for(int i=0 ; i<array.length ; i++) {
   if(target > array[mid]) {
    lo = mid+1;
    mid = (lo + hi )/2;
   } else if( target < array[mid]) {
    hi = mid-1;
    mid = (lo+hi )/2;
   } else {
    System.out.println("Element found at "+mid);
    break;
   }
  }
 }
}
