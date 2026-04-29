import java.util.Scanner;

public class Input {
    public static void main(String[] args) {

        Scanner scn = new Scanner(System.in);

        System.out.println("Enter your birth year :");
        int userInput = scn.nextInt();

        int age = 2026 - userInput;

        System.out.println("Your Age : " +  age);

    }
}
