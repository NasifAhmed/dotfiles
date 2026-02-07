package main

import "fmt"

// Node sturct like Node class of java
type Node struct {
	value int
	next  *Node
}

func main() {
	// Trying to make a node
	node1 := Node{
		value: 100,
		next:  nil,
	}

	node2 := Node{
		value: 200,
		next:  nil,
	}

	node3 := Node{
		value: 300,
		next:  nil,
	}

	node4 := Node{
		value: 400,
		next:  nil,
	}

	node1.next = &node2
	node2.next = &node3
	node3.next = &node4

	currentNode := &node1
	for currentNode.next != nil {
		fmt.Printf("%d --> ", currentNode.value)
		currentNode = currentNode.next
	}
	fmt.Printf(" %d ", currentNode.value)
}
