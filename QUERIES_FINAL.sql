-- Number of students placed in each college
DROP PROCEDURE IF EXISTS verify_college_name;
DROP PROCEDURE IF EXISTS company_in_college;
DROP PROCEDURE IF EXISTS max_ctc_company_placement_in_college;

DELIMITER $$

CREATE PROCEDURE verify_college_name(
    IN input_college_name VARCHAR(100)
) BEGIN 
    IF (
        SELECT NOT EXISTS (
            SELECT * 
            FROM college 
            WHERE college_name = input_college_name
        )
    ) THEN 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'College does not exist in our Database';
    END IF;
END $$

DELIMITER $$

-- students in a college who are placed in the highest paying company
CREATE PROCEDURE max_ctc_company_placement_in_college(
    IN input_college_name VARCHAR(100)
) BEGIN 
    CALL verify_college_name(input_college_name);

    SELECT 
        student.student_name AS `Name`,
        college.college_name AS `College`,
        company.company_name AS `Company`
    FROM 
        student JOIN
        college USING(college_id) JOIN 
        placement USING(student_id) JOIN 
        company USING (company_id) JOIN (
            SELECT company_id
            FROM company JOIN college_company 
            USING (company_id) 
            WHERE college_id IN (
                SELECT college_id 
                FROM college 
                WHERE college_name = input_college_name
            )
            ORDER BY avg_sal DESC 
            LIMIT 1
        ) max_paying_company 
        ON placement.company_id = max_paying_company.company_id
    WHERE college_name = input_college_name;
END $$

DELIMITER $$

CREATE PROCEDURE company_in_college(
    IN input_college_name VARCHAR(100)
) BEGIN
    CALL verify_college_name(input_college_name);

    SELECT  
        company.company_id AS `Company ID`,
        company.company_name AS `Company Name`
    FROM
        company
    WHERE company.company_id IN (
        SELECT company_id 
        FROM college_company
        WHERE college_id = (
            SELECT college_id
            FROM college
            WHERE college_name = input_college_name
        )
    ); 
END $$

DELIMITER ;
