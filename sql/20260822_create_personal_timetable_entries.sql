-- 학생이 직접 입력하는 개인 시간표입니다.
-- 기존 courses, enrolments, class_timetable_slots 구조와 의도적으로 연결하지 않습니다.
CREATE TABLE IF NOT EXISTS personal_timetable_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    day ENUM('월', '화', '수', '목', '금') NOT NULL,
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
  COMMENT = '학생 직접 입력 개인 시간표';
