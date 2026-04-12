#!/bin/bash
# Guard: Spec 파일(specs/SPEC-*.md)의 직접 편집을 차단한다.
# .spec-writing-active 잠금 파일이 존재할 때만 편집을 허용한다.
#
# 사용: PreToolUse hook에서 Edit/Write 도구가 specs/SPEC-*.md 대상일 때 호출
# 입력: stdin으로 hook event JSON (tool_input.file_path 포함)
# 출력: JSON { "decision": "allow" | "block", "reason": "..." }

set -euo pipefail

# stdin에서 hook event JSON을 읽는다
INPUT=$(cat)

# tool_input.file_path를 추출한다
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# specs/SPEC-*.md 패턴에 해당하는지 확인한다
if echo "$FILE_PATH" | grep -qE 'specs/SPEC-[^/]*\.md$'; then
  # 잠금 파일 확인
  LOCK_FILE=".spec-writing-active"

  # 프로젝트 루트에서 잠금 파일을 찾��다
  # FILE_PATH가 절대 경로면 specs/ 상위 디렉터리에서 찾는다
  if echo "$FILE_PATH" | grep -q '^/'; then
    PROJECT_ROOT=$(echo "$FILE_PATH" | sed 's|/specs/SPEC-.*||')
    LOCK_PATH="$PROJECT_ROOT/$LOCK_FILE"
  else
    LOCK_PATH="$LOCK_FILE"
  fi

  if [ -f "$LOCK_PATH" ]; then
    echo '{"decision":"allow"}'
  else
    echo '{"decision":"block","reason":"Spec 파일은 spec-writing skill을 통해서만 수정할 수 있습니다. /spec-writing 을 사용해주세요."}'
  fi
else
  # specs/SPEC-*.md가 아닌 파일은 통과
  echo '{"decision":"allow"}'
fi
