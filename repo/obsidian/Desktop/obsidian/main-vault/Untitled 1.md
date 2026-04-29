### Leap Year Verification

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

Centurial years refer to the years that are divisible by 100. The centurial years are not leap years except for years that are exactly divisible by 400. The non-centurial years, that is, years that are not divisible by 100, refer to leap years that are divisible by 4. The function `isLeapYear` receives an integer number `year` and returns true if a given year is a leap year or false otherwise.

**Pseudocode:**
```plaintext
○ boolean: isLeapYear (integer: year)
  if (year mod 400 = 0)
    return true
  elseif (year mod 100 = 0)
    return false
  elseif (year mod 4 = 0)
    return true
  else
    return false
  endif
```

---

### Perfect Number Verification

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The function `isPerfect` receives positive number `n`, and returns whether `n` is a perfect number. Here, a number is a "perfect number" if the sum of its positive divisors (excluding the number itself) is equal to the number itself. For instance, 28 is a perfect number because 28 has divisors 1, 2, 4, 7, and 14, and 1+2+4+7+14=28.

**Pseudocode:**

```plaintext
○ boolean: isPerfect (integer: n)
  integer: k
  integer: sum <- 0
  integer: half <- integer part of (n / 2)
  for (increase k from 1 to half by 1)
    if (n mod k = 0)
      sum <- sum + k
    endif
  endfor
  if (sum = n)
    return true
  else
    return false
  endif
```

---

### Binary to Decimal Conversion

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The following function receives an integer number and returns the result of interpreting the decimal representation of the number as a binary number. Note that the number is non-negative, and its decimal representation comprises only the digits 0 and 1. For instance, if it receives 1100, it returns 12.

**Pseudocode:**
```plaintext
○ integer: convert(integer: number)
  integer: place, n, remainder, decimal
  decimal <- 0
  place <- 1
  n <- number
  while (n > 0)
    remainder <- n mod 10
    n <- integer part of (n / 10)
    decimal <- decimal + remainder * place
    place <- 2 * place
  endwhile
  return decimal
```

---

### Calculation of $(\sqrt{x}+\sqrt{y})^2$

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The function `calc` receives the positive real numbers `x` and `y`, and returns the result of the calculation of $(\sqrt{x}+\sqrt{y})^2$. For instance, when the function `calc` is called as `calc(4, 9)`, the return value is 25. Here, the function `pow(a, b)` returns `a` raised to the power of `b`.

**Pseudocode:**
```plaintext
○ real: calc(real: x, real: y)
  return pow(pow(x, 0.5) + pow(y, 0.5), 2)
```

---

### Gray Code to Binary Conversion

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

Gray code is a sequence of binary numbers in which two successive values differ by only 1 bit. The function `GrayBiCon` converts the gray code to a binary code using bitwise operators. The bitwise operators operate on the individual bits of the variables. The function receives the 8-bit type argument `x` as a gray code, and returns a corresponding binary number of the given argument. The value of each bit after conversion is the exclusive OR of the most significant bit in the gray code up to the corresponding bit position and the converted value of the next higher bit position. For instance, when the function `GrayBiCon` is called as `GrayBiCon(00001100)`, the return value is a binary number `00001000`.

**Pseudocode:**
```plaintext
○ 8-bit: GrayBiCon(8-bit: x)
  8-bit: y <- x
  8-bit: z <- x
  while (z != 00000000)
    z <- z >> 1
    y <- y ^ z
  endwhile
  return y
```

---

### String Reverse Using Stack

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The function `reverse` takes a string `inputStr` as a parameter and returns the reversed string. Here, the length of the string given to `inputStr` is 100 or less. In the program, areas outside of the arrays must not be referenced and the undefined value must not be appended to a string.

**Pseudocode:**

```plaintext
global: character []: stack <- {100 undefined}
global: integer: sp <- 0

○ string: reverse(string: inputStr)
  integer: n <- length of inputStr
  integer: i
  character: x, v
  string: outputStr <- ""
  for (increase i from 1 to n by 1)
    x <- the i-th character of string inputStr
    push(x)
  endfor
  while (sp != 0)
    v <- pop()
    append v to outputStr
  endwhile
  return outputStr

○ push (character: x)
  sp <- sp + 1
  stack[sp] <- x

○ character: pop()
  character: retvar <- stack[sp]
  sp <- sp - 1
  return retvar
```

---

### Identical Binary Trees Check

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

Given the root of two binary trees, the aim of the following program is to check whether these two trees are identical. Two binary trees are defined as identical if they satisfy the following formal conditions:

Structure: Both trees have the same structure, implying that for every corresponding node in the two trees, the arrangement of the left and right children is the same.

Node Values: Each corresponding node in the two trees must contain the same value. Specifically, if tree $T_1$ has a node $N_1$ with value $v_1$ and tree $T_2$ has the corresponding node $N_2$ with value $v_2$, then $v_1=v_2$. The function `isSameTree` takes two instances of class `TreeNode` as the argument representing the root nodes of two binary trees, and returns true if the trees are identical, or false otherwise.

**Pseudocode:**

```plaintext
○ boolean isSameTree(TreeNode: p, TreeNode: q)
  boolean: checkLeft, checkRight
  if (p = undefined and q = undefined)
    return true
  endif
  if (p = undefined or q = undefined)
    return false
  endif
  if (p.val != q.val)
    return false
  endif
  checkLeft <- isSameTree(p.left, q.left)
  checkRight <- isSameTree(p.right, q.right)
  return checkLeft and checkRight
```

---

### Doubly Linked List Delete Last

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The procedure `deleteLast` removes an element at the end of a doubly linked list. Each element of the doubly linked list is represented by the class `ListElement`. The global variable `listHead` holds a reference to the head element of the doubly linked list. Remember that each element in the doubly linked list has a reference to its previous element and its next element. Here, if the list is empty, `listHead` is set to undefined.

The procedure handles three main cases: if the list is empty, it outputs "empty." If the list contains only one element, it becomes empty after deletion. If multiple elements are present, it only removes the last element.

**Pseudocode:**

```plaintext
global: ListElement: listHead

○ deleteLast()
  ListElement: current
  if (listHead is undefined) // empty list
    output "empty"
  else
    current <- listHead
    while (current.next is not undefined)
      current <- current.next
    endwhile
    if (current.prev is not undefined) // multiple elements are present
      current.prev.next <- undefined
    else // only one element is present
      listHead <- undefined
    endif
  endif
```

---

### Counting Sort

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The procedure `sort` receives an integer array `arr` and prints all the integers in `arr` in ascending order, separated by commas. The number of elements in `arr` is ≥ 1. The values of all array elements are in the range of 0-10. If `arr` is {9, 3, 2, 0, 9, 3, 0, 1, 5, 3, 8}, at the end of the procedure, it outputs "0, 0, 1, 2, 3, 3, 3, 5, 8, 9, 9, " and the values of the elements of array `s` will be tracked appropriately.

