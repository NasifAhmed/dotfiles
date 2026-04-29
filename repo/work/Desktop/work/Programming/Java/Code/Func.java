public class Func {
    public static void main(String[] args) {
        System.out.println(fibo(5));
    }

    public static int fibo(int input) {
        if(input==0 || input==1) {
            return input;
        }

        return fibo(input-1) + fibo(input-2);

    }
}
