DROP TABLE IF EXISTS Company, College, Student, Placement, college_company;

CREATE TABLE Company(
    company_id INT NOT NULL, 
    company_name VARCHAR(100) UNIQUE, 
    avg_sal DECIMAL(32, 2) DEFAULT 0.00, 
    PRIMARY KEY(company_id) 
);

CREATE TABLE College(
    college_id INT NOT NULL,
    college_name VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    PRIMARY KEY (college_id)
);

CREATE TABLE Student(
    student_id INT NOT NULL UNIQUE,
    student_name VARCHAR(50),
    college_id INT,
    FOREIGN KEY(college_id) REFERENCES College(college_id),
    PRIMARY KEY (student_id)
);

CREATE TABLE Placement(
    student_id INT NOT NULL, 
    company_id INT NOT NULL,
    CTC DECIMAL(32, 2) NOT NULL, 
    FOREIGN KEY(company_id) REFERENCES Company(company_id),
    FOREIGN KEY(student_id) REFERENCES Student(student_id),
    PRIMARY KEY(student_id, company_id)
);

CREATE TABLE college_company (
    college_id INT NOT NULL,
    company_id INT NOT NULL,
    FOREIGN KEY (college_id) REFERENCES College(college_id),
    FOREIGN KEY (company_id) REFERENCES company(company_id),
    PRIMARY KEY(college_id, company_id)
);

DROP TRIGGER IF EXISTS avg_sal_insert;
DROP TRIGGER IF EXISTS avg_sal_delete;
DROP TRIGGER IF EXISTS college_company_add;
DROP TRIGGER IF EXISTS college_company_delete;

DELIMITER $$

CREATE TRIGGER avg_sal_insert 
AFTER INSERT 
ON placement 
FOR EACH ROW 
BEGIN 
    UPDATE company 
    SET company.avg_sal := (
        SELECT AVG(placement.CTC) 
        FROM placement 
        WHERE NEW.company_id = placement.company_id 
    ) 
    WHERE company.company_id = NEW.company_id;
END $$

CREATE TRIGGER avg_sal_delete 
AFTER DELETE  
ON placement 
FOR EACH ROW 
BEGIN 
    UPDATE company 
    SET company.avg_sal := (
        SELECT AVG(placement.CTC) 
        FROM placement 
        WHERE OLD.company_id = placement.company_id 
    ) 
    WHERE company.company_id = OLD.company_id;
END $$

DELIMITER $$

CREATE TRIGGER college_company_add 
AFTER INSERT 
ON placement 
FOR EACH ROW 
BEGIN 
    DECLARE college_id_student INT;

    SET college_id_student := (SELECT college_id 
                               FROM student 
                               WHERE student.student_id = NEW.student_id);
    IF ( SELECT NOT EXISTS (
            SELECT college_id 
            FROM college_company 
            WHERE college_company.company_id = NEW.company_id 
            AND college_id = college_id_student
            )
        ) THEN
        INSERT INTO 
            college_company
        VALUES 
            (college_id_student, NEW.company_id);
    END IF;

END $$

DELIMITER $$

CREATE TRIGGER college_company_delete 
AFTER DELETE  
ON placement 
FOR EACH ROW 
BEGIN 
    DECLARE college_id_student INT;

    SET college_id_student := (SELECT college_id 
                               FROM student 
                               WHERE student.student_id = OLD.student_id);
    IF ( SELECT EXISTS (
            SELECT college_id 
            FROM college_company 
            WHERE college_company.company_id = OLD.company_id 
            AND college_id = college_id_student
            )
        ) THEN
        DELETE 
        FROM 
            college_company
        WHERE 
            college_company.company_id = OLD.company_id 
            AND college_id = college_id_student;
    END IF;
END $$

DELIMITER ;


