-- Highlog complete database DDL for MySQL 8.0 or later.

-- utf8mb4 remains enabled so application data can contain any Unicode text.
CREATE DATABASE IF NOT EXISTS highlog
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE highlog;

CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Student ID',
    username VARCHAR(10) NOT NULL COMMENT 'Student name',
    login_id VARCHAR(50) NOT NULL UNIQUE COMMENT 'Login ID',
    password VARCHAR(255) NOT NULL COMMENT 'Password hash',
    grade INT NOT NULL COMMENT 'Grade',
    class_no INT NOT NULL COMMENT 'Home class number',
    school_number INT NOT NULL COMMENT 'School number',
    can_manage_courses BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Course management permission',
    UNIQUE KEY uq_student_school_number (grade, class_no, school_number)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  AUTO_INCREMENT = 10000
  COMMENT = 'Students';

CREATE TABLE IF NOT EXISTS courses (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Course ID',
    title VARCHAR(80) NOT NULL COMMENT 'Course title',
    tag VARCHAR(30) NULL COMMENT 'Selection group tag',
    classroom VARCHAR(50) NOT NULL COMMENT 'Classroom',
    days JSON NOT NULL COMMENT 'Course schedule JSON',
    grade INT NOT NULL COMMENT 'Target grade',
    class_no INT NULL COMMENT 'Target home class',
    day VARCHAR(10) NOT NULL COMMENT 'Day',
    period INT NOT NULL COMMENT 'Period from 1 to 7',
    color CHAR(7) NOT NULL DEFAULT '#FFFFFF' COMMENT 'Timetable color',
    is_class_wide BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Shared by the home class',
    created_by_student_id INT NULL COMMENT 'Creator student ID',
    INDEX idx_course_owner (created_by_student_id),
    CONSTRAINT fk_course_owner FOREIGN KEY (created_by_student_id) REFERENCES students (id) ON DELETE SET NULL,
    CONSTRAINT chk_course_period CHECK (period BETWEEN 1 AND 7)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  AUTO_INCREMENT = 100
  COMMENT = 'Courses';

CREATE TABLE IF NOT EXISTS class_timetable_slots (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Timetable slot ID',
    grade INT NOT NULL COMMENT 'Grade',
    class_no INT NULL COMMENT 'Home class; NULL for grade-wide slots',
    class_scope INT GENERATED ALWAYS AS (IFNULL(class_no, 0)) STORED COMMENT 'Normalized class scope',
    day VARCHAR(10) NOT NULL COMMENT 'Day',
    period INT NOT NULL COMMENT 'Period from 1 to 7',
    label VARCHAR(80) NOT NULL COMMENT 'Fixed title or selection label',
    tag VARCHAR(30) NULL COMMENT 'Selection group tag',
    course_id INT NULL COMMENT 'Course ID for a fixed slot',

    UNIQUE KEY uq_class_slot (grade, class_scope, day, period),
    INDEX idx_class_slot_lookup (grade, class_no),
    INDEX idx_class_slot_conflict (grade, day, period, class_no),
    INDEX idx_class_slot_course (course_id),
    CONSTRAINT fk_class_slot_course
        FOREIGN KEY (course_id) REFERENCES courses (id),
    CONSTRAINT chk_class_slot_type CHECK (
        (course_id IS NOT NULL AND tag IS NULL)
        OR (course_id IS NULL AND tag IS NOT NULL)
    ),
    CONSTRAINT chk_class_slot_period CHECK (period BETWEEN 1 AND 7)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Grade and class timetable slots';

CREATE TABLE IF NOT EXISTS enrolments (
    student_id INT NOT NULL COMMENT 'Student ID',
    course_id INT NOT NULL COMMENT 'Course ID',
    source ENUM('fixed', 'selected') NOT NULL DEFAULT 'selected'
        COMMENT 'fixed: automatic, selected: student selection',

    PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrolments_student
        FOREIGN KEY (student_id) REFERENCES students (id),
    CONSTRAINT fk_enrolments_course
        FOREIGN KEY (course_id) REFERENCES courses (id)
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Student course enrolments';

DROP TRIGGER IF EXISTS bi_class_slot_scope_conflict;
DROP TRIGGER IF EXISTS bu_class_slot_scope_conflict;

-- Optional example data for grade 1, class 1.
INSERT IGNORE INTO courses
    (id, title, tag, classroom, days, grade, class_no, day, period, color, is_class_wide)
VALUES
    (100, 'Language', NULL, 'Classroom 1-1', JSON_ARRAY(JSON_OBJECT('day', 'Monday', 'period', 1)), 1, 1, 'Monday', 1, '#BBF7D0', TRUE),
    (101, 'Math', NULL, 'Classroom 1-1', JSON_ARRAY(JSON_OBJECT('day', 'Monday', 'period', 3)), 1, 1, 'Monday', 3, '#FDE68A', TRUE);

INSERT IGNORE INTO class_timetable_slots
    (grade, class_no, day, period, label, tag, course_id)
VALUES
    (1, 1, 'Monday', 1, 'Language', NULL, 100),
    (1, NULL, 'Monday', 2, 'Career A', 'Career A', NULL),
    (1, 1, 'Monday', 3, 'Math', NULL, 101),
    (1, NULL, 'Tuesday', 1, 'Career B', 'Career B', NULL);

-- Prevent grade-wide slots from overlapping class-specific slots.
DELIMITER //
CREATE TRIGGER bi_class_slot_scope_conflict BEFORE INSERT ON class_timetable_slots FOR EACH ROW
BEGIN
    IF (NEW.class_no IS NULL AND EXISTS (SELECT 1 FROM class_timetable_slots WHERE grade=NEW.grade AND day=NEW.day AND period=NEW.period))
       OR (NEW.class_no IS NOT NULL AND EXISTS (SELECT 1 FROM class_timetable_slots WHERE grade=NEW.grade AND day=NEW.day AND period=NEW.period AND class_no IS NULL)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Grade-wide and class-specific timetable slots conflict';
    END IF;
END//
CREATE TRIGGER bu_class_slot_scope_conflict BEFORE UPDATE ON class_timetable_slots FOR EACH ROW
BEGIN
    IF (NEW.class_no IS NULL AND EXISTS (SELECT 1 FROM class_timetable_slots WHERE id<>OLD.id AND grade=NEW.grade AND day=NEW.day AND period=NEW.period))
       OR (NEW.class_no IS NOT NULL AND EXISTS (SELECT 1 FROM class_timetable_slots WHERE id<>OLD.id AND grade=NEW.grade AND day=NEW.day AND period=NEW.period AND class_no IS NULL)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Grade-wide and class-specific timetable slots conflict';
    END IF;
END//
DELIMITER ;

-- Personal timetable entries entered by each student.
-- Each student can have one entry per day and period.
CREATE TABLE IF NOT EXISTS personal_timetable_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    day VARCHAR(10) NOT NULL,
    period TINYINT NOT NULL,
    subject_name VARCHAR(80) NOT NULL,
    class_name VARCHAR(50) NOT NULL,
    color CHAR(7) NOT NULL DEFAULT '#E0E7FF',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_personal_timetable_slot (student_id, day, period),
    CONSTRAINT fk_personal_timetable_student
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT chk_personal_timetable_period CHECK (period BETWEEN 1 AND 7),
    CONSTRAINT chk_personal_timetable_color CHECK (color REGEXP '^#[0-9A-Fa-f]{6}$')
) ENGINE = InnoDB
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Student-managed personal timetable';
