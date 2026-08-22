-- Personal timetable entries entered by each student.
-- This table is intentionally independent from courses and class timetable slots.
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
