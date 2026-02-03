-- ==========================================
-- 1. CLEAN SLATE (The Reset Mechanism)
-- ==========================================
DROP DATABASE IF EXISTS class_db;
CREATE DATABASE class_db;
USE class_db;

-- ==========================================
-- 2. CREATE TABLES
-- ==========================================

-- Table 1: Departments (New! For Joining & Grouping practice)
CREATE TABLE Departments (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50),
    Location VARCHAR(50)
);

-- Table 2: Teachers (New! For Cross Joins & Subqueries)
CREATE TABLE Teachers (
    TeacherID INT PRIMARY KEY,
    TeacherName VARCHAR(50),
    Email VARCHAR(100)
);

-- Table 3: Student (From Image + DeptID for Joins)
CREATE TABLE Student (
    StudentNumber INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender VARCHAR(10),
    DeptID INT, -- Foreign Key link (nullable for Left Join practice)
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

-- Table 4: Subject (From Image + TeacherID for Joins)
CREATE TABLE Subject (
    SubjectNumber VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(50),
    TeacherID INT,
    Credits INT DEFAULT 3, -- Added for Aggregation practice
    FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID)
);

-- Table 5: Score (From Image)
CREATE TABLE Score (
    StudentNumber INT,
    SubjectNumber VARCHAR(10),
    Score INT,
    ExaminationDate DATE,
    PRIMARY KEY (StudentNumber, SubjectNumber),
    FOREIGN KEY (StudentNumber) REFERENCES Student(StudentNumber) ON DELETE CASCADE,
    FOREIGN KEY (SubjectNumber) REFERENCES Subject(SubjectNumber)
);

-- ==========================================
-- 3. POPULATE DATA
-- ==========================================

-- A. Departments
INSERT INTO Departments VALUES 
(1, 'Science', 'Building A'),
(2, 'Humanities', 'Building B'),
(3, 'Engineering', 'Building C'),
(4, 'Arts', 'Building D'); -- Dept with no students (For RIGHT JOIN)

-- B. Teachers
INSERT INTO Teachers VALUES
(101, 'Mr. Sato', 'sato@school.edu'),
(102, 'Ms. Suzuki', 'suzuki@school.edu'),
(103, 'Dr. Tanaka', 'tanaka@school.edu');

-- C. Students 
-- (Originals from Image)
INSERT INTO Student (StudentNumber, Name, Gender, DeptID) VALUES 
(6724, 'Kazuki Yamamoto', 'Male', 1),
(6725, 'Jyugo Motoyama', 'Male', 1),
(6816, 'Mone Yamada', 'Female', 2),
(6817, 'Chiyo Yamamoto', 'Female', 2);

-- (New Students for Bulk Data/Filtering)
INSERT INTO Student (StudentNumber, Name, Gender, DeptID) VALUES 
(7001, 'Kenjiro Tsuda', 'Male', 3),
(7002, 'Maaya Sakamoto', 'Female', 3),
(7003, 'Hiroshi Kamiya', 'Male', 3),
(7004, 'Rie Kugimiya', 'Female', 1),
(7005, 'Mamoru Miyano', 'Male', 2),
(7006, 'Kana Hanazawa', 'Female', NULL); -- NULL DeptID (For LEFT JOIN/IS NULL practice)

-- D. Subjects
-- (Originals + Teachers)
INSERT INTO Subject (SubjectNumber, SubjectName, TeacherID, Credits) VALUES 
('K11', 'English I', 101, 2),
('K12', 'English II', 101, 2),
('K21', 'Mathematics', 103, 4);

-- (New Subjects)
INSERT INTO Subject (SubjectNumber, SubjectName, TeacherID, Credits) VALUES 
('S01', 'Physics', 103, 4),
('S02', 'Chemistry', 103, 4),
('H01', 'History', 102, 3),
('X99', 'Quantum Mechanics', NULL, 5); -- Subject with no Teacher (For IS NULL)

-- E. Scores
-- (Originals from Image)
INSERT INTO Score VALUES 
(6724, 'K11', 65, '2025-10-20'),
(6724, 'K21', 85, '2025-10-21'),
(6725, 'K21', 60, '2025-10-21'),
(6817, 'K11', 85, '2025-10-20'),
(6817, 'K12', 90, '2025-10-20'),
(6817, 'K21', 95, '2025-10-21');

-- (New Scores for Aggregation/Grouping)
INSERT INTO Score VALUES 
(7001, 'S01', 92, '2025-10-22'),
(7001, 'S02', 88, '2025-10-23'),
(7002, 'S01', 75, '2025-10-22'),
(7003, 'S01', 40, '2025-10-22'), -- Low score (For filtering < 50)
(7003, 'K21', 55, '2025-10-21'),
(7005, 'H01', 89, '2025-10-24'),
(7006, 'K11', 70, '2025-10-20');

-- ==========================================
-- 4. PERMISSIONS & VIEWS (For Practice)
-- ==========================================

-- Create a dummy view so they can practice "DROP VIEW" or "SELECT FROM VIEW"
CREATE OR REPLACE VIEW HighAchievers AS
SELECT s.Name, sc.Score, sub.SubjectName
FROM Student s
JOIN Score sc ON s.StudentNumber = sc.StudentNumber
JOIN Subject sub ON sc.SubjectNumber = sub.SubjectNumber
WHERE sc.Score >= 90;

-- Create Users (If not already created in previous steps, this ensures they exist)
CREATE USER IF NOT EXISTS 'student1'@'%' IDENTIFIED BY 'student1';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP, CREATE VIEW, SHOW VIEW, TRIGGER, ROUTINE 
ON class_db.* TO 'student1'@'%';
FLUSH PRIVILEGES;
