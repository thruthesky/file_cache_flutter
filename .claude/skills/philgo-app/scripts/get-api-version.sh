#!/bin/bash

# 필고 API 함수 목록 조회 스크립트
# Philgo API Functions List Script
#
# 사용법 (Usage):
#   ./get-api-version.sh
#
# 출력 (Output):
#   API에서 허용된 함수 목록 (func.php를 통해 호출 가능한 함수들)
#
# 참고 (Reference):
#   .claude/skills/philgo-api-skill/SKILL.md 문서 참조

API_URL="https://philgo.com/func.php?func=get_functions"

echo "=========================================="
echo "  필고 API 함수 목록 (Philgo API Functions)"
echo "=========================================="
echo ""

# API 호출 및 결과 출력
# Call API and display result
response=$(curl -s "$API_URL")

if [ $? -eq 0 ]; then
    echo "허용된 API 함수 목록 (Allowed API Functions):"
    echo ""
    echo "$response" | python3 -m json.tool 2>/dev/null || echo "$response"
    echo ""
    echo "API 엔드포인트: $API_URL"
    echo "조회 시간: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "📌 참고: 각 함수는 func.php?func=함수명 형식으로 호출합니다."
    echo "   예시: curl \"https://philgo.com/func.php?func=get_my_data&token=xxx\""
else
    echo "오류: API 호출 실패 (Error: API call failed)"
    exit 1
fi

echo ""
echo "=========================================="
