public class TraceFor {
    public static void main(String[] args) {
        int result = 0;

        for (int i = 1; i <= 6; i++) {
            if (i % 3 == 0) {
                result = result + 5;
            } else if (i % 2 == 0) {
                result = result - 2;
            } else {
                result = result + i;
            }
        }
        System.out.println("Result = " + result);
    }
}
