create table students (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(10) NOT NULL COMMENT '아이디',
    grade INT NOT NULL COMMENT '학년',
    class INT NOT NULL COMMENT '반',
    school_number INT NOT NULL COMMENT '학번'
) AUTO_INCREMENT = 10000;

create table courses (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(80) NOT NULL COMMENT '과목명',
    classroom VARCHAR(50) NOT NULL COMMENT '강의실',
    day JSON NOT NULL
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
SELECT * FROM students WHERE day LIKE '%M%'; 

create table enrolments (
    student_idx INT NOT NULL,
    course_idx INT NOT NULL,
    FOREIGN KEY (student_idx) REFERENCES students (idx),
    FOREIGN KEY (course_idx) REFERENCES courses (idx),
    UNIQUE KEY (student_idx, course_idx)
);

-- create table schedules (
--     course_idx INT NOT NULL,
--     day VARCHAR(10) NOT NULL COMMENT '요일',
--     period INT NOT NULL COMMENT '교시',
--     FOREIGN KEY (course_idx) REFERENCES courses (idx)
-- );