public class PrintPrime {
    public static void main(String[] args) {
        printPrime(36);

    }

    public static void printPrime(int limit) {
        int count = 0;
        for(int i=1; i<=limit ; i++) {
            for(int j=1 ; j<=Math.sqrt(i) ; j++) {
                if(i%j==0) {
                    count++;
                }
            }
            if(count == 1 && i != 1) {
                System.out.println(i);
            }
            count = 0;
        }

    }
}
