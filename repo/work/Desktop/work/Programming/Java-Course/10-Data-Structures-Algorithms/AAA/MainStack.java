// A simple integer stack implementation without using generics.
public class MainStack {

    // Array to store the elements of the stack.
    private int[] stackArray;
    // Index of the top element in the stack. -1 indicates an empty stack.
    private int top;
    // Maximum capacity of the stack.
    private int capacity;

    /**
     * Constructor to initialize the stack with a given size.
     * @param size The maximum number of elements the stack can hold.
     */
    public IntStack(int size) {
        this.capacity = size;
        this.stackArray = new int[capacity];
        this.top = -1; // Initialize top to -1, indicating an empty stack.
    }

    /**
     * Pushes an integer element onto the top of the stack.
     * Throws an IllegalStateException if the stack is full.
     * @param item The integer to be pushed onto the stack.
     */
    public void push(int item) {
        if (isFull()) {
            throw new IllegalStateException("Stack is full. Cannot push element: " + item);
        }
        stackArray[++top] = item; // Increment top and then add the item.
    }

    /**
     * Removes and returns the integer element at the top of the stack.
     * Throws an IllegalStateException if the stack is empty.
     * @return The integer element removed from the top of the stack.
     */
    public int pop() {
        if (isEmpty()) {
            throw new IllegalStateException("Stack is empty. Cannot pop element.");
        }
        return stackArray[top--]; // Return the item at top and then decrement top.
    }

    /**
     * Returns the integer element at the top of the stack without removing it.
     * Throws an IllegalStateException if the stack is empty.
     * @return The integer element at the top of the stack.
     */
    public int peek() {
        if (isEmpty()) {
            throw new IllegalStateException("Stack is empty. Cannot peek element.");
        }
        return stackArray[top]; // Return the item at top without changing top.
    }

    /**
     * Checks if the stack is empty.
     * @return true if the stack contains no elements, false otherwise.
     */
    public boolean isEmpty() {
        return top == -1;
    }

    /**
     * Checks if the stack is full.
     * @return true if the stack has reached its maximum capacity, false otherwise.
     */
    public boolean isFull() {
        return top == capacity - 1;
    }

    /**
     * Returns the number of elements currently in the stack.
     * @return The current size of the stack.
     */
    public int size() {
        return top + 1;
    }
}
