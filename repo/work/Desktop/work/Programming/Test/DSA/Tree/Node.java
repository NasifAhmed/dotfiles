public class Node {
    int value;
    Node leftChild;
    Node rightChild;
    boolean isVisited;
    String name;

    public Node(int data, String s) {
        value = data;
        leftChild = null;
        rightChild = null;
        isVisited = false;
        name = s;
    }
}
