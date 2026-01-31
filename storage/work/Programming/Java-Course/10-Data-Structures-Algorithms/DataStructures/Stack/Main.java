public class Main {
  public static void main(String[] args) {
    Stack s = new Stack();
    System.out.println("Stack operations:");
    System.out.println("Is empty: " + s.isEmpty());
    System.out.println("Size: " + s.size());
    
    s.push(10);
    s.push(20);
    s.push(30);
    System.out.println("Pushed 10, 20, 30");
    System.out.println("Top element: " + s.peek());
    System.out.println("Size: " + s.size());
    
    System.out.println("Popped: " + s.pop());
    System.out.println("Popped: " + s.pop());
    System.out.println("Top element after 2 pops: " + s.peek());
    System.out.println("Size: " + s.size());
    
    System.out.println("Popped: " + s.pop());
    System.out.println("Popped: " + s.pop());
    System.out.println("Is empty: " + s.isEmpty());
  }
}