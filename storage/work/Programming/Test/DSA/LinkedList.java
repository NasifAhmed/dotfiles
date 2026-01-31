public class LinkedList {
    Node head;

    void add(int data) {
        Node newNode = new Node(data);
        head.next = newNode;

        Node currentNode = head;
        while(currentNode.next != null) {
            currentNode = currentNode.next;
        }

        currentNode.next = newNode;
    }
}