**Pseudocode:**

```plaintext
○ sort(integer []: arr) // prints all the elements in arr in ascending order
  integer []: s <- {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  integer: i, j
  for (increase i from 1 to (the number of elements in arr) by 1)
    s[arr[i]] <- s[arr[i]] + 1
  endfor
  for (increase i from 0 to 10 by 1)
    if (s[i] > 0)
      for (increase j from 0 to s[i] - 1 by 1)
        output i and ", "
      endfor
    endif
  endfor
  return
```

---

### Hamming Distance

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The function `hammingDistance` compares the two-character arrays `s1` and `s2` that are given as arguments. `s1` and `s2` have one or more elements. If `s1` and `s2` do not have the same number of elements, the function returns -1. Otherwise, it returns the number of indices where two arrays have different element values at the same index.

**Pseudocode:**

```plaintext
○ integer: hammingDistance (character []: s1, character []: s2)
  integer: i, cnt <- 0
  if (the number of elements in s1 != the number of elements in s2)
    return -1
  endif
  for (increase i from 1 to the number of elements in s1 by 1)
    if (s1[i] != s2[i])
      cnt <- cnt + 1
    endif
  endfor
  return cnt
```

---

### Maximum Subarray

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The procedure `maximumSubarray` calculates the maximum sum of the subarray of the array `T`. A subarray is a contiguous portion of the array, for instance, from T[1] to T[3]. It can be as short as one element or as long as the entire array. The procedure finds one of the subarrays with the largest sum of values, and outputs the sum, the first, and the last indices of the subarray. For instance, if the content of the array is {-2, 1, -3, 4, 1, 2, 1, 5, 4}, the output will be 6, 4, and 7 representing the sum, first index, and last index, respectively.

**Pseudocode:**

```plaintext
○ maximumSubarray (integer []: T)
  integer: n <- the number of elements in T
  integer: i, j
  integer: first, last /* the first and last indices of the subarray */
  integer: sum
  integer: max <- T[1] - 1
  for (increase i from 1 to n by 1)
    sum <- 0
    for (increase j from i to n by 1)
      sum <- sum + T[j]
      if (sum > max)
        first <- i
        last <- j
        max <- sum
      endif
    endfor
  endfor
  output max, first, last
```

---

### Cosine Maclaurin Series Approximation

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

The function `cosine(z)` returns an approximate value of the cosine value of `z` degrees. The function uses Maclaurin series expansion for the cosine shown below and can be used to determine $\cos(y)$ for values of `y` radians.

$\cos(y)=1-\frac{y^2}{2!}+\frac{y^4}{4!}-\frac{y^6}{6!}+...$

**Pseudocode:**

```plaintext
○ real: cosine (real: z)
  real: y <- z * pi / 180 // convert from degrees to radians
  real: term <- 1
  real: cosy <- term
  integer: n <- 0
  while (absolute value of term > 0.000000001)
    n <- n + 1
    term <- term * (-1 * (y squared / (2 * n * (2 * n - 1))))
    cosy <- cosy + term
  endwhile
  return cosy
```

---

### Craps Monte Carlo Simulation

**Year & Exam:** April 2025 (2025S)

**Explanation/Context:**

Craps is a casino dice game in which players bet on the outcomes of the roll of a pair dice. In the rules of the game, a player rolls two dice and finds their sum.

1. If the sum is 7 or 11, the player wins.
    
2. If the sum is 2, 3 or 12, the player loses.
    
3. Otherwise (the sum is 4, 5, 6, 8, 9 or 10), the player neither wins nor loses. However, the player continues rolling the dice until they either roll the same (initial) sum again (in which case they win the game) or roll a sum of 7 (in which case they lose the game).
    
    The program approximates the chance of winning a game of Craps using the Monte Carlo method (generating random numbers rather than actually rolling dice) and outputs it. It also calculates and outputs the relative error.
    

**Pseudocode:**

```plaintext
integer: wins_sum <- 0
integer: lose_sum <- 0
integer: n <- 10000
integer: i, dice1, dice2, sum, newsum
real: result, pt <- (244 / 495)
for (increase i from 1 to n by 1)
  dice1 <- random_int(1, 6)
  dice2 <- random_int(1, 6)
  sum <- dice1 + dice2
  if (sum = 7 or sum = 11)
    wins_sum <- wins_sum + 1
  elseif (sum = 2 or sum = 3 or sum = 12)
    lose_sum <- lose_sum + 1
  else
    do
      dice1 <- random_int(1, 6)
      dice2 <- random_int(1, 6)
      newsum <- dice1 + dice2
      if (newsum = sum)
        wins_sum <- wins_sum + 1
      elseif (newsum = 7)
        lose_sum <- lose_sum + 1
      endif
    while (newsum != sum and newsum != 7)
  endif
endfor
result <- wins_sum / n
output result, absolute value of ((result - pt) / pt)
```

---

### Sum of Even Elements in Range

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The function `sum` receives an integer array `array` with at least two elements and two positive integers `k` and `m` (`k < m ≤` number of elements in array). It calculates the sum of even elements of the array `array` whose indices are from `k` to `m`.

**Pseudocode:**

```plaintext
○ integer: sum(integer []: array, integer: k, integer: m)
  integer: s <- 0
  integer: i <- k
  while (i <= m)
    if (array[i] mod 2 = 0)
      s <- s + array[i]
    endif
    i <- i + 1
  endwhile
  return s
```

---

### Find Mode of Dataset

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

In statistics, the mode is the value that occurs most frequently in a dataset. For example, the mode of the integer array `{2, 1, 1, 9, 6, 6, 2, 5, 6}` is 6, as it occurs most often. The function `findMode` receives an integer array `arr` as a dataset and returns the mode for it.

**Pseudocode:**

```plaintext
○ integer findMode (integer []: arr)
  integer: n <- the number of elements in arr
  integer: m <- arr[1] /* Current mode value */
  integer: m_c <- 1 /* Frequency count of mode */
  integer: c, i, j
  for (increase i from 1 to n - 1 by 1)
    c <- 1
    for (increase j from i + 1 to n by 1)
      if (arr[i] = arr[j])
        c <- c + 1
      endif
    endfor
    if (m_c < c)
      m_c <- c
      m <- arr[i]
    endif
  endfor
  return m
```

---

### Subarray Sum

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Given an array of positive integers and a target sum, the problem is to find the subarray whose sum is equal to the target sum. A subarray is a part of the given array composed of contiguous elements. The procedure `subArraySum` receives an integer array `arr` and an integer value `targetSum` as arguments and finds the subarray whose sum is equal to the target sum. If a subarray that satisfies this condition is found, it prints their starting and ending indices, and finishes the task. Otherwise, it prints the message "No subarray found".

