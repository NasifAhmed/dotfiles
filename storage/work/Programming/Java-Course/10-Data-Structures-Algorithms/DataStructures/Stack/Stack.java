public class Stack {
  Element bottom;
  Element top;

  public void push(int data) {
    Element newElement = new Element(data);
    if(top==null) {
      top = newElement;
      bottom = newElement;
    } else {
      newElement.next = top;
      top = newElement;
    }
  }

  public int pop() {
    if(top==null) {
      System.out.println("Stack is empty");
      return -1;
    } else {
      int data = top.value;
      top = top.next;
      if(top==null) {
        bottom = null;
      }
      return data;
    }
  }

  public int peek() {
    if(top==null) {
      System.out.println("Stack is empty");
      return -1;
    } else {
      return top.value;
    }
  }

  public boolean isEmpty() {
    return top == null;
  }

  public int size() {
    int count = 0;
    Element current = top;
    while(current != null) {
      count++;
      current = current.next;
    }
    return count;
  }

}
