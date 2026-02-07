public class Test {
    public static void main(String[] args) {
        String thing = "*";
        String thing2 = " ";

        for (int i = 4; i >= 0; i--) {
            for (int j = 1; j <= i; j++) {
                System.out.print(thing2); 
            }
            for (int a = 5-i ; a>0; a--) {
                System.out.print(thing);
            }
            System.out.println();
        }
    }
}
