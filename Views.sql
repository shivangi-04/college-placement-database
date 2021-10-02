CREATE OR REPLACE VIEW `Number of students placed in each college` AS 
SELECT 
    college.college_name AS `College`, 
    COUNT(*) AS `Number of students placed`
FROM student JOIN college 
    USING (college_id) 
WHERE student.student_id IN (
    SELECT placement.student_id 
    FROM placement 
) GROUP BY college.college_name;

CREATE OR REPLACE VIEW `Students not placed` AS
SELECT 
    student.student_id AS `Enrollment Number`,
    student.student_name AS `Name`,
    college.college_name AS `College`
FROM
    student JOIN
    college USING(college_id)
WHERE student_id NOT IN(
    SELECT student_id 
    FROM placement
);

CREATE OR REPLACE VIEW `List placement` AS 
SELECT
    student.student_id AS `Enrollment Number`,
    student.student_name AS `Name`,
    placement.CTC AS `CTC`,
    company_name AS `Company`,
    college.college_name AS `College`
FROM
    student JOIN
    placement USING (student_id) JOIN
    college USING (college_id) JOIN 
    company USING (company_id);

CREATE OR REPLACE VIEW `Average salary per college` AS 
SELECT 
    college_name AS `College`,
    FORMAT(AVG(CTC), 2) AS `Average CTC` 
FROM
    student 
    JOIN placement USING (student_id) 
    JOIN company USING (company_id) 
    JOIN college USING (college_id)
GROUP BY college_name;

CREATE OR REPLACE VIEW `Total number of students in each college` AS 
SELECT 
    college_name AS `College`, 
    COUNT(student_id) AS `Total Students`
FROM 
    student JOIN college USING(college_id)
GROUP BY college_name;

CREATE OR REPLACE VIEW `Percentage placed in each college` AS 
SELECT 
    `College`,
    FORMAT(`Number of students placed` * 100 / `Total Students`, 2) AS `Percent Placed` 
FROM 
    `Number of students placed in each college` 
    JOIN `College Population` USING(`College`); 

CREATE OR REPLACE VIEW `Number of students placed in each city` AS 
SELECT 
    college.city AS `City`, 
    COUNT(*) AS `Number of students placed`
FROM student JOIN college 
    USING (college_id) 
WHERE student.student_id IN (
    SELECT placement.student_id 
    FROM placement 
) GROUP BY college.city;
