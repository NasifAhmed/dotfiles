public class Main {
  public static void main(String[] args) {
    List a = new List();
    System.out.println("Singly Linked List operations:");
    System.out.println("Initial list:");
    a.showList();
    System.out.println("Size: " + a.size());
    
    a.add(10);
    a.add(20);
    System.out.println("After adding 10, 20:");
    a.showList();
    System.out.println("Size: " + a.size());
    
    a.add(30);
    a.add(40);
    System.out.println("After adding 30, 40:");
    a.showList();
    System.out.println("Size: " + a.size());
    
    a.removeLast();
    System.out.println("After removing last element:");
    a.showList();
    System.out.println("Size: " + a.size());
    
    a.removeFirst();
    System.out.println("After removing first element:");
    a.showList();
    System.out.println("Size: " + a.size());
    
    a.removeFirst();
    a.removeFirst();
    System.out.println("After removing all remaining elements:");
    a.showList();
    System.out.println("Size: " + a.size());
  }
}
