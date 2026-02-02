**1. The "Hello World" of SQL**
View every single row and column in the Student table.
```sql
SELECT * FROM Student;
```

**2. Picking specific columns We only want to see names and genders, not the IDs.**
```sql
SELECT Name, Gender FROM Student;
```

**3. Filtering data (The WHERE clause) Show only the Female students.**
```sql
SELECT * FROM Student WHERE Gender = 'Female';
```

**4. Filtering with numbers Show students whose StudentNumber is greater than 7000.**
```sql
SELECT * FROM Student WHERE StudentNumber > 7000;
```

**5. Multiple Filters (AND)** Show students who are 'Male' AND belong to DeptID 1.
```sql
SELECT * FROM Student 
WHERE Gender = 'Male' AND DeptID = 1;
```

**6. Multiple Filters (OR)** Show students who are in Dept 1 OR Dept 3.
```sql
SELECT * FROM Student 
WHERE DeptID = 1 OR DeptID = 3;
```

**7. Sorting results (ORDER BY)** Show scores sorted from highest to lowest (Descending).
```sql
SELECT * FROM Score ORDER BY Score DESC;
```

**8. Sorting by text** Show students sorted alphabetically by Name.
```sql
SELECT * FROM Student ORDER BY Name ASC;
```

**9. Removing Duplicates (DISTINCT)** Show a list of all subjects that have been taken, but remove duplicates.
```sql
SELECT DISTINCT SubjectNumber FROM Score;
```

**10. Searching for patterns (LIKE)** Find students whose name starts with "K". (`%` matches anything after).
```sql
SELECT * FROM Student WHERE Name LIKE 'K%';
```

**11. Searching for endings** Find students whose name ends with "moto".
```sql
SELECT * FROM Student WHERE Name LIKE '%moto';
```

**12. Range Search (BETWEEN)** Find scores that are between 60 and 80.
```sql
SELECT * FROM Score WHERE Score BETWEEN 60 AND 80;
```

**13. List Search (IN)** Find students who are in Departments 1, 2, or 4.
```sql
SELECT * FROM Student WHERE DeptID IN (1, 2, 4);
```

**14. Inserting a new row** Add yourself to the database! (Change 9999 to a unique ID).
```sql
INSERT INTO Student (StudentNumber, Name, Gender, DeptID) 
VALUES (9999, 'My Name', 'Male', 1);
```

**15. Verifying your insert** Check if you are in the table.
```sql
SELECT * FROM Student WHERE StudentNumber = 9999;
```

**16. Updating a row** You moved to Department 2. Let's update your record.
```sql
UPDATE Student SET DeptID = 2 WHERE StudentNumber = 9999;
```

**17. Updating multiple rows** Give a bonus: Increase everyone's score in subject 'K21' by 2 points.
```sql
UPDATE Score SET Score = Score + 2 WHERE SubjectNumber = 'K21';
```

**18. Deleting a row** Remove yourself from the database.
```sql
DELETE FROM Student WHERE StudentNumber = 9999;
```

**19. Counting rows** How many scores are recorded in the database?
```sql
SELECT COUNT(*) FROM Score;
```

**20. Averages** What is the average score for Subject 'K21'?
```sql
SELECT AVG(Score) FROM Score WHERE SubjectNumber = 'K21';
```

**21. Max and Min** What was the highest and lowest score ever?
```sql
SELECT MAX(Score), MIN(Score) FROM Score;
```

**22. Grouping (GROUP BY)** Count how many students are in _each_ department.
```sql
SELECT DeptID, COUNT(*) FROM Student GROUP BY DeptID;
```

**23. Filtering Groups (HAVING)** Show only departments that have more than 2 students. _(Note: We use HAVING instead of WHERE when filtering groups)_
```sql
SELECT DeptID, COUNT(*) 
FROM Student 
GROUP BY DeptID 
HAVING COUNT(*) > 2;
```

**24. Inner Join (The Basic Connect)** The Student table only has `DeptID`. Let's join with `Departments` to see the actual Department Name.
```sql
SELECT Student.Name, Departments.DeptName 
FROM Student
INNER JOIN Departments ON Student.DeptID = Departments.DeptID;
```

**25. Left Join (Finding Missing Data)** Show ALL students, even those who don't have a department (DeptID is NULL). _(Notice 'Kana Hanazawa' appears here, but not in the Inner Join)_
```sql
SELECT Student.Name, Departments.DeptName 
FROM Student
LEFT JOIN Departments ON Student.DeptID = Departments.DeptID;
```

**26. Right Join** Show ALL Departments, even if they have no students. _(Notice 'Arts' appears here)_
```sql
SELECT Student.Name, Departments.DeptName 
FROM Student
RIGHT JOIN Departments ON Student.DeptID = Departments.DeptID;
```

**27. Three Table Join** Let's see: Student Name, Subject Name, and Score.
```sql
SELECT Student.Name, Subject.SubjectName, Score.Score
FROM Student
JOIN Score ON Student.StudentNumber = Score.StudentNumber
JOIN Subject ON Score.SubjectNumber = Subject.SubjectNumber;
```

**28. Subquery (Query inside a Query)** Find students who scored higher than the _average_ score of 'K21'.
```sql
SELECT * FROM Score 
WHERE SubjectNumber = 'K21' 
AND Score > (SELECT AVG(Score) FROM Score WHERE SubjectNumber = 'K21');
```

