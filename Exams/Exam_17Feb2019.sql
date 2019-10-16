--CREATE DATABASE School
--1
USE School

CREATE TABLE Students
(Id         INT
 PRIMARY KEY IDENTITY(1, 1), 
 FirstName  NVARCHAR(30) NOT NULL, 
 MiddleName NVARCHAR(25), 
 LastName   NVARCHAR(30) NOT NULL, 
 Age        INT NOT NULL
                CHECK(Age >= 5
                      AND Age <= 100), 
 [Address]  NVARCHAR(30), 
 Phone      CHAR(10)
);

CREATE TABLE Subjects
(Id      INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Name]  NVARCHAR(20) NOT NULL, 
 Lessons INT NOT NULL
             CHECK(Lessons > 0)
);

CREATE TABLE StudentsSubjects
(Id        INT
 PRIMARY KEY IDENTITY(1, 1), 
 StudentId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Students(Id), 
 SubjectId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Subjects(Id), 
 Grade     DECIMAL(3, 2) NOT NULL
                         CHECK(Grade >= 2.00
                               AND Grade <= 6.00)
);

CREATE TABLE Exams
(Id        INT
 PRIMARY KEY IDENTITY(1, 1), 
 [Date]    DATETIME2, 
 SubjectId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Subjects(Id)
);

CREATE TABLE StudentsExams
(StudentId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Students(Id), 
 ExamId    INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Exams(Id), 
 PRIMARY KEY(StudentId, ExamId), 
 Grade     DECIMAL(3, 2) NOT NULL
                         CHECK(Grade >= 2.00
                               AND Grade <= 6.00)
);

CREATE TABLE Teachers
(Id        INT
 PRIMARY KEY IDENTITY(1, 1), 
 FirstName NVARCHAR(20) NOT NULL, 
 LastName  NVARCHAR(20) NOT NULL, 
 [Address] NVARCHAR(20), 
 Phone     CHAR(10), 
 SubjectId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Subjects(Id)
);

CREATE TABLE StudentsTeachers
(StudentId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Students(Id), 
 TeacherId INT NOT NULL
               FOREIGN KEY REFERENCES dbo.Teachers(Id), 
 PRIMARY KEY(StudentId, TeacherId),
);

GO

--2
USE School
GO

INSERT INTO dbo.Teachers
			(FirstName, LastName, [Address], Phone, SubjectId)
VALUES
			(N'Ruthanne', N'Bamb', N'84948 Mesta Junction', '3105500146', 6),
			(N'Gerrard', N'Lowin', N'370 Talisman Plaza', '3324874824', 2),
			(N'Merrile', N'Lambdin', N'81 Dahle Plaza', '4373065154', 5),
			(N'Bert', N'Ivie', N'2 Gateway Circle', '4409584510', 4)

INSERT INTO dbo.Subjects
			([Name], Lessons)
VALUES
			(N'Geometry', 12),
			(N'Health', 10),
			(N'Drama', 7),
			(N'Sports', 9)
GO

--3
USE School
GO

UPDATE dbo.StudentsSubjects
  SET 
      dbo.StudentsSubjects.Grade = 6
WHERE dbo.StudentsSubjects.SubjectId IN(1, 2)
AND dbo.StudentsSubjects.Grade >= 5.50;

UPDATE dbo.StudentsExams
  SET 
      dbo.StudentsExams.Grade = 6
WHERE dbo.StudentsExams.ExamId IN
(
    SELECT e.Id
    FROM dbo.Exams e
    WHERE e.SubjectId IN(1, 2)
)
AND dbo.StudentsExams.Grade >= 5.50;

GO

--4
USE School
GO


DELETE FROM dbo.StudentsTeachers
WHERE dbo.StudentsTeachers.TeacherId IN (
    SELECT t.Id
    FROM dbo.Teachers t
    WHERE t.Phone LIKE '%72%'
)

DELETE FROM dbo.Teachers
WHERE dbo.Teachers.Phone LIKE '%72%';

GO

--5
USE School
GO

SELECT s.FirstName, 
       s.LastName, 
       s.Age
FROM dbo.Students s
WHERE s.Age >= 12
ORDER BY s.FirstName, 
         s.LastName;

GO

--6
USE School
GO

SELECT CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName) [Full Name], 
       s.[Address]
FROM dbo.Students s
WHERE s.[Address] LIKE '%road%'
ORDER BY s.FirstName, 
         s.LastName, 
         s.[Address];

GO

--7
USE School
GO

SELECT s.FirstName, 
       s.Address, 
       s.Phone
