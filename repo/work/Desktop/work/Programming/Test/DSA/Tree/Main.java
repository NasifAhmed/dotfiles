public class Main {
    public static void main(String[] args) {
        Node A = new Node(10, "A");
        Node B = new Node(20, "B");
        Node C = new Node(30, "C");

        A.leftChild = B;
        A.rightChild = C;

        System.out.println(A.leftChild.name);
        System.out.println(A.rightChild.name);

        bfs(A, 50); // returns name
    }

    public static String bfs(Node top, int v) {
        while() {
            if(top.leftChild == null && top.rightChild == null) {
                top.isVisited = true;
            } else if(top.leftChild.isVisited == true && top.rightChild.isVisited == true) {
                top.isVisited = true;
            }
        }
    }

}
