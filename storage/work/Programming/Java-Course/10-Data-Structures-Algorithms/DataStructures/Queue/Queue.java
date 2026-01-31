public class Queue {
  Element firstElement = null;
  Element lastElement = null;

  public void enqueue(int data) {
    Element newElement = new Element(data);
    if(firstElement==null) {
      firstElement = newElement;
      lastElement = newElement;
    } else {
      lastElement.next = newElement;
      lastElement = newElement;
    }
  }

  public int dequeue() {
    if(firstElement==null) {
      System.out.println("Queue is empty");
      return -1;
    } else {
      int data = firstElement.value;
      firstElement = firstElement.next;
      if(firstElement==null) {
        lastElement = null;
      }
      return data;
    }
  }

  public int peek() {
    if(firstElement==null) {
      System.out.println("Queue is empty");
      return -1;
    } else {
      return firstElement.value;
    }
  }

  public boolean isEmpty() {
    return firstElement == null;
  }

  public int size() {
    int count = 0;
    Element current = firstElement;
    while(current != null) {
      count++;
      current = current.next;
    }
    return count;
  }

}
