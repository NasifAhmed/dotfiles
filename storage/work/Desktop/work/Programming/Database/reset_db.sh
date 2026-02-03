#!/bin/bash

echo "🔄 Resetting Database content..."

# Execute SQL directly inside the container
docker exec -i mysql-class mysql -u root -proot <<EOF
-- DISABLE FOREIGN KEY CHECKS TO PREVENT ERRORS DURING DROP
SET FOREIGN_KEY_CHECKS = 0;

-- 1. CLEAN SLATE
DROP DATABASE IF EXISTS class_db;
CREATE DATABASE class_db;
USE class_db;

-- 2. CREATE TABLES
CREATE TABLE Departments (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50),
    Location VARCHAR(50)
    );

    CREATE TABLE Teachers (
        TeacherID INT PRIMARY KEY,
        TeacherName VARCHAR(50),
        Email VARCHAR(100)
        );

        CREATE TABLE Student (
            StudentNumber INT PRIMARY KEY,
            Name VARCHAR(100),
            Gender VARCHAR(10),
            DeptID INT, 
            FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
            );

            CREATE TABLE Subject (
                SubjectNumber VARCHAR(10) PRIMARY KEY,
                SubjectName VARCHAR(50),
                TeacherID INT,
                Credits INT DEFAULT 3, 
                FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID)
                );

                CREATE TABLE Score (
                    StudentNumber INT,
                    SubjectNumber VARCHAR(10),
                    Score INT,
                    ExaminationDate DATE,
                    PRIMARY KEY (StudentNumber, SubjectNumber),
                    FOREIGN KEY (StudentNumber) REFERENCES Student(StudentNumber) ON DELETE CASCADE,
                    FOREIGN KEY (SubjectNumber) REFERENCES Subject(SubjectNumber)
                    );

                    -- 3. POPULATE DATA
                    INSERT INTO Departments VALUES (1, 'Science', 'Building A'), (2, 'Humanities', 'Building B'), (3, 'Engineering', 'Building C'), (4, 'Arts', 'Building D');
                    INSERT INTO Teachers VALUES (101, 'Mr. Sato', 'sato@school.edu'), (102, 'Ms. Suzuki', 'suzuki@school.edu'), (103, 'Dr. Tanaka', 'tanaka@school.edu');

                    INSERT INTO Student VALUES 
                    (6724, 'Kazuki Yamamoto', 'Male', 1), (6725, 'Jyugo Motoyama', 'Male', 1), 
                    (6816, 'Mone Yamada', 'Female', 2), (6817, 'Chiyo Yamamoto', 'Female', 2),
                    (7001, 'Kenjiro Tsuda', 'Male', 3), (7002, 'Maaya Sakamoto', 'Female', 3), 
                    (7003, 'Hiroshi Kamiya', 'Male', 3), (7004, 'Rie Kugimiya', 'Female', 1), 
                    (7005, 'Mamoru Miyano', 'Male', 2), (7006, 'Kana Hanazawa', 'Female', NULL);

                    INSERT INTO Subject VALUES 
                    ('K11', 'English I', 101, 2), ('K12', 'English II', 101, 2), ('K21', 'Mathematics', 103, 4),
                    ('S01', 'Physics', 103, 4), ('S02', 'Chemistry', 103, 4), ('H01', 'History', 102, 3), ('X99', 'Quantum Mechanics', NULL, 5);

                    INSERT INTO Score VALUES 
                    (6724, 'K11', 65, '2025-10-20'), (6724, 'K21', 85, '2025-10-21'), (6725, 'K21', 60, '2025-10-21'),
                    (6817, 'K11', 85, '2025-10-20'), (6817, 'K12', 90, '2025-10-20'), (6817, 'K21', 95, '2025-10-21'),
                    (7001, 'S01', 92, '2025-10-22'), (7001, 'S02', 88, '2025-10-23'), (7002, 'S01', 75, '2025-10-22'),
                    (7003, 'S01', 40, '2025-10-22'), (7003, 'K21', 55, '2025-10-21'), (7005, 'H01', 89, '2025-10-24'),
                    (7006, 'K11', 70, '2025-10-20');

                    -- 4. CREATE USERS & PERMISSIONS
                    CREATE USER IF NOT EXISTS 'student1'@'%' IDENTIFIED BY 'student1';
                    GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP, CREATE VIEW, SHOW VIEW ON class_db.* TO 'student1'@'%';
                    -- Repeat for other students if needed or stick to student1 for simplicity
                    FLUSH PRIVILEGES;

                    SET FOREIGN_KEY_CHECKS = 1;
EOF

echo "✅ Database has been reset to fresh state!"
