# Highlog DB 백업 및 복구 절차

대상은 `docker-compose.yml`의 `highlog-mysql` 개발·운영 컨테이너입니다. 백업 파일은 기본적으로 프로젝트의 `backups/`에 생성되며 Git에서 제외됩니다.

## 백업

프로젝트 루트에서 실행합니다.

```powershell
.\scripts\backup-database.ps1
```

스크립트는 다음 항목을 수행합니다.

- InnoDB 일관성을 위한 `--single-transaction` 덤프
- 트리거·프로시저·이벤트와 binary 데이터 포함
- UTF-8 SQL 파일 생성
- SHA-256 체크섬 파일 생성
- 비밀번호를 저장 파일이나 명령 인자로 직접 전달하지 않고 컨테이너 환경변수 사용

백업 파일과 같은 이름의 `.sha256` 파일을 함께 보관하세요. DB 서버와 다른 저장소에도 암호화해 복사해야 서버·디스크 장애에 대비할 수 있습니다.

권장 주기:

- 운영 DB: 매일 자동 백업, 최소 30일 보관
- 과목 대량 등록·스키마 변경·배포 직전: 수동 백업
- 월 1회: 별도 임시 DB에서 실제 복구 테스트

## 복구 전 확인

복구는 현재 DB 내용을 백업 파일의 상태로 변경할 수 있습니다.

1. 앱과 백엔드의 쓰기 요청을 중단합니다.
2. 복구할 `.sql`과 `.sha256` 파일이 함께 있는지 확인합니다.
3. 가능하면 운영 DB가 아닌 별도 컨테이너에서 먼저 복구합니다.
4. 현재 DB의 디스크 여유 공간을 확인합니다.

## 복구

명시적인 확인 문자열이 없으면 스크립트가 실행되지 않습니다.

```powershell
.\scripts\restore-database.ps1 `
  -BackupFile .\backups\highlog-20260818-120000.sql `
  -Confirm RESTORE-highlog
```

복구 스크립트는 체크섬을 검증하고, 현재 DB를 자동으로 한 번 더 백업한 뒤 복구합니다. SQL 파일은 임시로 컨테이너에 복사되며 작업 후 제거됩니다.

## 복구 검증

복구 후 다음을 확인합니다.

```powershell
docker exec highlog-mysql sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mysql -u"$MYSQL_USER" "$MYSQL_DATABASE" -e "SHOW TABLES; SELECT COUNT(*) AS students FROM students; SELECT COUNT(*) AS courses FROM courses; SELECT COUNT(*) AS enrolments FROM enrolments;"'
```

그 다음 백엔드를 시작하고 회원가입, 로그인, 과목 선택, 시간표 조회를 테스트합니다. 검증이 끝난 뒤에만 사용자 쓰기 요청을 다시 허용하세요.

## 정기 복구 테스트 기록

아래 항목을 매번 기록합니다.

- 백업 생성 시각과 파일명
- SHA-256 검증 결과
- 복구 대상(반드시 임시 DB 우선)
- 복구 시작·종료 시각
- 테이블 및 주요 행 개수
- 로그인·시간표 기능 확인 결과
- 담당자와 발견된 문제