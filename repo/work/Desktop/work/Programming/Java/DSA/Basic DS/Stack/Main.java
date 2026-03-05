public class Main {
    public static void main(String[] args) {
        Stack myStack = new Stack(10);
        myStack.display();
        myStack.peek();
        myStack.push(10);
        myStack.display();
        myStack.push(20);
        myStack.push(30);
        myStack.display();
        myStack.pop();
        myStack.display();
    }
}

class Stack {

    int stackPointer;
    int stackArray[];
    int capacity;

    public Stack(int size) {
        capacity = size;
        stackArray = new int[capacity];
        stackPointer = -1;
    }

    public void push(int element) {
        if (stackPointer >= capacity - 1) {
            System.out.println("Stack Overflow! Cannot push " + element);
            return;
        }
        stackPointer++;
        stackArray[stackPointer] = element;
    }
    
    public void pop() {
        stackArray[stackPointer] = 0;
        stackPointer--;
    }

    public void peek() {
        if (stackPointer == -1) {
            System.out.println("Stack is empty.");
            return;
        }
        System.out.println(stackArray[stackPointer]);
    }

    public void display() {
        if (stackPointer == -1) {
            System.out.println("Stack is empty");
            return;
        }

        for(int i = 0; i <= stackPointer; i++) {
            System.out.print(stackArray[i]);

            // Only print arrow if it's NOT the last element
            if(i < stackPointer) {
                System.out.print(" --> ");
            }
        }

        System.out.println(); // New line at the end
    }
}

