public class InsertionSort {
    public static void main(String[] args) {
        int[] array = { 2, 4, 1, 10, 100, 5, 3, 8 };
        arrayPrinter(insertionSort(array));
        arrayPrinter(array);
    }

    public static int[] insertionSort(int[] array) {
        for (int i = 1; i < array.length; i++) {
            int key = array[i];
            int j = i - 1;
            while (j >= 0 && array[j] > key) {
                array[j + 1] = array[j];
                j--;
            }
            array[j + 1] = key;
        }
        return array;
    }

    public static void arrayPrinter(int[] array) {
        for (int i = 0; i < array.length; i++) {
            if (i == 0) {
                System.out.print("{ ");
            } else if (i < array.length - 1) {
                System.out.print(array[i] + ", ");
            } else {
                System.out.print(array[i]);
                System.out.print(" }");
            }
        }
    }
}