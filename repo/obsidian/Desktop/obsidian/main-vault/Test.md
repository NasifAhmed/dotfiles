1. **The Budget Check:** You want to find employees whose salary is higher than **every single** person in the Marketing department. Which operator do you use?
    
    - A) `IN`
        
    - B) `ANY`
        
    - C) `ALL`
        
2. **The Presence Check:** You want to list all Sales Orders, but only if the "Discounts" table actually contains **at least one** active holiday promotion. You don't care what the promotion is, just that it exists.
    
    - A) `EXISTS`
        
    - B) `IN`
        
    - C) `ANY`
        
3. **The Team List:** You have a list of `ID` numbers for the Top 10 scorers. You want to pull the names of players whose `ID` matches **one of the items** in that specific list.
    
    - A) `ALL`
        
    - B) `IN`
        
    - C) `EXISTS`
        
4. **The Minimum Bar:** You want to find students who scored higher than **at least one** student from the rival school. (i.e., they aren't the worst).
    
    - A) `> ALL`
        
    - B) `> ANY`
        
    - C) `EXISTS`
        

---

**5. What does this query return?**

SQL

```
SELECT ProductID FROM Warehouse 
WHERE StockLevel > ALL (SELECT StockLevel FROM Showroom);
```

- A) Products with more stock than the _average_ showroom item.
    
- B) Products with more stock than _at least one_ showroom item.
    
- C) Products with more stock than _the highest_ stocked item in the showroom.
    

**6. True or False?** The following two queries will always produce the exact same result:

_Query A:_ `SELECT Name FROM Users WHERE ID IN (SELECT UserID FROM Admins);`

_Query B:_ `SELECT Name FROM Users WHERE ID = ANY (SELECT UserID FROM Admins);`


---

**7. Write the Query:** We have two tables: `Books` (Title, Price) and `Library_Orders` (Title). Write a query to find all **Titles** from the `Books` table that are **NOT** present in the `Library_Orders` table using the `NOT EXISTS` operator.

**8. The "Ghost" Problem:** You have a table of `Subscribers`. Some have an `Email`, but others have `NULL` (unknown). If you run: `SELECT * FROM Users WHERE Email NOT IN (SELECT Email FROM Subscribers);` ...and the `Subscribers` table contains even **one** `NULL` value, what happens?

- A) It returns all Users not in the list.
    
- B) It returns nothing (Empty Set).
    
- C) It ignores the `NULL` and works normally.
    

**9. The Comparison Challenge:** Which of these is the correct way to find employees who earn **more than any** manager?

- A) `WHERE Salary > ANY (SELECT Salary FROM Managers)`
    
- B) `WHERE Salary > SOME (SELECT Salary FROM Managers)`
    
- C) Both A and B are correct (they are synonyms).
    

---

**10. Draw a line (or match) the following:**

- **Operator:** `!= ALL`
    
- **Operator:** `= ANY`
    
- **Operator:** `> ALL`
    
- **Operator:** `> ANY`
    
- **Logic:** A) Equivalent to `NOT IN`.
    
- **Logic:** B) Equivalent to `IN`.
    
- **Logic:** C) Must be greater than the `MAX` value.
    
- **Logic:** D) Must be greater than the `MIN` value.
    

---

**11. The "Efficiency" Question:** You are checking if a Customer has **at least one** order in a table with 10 million rows. Why is `EXISTS` usually faster than `IN`?

- A) `EXISTS` is written in a different programming language.
    
- B) `EXISTS` stops searching as soon as it finds the _first_ match (Short-circuiting).
    
- C) `IN` doesn't support large numbers.
    

---

**12. Refactor this code:** The following code uses `NOT IN`. Rewrite it using `NOT EXISTS`.

SQL

```
SELECT TeacherName 
FROM Teachers 
WHERE TeacherID NOT IN (SELECT TeacherID FROM ClassAssignments);
```