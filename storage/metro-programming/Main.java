public class Main {
  public static void main(String[] args) {
    LinkedList list = new LinkedList();

    System.out.println("Adding 10, 20, and 30...");
    list.add(10);
    list.add(40);
    list.add(50);

    list.display();

    System.out.println("Adding 40...");
    list.add(40);

    list.display();

  }
}
