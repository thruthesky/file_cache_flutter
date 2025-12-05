#!/bin/bash
# ============================================================================
# 윙 배너 API 테스트 스크립트
#
# 용도: get_wing_banners API를 호출하여 윙 배너 목록을 조회합니다.
#
# 사용법:
#   ./test-get-wing-banners.sh                 # 전체 윙 배너 조회
#   ./test-get-wing-banners.sh wanted          # wanted 카테고리 배너 조회
#   ./test-get-wing-banners.sh travel          # travel 카테고리 배너 조회
#
# 주의: philgo.com은 Cloudflare 보안이 적용되어 있어 curl 테스트가 실패할 수 있습니다.
#       실패 시 브라우저 콘솔에서 테스트하거나 PHP 스크립트를 사용하세요.
# ============================================================================

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API 엔드포인트
API_URL="https://philgo.com/etc/api.php"
LOCAL_API_URL="https://local.philgo.com:444/etc/api.php"

# 카테고리 파라미터 (선택)
CATEGORY="${1:-}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   윙 배너 API 테스트 (get_wing_banners)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 요청 데이터 생성
if [ -z "$CATEGORY" ]; then
    REQUEST_DATA='{"fn": "get_wing_banners"}'
    echo -e "${YELLOW}카테고리:${NC} 없음 (전체 배너)"
else
    REQUEST_DATA="{\"fn\": \"get_wing_banners\", \"category\": \"$CATEGORY\"}"
    echo -e "${YELLOW}카테고리:${NC} $CATEGORY"
fi

echo -e "${YELLOW}API URL:${NC} $API_URL"
echo -e "${YELLOW}요청 데이터:${NC} $REQUEST_DATA"
echo ""

# API 호출
echo -e "${GREEN}▶ API 호출 중...${NC}"
echo ""

RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$REQUEST_DATA" \
    --max-time 10 \
    2>&1)

# 응답 확인
if echo "$RESPONSE" | grep -q "cf_chl"; then
    echo -e "${RED}✗ Cloudflare 보안 체크로 인해 curl 테스트 실패${NC}"
    echo ""
    echo -e "${YELLOW}대안 방법:${NC}"
    echo "1. 브라우저에서 philgo.com 접속 후 콘솔(F12)에서 테스트:"
    echo ""
    echo "   func('get_wing_banners', {}).then(r => console.log(r));"
    echo ""
    echo "2. 로컬 PHP 스크립트로 테스트:"
    echo "   php tests/debug-wing-banner-order.php --db-config=etc/db.config.dev.php"
    echo ""
    exit 1
fi

# JSON 응답 파싱 및 출력
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}▶ 응답 결과:${NC}"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
elif command -v jq &> /dev/null; then
    echo -e "${GREEN}▶ 응답 결과:${NC}"
    echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${GREEN}▶ 응답 결과 (raw):${NC}"
    echo "$RESPONSE"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}테스트 완료${NC}"
echo -e "${BLUE}========================================${NC}"