**Pseudocode:**

```plaintext
○ subArraySum(integer []: arr, integer: targetSum)
  integer: sum, start, end
  integer: N <- the number of elements in arr
  for (increase start from 1 to N by 1)
    sum <- 0
    for (increase end from start to N by 1)
      sum <- sum + arr[end]
      if (sum = targetSum)
        output start, end
        return
      elseif (sum > targetSum)
        exit the for block marked alpha
      endif
    endfor // alpha
  endfor
  output "No subarray found"
```

---

### Reverse Digits of a Number

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The procedure `reverse_digits` receives one positive integer argument named `num` and outputs both the original integer and the integer with its digits reversed. Assume that the ones digit of `num` is not 0. For example, if the number is 456, it outputs 654.

**Pseudocode:**

```plaintext
○ reverse_digits (integer: num)
  integer: rev <- 0
  integer: rm <- 0
  integer: temp <- num
  while (temp > 0)
    rm <- temp mod 10
    rev <- rev * 10 + rm
    temp <- integer part of (temp / 10)
  endwhile
  output "Number is", num, ", output", rev
```

---

### Print Prime Numbers

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Prime numbers are the positive integers that are only divisible by the number itself and 1. Procedure `printPrime` receives the integer `N` (N ≥ 1) as an argument and prints the first `N` prime numbers. For example, `printPrime(6)` will print "2 3 5 7 11 13".

**Pseudocode:**

```plaintext
○ printPrime (integer: N)
  integer: count, number, i
  boolean: isPrime
  count <- 1
  number <- 2
  while (count <= N)
    isPrime <- true
    for (increase i from 2 to integer part of the square root of number by 1)
      if (number mod i = 0)
        isPrime <- false
        exit the for block
      endif
    endfor
    if (isPrime = true)
      output number, " "
      count <- count + 1
    endif
    number <- number + 1
  endwhile
```

---

### Class Inheritance Output Trace

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Class `Rectangle` represents a two-dimensional figure, and class `Cuboid` represents a three-dimensional figure. The class `Cuboid` is a subclass of the class `Rectangle`. The `enlarge` method increases the size of the calling object by adding the dimensions of the shape passed as an argument. The program calls these methods to output the final dimensions.

**Pseudocode:**

```plaintext
Rectangle: f1 <- Rectangle(5, 2)
Cuboid: f2 <- Cuboid(9, 4, 7)
f1.enlarge(f2)
f1.output()

// Expected Output: (14, 6)
```

---

### Reverse Singly Linked List

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

A singly linked list can be reversed using a recursive procedure. Let `head` be the first element of the list, and let `elm` be undefined. To reverse the order of the elements in the list starting from `head`, reverse the list starting from the next element of `head`, and then connect `head` to the end of the reversed list. The recursive function `reverseList` reverses a singly linked list and returns the head of the reversed list.

**Pseudocode:**

```plaintext
○ ListElement: reverseList (ListElement: head, ListElement: elm)
  ListElement: listHead
  if (head.next is not undefined)
    listHead <- reverseList(head.next, head)
  else
    listHead <- head
  endif
  head.next <- elm
  return listHead
```

---

### Stack Push and Pop Operations

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Stack stores data using first-in, last-out ordering. Here, the items stored in the stack are integer values, and the stack is controlled by the procedure `push` and the function `pop`. The procedure `push` adds an item given as an argument to the top of the stack, and the function `pop` removes the top item from the stack and returns it. The global variable `stck` is an array of 10 integers that stores the stack items, and the global variable `tos` is the pointer that points to the topmost item of the stack.

**Pseudocode:**

```plaintext
global: integer []: stck <- {10 undefined}
global: integer: tos <- 0

○ push (integer: item)
  if (tos = 10)
    output "Stack is Full"
  else
    tos <- tos + 1
    stck[tos] <- item
  endif

○ integer: pop()
  integer: item
  if (tos < 1)
    output "Stack is Empty"
    return undefined
  else
    item <- stck[tos]
    tos <- tos - 1
  endif
  return item
```

---

### Breadth-First Search (Graph Traversal)

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The procedure `traverse` traces through a vertex of a graph, and outputs all vertex numbers in the graph. One of the vertex numbers of the graph is specified with the argument `k`. The global 2-dimensional array `graph` represents the graph. Each element `graph[i,j]` is equal to 1 if there is an edge between vertices `i` and `j`, and 0 otherwise. The array `visited` stores boolean values indicating whether a vertex has been visited. The procedure uses a Queue to manage the traversal order.

**Pseudocode:**

```plaintext
global: integer [,]: graph <- {{0, 1, 0, 1, 0},
                               {1, 0, 1, 0, 1},
                               {0, 1, 0, 0, 0},
                               {1, 0, 0, 0, 1},
                               {0, 1, 0, 1, 0}}

○ traverse(integer: k)
  Queue: queue <- Queue()
  boolean []: visited <- {false, false, false, false, false}
  integer: v, i
  queue.enqueue(k)
  visited[k] <- true
  while (not queue.isEmpty())
    v <- queue.dequeue()
    output v
    for (increase i from 1 to 5 by 1)
      if (graph[v, i] = 1 and visited[i] = false)
        queue.enqueue(i)
        visited[i] <- true
      endif
    endfor
  endwhile

// Expected Output for traverse(1): 1, 2, 4, 3, 5
```

---

### Insert After in Singly Linked List

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The procedure `insertAfter` inserts an element into a singly linked list at the position after an existing element with a specific data value. The argument `targetData` is a string type data that represents the value of the existing element in the list, after which a new element is to be inserted. If no corresponding element exists, no action is taken. The argument `newData` represents the value of the new element to be inserted.

**Pseudocode:**

```plaintext
global: Element: head // stores first element in the list

○ insertAfter (string: targetData, string: newData)
  Element: x, y
  x <- head
  while(x is not undefined)
    if (x.data = targetData)
      y <- Element(newData)
      y.next <- x.next
      x.next <- y
      exit the while block
    else
      x <- x.next
    endif
  endwhile
```

---

### Optimized Bubble Sort

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The bubble sort compares adjacent elements in an array and swaps them if they are out of order. It makes multiple passes through an array. The bubble sort can be modified to stop early if it finds that the array has become sorted. The function `quickBubble` is modified from conventional bubble sort, which sorts the elements in ascending order, to recognize a sorted array and stop early using an `exchange` flag.

**Pseudocode:**

```plaintext
○ integer []: quickBubble (integer []: array)
  integer []: arraySorted <- array
  boolean: exchange
  integer: maxIdx, i
  exchange <- true
  maxIdx <- (the number of elements in arraySorted) - 1
  while (maxIdx > 0 and exchange = true)
    exchange <- false
    for (increase i from 1 to maxIdx by 1)
      if (arraySorted[i] > arraySorted[i+1])
        exchange <- true
        swap the values of arraySorted[i] and arraySorted[i+1]
      endif
    endfor
    maxIdx <- maxIdx - 1
  endwhile
  return arraySorted
```