FROM dbo.Students s
WHERE s.MiddleName IS NOT NULL
      AND s.Phone LIKE '42%'
ORDER BY s.FirstName;

GO


--8
USE School
GO

SELECT s.FirstName, 
       s.LastName, 
       COUNT(st.TeacherId) TeachersCount
FROM dbo.Students s
     LEFT JOIN dbo.StudentsTeachers st ON s.Id = st.StudentId
GROUP BY s.FirstName, 
         s.LastName;

GO

--9
USE School
GO

SELECT CONCAT(t.FirstName, ' ', t.LastName) Fullname, 
       CONCAT(s.Name, '-', s.Lessons) Subjects, 
       COUNT(st.StudentId) Students
FROM dbo.Teachers t
     JOIN dbo.Subjects s ON t.SubjectId = s.Id
     JOIN dbo.StudentsTeachers st ON t.Id = st.TeacherId
GROUP BY t.FirstName, 
         t.LastName, 
         s.Name, 
         s.Lessons
ORDER BY Students DESC, 
         Fullname, 
         Subjects;

GO

--10
USE School
GO

SELECT CONCAT(s.FirstName, ' ', s.LastName) [Full Name]
FROM dbo.Students s
     LEFT JOIN dbo.StudentsExams se ON s.Id = se.StudentId
WHERE se.ExamId IS NULL
GROUP BY s.FirstName, 
         s.LastName
ORDER BY [Full Name];

GO

--11
USE School
GO

SELECT TOP (10) t.FirstName, 
                t.LastName, 
                COUNT(st.StudentId) StudentsCount
FROM dbo.Teachers t
     JOIN dbo.StudentsTeachers st ON t.Id = st.TeacherId
GROUP BY t.FirstName, 
         t.LastName
ORDER BY StudentsCount DESC, 
         t.FirstName, 
         t.LastName;

GO

--12
USE School
GO

SELECT TOP (10) s.FirstName [First Name], 
                s.LastName [Last Name], 
                CAST(AVG(se.Grade) AS DECIMAL(3, 2)) Grade
FROM dbo.Students s
     JOIN dbo.StudentsExams se ON s.Id = se.StudentId
GROUP BY s.FirstName, 
         s.LastName
ORDER BY Grade DESC, 
         s.FirstName, 
         s.LastName;
		 
GO

--13 Second Hihest in this case means second in order, not second in value
USE School
GO

WITH CTE_OrderedGrades AS (SELECT s.FirstName [FirstName], 
       s.LastName [LastName], 
       ss.Grade [Grade], 
       ROW_NUMBER() OVER(PARTITION BY s.FirstName, 
                                      s.LastName
       ORDER BY ss.Grade DESC) GradeRank
FROM dbo.Students s
     JOIN dbo.StudentsSubjects ss ON s.Id = ss.StudentId)

SELECT [FirstName], 
       [LastName], 
       [Grade]
FROM CTE_OrderedGrades cog
WHERE cog.GradeRank = 2
ORDER BY [FirstName], 
         [LastName];

GO

--14
USE School
GO

SELECT CASE
           WHEN s.MiddleName IS NULL
           THEN CONCAT(s.FirstName, ' ', s.LastName)
           ELSE CONCAT(s.FirstName, ' ', s.MiddleName, ' ', s.LastName)
       END AS [Full Name]
FROM dbo.Students s
     LEFT JOIN dbo.StudentsSubjects ss ON s.Id = ss.StudentId
WHERE ss.SubjectId IS NULL
ORDER BY [Full Name];

GO

--15 Have to make sure that Subject table is correctly connected with Students and Teachers By ID
USE School
GO

WITH CTE_AVGGRades AS (SELECT CONCAT(t.FirstName, ' ', t.LastName) [Teacher Full Name], 
       su.Name [Subject Name], 
       CONCAT(s.FirstName, ' ', s.LastName) [Student Full Name], 
       AVG(ss.Grade) Grade       
FROM dbo.Teachers t
     JOIN StudentsTeachers AS st ON st.TeacherId = t.Id
     JOIN Students AS s ON s.Id = st.StudentId
     JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
     JOIN Subjects AS su ON su.Id = ss.SubjectId AND su.Id = t.SubjectId
GROUP BY t.FirstName, 
         t.LastName,
		 su.Name,
		 s.FirstName, 
         s.LastName)

SELECT orderedAVG.[Teacher Full Name], 
       orderedAVG.[Subject Name], 
       orderedAVG.[Student Full Name], 
       orderedAVG.Grade
