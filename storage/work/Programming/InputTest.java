import java.util.Scanner;

public class InputTest {
    public static void main(String[] args) {
        // How to take input

        Scanner scn = new Scanner(System.in);
        
        // System.out.println("What do you want to do ?");
        // System.out.println("1. Add");
        // System.out.println("2. Minus");
        // System.out.println("3. Multiply");
        // System.out.println("4. Division");
        
        // int input = scn.nextInt();

        // if(input==1) {
        //     System.out.println("Give fist number");
        //     int num1 = scn.nextInt();
        //     System.out.println("Give second number");
        //     int num2 = scn.nextInt();
        //     int result = num1+num2;
        //     System.out.println("Your answer is : "+result);
        
        
        System.out.println("What is 10 - 3 ?");
        System.out.println("a. 4");
        System.out.println("b. 5");
        System.out.println("c. 2");
        System.out.println("d. 7");
        
        String input = scn.nextLine();

        if(input.equals("d")) {
            System.out.println("Right bollen");
        } else {
            System.out.println("Chigaimasu");
            System.out.println("-999999 Aura loss");
        }
        

        
    }
}