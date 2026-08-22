-- Create the account through Highlog registration before running this file.
-- Registration is required so the password is securely hashed and consent records are created.
-- Replace the login ID in both statements before execution.

UPDATE students
SET is_admin = TRUE
WHERE login_id = 'replace-with-admin-login-id';

SELECT id, username, login_id, grade, class_no, school_number, is_admin
FROM students
WHERE login_id = 'replace-with-admin-login-id';
