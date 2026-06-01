create table students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(10) NOT NULL COMMENT '아이디',
    grade INT NOT NULL COMMENT '학년',
    class_no INT NOT NULL COMMENT '반',
    school_number INT NOT NULL COMMENT '학번'
) AUTO_INCREMENT = 10000;

create table courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(80) NOT NULL COMMENT '과목명',
    classroom VARCHAR(50) NOT NULL COMMENT '강의실',
    days JSON NOT NULL
) AUTO_INCREMENT = 100;
/*
[{
    "day": "월요일",
    "period": "3"
}, {
    "day": "화요일",
    "period": "3"
}]
*/
-- SELECT * FROM students WHERE day LIKE '%M%'; 

create table enrolments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students (id),
    FOREIGN KEY (course_id) REFERENCES courses (id),
    UNIQUE KEY (student_id, course_id)
);

-- create table schedules (
--     course_id INT NOT NULL,
--     day VARCHAR(10) NOT NULL COMMENT '요일',
--     period INT NOT NULL COMMENT '교시',
--     FOREIGN KEY (course_id) REFERENCES courses (id)
-- );

ALTER TABLE students
ADD COLUMN login_id VARCHAR(50) UNIQUE NOT NULL,
ADD COLUMN password VARCHAR(255) NOT NULL;