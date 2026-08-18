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
| tag | VARCHAR(30) | NOT NULL | 과목 선택 그룹 태그. 같은 태그에서는 한 과목만 선택 가능 |
| classroom | VARCHAR(50) | NOT NULL | 강의실 |
| days | JSON | NOT NULL | 수업 일정(월~금, 1~7교시) |

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

### class_timetable_slots

학년과 반별 시간표의 고정 틀을 저장합니다. 한 반의 한 요일/교시에는 슬롯 하나만 존재합니다.

| 컬럼명 | 타입 | 제약조건 | 설명 |
|---------|---------|---------|---------|
| id | INT | AUTO_INCREMENT, PRIMARY KEY | 슬롯 ID |
| grade | INT | NOT NULL | 학년 |
| class_no | INT | NOT NULL | 반 |
| day | VARCHAR(10) | NOT NULL | 요일 (`월요일` 등) |
| period | INT | NOT NULL, CHECK 1~7 | 교시 |
| label | VARCHAR(80) | NOT NULL | 선택 전 또는 고정 슬롯에 표시할 이름 |
| tag | VARCHAR(30) | NULL | 선택 과목과 연결할 태그. NULL이면 고정 슬롯 |
| course_id | INT | NULL, FOREIGN KEY | 고정 슬롯에 직접 연결된 과목 ID. 선택 슬롯이면 NULL |

`UNIQUE (grade, class_no, day, period)`로 동일 시간의 중복 슬롯을 막습니다.

동작 규칙:

- `course_id IS NOT NULL`: 연결된 과목을 고정 과목으로 표시하고 회원가입 시 자동 수강 등록합니다.
- `tag IS NOT NULL`: 학생이 같은 `courses.tag`에서 선택한 과목의 이름과 강의실을 표시합니다.
- 해당 태그에서 아직 선택하지 않았다면 `label`을 자리표시자로 표시합니다.
- 학생의 반 정보는 로그인 토큰의 학생 ID로 조회하므로 프론트가 다른 반 번호를 지정하지 않습니다.

예시:

```sql
INSERT INTO class_timetable_slots
  (grade, class_no, day, period, label, tag, course_id)
VALUES
  (1, 1, '월요일', 1, '국어', NULL, 100),
  (1, 1, '월요일', 2, '진로 A', '진로 A', NULL);
```

---

### enrolments

학생과 과목의 수강 관계를 저장하는 테이블입니다.

| 컬럼명 | 타입 | 제약조건 | 설명 |
|---------|---------|---------|---------|
| student_id | INT | NOT NULL | 학생 ID |
| course_id | INT | NOT NULL | 과목 ID |
| source | ENUM('fixed', 'selected') | NOT NULL | 자동 등록된 고정 과목인지 직접 선택한 과목인지 구분 |

제약 조건:

- FOREIGN KEY (`student_id`) REFERENCES `students`(`id`)
- FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`)
- UNIQUE KEY (`student_id`, `course_id`)

`source='fixed'`인 수강 정보는 반별 시간표에서 자동 생성되며 수강신청 API로 삭제되지 않습니다.

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

`class_timetable_slots`는 학생 테이블을 직접 참조하지 않고 `(grade, class_no)` 값으로
반 전체에 적용됩니다. 반이 바뀌면 해당 학생은 새 학년/반의 틀을 자동으로 조회합니다.

---

## 설계 참고 사항

현재 시간표 화면은 `class_timetable_slots`를 우선 사용합니다. `courses.days` JSON은
기존 데이터 및 반별 틀이 아직 등록되지 않은 학생을 위한 fallback 일정으로 유지합니다.

기존 설계:

```sql
CREATE TABLE schedules (
    course_id INT NOT NULL,
    day VARCHAR(10) NOT NULL COMMENT '요일',
    period INT NOT NULL COMMENT '교시',
    FOREIGN KEY (course_id) REFERENCES courses(id)
);
```
