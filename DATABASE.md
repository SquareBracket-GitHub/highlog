# Database Schema

이 문서는 `ddl.sql`에 정의된 데이터베이스 테이블 구조를 정리합니다.

## 테이블 구조

### students

- `idx` INT AUTO_INCREMENT PRIMARY KEY
- `username` VARCHAR(10) NOT NULL COMMENT '아이디'
- `grade` INT NOT NULL COMMENT '학년'
- `class` INT NOT NULL COMMENT '반'
- `school_number` INT NOT NULL COMMENT '학번'

### courses

- `idx` INT AUTO_INCREMENT PRIMARY KEY
- `title` VARCHAR(80) NOT NULL COMMENT '과목명'
- `classroom` VARCHAR(50) NOT NULL COMMENT '강의실'
- `day` JSON NOT NULL

설명:
- 예시 JSON:
  ```json
  [{
      "day": "월요일",
      "period": "3"
  }, {
      "day": "화요일",
      "period": "3"
  }]
  ```

### enrolments

- `student_idx` INT NOT NULL
- `course_idx` INT NOT NULL
- FOREIGN KEY (`student_idx`) REFERENCES `students`(`idx`)
- FOREIGN KEY (`course_idx`) REFERENCES `courses`(`idx`)
- UNIQUE KEY (`student_idx`, `course_idx`)

## 미사용/주석 처리된 설계

- `schedules` 테이블을 정규하된 테이블에서 JSON을 사용하는 것으로 변경됨. 
- 주석 처리된 내용:
  ```sql
  -- create table schedules (
  --     course_idx INT NOT NULL,
  --     day VARCHAR(10) NOT NULL COMMENT '요일',
  --     period INT NOT NULL COMMENT '교시',
  --     FOREIGN KEY (course_idx) REFERENCES courses (idx)
  -- );
  ```
