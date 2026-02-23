public class ReverseNumber {
    public static void main(String[] args) {
        
        reverse_number(456);
        reverse_number(12345);
    }

    public static void reverse_number(int n) {
        int rm = 0;
        int rev = 0;
        while(n!=0) {
            rm = n % 10;
            n = n/10;
            rev = (rev*10)+rm;
        }
        System.out.println(rev);
    }
}
