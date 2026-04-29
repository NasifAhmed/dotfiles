public class Func {
    public static void main(String[] args) {
        int[] test1 = { 10, 20, 30 };
        int[] test2 = { 100, 200, 3000, 1023, 123 };

        arrayPrinter(test1);
        arrayPrinter(test2);
        findLargest(test1);
        findSmallest(test2);
    }

    public static int arrayAdder(int[] input) {
        int sum = 0;
        for(int i=0 ; i<input.length ; i++) {
            sum = sum + input[i];
        }
        return sum;
    }

    public static void arrayPrinter(int[] input) {
        for(int i=0 ; i<input.length ; i++) {
            System.out.println(input[i]);
        }
    }

    public static int findLargest(int[] input) {
        int largest = 0;
        for(int i=0 ; i<input.length ; i++) {
            if(input[i] > largest) {
                largest = input[i];
            }
        }

        return largest;
    }

    public static int findSmallest(int[] input) {
        int largest = input[0];
        for(int i=0 ; i<input.length ; i++) {
            if(input[i] < smallest) {
                smallest = input[i];
            }
        }

        return smallest;
    }
}