---

### Contains Substring

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The function `containsSubstring` receives two-character arrays `str` and `seq` as arguments, and returns a boolean value indicating whether the character array `str` contains the sequence `seq` as a substring. The character array `str` contains `seq` as a substring if every sequence of consecutive characters in `seq` exists somewhere in the sequence of characters in `str`, in the same order.

**Pseudocode:**

```plaintext
○ boolean: containsSubstring(character []: str, character []: seq)
  integer: strlen, seqlen, len, i, j
  strlen <- the number of elements in str
  seqlen <- the number of elements in seq
  if (seqlen > strlen)
    return false
  endif
  len <- strlen - seqlen + 1
  for (increase i from 1 to len by 1)
    j <- 1
    while (j <= seqlen)
      if (str[i + j - 1] != seq[j])
        exit the while block
      endif
      j <- j + 1
    endwhile
    if (j = seqlen + 1)
      return true
    endif
  endfor
  return false
```

---

### Binary Search Tree Node Removal

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Binary Search Trees (BST) are a fundamental data structure where each node has at most two children: a left child and a right child. The key property of a BST is that each value of all nodes in its left subtree are less than the value of the node, and each value of all nodes in its right subtree are greater than the value of the node. The function `remove` removes a node with the same key value as the argument `key` from the BST specified by the argument `node` and returns the resulting BST. It handles nodes with zero, one, or two children (by finding the smallest value in the right subtree to replace it).

**Pseudocode:**

```plaintext
○ Node: remove (Node: node, integer: key)
  Node: node2
  if (node is undefined)
    return undefined
  elseif (key < node.key)
    node.left <- remove (node.left, key)
  elseif (key > node.key)
    node.right <- remove (node.right, key)
  elseif (node.right is undefined)
    return node.left
  else
    node2 <- node.right
    while (node2.left is not undefined)
      node2 <- node2.left
    endwhile
    node.key <- node2.key
    node.right <- remove (node.right, node2.key)
  endif
  return node
```

---

### Magic Square Check

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

A 3x3 normal magic square is a 3x3 matrix where the sum of the elements for each row, each column, and each diagonal is the same (15). The square contains the numbers 1 to 9. The function `checkMagicSquare` receives a two-dimensional 3x3 integer array (matrix) `m` containing the numbers 1 to 9, and returns whether the given matrix is a magic square or not by checking all row, column, and diagonal sums.

**Pseudocode:**

```plaintext
○ boolean: checkMagicSquare (integer [,]: m)
  integer: i, j, k
  integer: dia1Sum <- 0
  integer: dia2Sum <- 0
  integer []: rowSum <- {0, 0, 0}
  integer []: colSum <- {0, 0, 0}
  for (increase i from 1 to 3 by 1)
    for (increase j from 1 to 3 by 1)
      rowSum[i] <- rowSum[i] + m[i, j]
      colSum[i] <- colSum[i] + m[j, i]
    endfor
    dia1Sum <- dia1Sum + m[i, i]
    dia2Sum <- dia2Sum + m[i, 3 - i + 1]
  endfor
  if (dia1Sum != dia2Sum)
    return false
  endif
  for (increase k from 1 to 3 by 1)
    if ((rowSum[k] != colSum[k]) or (rowSum[k] != dia1Sum))
      return false
    endif
  endfor
  return true
```

---

### Inverse Document Frequency (IDF)

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

Inverse document frequency (IDF) is a metric used to evaluate the importance of a word in a document relative to a document collection. The function `calcIDF` receives a string `term` and an array of strings `corpus` as arguments, and calculates and returns the IDF score for the term based on the given corpus. Traditionally, IDF is computed using the formula: $IDF(t) = \log(N / (1 + df(t)))$, where `N` is the total number of documents and `df(t)` is the number of documents containing the term.

**Pseudocode:**

```plaintext
○ real: calcIDF (string: term, string []: corpus)
  integer: i, j, numDocs, numWords, termCount
  boolean: isContainsTerm
  real: idf
  string []: words
  termCount <- 0
  numDocs <- the number of elements in corpus
  for (increase i from 1 to numDocs by 1)
    isContainsTerm <- false
    words <- split(corpus[i])
    numWords <- the number of elements in words
    for (increase j from 1 to numWords by 1)
      if (words[j] = term)
        isContainsTerm <- true
        exit the for block marked alpha
      endif
    endfor // alpha
    if (isContainsTerm = true)
      termCount <- termCount + 1
    endif
  endfor
  idf <- log(numDocs / (1 + termCount)) /* Division is performed in data type real */
  return idf
```

---

### Jaccard Similarity Index

**Year & Exam:** October 2025 (2025A)

**Explanation/Context:**

The Jaccard similarity index, J, measures the similarity between two sets by computing the ratio of the number of elements in their intersection to the number of elements in their union. The intersection operation builds a new set taking members that are common to both sets; while the union operation builds a set taking all members of both sets, where each member will appear only once. The function `jaccardSimilarity` calculates the Jaccard similarity stated above and returns it.

**Pseudocode:**

```plaintext
○ real: jaccardSimilarity(integer []: A, integer []: B)
  integer: nA <- number of elements in A
  integer: nB <- number of elements in B
  integer: iCount <- 0
  integer: uCount <- nB
  boolean: found
  for (increase i from 0 to nA - 1 by 1)
    found <- false
    for (increase j from 0 to nB - 1 by 1) // alpha
      if (A[i] = B[j])
        iCount <- iCount + 1
        found <- true
        exit the for block marked alpha
      endif
    endfor
    if (found = false)
      uCount <- uCount + 1
    endif
  endfor
  return iCount / uCount /* Division is done in data type real */
```

---

### Letter Grade Evaluation

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

A school determines the letter grade that a student will receive based on the score, which is an integer value between 0 and 100, as follows: 80-100 (D), 50-79 (P), 0-49 (F). The function `grade` receives a score (non-negative integer value between 0 and 100) and returns the letter grade as a character.

**Pseudocode:**

```plaintext
○ character: grade (integer: score)
  character: ret
  if (score >= 80)
    ret <- "D"
  elseif (score >= 50)
    ret <- "P"
  else
    ret <- "F"
  endif
  return ret
```

---

### Bus Ticket Price Calculation

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

A bus company operates buses between two cities. The standard ticket price is 20 US dollars and the discount ticket price for passenger aged 10 and under or aged 60 and over is 10 US dollars. Additionally, registered members of all ages always get the ticket at the discount price. The function `ticketPrice` receives the arguments `age` (a non-negative integer value) and `isMember` (a boolean indicating that the passenger is a member if the value is true), which returns the value `ret` as the ticket price (in US dollars).

**Pseudocode:**

