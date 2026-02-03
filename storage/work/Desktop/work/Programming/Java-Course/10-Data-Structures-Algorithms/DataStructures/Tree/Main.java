public class Main {
  public static void main(String[] args) {
    Tree tree = new Tree();
    System.out.println("Binary Search Tree operations:");
    System.out.println("Is empty: " + tree.isEmpty());
    System.out.println("Size: " + tree.size());
    
    tree.insert(50);
    tree.insert(30);
    tree.insert(70);
    tree.insert(20);
    tree.insert(40);
    tree.insert(60);
    tree.insert(80);
    
    System.out.println("After inserting: 50, 30, 70, 20, 40, 60, 80");
    System.out.println("Size: " + tree.size());
    
    tree.inOrderTraversal();
    tree.preOrderTraversal();
    tree.postOrderTraversal();
    
    System.out.println("Search 40: " + tree.search(40));
    System.out.println("Search 90: " + tree.search(90));
    
    System.out.println("Search 50 (root): " + tree.search(50));
    System.out.println("Search 20 (left leaf): " + tree.search(20));
    System.out.println("Search 80 (right leaf): " + tree.search(80));
  }
}