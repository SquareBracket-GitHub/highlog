-- User inquiries and administrator responses for MySQL 8.0+.
CREATE TABLE IF NOT EXISTS inquiries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    status ENUM('open', 'answered', 'closed') NOT NULL DEFAULT 'open',
    admin_response TEXT NULL,
    responded_by_admin_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    student_read_at TIMESTAMP NULL,
    INDEX idx_inquiries_student (student_id, created_at),
    INDEX idx_inquiries_admin_queue (status, created_at),
    CONSTRAINT fk_inquiry_student FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT fk_inquiry_admin FOREIGN KEY (responded_by_admin_id) REFERENCES students (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
