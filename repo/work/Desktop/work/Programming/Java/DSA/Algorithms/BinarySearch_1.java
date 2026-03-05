public class BinarySearch {
    public static void main(String[] args) {
        int[] array = { 1, 2, 3, 4, 7, 10, 12, 15, 16, 20 };
        System.out.println(binarySearch(array, 10));
    }

    public static int binarySearch(int[] array, int target) {
        int lo = 0;
        int hi = array.length - 1;
        int mid = (lo + hi) / 2;

        for (int i = 0; i < array.length; i++) {
            if (target > array[mid]) {
                lo = mid + 1;
                mid = (lo + hi) / 2;
            } else if (target < array[mid]) {
                hi = mid - 1;
                mid = (lo + hi) / 2;
            }

        }
        return mid;
    }
}