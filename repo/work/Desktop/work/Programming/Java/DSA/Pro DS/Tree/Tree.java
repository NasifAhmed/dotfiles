public class Tree {
  Node root;

  public Tree() {
    root = null;
  }

  public void insert(int data) {
    root = insertRecursive(root, data);
  }

  private Node insertRecursive(Node current, int data) {
    if(current==null) {
      return new Node(data);
    }
    
    if(data < current.value) {
      current.left = insertRecursive(current.left, data);
    } else if(data > current.value) {
      current.right = insertRecursive(current.right, data);
    }
    
    return current;
  }

  public boolean search(int data) {
    return searchRecursive(root, data);
  }

  private boolean searchRecursive(Node current, int data) {
    if(current==null) {
      return false;
    }
    
    if(data == current.value) {
      return true;
    }
    
    return data < current.value ? 
      searchRecursive(current.left, data) : 
      searchRecursive(current.right, data);
  }

  public void inOrderTraversal() {
    System.out.print("In-order: ");
    inOrderRecursive(root);
    System.out.println();
  }

  private void inOrderRecursive(Node node) {
    if(node!=null) {
      inOrderRecursive(node.left);
      System.out.print(node.value + " ");
      inOrderRecursive(node.right);
    }
  }

  public void preOrderTraversal() {
    System.out.print("Pre-order: ");
    preOrderRecursive(root);
    System.out.println();
  }

  private void preOrderRecursive(Node node) {
    if(node!=null) {
      System.out.print(node.value + " ");
      preOrderRecursive(node.left);
      preOrderRecursive(node.right);
    }
  }

  public void postOrderTraversal() {
    System.out.print("Post-order: ");
    postOrderRecursive(root);
    System.out.println();
  }

  private void postOrderRecursive(Node node) {
    if(node!=null) {
      postOrderRecursive(node.left);
      postOrderRecursive(node.right);
      System.out.print(node.value + " ");
    }
  }

  public int size() {
    return sizeRecursive(root);
  }

  private int sizeRecursive(Node node) {
    if(node==null) {
      return 0;
    }
    return 1 + sizeRecursive(node.left) + sizeRecursive(node.right);
  }

  public boolean isEmpty() {
    return root == null;
  }
}