import java.util.Scanner;

public class Calc {
    public static void main(String[] args) {

        Scanner scn = new Scanner(System.in);

        while(true) {
            System.out.println("1. Add");
            System.out.println("2. Substract");
            System.out.println("3. Multiply");
            System.out.println("4. Division");
            System.out.println("5. Exit");
            System.out.println("What do want ?");

            int userInput = scn.nextInt();

            if(userInput==1) {
                System.out.println("Input first number : ");
                int a = scn.nextInt();
                System.out.println("Input second number : ");
                int b = scn.nextInt();
                System.out.println("Jogfol : " + adder(a,b));
            } else if(userInput==2) {
                System.out.println("Input first number : ");
                int a = scn.nextInt();
                System.out.println("Input second number : ");
                int b = scn.nextInt();
                System.out.println("Biyogfol : " + sub(a,b));
            } else if(userInput==3) {
                System.out.println("Input first number : ");
                int a = scn.nextInt();
                System.out.println("Input second number : ");
                int b = scn.nextInt();
                System.out.println("Multiply : " + mult(a,b));
            } else if(userInput==4) {
                System.out.println("Input first number : ");
                double a = scn.nextDouble();
                System.out.println("Input second number : ");
                double b = scn.nextDouble();
                System.out.println("Division : " + division(a,b));
            } else if(userInput==5) {
                break;
            }
            System.out.println();
        }
    }

    public static int adder(int input1, int input2) {
        return input1 + input2;
    }

    public static int sub(int input1, int input2) {
        return input1 - input2;
    }

    public static int mult(int input1, int input2) {
        return input1 * input2;
    }

    public static double division(double input1, double input2) {
        return input1 / input2;
    }


}
