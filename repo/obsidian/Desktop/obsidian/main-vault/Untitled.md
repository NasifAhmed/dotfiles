### Leap Year Verification
```
○ boolean: isLeapYear (integer: year) // returns true if the variable year is a leap year; otherwise, returns false
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

### Perfect Number Verification
```
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

### Binary to Decimal Conversion
```
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

### Calculation of $(\sqrt{x}+\sqrt{y})^2$
```
○ real: calc(real: x, real: y)
  return pow(pow(x, 0.5) + pow(y, 0.5), 2)
```

### Gray Code to Binary Conversion
```
○ 8-bit: GrayBiCon(8-bit: x)
  8-bit: y <- x
  8-bit: z <- x
  while (z != 00000000)
    z <- z >> 1
    y <- y ^ z
  endwhile
  return y
``` 

### String Reverse Using Stack
```
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

### Identical Binary Trees Check
```
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

### Doubly Linked List Delete Last
```
global: ListElement: listHead
/* A reference to the first element of the list is stored. */

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

### Counting Sort
```
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

### Hamming Distance
```
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

### Maximum Subarray
```
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

### Cosine Maclaurin Series Approximation
```
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

### Distance Calculation
```
○ real: calcDistance (real []: p1, real []: p2, integer: n)
  integer: i
  real: distance <- 0
  real: ex <- 1 / n /* Division is performed in data type real */
  for (increase i from 1 to number of elements in p1 by 1)
    distance <- distance + pow(abs(p1[i] - p2[i]), n)
  endfor
  distance <- pow(distance, ex)
  return distance
```

### Craps Monte Carlo Simulation
```
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

### Sum of Even Elements in Range
```
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

### Find Mode of Dataset
```
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

### Subarray Sum
```
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

### Reverse Digits of a Number
```
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

### Print Prime Numbers
```
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

### Class Inheritance Output Trace
```
Rectangle: f1 <- Rectangle(5, 2)
Cuboid: f2 <- Cuboid(9, 4, 7)
f1.enlarge(f2)
f1.output()

// Expected Output: (14, 6)
```

### Reverse Singly Linked List
```
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

### Stack Push and Pop Operations
```
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

### Breadth-First Search (Graph Traversal)
```
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

### Insert After in Singly Linked List
```
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

### Optimized Bubble Sort
```
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

### Contains Substring
```
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

### Binary Search Tree Node Removal
```
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

### Magic Square Check
```
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

### Inverse Document Frequency (IDF)
```
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

### Jaccard Similarity Index
```
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

### Letter Grade Evaluation
```
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

### Bus Ticket Price Calculation
```
○ integer: ticketPrice(integer: age, boolean: isMember)
  integer: ret
  if (((age <= 10) or (age >= 60)) or isMember)
    ret <- 10
  else
    ret <- 20
  endif
  return ret
```

### Sum of Even Numbers
```
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

### Sum of Digits
```
○ integer: sumDigits (integer: num)
  integer: sum <- 0
  while (num > 0)
    sum <- sum + num mod 10
    num <- integer part of (num / 10)
  endwhile
  return sum
```

### Seconds to HH:MM:SS Conversion
```
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

### Count Set Bits
```
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

### Fibonacci Sequence
```
○ integer: fibo (integer: n)
  if ((n = 1) or (n = 2))
    return n - 1
  else
    return fibo(n - 1) + fibo(n - 2)
  endif
```

### Stack Operations
```
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

### Binary Tree Preorder Traversal
```
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

### Linear Circular Linked List Insertion
```
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

### Selection Sort
```
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

### Palindrome Check
```
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

### Balanced Brackets Check
```
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

### Cosine Similarity Calculation
```
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

### N-Grams Generation
```
○ NGRAMS(integer: n, string: text)
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

### Maclaurin Expansion of Sin(x)
```
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

### Markov Chain (Bicycle Ridership)
```
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

### Coupon Calculation
```
○ integer: coupon (integer: prod_id, integer: pur_prod)
  integer: num_coupon <- 0
  if (prod_id mod 10 = 3)
    num_coupon <- integer part of (pur_prod / 3)
  endif
  return num_coupon
```

### Second-Largest Element
```
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

### Prime Factors
```
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

### Geometric Mean
```
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

### Quadratic Equation Roots
```
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

### Longest Common Subsequence (LCS)
```
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

### Priority Queue Trace
```
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

### Depth-First Search (Graph Traversal)
```
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

### Add Node in Singly-Linked List
```
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

### Insertion Sort
```
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

### Palindrome Check (Array)
```
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

### Hash Table Insertion (Linear Probing)
```
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

### Array Summarization (Quantiles)
```
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

### Markov Chain (Weather Prediction)
```
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

### Extended Hamming Distance
```
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