CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(10) NOT NULL COMMENT '이름',
    login_id VARCHAR(50) NOT NULL UNIQUE COMMENT '로그인 아이디',
    password VARCHAR(255) NOT NULL COMMENT '비밀번호',

    grade INT NOT NULL COMMENT '학년',
    class_no INT NOT NULL COMMENT '반',
    school_number INT NOT NULL COMMENT '학번'
) AUTO_INCREMENT = 10000;


CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,

    title VARCHAR(80) NOT NULL COMMENT '과목명',
    category VARCHAR(20) NOT NULL COMMENT '과목 카테고리',
    classroom VARCHAR(50) NOT NULL COMMENT '강의실',

    days JSON NOT NULL COMMENT '수업 일정'
    /*
    example:
    [
      {
        "day": "월요일",
        "period": 3
      },
      {
        "day": "화요일",
        "period": 3
      }
    ]
    */
) AUTO_INCREMENT = 100;


CREATE TABLE enrolments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,

    PRIMARY KEY (student_id, course_id),

    FOREIGN KEY (student_id)
        REFERENCES students(id),

    FOREIGN KEY (course_id)
        REFERENCES courses(id)
);

CREATE TABLE schedules (
    course_id INT NOT NULL PRIMARY KEY,
    title VARCHAR(50) NOT NULL COMMENT '수행 제목',
    schedule_content VARCHAR(1000) NOT NULL COMMENT '수행 내용',
    day_info JSON NOT NULL COMMENT '날짜 정보',
    /*
    {
      "day": "월요일",
      "date": Time
    }
    */

    FOREIGN (course_id)
      REFERENCES courses(id)
);