```plaintext
○ integer: ticketPrice(integer: age, boolean: isMember)
  integer: ret
  if (((age <= 10) or (age >= 60)) or isMember)
    ret <- 10
  else
    ret <- 20
  endif
  return ret
```

---

### Sum of Even Numbers

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The program outputs the even numbers between 1 and 100. Subsequently, it prints the sum of those even numbers. Note that division is performed for data type integer, that is, a / b is the quotient of a divided by b.

**Pseudocode:**

```plaintext
integer: i
integer: sum <- 0
for (increase i from 1 to 100 by 1)
  if (i mod 2 = 0)
    output i
    sum <- sum + i
  endif
endfor
output sum
```

---

### Sum of Digits

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `sumDigits` receives a non-negative integer value `num` as argument, and returns the sum of the digits of `num`.

**Pseudocode:**

```plaintext
○ integer: sumDigits (integer: num)
  integer: sum <- 0
  while (num > 0)
    sum <- sum + num mod 10
    num <- integer part of (num / 10)
  endwhile
  return sum
```

---

### Seconds to HH:MM:SS Conversion

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `division` receives two integer values `a` and `b` and returns the quotient of `a` divided by `b`. The function `modulus` receives two integer values `a` and `b` and returns the remainder of `a` divided by `b`. The procedure `convert` receives the value of seconds as the input argument and outputs that value in the form of hours, minutes, and seconds. For example, when the procedure `convert` is called as `convert(5450)` the output is "1, 30, 50". Here, suppose that the range of input values satisfy 0 ≤ input < 86400.

**Pseudocode:**

```plaintext
○ convert(integer: input)
  integer: hour, minute, second
  second <- modulus (input, 60)
  minute <- modulus (division (input, 60), 60)
  hour <- division (input, 3600)
  output hour, minute, second

○ integer: division (integer: a, integer: b)
  integer: u
  u <- integer part of (a / b)
  return u

○ integer: modulus (integer: a, integer: b)
  integer: u
  u <- a mod b
  return u
```

---

### Count Set Bits

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `count1` receives the bit8 type (8-bit type) argument `byte`, and returns the number of bits 1 in the argument. For example, when the function `count1` is called as `count1(11001011)`, the return value is 5. Here, operator `&` represents a bitwise logical product, operator `|` represents a bitwise logical sum; operator `>>` represents a logical shift to the right, and operator `<<` represents a logical shift to the left.

**Pseudocode:**

```plaintext
○ integer: count1(bit8: byte)
  bit8: rbyte <- byte
  integer: r <- 0
  integer: i
  for (increase i from 1 to 8 by 1)
    if (rbyte & (00000001 << (i - 1)) != 00000000)
      r <- r + 1
    endif
  endfor
  return r
```

---

### Fibonacci Sequence

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The Fibonacci sequence is a sequence in which each number is equal to the sum of the two preceding numbers. In this question, the sequence starts with 0 and 1. The first 10 values in the sequence are 0, 1, 1, 2, 3, 5, 8, 13, 21, 34. For example, the 8-th number 13 is the sum of the two preceding numbers 5 and 8. The function `fibo` takes an integer value `n` as the argument and returns the value at the n-th position. Here, `n` reflects the position of the number in the sequence, starting with 1 (one). When `n` is 9, the function returns 21.

**Pseudocode:**

```plaintext
○ integer: fibo (integer: n)
  if ((n = 1) or (n = 2))
    return n - 1
  else
    return fibo(n - 1) + fibo(n - 2)
  endif
```

---

### Stack Operations

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The program implements a stack. The stack implementation only accepts positive integers. The function `empty` checks whether the stack is empty. The function `full` checks whether the stack is full. If the stack is not full, the function `push` pushes an element with a specified value onto the stack. If the stack is not empty, the function `pop` removes an element from the stack and returns its value. In the program, areas outside of the array must not be referenced.

**Pseudocode:**

```plaintext
global: integer []: content <- {undefined, undefined, undefined, undefined}
global: integer: index <- 1
global: integer: max <- 4 /* max size of the stack */

○ boolean: empty()
  if (index = 1)
    return true
  else
    return false
  endif

○ boolean: full()
  if (index > max)
    return true
  else
    return false
  endif

○ boolean: push (integer: i)
  if (not full())
    content[index] <- i
    index <- index + 1
    return true
  else
    return false
  endif

○ integer: pop()
  if (not empty())
    index <- index - 1
    return content[index]
  else
    return -1
  endif
```

---

### Binary Tree Preorder Traversal

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The procedure `preorder` traverses a binary tree and outputs the value of each node by following the sequence: root, left subtree, and right subtree using a stack (Last In, First Out). Each node of the binary tree is represented by the class `Node`. The argument `root` holds a reference to the root of the binary tree, which is an instance of the class `Node`. In the program, areas outside of the array must not be referenced.

**Pseudocode:**

```plaintext
○ preorder (Node: root)
  Node []: stack <- {undefined, ..., undefined} // an array with sufficient number of elements
  Node: v
  integer: sp <- 1 // The stack pointer
  stack[sp] <- root // Push root to the stack
  while (sp is not 0)
    v <- stack[sp] // Pop an element from the stack
    output v.info
    sp <- sp - 1
    if (v.right is not undefined)
      sp <- sp + 1
      stack[sp] <- v.right
    endif
    if (v.left is not undefined)
      sp <- sp + 1
      stack[sp] <- v.left
    endif
  endwhile
```

---

### Linear Circular Linked List Insertion

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The procedure `Insert` inserts an integer number given by the argument after the last element of the linear circular linked list. Each element of the linear circular linked list is represented by the class `ListElement`. The global variable `listHead` holds a reference to the head element of the linear circular linked list. Remember that in the circular linked list the last element points to the `listHead`. Here, if the list is empty, `listHead` is set to undefined.

**Pseudocode:**

```plaintext
global: ListElement: listHead

○ Insert(integer: newItem)
  ListElement: tmp, newNode
  newNode <- ListElement(newItem)
  if (listHead is undefined)
    listHead <- newNode
    listHead.next <- listHead
  else
    tmp <- listHead
    while (tmp.next is not listHead)
      tmp <- tmp.next
    endwhile
    tmp.next <- newNode
    newNode.next <- listHead
  endif
```

---

### Selection Sort

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The program sorts the data in ascending order using the selection sort algorithm. The algorithm repeatedly selects the smallest element from the unsorted portion of the array and swaps it with the first element of the unsorted portion until the entire array is sorted.

**Pseudocode:**

```plaintext
integer []: data <- {12, 11, 13, 5, 6}
integer: i, j, temp, minPos
integer: size <- the number of elements in data
for (increase i from 1 to (size - 1) by 1)
  minPos <- i
  for (increase j from i + 1 to size by 1)
    if (data[j] < data[minPos])
      minPos <- j
    endif
  endfor
  temp <- data[i]
  data[i] <- data[minPos]
  data[minPos] <- temp
endfor
```

