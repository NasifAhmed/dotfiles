class Stack {
    int stackPointer;
    int capacity;
    int[] stackArray;

    public Stack(int size) {
        stackArray = new int[size];
        capacity = size;
        stackPointer = -1;
    }

    public void push(int element) {
        stackArray[stackPointer+1] = element;
        stackPointer++;
    }

    public void pop() {
        stackArray[stackPointer] = 0;
        stackPointer--;
    }

    public void stackDisplay() {
        System.out.println("------------------");
        for(int i = capacity-1; i >= 0; i--) {
            System.out.println("^");
            System.out.println(stackArray[i]);
        }
        System.out.println("------------------");
    }
}

public class Main {
    public static void main(String[] args) {
        Stack myStack = new Stack(10);

        myStack.push(100);
        myStack.push(200);
        myStack.push(300);
        myStack.stackDisplay();
        myStack.pop();
        myStack.stackDisplay();
    }
}
