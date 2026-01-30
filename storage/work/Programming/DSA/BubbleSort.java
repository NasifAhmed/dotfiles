public class BubbleSort {
    public static void main(String[] args) {
        int[] array = { 2, 4, 1, 10, 100, 5, 3, 8 };
        arrayPrinter(insertionSort(array));
    }

    public static int[] insertionSort(int[] a) {
        for (int i = 0; i < a.length - 1; i++) {
            // (n - i - 1) ensures we don't check the already sorted end-parts
            for (int j = 0; j < a.length - i - 1; j++) {
                if (a[j] > a[j + 1]) {
                    // Swap
                    int temp = a[j];
                    a[j] = a[j + 1];
                    a[j + 1] = temp;
                }
            }
        }
        return a;
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