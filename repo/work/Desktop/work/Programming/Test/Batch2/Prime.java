public class Prime {
    public static void main(String[] args) {
        System.out.println(isPrime(34));
        System.out.println(isPrime(129));

    }

    public static boolean isPrime(int n) {
        if(n<=1) {
            return false;
        }

        if(n==2) {
            return true;
        } else if(n%2==0) {
            return false;
        }

        for(int i=3 ; i<n ; i++) {
            if(n%i==0) {
                return false;
            }
        }

        return true;

    }
}
