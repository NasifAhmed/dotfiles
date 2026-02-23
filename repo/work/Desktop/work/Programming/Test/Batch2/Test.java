public class Test {
    public static void main(String[] args) {
        //function
        System.out.println(upperCase('x'));
    }

    public static char upperCase(char c) {
        int number = (int)c;
        int boroNumber = number - 32;
        char result = (char)boroNumber;

        return result;
    }
}