---

### Palindrome Check

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

A string of character(s) is called a palindrome if it reads the same forwards and backwards. Here the input string consists of only the uppercase Roman alphabet. As an example, the string "MADAM" is a palindrome as it remains the same when written backwards (right to left). The procedure `isPalindrome` receives a string `str` as a parameter and outputs whether the string `str` is a palindrome or not. The procedure should use the minimum number of iterations for any number of characters in the string.

**Pseudocode:**

```plaintext
○ isPalindrome (string: str)
  integer: i, j, len
  boolean: flag
  flag <- true
  len <- number of characters in str
  i <- 1
  j <- len
  while (i < j)
    if (the i-th character of string str != the j-th character of string str)
      flag <- false
      exit the while block
    endif
    i <- i + 1
    j <- j - 1
  endwhile
  if (flag)
    output str, " is a palindrome."
  else
    output str, " is not a palindrome."
  endif
```

---

### Balanced Brackets Check

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `are_brackets_balanced` checks for balanced brackets. It parses the given array of characters and when an opening bracket ("(", "[", "{") is encountered, this is pushed onto the stack. When a closing bracket (")", "]", "}") is encountered, an element is popped from the stack and tested if it corresponds to the opening bracket. If the closing bracket matches its corresponding opening bracket, the process continues. Otherwise, it fails and the function returns false. After all characters have been processed, it returns false if any characters remain on the stack, otherwise it returns true. For simplicity, only brackets are considered as arguments to the function.

**Pseudocode:**

```plaintext
global: character [][]: brackets <- {
  {"(", ")"},
  {"{", "}"},
  {"[", "]"}
}

○ boolean: are_brackets_balanced(character []: expr)
  Stack: stack <- Stack()
  character: c, stacked_bracket
  for (c in expr)
    if (is_opening_bracket(c))
      stack.push(c)
    else
      if (stack.isEmpty())
        return false
      endif
      stacked_bracket <- stack.pop()
      if (get_closing_bracket(stacked_bracket) != c)
        return false
      endif
    endif
  endfor
  return stack.isEmpty()

○ boolean: is_opening_bracket(character: c)
  character []: chars
  for (chars in brackets)
    if (chars[1] = c)
      return true
    endif
  endfor
  return false

○ character: get_closing_bracket(character: c)
  character []: chars
  for (chars in brackets)
    if (chars[1] = c)
      return chars[2]
    endif
  endfor
  return undefined
```

---

### Cosine Similarity Calculation

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `calcSim` takes two vectors (arrays) as input, calculates their similarity, and returns a value that characterizes the similarity. A large similarity indicates that the vectors are similar, and a small similarity indicates that the vectors are dissimilar. For example, to quantify the similarity between two documents, you can create a vector of occurrences of some words for each of the two documents and input them into `calcSim`.

**Pseudocode:**

```plaintext
// Assume that arrays v1 and v2 have the same number of one or more elements
// and that the arrays are not all-zero.
○ real: calcSim (integer []: v1, integer []: v2)
  integer: i, x, y
  integer: sxx <- 0
  integer: syy <- 0
  integer: sxy <- 0
  for (increase i from 1 to the number of elements in v1 by 1)
    x <- v1[i]
    y <- v2[i]
    sxx <- sxx + x * x
    syy <- syy + y * y
    sxy <- sxy + x * y
  endfor
  return sxy / (square root of (sxx * syy))
```

---

### N-Grams Generation

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

N-grams are continuous sequences of words, symbols, or tokens in a document. N-grams of texts are extensively used in text mining and natural language processing tasks. An n-gram model is built by counting how often word sequences occur in corpus text and then estimating the probabilities. The procedure `NGRAMS` generates n-grams from text and outputs them. If the argument for `n` is 1, the procedure outputs the unigram result. If `n` is 2, the procedure outputs the bigram result and so on. The input text is a string of words separated by a space, so it is needed to split the string to generate n-grams.

**Pseudocode:**

```plaintext
○ NGRAMS (integer: n, string: text)
  string []: words <- split(text)
  string: s
  integer: i, j, length
  length <- the number of elements in words
  for (increase i from 1 to length - n + 1 by 1)
    s <- ""
    for (increase j from i to i + n - 1 by 1)
      s <- s + words[j] + " "
    endfor
    output s
  endfor
```

---

### Maclaurin Expansion of Sin(x)

**Year & Exam:** April 2024 (2024S)

**Explanation/Context:**

The function `m_sin` calculates and returns the approximate value of `sin(x)` for the argument `x` using the Maclaurin expansion. The program calculates `sin(x)` using the approximate formula below: `sin(x) = x/1! - x^3/3! + x^5/5! - ... + (-1)^n * (x^(2n+1) / (2n+1)!)`. Here, `!` is the factorial symbol, and `n` is the first integer for which absolute value of `(x^(2n+1) / (2n+1)!) <= 10^-7` is satisfied.

**Pseudocode:**

```plaintext
○ real: m_sin(real: x)
  real: vn <- x
  real: k <- 1
  real: sum <- vn
  real: epsi <- 1 * 10^-7
  while (abs(vn) > epsi) // abs(vn) returns the absolute value of vn
    k <- k + 2
    vn <- -vn * x^2 / ((k - 1) * k)
    sum <- sum + vn
  endwhile
  return sum
```

---

Here is the final set of topics with their explanations and completed pseudocode from the **October 2024 (2024A)** exam.

### Markov Chain (Bicycle Ridership)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Bicycle ridership in a city is studied. Examination of several years of data revealed that 30% of the people who regularly ride bicycles in a given year do not regularly ride bicycles in the subsequent year. Additionally, 2% of the people who do not regularly ride bicycles in that year begin to ride bicycles regularly in the subsequent year. If 5,000 people ride bicycles and 100,000 people do not ride bicycles in a given year, then the following program calculates the number of cyclists in the subsequent year (cycling) and that of people who do not ride bicycles in the subsequent year (noncycling).

**Pseudocode:**

```plaintext
real: pc <- 0.3
real: pb <- 0.02
real: pa <- (1 - pc)
real: pd <- (1 - pb)
integer []: N <- {5000, 100000}
real [,]: P <- {{pa, pb}, {pc, pd}}
real: cycling, noncycling
cycling <- P[1,1] * N[1] + P[1,2] * N[2]
noncycling <- P[2,1] * N[1] + P[2,2] * N[2]
output cycling, noncycling
```

---

### Coupon Calculation

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The function `coupon` receives the argument `prod_id` (a positive integer value) of product ID, and `pur_prod` (a positive integer value) of the number of purchased products by a customer. The function returns the number of coupons. For every purchase of three products of the product ID of which the last digit is three, the customer receives one coupon. Otherwise, they receive no coupon.

