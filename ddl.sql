-- Highlog 데이터베이스 통합 DDL
-- 대상 DBMS: MySQL 8.0 이상
-- 이 파일 하나로 데이터베이스, 테이블, 기본 시간표 예시 데이터를 생성할 수 있습니다.

-- 한글과 이모지를 안전하게 저장하도록 데이터베이스 문자셋을 지정합니다.
CREATE DATABASE IF NOT EXISTS highlog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE highlog;

-- 학생의 기본 정보와 로그인 정보를 저장합니다.
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '학생 고유 ID',
    username VARCHAR(10) NOT NULL COMMENT '학생 이름',
    login_id VARCHAR(50) NOT NULL UNIQUE COMMENT '로그인 아이디',
    password VARCHAR(255) NOT NULL COMMENT '비밀번호 해시',
    grade INT NOT NULL COMMENT '학년',
    class_no INT NOT NULL COMMENT '반',
    school_number INT NOT NULL COMMENT '학번'
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  AUTO_INCREMENT = 10000
  COMMENT = '학생 정보';

-- 개설 과목과 과목별 수업 일정을 저장합니다.
-- 같은 tag에 속한 과목 중 학생은 한 과목을 선택할 수 있습니다.
CREATE TABLE IF NOT EXISTS courses (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '과목 고유 ID',
    title VARCHAR(80) NOT NULL COMMENT '과목명',
    tag VARCHAR(30) NOT NULL COMMENT '과목 선택 그룹 태그',
    classroom VARCHAR(50) NOT NULL COMMENT '강의실',
    days JSON NOT NULL COMMENT '수업 일정 [{"day":"월요일","period":3}]'
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  AUTO_INCREMENT = 100
  COMMENT = '개설 과목';

-- 학년과 반별 시간표의 기본 틀을 저장합니다.
-- tag가 NULL이면 label을 고정 과목명으로 표시합니다.
-- tag가 있으면 같은 courses.tag에서 학생이 선택한 과목으로 표시합니다.
CREATE TABLE IF NOT EXISTS class_timetable_slots (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '시간표 슬롯 ID',
    grade INT NOT NULL COMMENT '학년',
    class_no INT NOT NULL COMMENT '반',
    day VARCHAR(10) NOT NULL COMMENT '요일(예: 월요일)',
    period INT NOT NULL COMMENT '교시',
    label VARCHAR(80) NOT NULL COMMENT '고정 과목명 또는 선택 전 표시 이름',
    tag VARCHAR(30) NULL COMMENT '선택 과목 연결 태그; NULL이면 고정 슬롯',

    -- 같은 반의 동일 요일/교시에 슬롯이 중복되지 않도록 합니다.
    UNIQUE KEY uq_class_slot (grade, class_no, day, period),
    -- 로그인한 학생의 학년/반 시간표 조회를 빠르게 합니다.
    INDEX idx_class_slot_lookup (grade, class_no)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '학년 및 반별 시간표 슬롯';

-- 학생과 과목의 다대다 수강 관계를 저장합니다.
CREATE TABLE IF NOT EXISTS enrolments (
    student_id INT NOT NULL COMMENT '학생 ID',
    course_id INT NOT NULL COMMENT '과목 ID',

    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrolments_student
        FOREIGN KEY (student_id) REFERENCES students (id),
    CONSTRAINT fk_enrolments_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = '학생별 수강 과목';

-- 1학년 1반 시간표 예시입니다.
-- INSERT IGNORE를 사용하므로 이 파일을 다시 실행해도 기존 슬롯은 중복되지 않습니다.
INSERT IGNORE INTO class_timetable_slots
    (grade, class_no, day, period, label, tag)
VALUES
    (1, 1, '월요일', 1, '국어', NULL),
    (1, 1, '월요일', 2, '선택 A', '선택 A'),
    (1, 1, '월요일', 3, '수학', NULL),
    (1, 1, '화요일', 1, '선택 B', '선택 B');
