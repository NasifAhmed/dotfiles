import java.util.Scanner;

public class Test {
  public static void main(String[] args) {
    Scanner scn = new Scanner(System.in);
    
    System.out.println("What is your name ?");
    
    String input = scn.nextLine();
    
    System.out.println("Hello "+input+" ! Welcome ");
  }
}
