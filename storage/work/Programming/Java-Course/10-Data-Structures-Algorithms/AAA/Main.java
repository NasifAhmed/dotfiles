public class Main {
    public static void main(String[] args) {
        Node head = new Node(100);

        addNewNode(200, head);
        addNewNode(300, head);
        addNewNode(400, head);
        addNewNode(500, head);
        addNewNode(600, head);

        printList(head);
        deleteLast(head);
        printList(head);
        deleteLast(head);
        printList(head);
        addNewNode(1000, head);
        printList(head);

    }

    public static void addToNode(Node a, Node b) {
        a.next = b;
    }

    public static void addNewNode(int data, Node head) {
        Node newNode = new Node(data);
        Node currentNode = head;
        while(currentNode.next!=null) {
            currentNode = currentNode.next;
        }
        currentNode.next = newNode;
    }

    public static void printList(Node head) {
        Node currentNode = head;
        while(currentNode.next!=null) {
            System.out.print(currentNode.value+" --> ");
            currentNode = currentNode.next;
        }
        System.out.println(currentNode.value);
    }

    public static void deleteLast(Node head) {
        Node currentNode = head;
        while(currentNode.next.next!=null) {
            currentNode = currentNode.next;
        }
        currentNode.next = null;
    }
}
