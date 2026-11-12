--------

CREATE VIEW BasicInformation AS
SELECT Students.idnr, Students.name, Students.login, Students.program, StudentBranches.branch FROM Students
    LEFT OUTER JOIN StudentBranches
    ON Students.idnr = StudentBranches.student;

--------

CREATE VIEW FinishedCourses AS
SELECT Taken.student, Taken.course, Courses.name AS courseName, Taken.grade, Courses.credits FROM Taken
    JOIN Courses ON Taken.course = Courses.code; 

-------

CREATE VIEW Registrations AS
SELECT Registered.student, Registered.course, 'registered' AS status FROM Registered
UNION 
SELECT WaitingList.student, WaitingList.course, 'waiting' AS status FROM WaitingList;

-------

CREATE VIEW PassedCourses AS
SELECT student, course, credits FROM FinishedCourses WHERE grade != 'U';

-------

CREATE VIEW UnreadMandatory AS (
SELECT Students.idnr AS student, MandatoryProgram.course
FROM Students
    JOIN MandatoryProgram ON Students.program = MandatoryProgram.program
UNION
SELECT StudentBranches.student AS student, MandatoryBranch.course
FROM StudentBranches
    JOIN MandatoryBranch ON StudentBranches.branch = MandatoryBranch.branch
                        AND StudentBranches.program = MandatoryBranch.program
)
EXCEPT
SELECT student, course FROM PassedCourses;

-------

CREATE VIEW RecommendedCourses AS
SELECT PassedCourses.student, PassedCourses.course, PassedCourses.credits
FROM PassedCourses
JOIN StudentBranches ON PassedCourses.student = StudentBranches.student
JOIN RecommendedBranch ON StudentBranches.branch  = RecommendedBranch.branch
                      AND StudentBranches.program = RecommendedBranch.program
                      AND PassedCourses.course    = RecommendedBranch.course;

-------

--- wrong ?!
CREATE VIEW PathToGraduation AS
SELECT Students.idnr AS student, COALESCE(tc.total, 0) AS totalCredits
FROM Students
    LEFT JOIN (SELECT student, SUM(credits) AS total FROM PassedCourses GROUP BY student) tc
            ON Students.idnr = tc.student;


-------

CREATE VIEW warnRecMand AS
SELECT RecommendedBranch.branch, RecommendedBranch.program, RecommendedBranch.course
FROM recommendedBranch
JOIN MandatoryProgram ON RecommendedBranch.program = MandatoryProgram.program AND RecommendedBranch.course = MandatoryProgram.course;

-------

CREATE VIEW warnOverfull AS
SELECT limitedCourses.code AS course, COUNT(Registered.student) AS registered, LimitedCourses.capacity
FROM LimitedCourses
JOIN Registered ON LimitedCourses.code = Registered.course
GROUP BY LimitedCourses.code, LimitedCourses.capacity
HAVING COUNT(Registered.student) > LimitedCourses.capacity;

-------