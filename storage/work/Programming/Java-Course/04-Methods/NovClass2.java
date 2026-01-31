public class NovClass2 {
    public static void main(String[] args) {

        int[] arr = {1, 2, 3, 4, 5};

        // Rotate an arary by given places
        
        System.out.println("Main Array : ");
        arrayPrinter(arr);
        System.out.println("Ghurano Array : ");
        arrayPrinter(rotateArray(arr, 199));

    }
    
    public static int[] rotateArray(int[] mainArray, int ghor) {

        int mainArraySize = mainArray.length;
        int[] ghuranoArray = new int[mainArray.length];
        
        int limit = ghor % mainArray.length;
        
        for(int i=0 ; i<mainArray.length ; i++) {
            if(i+limit > mainArray.length-1) {
                ghuranoArray[ghor - mainArray.length -(i+1)] = mainArray[i];
            } else {
                ghuranoArray[i+limit] = mainArray[i];
            }
        }
        
        return ghuranoArray;
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
}