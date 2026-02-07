public class Main {
    public static void main(String[] args) {

        Node node1 = new Node(100);

        addNewNode(node1, 200);
        addNewNode(node1, 300);
        addNewNode(node1, 400);

        printList(node1);
        printListReverse(node1);

        addNewNode(node1, 500);
        addNewNode(node1, 600);
        addNewNode(node1, 6000);

        printList(node1);
        printListReverse(node1);
        
        System.out.println("Removing last");
        removeLast(node1);

        printList(node1);
        printListReverse(node1);

        System.out.println("Removing first");
        removeFirst(node1);

        printList(node1);
        printListReverse(node1);
    }

    public static void removeFirst(Node head) {
        head.next = head.next.next;
        head = head.next;
        head.prev = null;
    }

    public static void removeLast(Node head) {
        Node currentNode = head;
        while(currentNode.next != null) {
            currentNode = currentNode.next;
        }
        currentNode.prev.next = null;
    }


    public static void addNewNode(Node head, int data) {
        Node newNode = new Node(data);

        Node currentNode = head;
        while(currentNode.next != null) {
            currentNode = currentNode.next;
        }

        currentNode.next = newNode;
        newNode.prev = currentNode;

    }

    public static void printList(Node head){
        Node currentNode = head;
        while(currentNode.next != null) {
            System.out.print(currentNode.value+" <--> ");
            currentNode = currentNode.next;
        }
        System.out.println(currentNode.value);
    }

    public static void printListReverse(Node head){

        // Shoja loop - next kore kore
        Node currentNode = head;
        while(currentNode.next != null) {
            currentNode = currentNode.next;
        }

        // Ulta loop - prev kore kore
        while(currentNode.prev != null) {
            System.out.print(currentNode.value+" <--> ");
            currentNode = currentNode.prev;
        }
        System.out.println(currentNode.value);
    }
}
