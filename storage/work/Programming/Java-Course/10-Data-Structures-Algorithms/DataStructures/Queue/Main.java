public class Main {
  public static void main(String[] args) {
    Queue q = new Queue();
    System.out.println("Queue operations:");
    System.out.println("Is empty: " + q.isEmpty());
    System.out.println("Size: " + q.size());
    
    q.enqueue(10);
    q.enqueue(20);
    q.enqueue(30);
    System.out.println("Enqueued 10, 20, 30");
    System.out.println("Front element: " + q.peek());
    System.out.println("Size: " + q.size());
    
    System.out.println("Dequeued: " + q.dequeue());
    System.out.println("Dequeued: " + q.dequeue());
    System.out.println("Front element after 2 dequeues: " + q.peek());
    System.out.println("Size: " + q.size());
    
    System.out.println("Dequeued: " + q.dequeue());
    System.out.println("Dequeued: " + q.dequeue());
    System.out.println("Is empty: " + q.isEmpty());
  }
}