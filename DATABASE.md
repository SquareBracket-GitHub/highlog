# Database Schema

이 문서는 `ddl.sql`에 정의된 데이터베이스 테이블 구조를 정리합니다.

## 테이블 구조

### students

- `id` INT AUTO_INCREMENT PRIMARY KEY
- `username` VARCHAR(10) NOT NULL COMMENT '아이디'
- `grade` INT NOT NULL COMMENT '학년'
- `class_no` INT NOT NULL COMMENT '반'
- `school_number` INT NOT NULL COMMENT '학번'
 - `login_id` VARCHAR(50) UNIQUE NOT NULL COMMENT '로그인 아이디'
 - `password` VARCHAR(255) NOT NULL COMMENT '비밀번호(해시 저장)'

### courses

- `id` INT AUTO_INCREMENT PRIMARY KEY
- `title` VARCHAR(80) NOT NULL COMMENT '과목명'
- `classroom` VARCHAR(50) NOT NULL COMMENT '강의실'
- `days` JSON NOT NULL

설명:
- 예시 JSON:
  ```json
  [{
      "day": "월요일",
      "period": 3
  }, {
      "day": "화요일",
      "period": 3
  }]
  ```

### enrolments

- `student_id` INT NOT NULL
- `course_id` INT NOT NULL
- FOREIGN KEY (`student_id`) REFERENCES `students`(`id`)
- FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`)
- UNIQUE KEY (`student_id`, `course_id`)

## 미사용/주석 처리된 설계

- `schedules` 테이블을 정규하된 테이블에서 JSON을 사용하는 것으로 변경됨. 
- 주석 처리된 내용:
  ```sql
  -- create table schedules (
  --     course_id INT NOT NULL,
  --     day VARCHAR(10) NOT NULL COMMENT '요일',
  --     period INT NOT NULL COMMENT '교시',
  --     FOREIGN KEY (course_id) REFERENCES courses (id)
  -- );
  ```
