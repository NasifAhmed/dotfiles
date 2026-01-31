public class List {
  Node head;


  public void add(int data) {
    Node newNode = new Node(data);
    if(head==null) {
      head = newNode;
    } else {
      Node current = head;

      while(current.next!=null) {
        current = current.next;
      }
      current.next = newNode;
    }
  }

  public void remove() {
    if (head == null) {
      System.out.println("List is empty, nothing to remove.");
      return;
    }

    if (head.next == null) {
      head = null; // The list is now empty
      return;
    }

    Node current = head;

    while (current.next.next != null) {
      current = current.next; // MOVE FORWARD!
    }

    current.next = null;
  }

  public void printList() {
    Node current = head;
    if(head==null) {
      System.out.println("The list is empty");
    } else {
      System.out.print("The list : ");
      while(current!=null) {
        System.out.print(current.value + ", ");
        current = current.next;
      }
      System.out.println("null");
    }
  }
}
