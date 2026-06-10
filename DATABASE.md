# Database Schema

이 문서는 `ddl.sql`에 정의된 데이터베이스 구조를 정리합니다.

## 데이터베이스

- 데이터베이스명: `highlog`
- 문자셋: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`

---

## 테이블 구조

### students

학생 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 제약조건 | 설명 |
|---------|---------|---------|---------|
| id | INT | AUTO_INCREMENT, PRIMARY KEY | 학생 고유 ID |
| username | VARCHAR(10) | NOT NULL | 학생 이름 |
| login_id | VARCHAR(50) | NOT NULL, UNIQUE | 로그인 아이디 |
| password | VARCHAR(255) | NOT NULL | 비밀번호 해시 |
| grade | INT | NOT NULL | 학년 |
| class_no | INT | NOT NULL | 반 |
| school_number | INT | NOT NULL | 학번 |

초기 AUTO_INCREMENT 값: `10000`

---

### courses

과목 정보를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 제약조건 | 설명 |
|---------|---------|---------|---------|
| id | INT | AUTO_INCREMENT, PRIMARY KEY | 과목 고유 ID |
| title | VARCHAR(80) | NOT NULL | 과목명 |
| category | VARCHAR(20) | NOT NULL | 과목 카테고리 |
| classroom | VARCHAR(50) | NOT NULL | 강의실 |
| days | JSON | NOT NULL | 수업 일정 |

초기 AUTO_INCREMENT 값: `100`

#### days JSON 예시

```json
[
  {
    "day": "월요일",
    "period": 3
  },
  {
    "day": "화요일",
    "period": 3
  }
]
```

---

### enrolments

학생과 과목의 수강 관계를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 제약조건 | 설명 |
|---------|---------|---------|---------|
| student_id | INT | NOT NULL | 학생 ID |
| course_id | INT | NOT NULL | 과목 ID |

제약 조건:

- FOREIGN KEY (`student_id`) REFERENCES `students`(`id`)
- FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`)
- UNIQUE KEY (`student_id`, `course_id`)

---

## 테이블 관계

- 한 명의 학생은 여러 과목을 수강할 수 있음
- 하나의 과목은 여러 학생이 수강할 수 있음
- `enrolments` 테이블이 학생과 과목 간의 다대다(M:N) 관계를 관리함

```text
students
    |
    | 1:N
    |
enrolments
    |
    | N:1
    |
courses
```

---

## 설계 참고 사항

초기 설계에서는 별도의 `schedules` 테이블을 사용하려 했으나, 현재는 `courses.days` JSON 컬럼에 수업 시간 정보를 저장하는 방식으로 변경되었습니다.

기존 설계:

```sql
CREATE TABLE schedules (
    course_id INT NOT NULL,
    day VARCHAR(10) NOT NULL COMMENT '요일',
    period INT NOT NULL COMMENT '교시',
    FOREIGN KEY (course_id) REFERENCES courses(id)
);
```