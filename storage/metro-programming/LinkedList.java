public class LinkedList {
  Node head;

  public void add(int data) {
    Node newNode = new Node(data);

    if(head==null) {
      head = newNode;
    }

    else {
      Node current = head;

      while(current.next != null) {
        current = current.next;
      }

      current.next = newNode;
    }
  }

  public void display() {
    Node current = head;

    if(head==null) {
      System.out.println("This list is empty");
      return;
    }

    System.out.print("List: ");
    while(current!=null) {
      System.out.print(current.data + " -> ");
      current = current.next;
    }
    System.out.println("null");
  }
}
