public class Test {
    public static void main(String[] args) {
        fibo(10);
    }

    public static void fibo(int n) {
        int firstNumber = 0;
        System.out.println(firstNumber);
        int secondNumber = 1;
        System.out.println(secondNumber);

        int thirdNumber = 0;

        for(int i=0; i<n-2; i++) {
            thirdNumber = firstNumber + secondNumber;
            System.out.println(thirdNumber);
            firstNumber = secondNumber;
            secondNumber = thirdNumber;
        }
    }

    public static int fiboRecursion(int n) {
        if(n==0) {
            return 0;
        }
        if(n==1) {
            return 1;
        }
        return fiboRecursion(n-1) + fiboRecursion(n-2);
    }
}
