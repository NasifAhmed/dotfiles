public class SelectionSort {
    public static void main(String[] args) {

        int[] array = {2, 4, 1, 10, 100, 5, 3, 8};
        
        arrayPrinter(selectionSort(array));

    }
    
    public static int[] selectionSort(int[] array) {
        for(int i=0 ; i<array.length ; i++) {
            int smallestIndex = i;
            int temp = 0;
            for(int j=i+1 ; j<array.length ; j++) {
                if(array[j] < array[smallestIndex]) {
                    smallestIndex = j;
                }
            }
            temp = array[i];
            array[i] = array[smallestIndex];
            array[smallestIndex] = temp;
        }
        return array;
        
    }
    
    public static void arrayPrinter(int[] array) {
        for(int i=0 ; i<array.length ; i++) {
            if(i==0) {
                System.out.print("{ ");
            }else if(i<array.length-1) {
                System.out.print(array[i]+", ");
            } else {
                System.out.print(array[i]);
                System.out.print(" }");
            }
        }
    }
}