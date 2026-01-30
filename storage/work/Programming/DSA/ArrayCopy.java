public class ArrayCopy {
    public static void main(String[] args) {
        int[] array = {1, 2, 3, 4, 5};
        int[] najmulArray = new int[5];
        
        najmulArray[0] = array[0];
        najmulArray[1] = array[1];
        najmulArray[2] = array[2];
        najmulArray[3] = array[3];
        najmulArray[4] = array[4];
        
        System.out.println(array);
        System.out.println(najmulArray);
        
    }
}