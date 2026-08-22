-- Anonymous board and registration consent migration for MySQL 8.0+.
ALTER TABLE students
    ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Application administrator';

CREATE TABLE IF NOT EXISTS terms_consents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    consent_type ENUM('service_terms', 'privacy_policy', 'anonymous_board_notice', 'age_or_guardian') NOT NULL,
    terms_version VARCHAR(20) NOT NULL,
    agreed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_terms_consent (student_id, consent_type, terms_version),
    CONSTRAINT fk_terms_consent_student FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS board_memberships (
    student_id INT PRIMARY KEY,
    status ENUM('pending', 'approved', 'rejected', 'suspended') NOT NULL DEFAULT 'pending',
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    reviewed_by_admin_id INT NULL,
    review_note VARCHAR(200) NULL,
    INDEX idx_board_membership_queue (status, requested_at),
    CONSTRAINT fk_board_membership_student FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT fk_board_membership_admin FOREIGN KEY (reviewed_by_admin_id) REFERENCES students (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS anonymous_posts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    author_student_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    deleted_by_admin_id INT NULL,
    deletion_reason VARCHAR(200) NULL,
    INDEX idx_anonymous_posts_public (deleted_at, created_at),
    CONSTRAINT fk_anonymous_post_author FOREIGN KEY (author_student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT fk_anonymous_post_deleting_admin FOREIGN KEY (deleted_by_admin_id) REFERENCES students (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS anonymous_comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    post_id BIGINT NOT NULL,
    author_student_id INT NOT NULL,
    content VARCHAR(500) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    deleted_by_admin_id INT NULL,
    INDEX idx_anonymous_comments_post (post_id, deleted_at, created_at),
    CONSTRAINT fk_anonymous_comment_post FOREIGN KEY (post_id) REFERENCES anonymous_posts (id) ON DELETE CASCADE,
    CONSTRAINT fk_anonymous_comment_author FOREIGN KEY (author_student_id) REFERENCES students (id) ON DELETE CASCADE,
    CONSTRAINT fk_anonymous_comment_deleting_admin FOREIGN KEY (deleted_by_admin_id) REFERENCES students (id) ON DELETE SET NULL
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS board_admin_audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_student_id INT NOT NULL,
    action ENUM('VIEW_POST_AUTHOR', 'DELETE_POST', 'DELETE_COMMENT', 'APPROVE_MEMBER', 'REJECT_MEMBER', 'SUSPEND_MEMBER') NOT NULL,
    target_type ENUM('post', 'comment', 'student') NOT NULL,
    target_id BIGINT NOT NULL,
    reason VARCHAR(200) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_board_admin_audit_admin (admin_student_id, created_at),
    CONSTRAINT fk_board_audit_admin FOREIGN KEY (admin_student_id) REFERENCES students (id) ON DELETE RESTRICT
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
