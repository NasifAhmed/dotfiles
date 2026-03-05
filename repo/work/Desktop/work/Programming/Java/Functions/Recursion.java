public class Recursion {
    public static void main(String[] args) {
        System.out.println(factorial(30));
        System.out.println(fibo(20));
    }


    // Factorial with recursion
    public static int factorial(int n) {
        if(n==0) {
            return 1;
        } else {
            return n*factorial(n-1);
        }
    }

    // Sum of fibonacci with recursion
    public static int fibo(int n) {
        if(n<=1) {
            return n;
        } else {
            return fibo(n-1) + fibo(n-2);
        }
    }

}

