-- Number of students placed in each college
DROP PROCEDURE IF EXISTS verify_college_name;
DROP PROCEDURE IF EXISTS list_more_sal_than;
DROP PROCEDURE IF EXISTS list_less_sal_than;
DROP PROCEDURE IF EXISTS list_more_sal_than_in_college;
DROP PROCEDURE IF EXISTS list_less_sal_than_in_college;
DROP PROCEDURE IF EXISTS company_in_college;
DROP PROCEDURE IF EXISTS num_placed_in_college;
DROP PROCEDURE IF EXISTS max_ctc_in_college;
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

CREATE PROCEDURE num_placed_in_college (
    IN input_college_name VARCHAR(100)
)
BEGIN
    CALL verify_college_name(input_college_name);

    SELECT 
        *
    FROM 
        `Number of students placed in each college`
    WHERE 
        `College` = input_college_name;
END $$

DELIMITER $$

-- students in a college who are placed in the highes paying company
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

-- MAX CTC in given college
CREATE PROCEDURE max_ctc_in_college(
    IN input_college_name VARCHAR(100),
    IN input_limit INT
) BEGIN
    CALL verify_college_name(input_college_name);

    SELECT
        `Name`,
        `CTC`,
        `Company`,
        `College`
    FROM 
        `List placement`
    WHERE 
        `College` = input_college_name
    ORDER BY CTC DESC LIMIT input_limit;
END$$


-- information of students with salary greater than input amount
DELIMITER $$

CREATE PROCEDURE list_more_sal_than (
    IN input_amount DECIMAL(32, 2)
) BEGIN 
    SELECT 
        *
    FROM
        `List placement` 
    WHERE `list placement`.`CTC` > input_amount;
END $$

-- information of students with salary smaller than input amount
DELIMITER $$

CREATE PROCEDURE list_less_sal_than (
    IN input_amount DECIMAL(32, 2)
)
BEGIN 
    SELECT
        *
    FROM
        `List placement`
    WHERE `List placement`.`CTC` < input_amount;
END $$

DELIMITER $$

CREATE PROCEDURE list_more_sal_than_in_college (
    IN input_college_name VARCHAR(100),
    IN input_amount DECIMAL(32, 2)
)
BEGIN 
    CALL verify_college_name(input_college_name);
    
    SELECT
        *
    FROM
        `List placement` 
    WHERE 
        `list placement`.`CTC` > input_amount
        AND `College` = input_college_name;
END $$

-- information of students with salary smaller than input amount
DELIMITER $$

CREATE PROCEDURE list_less_sal_than_in_college (
    IN input_college_name VARCHAR(100),
    IN input_amount DECIMAL(32, 2)
)
BEGIN 
    CALL verify_college_name(input_college_name);

    SELECT
        *
    FROM
        `List placement`
    WHERE 
        `list placement`.`CTC` < input_amount 
        AND `College` = input_college_name;
END $$
-- list of companies in a particular college
DELIMITER $$

CREATE PROCEDURE company_in_college(
    IN input_college_name VARCHAR(100)
) BEGIN
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
