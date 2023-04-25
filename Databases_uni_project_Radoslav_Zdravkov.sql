CREATE DATABASE sport_academy_db;
USE sport_academy_db;

#ZAD1
CREATE TABLE scholarships(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    type ENUM('none','ordinary','extra')
);

CREATE TABLE students(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    egn VARCHAR(10) NOT NULL,
    age INT,
    grade DOUBLE NOT NULL CHECK(grade>=2 AND grade<=6),
    address VARCHAR(50) NOT NULL,
    phone VARCHAR(10) NOT NULL,
    scholarship_id INT NOT NULL,
    FOREIGN KEY(scholarship_id) REFERENCES scholarships(id)
);

CREATE TABLE sports(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30) 
);

CREATE TABLE student_sport(
	student_id INT NOT NULL,
    sport_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (sport_id) REFERENCES sports(id),
    PRIMARY KEY(student_id, sport_id)
);
    
CREATE TABLE coaches(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    egn VARCHAR(10) NOT NULL,
    hourly_pay INT NOT NULL,
    salary INT,
    sport_id INT NOT NULL UNIQUE,
    FOREIGN KEY (sport_id) REFERENCES sports(id)
);

#INSERT QUERIES
INSERT INTO scholarships(type)
VALUES ('none'),
		('ordinary'),
        ('extra');

INSERT INTO students(name, age, egn, address, phone, grade, scholarship_id)
VALUES ("Galina Ivanova",21,"0121121316","Burgas","0887636412",6,3),
		("Ivan Topuzov",19,"0321121228","Petrich","0887631218",4,2),
        ("Ivan Georgiev", 20, "0232128712","Sofia","0878431234",5,2),
        ("Petar Petrov", 22, "0046128712","Sofia","0878437939",3,1);

INSERT INTO sports(name)
VALUES ("Swimming"),
		("Basketball"),
        ("Football"),
        ("Skiing"),
        (NULL);
        
INSERT INTO student_sport(student_id, sport_id)
VALUES (1,1),
		(1,2),
		(2,3),
        (3,2),
        (4,4);

INSERT INTO coaches(name, egn, hourly_pay, salary, sport_id)
VALUES ("Grigor Tashev","7802401211", 10, 1280, 1),
		("Petq Likova","9621141231", 10, 1600, 2),
        ("Valerii Kuzmanov","7201321081", 10, 1600, 3),
        ("Galin Petkov","8302121888", 12, 1920, 4),
        ("Alexander Papazov","123456789", 6, 960, 5);

#ZAD2
SELECT * FROM students
WHERE students.name LIKE 'Ivan%' AND students.age = 20;

#ZAD3
SELECT students.name, COUNT(sports.id) AS sportsCount
FROM students 
JOIN student_sport ON students.id = student_sport.student_id
JOIN sports ON student_sport.sport_id = sports.id
GROUP BY students.name;

#ZAD4
SELECT students.name, sports.name
FROM students 
INNER JOIN student_sport ON students.id = student_sport.student_id
INNER JOIN sports ON student_sport.sport_id = sports.id;

#ZAD5
SELECT coaches.name, sports.name
FROM coaches
LEFT OUTER JOIN sports
ON coaches.sport_id = sports.id;

#ZAD6
SELECT students.name, sports.name
FROM students
JOIN sports ON students.id IN(
	SELECT student_sport.student_id
    FROM student_sport
    WHERE student_sport.sport_id = sports.id
    );

#ZAD7
SELECT sports.name, COUNT(students.id) AS studentsCount
FROM sports
JOIN student_sport ON sports.id = student_sport.sport_id
JOIN students ON student_sport.student_id = students.id
GROUP BY sports.name;
    
#ZAD8 
CREATE TRIGGER before_hourly_pay_update
BEFORE UPDATE ON coaches
FOR EACH ROW
SET NEW.salary = NEW.hourly_pay*160;

UPDATE coaches
SET hourly_pay = 10
WHERE coaches.id=1;
SELECT* FROM coaches;

#ZAD9
DELIMITER |
CREATE PROCEDURE procedure_with_cursor()
BEGIN
	DECLARE curr_student_name VARCHAR(40);
    DECLARE curr_student_egn VARCHAR(10);
    DECLARE finished INT;
    DECLARE cur CURSOR FOR 
		SELECT students.name, students.egn
        FROM students;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    CREATE TEMPORARY TABLE stud(
		stud_name VARCHAR(40),
        stud_egn VARCHAR(10)
	)ENGINE = MEMORY;
    SET finished = 0;
    OPEN cur;
    loop_label:
		WHILE (finished = 0)
		DO 
			FETCH cur INTO curr_student_name, curr_student_egn;
            IF(finished=1)
			THEN
				LEAVE loop_label;
			END IF;
            INSERT INTO stud
            VALUES(curr_student_name, curr_student_egn);
		END WHILE;
	CLOSE cur;
    SELECT * FROM stud;
    DROP TABLE stud;
END
|
DELIMITER ;

CALL procedure_with_cursor();