**Pseudocode:**

```plaintext
○ integer: coupon (integer: prod_id, integer: pur_prod)
  integer: num_coupon <- 0
  if (prod_id mod 10 = 3)
    num_coupon <- integer part of (pur_prod / 3)
  endif
  return num_coupon
```

---

### Second-Largest Element

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The program determines the second-largest element of an integer-type array and outputs its value. For instance, the second largest element of the array {2, 6, 9, 1, 7, 5} is 7. Here, we assume that the array has two or more elements and that no duplicate elements are present in the array.

**Pseudocode:**

```plaintext
integer []: array <- {2, 6, 9, 1, 7, 5}
integer: i
integer: max1 <- -∞
integer: max2 <- -∞
for (increase i from 1 to the number of elements of array by 1)
  if (array[i] > max1)
    max2 <- max1
    max1 <- array[i]
  elseif (array[i] > max2)
    max2 <- array[i]
  endif
endfor
output max2
```

---

### Prime Factors

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The procedure `primeFactors` outputs the prime factors for the input values as its argument. The first few prime numbers are 2, 3, 5, 7, 11, and 13. For instance, if the input integer is 12, the output is "2 x 2 x 3". If the input integer is 78, the output is "2 x 3 x 13". The input integer must be greater than 1.

**Pseudocode:**

```plaintext
○ primeFactors (integer: num)
  integer: i
  i <- 2
  do
    if (num mod i = 0)
      num <- integer part of (num / i)
      output i
      if (num > 1)
        output "x"
      endif
    else
      i <- i + 1
    endif
  while (num > 1)
```

---

### Geometric Mean

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Function `calcGeoMean` receives the array `dataArray` (the number of elements ≥ 1) as an argument and returns the geometric mean of values in `dataArray` as the return value. For the numbers $a_1, a_2, ..., a_n$, the geometric mean is the n-th root of $(a_1 \times a_2 \times ... \times a_n)$. Here, the `pow(x, y)` function returns a real value by raising `x` to the power of `y`. In the program, division is performed in data type real.

**Pseudocode:**

```plaintext
○ real: calcGeoMean (real []: dataArray)
  real: product, geomean
  integer: n <- the number of elements in dataArray
  integer: i
  product <- 1
  for (increase i from 1 to n by 1)
    product <- product * dataArray[i]
  endfor
  geomean <- pow(product, 1 / n)
  return geomean
```

---

### Quadratic Equation Roots

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The standard form of a quadratic equation is as follows: $ax^2 + bx + c = 0$, where a, b and c are real numbers and $a \neq 0$. Here, the term $b^2 - 4ac$ is known as the discriminant of a quadratic equation. It indicates the nature of the roots. If the discriminant value is positive, there are two solutions; if it is zero, there is one solution. Here, we assume that the discriminant value is non-negative. Function `sqrt(discriminant)` returns the principal square root value of the parameter. The procedure `findRoots` receives three real number arguments a, b, and c as coefficients and outputs the value of the root(s) of the quadratic equation.

**Pseudocode:**

```plaintext
○ findRoots (real: a, real: b, real: c)
  real: discriminant, root1, root2
  discriminant <- b * b - 4 * a * c
  if (discriminant > 0)
    root1 <- (-b + sqrt(discriminant)) / (2 * a)
    root2 <- (-b - sqrt(discriminant)) / (2 * a)
    output "root1 = ", root1, " and root2 = ", root2
  elseif (discriminant = 0)
    root1 <- -b / (2 * a)
    output "root1 = root2 = ", root1
  endif
```

---

### Longest Common Subsequence (LCS)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Given two strings, `str1` and `str2`, the task is to determine the length of the longest common subsequence (LCS), that is, the length of the longest subsequence present in both strings. For instance, if `str1` is "ABXDZ" and `str2` is "ABCD", the LCS between `str1` and `str2` will be "ABD" and the length of the LCS will be 3. The function `lcs` takes two strings and two integers `m` and `n` as arguments, representing the lengths of `str1` and `str2` on the first call. Another function `max` compares two integers and returns the maximum.

**Pseudocode:**

```plaintext
○ integer: max(integer: a, integer: b)
  if (a > b)
    return a
  else
    return b
  endif

○ integer: lcs (string: str1, string: str2, integer: m, integer: n)
  if (m = 0 or n = 0)
    return 0
  endif
  if (the m-th character of string str1 = the n-th character of string str2)
    return 1 + lcs(str1, str2, m - 1, n - 1)
  else
    return max(lcs(str1, str2, m, n - 1), lcs(str1, str2, m - 1, n))
  endif
```

---

### Priority Queue Trace

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

A priority queue is a queue where the handled elements have a priority assigned to them, and the elements are extracted with the order of the highest priority first. The class `PrioQueue` represents a priority queue. Here, the priority is the integer value 1, 2, or 3, and the smaller the value the higher the priority. When the procedure `prioSched` is called, it demonstrates inserting items with varying priorities and dequeuing them to output.

**Pseudocode:**

```plaintext
○ prioSched()
  PrioQueue: prioQueue <- PrioQueue()
  prioQueue.enqueue("E", 3)
  prioQueue.enqueue("F", 2)
  prioQueue.enqueue("G", 1)
  prioQueue.enqueue("H", 1)
  prioQueue.dequeue() /* The return value is ignored */
  prioQueue.dequeue() /* The return value is ignored */
  prioQueue.enqueue("I", 1)
  prioQueue.enqueue("J", 1)
  prioQueue.dequeue() /* The return value is ignored */
  prioQueue.enqueue("K", 2)
  prioQueue.enqueue("L", 3)
  prioQueue.enqueue("M", 1)
  while (prioQueue.size() is not equal to 0)
    output prioQueue.dequeue()
  endwhile

// Expected Output: "J", "M", "F", "K", "E", "L"
```

---

### Depth-First Search (Graph Traversal)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The procedure `traverse` traces through a vertex of a graph, and outputs all vertex numbers in the graph. The vertex number of the graph is specified with the argument `k`. The global variable `n` indicates the number of vertices in the graph. The global array `graph` represents the graph. Each element `graph[i][j]` is equal to 1 if an edge exists between vertices `i` and `j`, and it is equal to 0 otherwise. The global array `visited` stores boolean values, where `visited[i]` indicates whether vertex `i` of the graph has been visited during the procedure.

**Pseudocode:**

```plaintext
global: integer: n <- 5
global: integer [,]: graph <- {{0, 1, 0, 1, 0},
                               {1, 0, 1, 0, 1},
                               {0, 1, 0, 0, 0},
                               {1, 0, 0, 0, 1},
                               {0, 1, 0, 1, 0}}
global: boolean []: visited <- {false, false, false, false, false}

○ traverse (integer: k)
  integer: i
  visited[k] <- true
  output k
  for (increase i from 1 to n by 1)
    if (graph[k][i] = 1 and visited[i] = false)
      traverse(i)
    endif
  endfor

// Expected Output for traverse(1): 1, 2, 3, 5, 4
```

