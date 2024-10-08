USE PRACTICE;
-- ------------------------------------------------------------------------------
DROP TABLE PP_Employee;
CREATE TABLE PP_Employee (
emp_id int NOT NULL,
name varchar(40) NOT NULL,
birthdate date NOT NULL,
gender varchar(10) NOT NULL,
hire_date date NOT NULL,
PRIMARY KEY (emp_id)
);

INSERT INTO PP_Employee (emp_id, name, birthdate, gender, hire_date) VALUES
(101, 'Bryan', '1988-08-12', 'M', '2015-08-26'),
(102, 'Joseph', '1978-05-12', 'M', '2014-10-21'),
(103, 'Mike', '1984-10-13', 'M', '2017-10-28'),
(104, 'Daren', '1979-04-11', 'M', '2006-11-01'),
(105, 'Marie', '1990-02-11', 'F', '2018-10-12');

drop table pp_payment;

SELECT *FROM PP_Employee;

CREATE TABLE PP_Payment (
payment_id int PRIMARY KEY NOT NULL,
emp_id int NOT NULL,
amount float NOT NULL,
payment_date date NOT NULL,
constraint fk  FOREIGN KEY (emp_id) REFERENCES PP_Employee (emp_id) ON DELETE CASCADE 
);

INSERT INTO PP_Payment (payment_id, emp_id, amount, payment_date) VALUES
(301, 101, 1200, '2015-09-15'),
(302, 101, 1200, '2015-09-30'),
(303, 101, 1500, '2015-10-15'),
(304, 101, 1500, '2015-10-30'),
(305, 102, 1800, '2015-09-15'),
(306, 102, 1800, '2015-09-30');

SELECT * FROM PP_PAYMENT;

-- DELETE 
DELETE FROM PP_EMPLOYEE WHERE EMP_ID=102;
SELECT * FROM PP_EMPLOYEE;
SELECT * FROM PP_PAYMENT;

USE INFORMATION_SCHEMA;
SELECT table_name FROM referential_constraints
WHERE constraint_schema = 'PRACTICE'
AND referenced_table_name = 'PP_EMPLOYEE'
AND delete_rule = 'CASCADE';

-- -------------------------------------------------------------------
DESCRIBE PP_PAYMENT;
alter table pp_payment
drop constraint fk;
ALTER TABLE PP_PAYMENT
ADD constraint fk1 foreign key(EMP_ID) references PP_EMPLOYEE(EMP_ID) ON UPDATE cascade ON delete CASCADE;

UPDATE PP_EMPLOYEE
SET EMP_ID=107 WHERE EMP_ID=101;
SELECT * FROM PP_EMPLOYEE;
SET SQL_SAFE_UPDATES=0;



select * from pp_payment;
