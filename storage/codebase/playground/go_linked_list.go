package main

import "fmt"

// Node represents a single node in the linked list.
type Node struct {
	Value int
	Next  *Node
}

// LinkedList represents the linked list itself.
type LinkedList struct {
	Head   *Node
	Length int
}

// NewLinkedList creates and returns a new empty LinkedList.
func NewLinkedList() *LinkedList {
	return &LinkedList{}
}

// Append adds a new node with the given value to the end of the list.
func (l *LinkedList) Append(value int) {
	newNode := &Node{Value: value}
	if l.Head == nil {
		l.Head = newNode
	} else {
		current := l.Head
		for current.Next != nil {
			current = current.Next
		}
		current.Next = newNode
	}
	l.Length++
}

// Prepend adds a new node with the given value to the beginning of the list.
func (l *LinkedList) Prepend(value int) {
	newNode := &Node{Value: value, Next: l.Head}
	l.Head = newNode
	l.Length++
}

// DeleteWithValue removes the first occurrence of a node with the given value.
// Returns true if a node was deleted, false otherwise.
func (l *LinkedList) DeleteWithValue(value int) bool {
	if l.Head == nil {
		return false // List is empty
	}

	if l.Head.Value == value {
		l.Head = l.Head.Next // Delete head node
		l.Length--
		return true
	}

	current := l.Head
	for current.Next != nil && current.Next.Value != value {
		current = current.Next
	}

	if current.Next != nil {
		current.Next = current.Next.Next // Skip the node to be deleted
		l.Length--
		return true
	}

	return false // Value not found
}

// Search checks if a node with the given value exists in the list.
// Returns true if found, false otherwise.
func (l *LinkedList) Search(value int) bool {
	current := l.Head
	for current != nil {
		if current.Value == value {
			return true
		}
		current = current.Next
	}
	return false
}

// Display prints all values in the linked list.
func (l *LinkedList) Display() {
	if l.Head == nil {
		fmt.Println("List is empty.")
		return
	}
	current := l.Head
	fmt.Print("List: ")
	for current != nil {
		fmt.Printf("%d -> ", current.Value)
		current = current.Next
	}
	fmt.Println("nil")
}

// GetLength returns the current number of nodes in the list.
func (l *LinkedList) GetLength() int {
	return l.Length
}

func main() {
	list := NewLinkedList()

	fmt.Println("--- Appending elements ---")
	list.Append(10)
	list.Append(20)
	list.Append(30)
	list.Display() // Expected: List: 10 -> 20 -> 30 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 3

	fmt.Println("\n--- Prepending elements ---")
	list.Prepend(5)
	list.Prepend(1)
	list.Display() // Expected: List: 1 -> 5 -> 10 -> 20 -> 30 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 5

	fmt.Println("\n--- Searching for elements ---")
	fmt.Printf("Search for 10: %t\n", list.Search(10))   // Expected: true
	fmt.Printf("Search for 100: %t\n", list.Search(100)) // Expected: false

	fmt.Println("\n--- Deleting elements ---")
	fmt.Println("Deleting 1 (head):", list.DeleteWithValue(1)) // Expected: true
	list.Display() // Expected: List: 5 -> 10 -> 20 -> 30 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 4

	fmt.Println("Deleting 20 (middle):", list.DeleteWithValue(20)) // Expected: true
	list.Display() // Expected: List: 5 -> 10 -> 30 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 3

	fmt.Println("Deleting 30 (tail):", list.DeleteWithValue(30)) // Expected: true
	list.Display() // Expected: List: 5 -> 10 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 2

	fmt.Println("Deleting 100 (not found):", list.DeleteWithValue(100)) // Expected: false
	list.Display() // Expected: List: 5 -> 10 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 2

	fmt.Println("Deleting 5 (new head):", list.DeleteWithValue(5)) // Expected: true
	list.Display() // Expected: List: 10 -> nil
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 1

	fmt.Println("Deleting 10 (last element):", list.DeleteWithValue(10)) // Expected: true
	list.Display() // Expected: List is empty.
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 0

	fmt.Println("Deleting from empty list:", list.DeleteWithValue(99)) // Expected: false
	list.Display() // Expected: List is empty.
	fmt.Printf("Length: %d\n", list.GetLength()) // Expected: Length: 0
}