FROM
(
    SELECT [Teacher Full Name], 
           [Subject Name], 
           [Student Full Name], 
           FORMAT(Grade, 'N2') Grade, 
           DENSE_RANK() OVER(PARTITION BY [Teacher Full Name]
           ORDER BY CTE_AVGGRades.Grade DESC) AvgGradeRank
    FROM CTE_AVGGRades
) AS orderedAVG
WHERE orderedAVG.AvgGradeRank = 1
ORDER BY [Subject Name], 
         [Teacher Full Name], 
         Grade DESC;

GO

--16
USE School
GO

SELECT s.Name, 
       AVG(ss.Grade) AverageGrade
FROM dbo.Subjects s
     JOIN dbo.StudentsSubjects ss ON s.Id = ss.SubjectId
GROUP BY s.Id, 
         s.Name
ORDER BY s.Id;

GO

--17
USE School
GO

WITH CTE_GroupedStudents AS (SELECT IIF(e.[Date] IS NULL, 'TBA', 'Q' + DATENAME(quarter, e.[Date])) [Quarter], 
       s.Name SubjectName, 
       COUNT(se.StudentId) StudentsCount
FROM dbo.Exams e
     JOIN dbo.Subjects s ON e.SubjectId = s.Id
     JOIN dbo.StudentsExams se ON e.Id = se.ExamId
WHERE se.Grade >= 4.00
GROUP BY e.[Date], 
         s.Name)

SELECT [Quarter], 
       SubjectName, 
       SUM(StudentsCount)
FROM CTE_GroupedStudents
GROUP BY [Quarter], 
         SubjectName
ORDER BY [Quarter], 
         SubjectName;

GO

--18
USE School
GO

CREATE FUNCTION udf_ExamGradesToUpdate
(@StudentId INT, 
 @Grade     DECIMAL(3, 2)
)
RETURNS VARCHAR(100)
AS
     BEGIN
         DECLARE @studentFirstName VARCHAR(30)=
         (
             SELECT s.FirstName
             FROM dbo.Students s
             WHERE s.Id = @StudentId
         );
         IF(@studentFirstName IS NULL)
             BEGIN
                 RETURN 'The student with provided id does not exist in the school!';
         END;
         IF(@Grade > 6.00)
             BEGIN
                 RETURN 'Grade cannot be above 6.00!';
         END;
         DECLARE @upperGrade DECIMAL(3, 2)= IIF(@Grade >= 5.50
                                                AND @Grade <= 6.00, 6.00, @Grade + 0.50);
         DECLARE @countGrades INT=
         (
             SELECT COUNT(ss.Grade)
             FROM dbo.StudentsSubjects ss
             WHERE ss.Grade > @Grade
                   AND ss.Grade <= @upperGrade
                   AND ss.StudentId = @StudentId
         );
         RETURN 'You have to update ' + CAST(@countGrades AS VARCHAR(5)) + ' grades for the student ' + @studentFirstName;
     END;

GO

SELECT * FROM dbo.StudentsSubjects ss WHERE ss.StudentId = 12 AND ss.Grade >= 5.50

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)

GO


--19
USE School
GO

CREATE PROC usp_ExcludeFromSchool(@StudentId INT)
AS
     DECLARE @studentSchoolID VARCHAR(30)=
     (
         SELECT s.Id
         FROM dbo.Students s
         WHERE s.Id = @StudentId
     );
     IF(@studentSchoolID IS NULL)
         BEGIN
             RAISERROR('This school has no student with the provided id!', 16, 1);
             RETURN;
     END;
     DELETE FROM dbo.StudentsExams
     WHERE dbo.StudentsExams.StudentId = @studentSchoolID;
     DELETE FROM dbo.StudentsTeachers
     WHERE dbo.StudentsTeachers.StudentId = @studentSchoolID;
     DELETE FROM dbo.StudentsSubjects
     WHERE dbo.StudentsSubjects.StudentId = @studentSchoolID;
     DELETE FROM dbo.Students
     WHERE dbo.Students.Id = @studentSchoolID;
	
GO

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students

EXEC usp_ExcludeFromSchool 301

GO


--20
USE School
GO

CREATE TABLE ExcludedStudents(
StudentId int, 
StudentName NVARCHAR(60)
)
GO

CREATE TRIGGER tr_ExcludeStudents ON Students
FOR DELETE
AS
INSERT INTO ExcludedStudents(StudentId, StudentName)
		SELECT Id, FirstName + ' ' + LastName FROM deleted

GO