public class List {
  Node head = null;

  public void add(int data) {
    Node newNode = new Node(data);
    if(head==null) {
      head = newNode;
    } else {
      Node currentNode = head;
      while(currentNode.next!=null) {
        currentNode = currentNode.next;
      }
      currentNode.next = newNode;
    }
  }

  public void removeLast() {
    if(head==null) {
      System.out.println("List is empty");
    } else if(head.next==null) {
      head = null;
    } else {
      Node currentNode = head;
      while(currentNode.next.next!=null) {
        currentNode = currentNode.next;
      }
      currentNode.next = null;
    }
  }

  public void removeFirst() {
    if(head==null) {
      System.out.println("List is empty");
    } else {
      head = head.next;
    }
  }

  public int size() {
    int count = 0;
    Node current = head;
    while(current != null) {
      count++;
      current = current.next;
    }
    return count;
  }

  public void showList() {
    if(head==null) {
      System.out.println("The list is empty");
    } else {
      Node currentNode = head;
      while(currentNode.next!=null) {
        System.out.print(currentNode.value + "--> ");
        currentNode = currentNode.next;
      }
      System.out.print(currentNode.value + "--> ");
      System.out.println("null");
    }
  }

}
