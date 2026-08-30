-- Feature migration for existing Highlog databases (MySQL 8.0+).
USE highlog;

CREATE TABLE IF NOT EXISTS board_reports (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reporter_student_id INT NOT NULL,
    target_type ENUM('post', 'comment') NOT NULL,
    target_id BIGINT NOT NULL,
    reason VARCHAR(500) NOT NULL,
    status ENUM('pending', 'resolved', 'dismissed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    reviewed_by_admin_id INT NULL,
    UNIQUE KEY uq_board_reporter_target (reporter_student_id, target_type, target_id),
    INDEX idx_board_reports_queue (status, created_at),
    CONSTRAINT fk_board_reporter FOREIGN KEY (reporter_student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT fk_board_report_reviewer FOREIGN KEY (reviewed_by_admin_id) REFERENCES students (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

ALTER TABLE board_admin_audit_logs
    MODIFY COLUMN action ENUM('VIEW_POST_AUTHOR', 'DELETE_POST', 'DELETE_COMMENT', 'APPROVE_MEMBER', 'REJECT_MEMBER', 'SUSPEND_MEMBER', 'RESTORE_MEMBER') NOT NULL;

ALTER TABLE board_admin_audit_logs
    ADD COLUMN report_id BIGINT NULL AFTER target_id,
    ADD CONSTRAINT fk_board_audit_report FOREIGN KEY (report_id) REFERENCES board_reports (id) ON DELETE SET NULL;

ALTER TABLE inquiries ADD COLUMN student_read_at TIMESTAMP NULL AFTER responded_at;