---

### Add Node in Singly-Linked List

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The procedure `addNode` adds a node to a singly-linked list at the position specified by the argument `pos`. The argument `pos` is a positive integer that is equal to or less than the (number of nodes + 1) in the list. The position at the top of the list is 1. The class `ListNode` represents a node in a singly-linked list. A reference to the first node in the list is pre-stored in the global variable `listHead`.

**Pseudocode:**

```plaintext
global: ListNode: listHead // stores the first node in the list

○ addNode(integer: pos, character: val)
  ListNode: prev, newNode
  integer: i
  newNode <- ListNode()
  newNode.val <- val
  if (pos is equal to 1)
    newNode.next <- listHead
    listHead <- newNode
  else
    prev <- listHead
    /* if pos is equal to 2, the following iteration process is not executed */
    for (increase i from 2 to pos - 1 by 1)
      prev <- prev.next
    endfor
    newNode.next <- prev.next
    prev.next <- newNode
  endif
```

---

### Insertion Sort

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The procedure `sort` sorts an integer array containing a certain number ($\ge 2$) of elements in ascending order by iterating and shifting elements back until they are in their correct sorted position relative to the previously processed items.

**Pseudocode:**

```plaintext
○ sort (integer []: arg)
  integer []: A <- arg
  integer: i, k
  for (increase i from 2 to the number of elements in A by 1)
    k <- i
    while (k > 1)
      if (A[k - 1] <= A[k])
        exit the while block
      endif
      swap A[k] and A[k - 1]
      k <- k - 1
    endwhile
  endfor
  output A
```

---

### Palindrome Check (Array)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The function `isPalindrome` determines whether the character array `s` given as argument is a palindrome. Palindromes are words when read backward will still be the same such as "noon" and "madam." If character array `s` is a palindrome, it returns the value true and if not, the function returns false. In the program, areas outside of the arrays must not be referenced.

**Pseudocode:**

```plaintext
○ boolean: isPalindrome (character []: s)
  integer: left <- 1
  integer: right <- the number of elements in s
  boolean: ok <- true
  while (left < right)
    if (s[left] = s[right])
      left <- left + 1
      right <- right - 1
    else
      ok <- false
      break
    endif
  endwhile
  return ok
```

---

### Hash Table Insertion (Linear Probing)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Hashing in data structures is a fundamental concept used for efficient data retrieval and storage mechanisms. A program storing key-data pairs in an array by transforming keys into array indexes using a hash function exists. A collision occurs when two keys hash to the same index in the array representing the hash table. A common method handling collisions, the probing mechanism (checking for an available element), is used in the function. The procedure `insertData` inserts a pair of key and data, if the element in the array is `{undefined}`.

**Pseudocode:**

```plaintext
global: integer [][]: hashTable <- {Elements comprising 1000 {undefined}}
global: integer: size <- 1000

○ integer: hashFunction (integer: key)
  return (key mod size) + 1

○ insertData(integer: key, integer: data)
  integer: index
  index <- hashFunction (key)
  while (hashTable[index][1] != undefined)
    if (index = size)
      index <- 1
    else
      index <- index + 1
    endif
  endwhile
  hashTable[index] <- {key, data}
```

---

### Array Summarization (Quantiles)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

The function `summarize` receives the array `sortedData` sorted in ascending order and returns five values that characterize the array. The array `sortedData` must have at least one element. The `summarize` calls the `findRank` with two arguments, `sortedData` and `q` to extract specific quantiles like the minimum, lower quartile, median, upper quartile, and maximum from the array.

**Pseudocode:**

```plaintext
○ real: findRank (real []: sortedData, real: q)
  integer: j
  j <- floor(q * (the number of elements in sortedData - 1))
  // floor returns the closest integer less than or equal to a given
  // number, e.g. floor (7.75) returns 7.
  return sortedData[j + 1]

○ real []: summarize (real []: sortedData)
  real []: rankData <- {} /* array with 0 elements */
  real []: q <- {0, 0.25, 0.5, 0.75, 1}
  integer: i
  for (increase i from 1 to the number of elements in q by 1)
    add the return value of findRank (sortedData, q[i]) to the end of rankData
  endfor
  return rankData

// Expected Output for summarize({0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1}): {0.1, 0.3, 0.5, 0.7, 1}
```

---

### Markov Chain (Weather Prediction)

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Suppose the weather in a city, from day to day, follows a Markov process. This implies the next day's weather depends only on today's weather and not on those of the previous days. If it rains today in the city, a probability 0.3 exists that it will rain again tomorrow. Similarly, the probability that tomorrow's weather will be sunny is 0.4 and that it will be cloudy is 0.3... Using this transition matrix, the probability distribution of the weather after several days can be estimated. The program calculates the probability distribution of the weather of the city after three days from the present day and outputs a 3x3 square matrix that shows this probability distribution of the weather.

**Pseudocode:**

```plaintext
real [,]: pmat <- {{0.3, 0.4, 0.3}, {0.2, 0.7, 0.1}, {0.25, 0.5, 0.25}}
real [,]: dmat <- pmat
real [,]: smat
integer: i, j, k, m
for (increase m from 1 to 2 by 1)
  smat <- {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
  for (increase i from 1 to 3 by 1)
    for (increase j from 1 to 3 by 1)
      for (increase k from 1 to 3 by 1)
        smat[i, j] <- smat[i, j] + dmat[i, k] * pmat[k, j]
      endfor
    endfor
  endfor
  dmat <- smat
endfor
output dmat
```

---

### Extended Hamming Distance

**Year & Exam:** October 2024 (2024A)

**Explanation/Context:**

Function `hammingDistance` receives two strings as argument and returns Hamming distance as the return value. Hamming distance is a metric used to measure the difference between two strings of equal length. It counts the number of positions at which the corresponding characters are different. It can also be extended to strings of different lengths by considering the unmatched characters as differences. For instance, the return value is 5 when the function `hammingDistance("101010", "111000111")` is called, because of two differences in first six characters and addition of three extra unmatched characters.

**Pseudocode:**

```plaintext
○ integer: hammingDistance (string: s1, string: s2)
  integer: distance, length1, length2, minLength, remainingLength
  length1 <- length of s1
  length2 <- length of s2
  distance <- 0
  minLength <- length1
  if (length2 < length1)
    minLength <- length2
  endif
  for (increase i from 1 to minLength by 1)
    if (the i-th character of string s1 is not equal to the i-th character of string s2)
      distance <- distance + 1
    endif
  endfor
  if (length1 > length2)
    remainingLength = length1 - length2
  else
    remainingLength = length2 - length1
  endif
  distance <- distance + remainingLength
  return distance
```