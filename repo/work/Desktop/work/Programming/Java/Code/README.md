# Array Utilities Project

A Java utility project providing common array operations and algorithms.

## Overview

This project contains a collection of array manipulation methods, including duplicate detection and binary search functionality.

## Features

### 1. **Duplicate Detector**
Detects if an array contains duplicate elements.

- **Algorithm**: Hash Set based approach (optimized)
- **Time Complexity**: O(n)
- **Space Complexity**: O(n)
- **Advantage**: Single pass through the array; much faster than nested loop approach

**Implementation:**
```java
HashSet<Integer> seen = new HashSet<>();
for(int num : a) {
    if(seen.contains(num)) {
        duplicateAse = true;
        break;
    }
    seen.add(num);
}
```

### 2. **Binary Search**
Searches for a target element in a sorted array and returns its index.

- **Time Complexity**: O(log n)
- **Space Complexity**: O(1)
- **Prerequisite**: Array must be sorted

**Method Signature:**
```java
public static int binarySearch(int[] arr, int target)
```

**Returns:**
- Index of the target element if found
- `-1` if target is not found

## Usage

### Example: Duplicate Detection
```java
int[] a = { 10, 5, 2, 33, 5, 60 };
// Output: "Duplicate Ase" (duplicate found)
```

### Example: Binary Search
```java
int[] sortedArray = { 2, 5, 10, 33, 60 };
int index = binarySearch(sortedArray, 33);
// Returns: 3
```

## Class Structure

### `Array.java`
- **Main Method**: Executes the duplicate detection example
- **binarySearch()**: Static method for binary search operations

## Requirements

- Java 8 or higher
- No external dependencies

## Compilation and Execution

```bash
# Compile
javac Array.java

# Run
java Array
```

## Future Enhancements

- [ ] Sum of Array calculation
- [ ] Average of Array calculation
- [ ] Additional sorting algorithms
- [ ] Performance benchmarking

## Notes

- The duplicate detector currently uses the sample array `{ 10, 5, 2, 33, 5, 60 }`
- The binary search method works only on sorted arrays
- Both algorithms are optimized for performance and readability

---

**Last Updated**: April 2026