**29. EXISTS** List Departments that actually have students.
```sql
SELECT DeptName FROM Departments d
WHERE EXISTS (SELECT 1 FROM Student s WHERE s.DeptID = d.DeptID);
```

**30. UNION (Combining Lists)** Make one big list of all names (Students AND Teachers).
```sql
SELECT Name FROM Student
UNION
SELECT TeacherName FROM Teachers;
```

**31. CASE (If-Then Logic)** Show a "Pass" or "Fail" label next to each score.
```sql
SELECT StudentNumber, Score,
  CASE 
    WHEN Score >= 60 THEN 'Pass'
    ELSE 'Fail'
  END AS GradeStatus
FROM Score;
```

**32. Views (Saving a Query)** Create a shortcut called `Good_Students` for everyone with a score > 80.
```sql
CREATE VIEW Good_Students AS
SELECT * FROM Score WHERE Score > 80;
```

**33. Using the View** Now you can select from it like a real table.
```sql
SELECT * FROM Good_Students;
```

**34. Pagination (LIMIT)** When you have thousands of rows, you only want to see a few at a time.

- `LIMIT 2`: Show only the top 2 rows.
    
- `OFFSET 1`: Skip the first row.
    
```sql
SELECT * FROM Student 
ORDER BY StudentNumber 
LIMIT 2 OFFSET 1;
```

**35. String Magic (CONCAT)** Combine columns into a single sentence.
```sql
SELECT CONCAT(Name, ' is a ', Gender) AS Description 
FROM Student;
```

**36. Date Calculations** Find scores specifically from the year 2025.
```sql
SELECT * FROM Score 
WHERE YEAR(ExaminationDate) = 2025;
```

**37. Transactions (The "Undo" Button)** Transactions let you run multiple commands safely. If one fails (or you change your mind), you can rollback everything.

1. Start the transaction.
    
2. Delete everyone (Don't panic!).
    
3. Rollback (Undo) to bring them back.
    
```sql
START TRANSACTION;

DELETE FROM Score; -- Oh no! Deleted all scores!

SELECT * FROM Score; -- Verify they are gone (Empty)

ROLLBACK; -- Phew! Undo everything.

SELECT * FROM Score; -- They are back!
```

**38. Stored Procedures (Reusable Scripts)** Instead of typing the same query every day, save it as a "Procedure". _(Note: Copy this entire block at once)_
```sql
DELIMITER $$
CREATE PROCEDURE GetStudentGrades(IN s_id INT)
BEGIN
    SELECT * FROM Score WHERE StudentNumber = s_id;
END$$
DELIMITER ;
```

Now, run it anytime for any student:
```sql
CALL GetStudentGrades(6724);
```

**39. Cursors (Looping Row-by-Row)** SQL usually works on _sets_ of data at once. A **Cursor** allows you to loop through rows one by one, like a `for` loop in programming.

- **Goal:** Loop through every student and record a message in a log table.
    

**Step A: Create a log table to see the results**
```sql
CREATE TABLE Cursor_Log (LogMessage VARCHAR(255));
```

**Step B: Create the Procedure with the Cursor** _(Copy this entire block)_
```sql
DELIMITER $$

CREATE PROCEDURE ProcessAllStudents()
BEGIN
    -- 1. Declare variables to hold data
    DECLARE done INT DEFAULT FALSE;
    DECLARE s_name VARCHAR(100);
    
    -- 2. Define the Cursor (The list to loop through)
    DECLARE my_cursor CURSOR FOR SELECT Name FROM Student;
    
    -- 3. Handler to stop the loop when list is empty
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 4. Open the list
    OPEN my_cursor;

    -- 5. Start Looping
    read_loop: LOOP
        FETCH my_cursor INTO s_name;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- DO SOMETHING: Insert a message into our log table
        INSERT INTO Cursor_Log (LogMessage) 
        VALUES (CONCAT('Processed user: ', s_name));
        
    END LOOP;

    CLOSE my_cursor;
END$$

DELIMITER ;
```

**Step C: Run it and check the log**
```sql
CALL ProcessAllStudents();

-- See the proof that it looped!
SELECT * FROM Cursor_Log;
```

**40. Triggers (Automation)** A trigger automatically runs code _when_ a change happens.

- **Goal:** Automatically save a backup copy whenever a student is deleted.
    

**Step A: Create a backup table**
```sql
CREATE TABLE Deleted_Students_Archive (
    StudentNumber INT, 
    Name VARCHAR(100), 
    DeletedAt DATETIME
);
```

**Step B: Create the Trigger** _(Copy this entire block)_
```sql
CREATE TRIGGER before_student_delete
BEFORE DELETE ON Student
FOR EACH ROW
BEGIN
    INSERT INTO Deleted_Students_Archive (StudentNumber, Name, DeletedAt)
    VALUES (OLD.StudentNumber, OLD.Name, NOW());
END;
```

**Step C: Test it** Delete a student, then check the archive.
```sql
-- 1. Delete a student
DELETE FROM Student WHERE StudentNumber = 6724;

-- 2. Check the archive... The trigger saved them automatically!
SELECT * FROM Deleted_Students_Archive;
```