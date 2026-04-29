public class Matryoshka {

    public static void main(String[] args) {
        System.out.println(matryoshkaNumber(432));
    }

    public static int matryoshkaNumber(int a) {
        int sum = 0;
        while(a!=0) {
            sum = sum + a%10;
            a = a/10;
        }

        return sum;
    }





    public static int matryoshkaNumber(int a) {
        if(a==0) {
            return 0;
        }
        return a%10 + matryoshkaNumber(a/10);
    }

}
