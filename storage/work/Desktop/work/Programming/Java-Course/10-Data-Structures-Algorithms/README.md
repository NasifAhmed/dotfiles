# Module 10: Data Structures & Algorithms

This module covers fundamental data structures and algorithms that are essential for efficient programming and problem-solving.

## What You'll Learn

- **Data Structures**: Arrays, Linked Lists, Stacks, Queues, Trees, Graphs
- **Algorithms**: Searching, Sorting, and optimization techniques
- **Complexity Analysis**: Big O notation and performance considerations

## Files in This Module

### 📊 Data Structures

#### Linked Lists
- **[Singly Linked List/](./DataStructures/Singly%20Linked%20List/)** - One-way linked list implementation
- **[Doubly Linked List/](./DataStructures/Doubly%20Linked%20List/)** - Two-way linked list

#### Trees & Graphs
- **[Tree/](./DataStructures/Tree/)** - Tree data structure implementations
- **[Graph/](./DataStructures/Graph/)** - Graph algorithms and representations

#### Other Structures
- **[Stack/](./DataStructures/Stack/)** - LIFO data structure
- **[Queue/](./DataStructures/Queue/)** - FIFO data structure

### 🔍 Algorithms

#### Sorting Algorithms
- **[BubbleSort.java](./BubbleSort.java)** - Simple sorting algorithm
- **[SelectionSort.java](./SelectionSort.java)** - Selection-based sorting
- **[InsertionSort.java](./InsertionSort.java)** - Build sorted array one item at a time
- **[QuickSort.java](./QuickSort.java)** - Efficient divide-and-conquer sorting

#### Searching Algorithms
- **[BinarySearch.java](./BinarySearch.java)** - Fast searching in sorted arrays

#### Utility
- **[ArrayCopy.java](./ArrayCopy.java)** - Array manipulation techniques

## Data Structure Overview

### 1. Arrays
```java
int[] arr = new int[5];
// Fixed size, O(1) access
```

### 2. Linked Lists
```java
class Node {
    int data;
    Node next;
}
// Dynamic size, O(n) access
```

### 3. Stacks (LIFO)
```java
stack.push(10);
int top = stack.pop(); // Last in, first out
```

### 4. Queues (FIFO)
```java
queue.add(10);
int front = queue.remove(); // First in, first out
```

## Algorithm Complexity

| Algorithm | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Bubble Sort | O(n²) | O(1) |
| Quick Sort | O(n log n) avg | O(log n) |
| Binary Search | O(log n) | O(1) |
| Linear Search | O(n) | O(1) |

## Practice Problems

### 🟢 Easy
1. Implement a stack using arrays
2. Create a basic linked list with insert/delete operations
3. Write a function to reverse an array

### 🟡 Medium
1. Implement binary search on a sorted array
2. Create a queue using two stacks
3. Design a simple binary search tree

### 🔴 Hard
1. Implement graph traversal (BFS/DFS)
2. Create a balanced binary search tree
3. Implement Dijkstra's shortest path algorithm

## How to Run Examples

```bash
# Navigate to specific data structure
cd "DataStructures/Singly Linked List"

# Compile and run
javac *.java
java MainProgram
```

## Project Ideas

- 📚 **Library Management System** - Use trees for book categorization
- 🗺️ **Route Finder** - Implement graph algorithms for pathfinding
- 📦 **Inventory System** - Use hash tables for quick lookups
- 🎮 **Game AI** - Use queues for turn-based systems

## Recommended Learning Path

1. **Start with**: Arrays and basic sorting
2. **Move to**: Linked lists and stacks/queues
3. **Advance to**: Trees and graphs
4. **Master**: Complex algorithms and optimization

## Next Steps

- [Module 11: Advanced Topics](../11-Advanced-Topics)
- [Projects](../Projects) - Apply your knowledge to complete projects

---

💡 **Pro Tip**: Understanding data structures and algorithms is crucial for technical interviews and efficient problem-solving. Practice regularly!