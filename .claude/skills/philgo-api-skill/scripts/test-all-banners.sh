#!/bin/bash
# ============================================================================
# 전체 배너 API 테스트 스크립트
#
# 용도: 모든 배너 API를 한 번에 테스트합니다.
#       - get_top_banners (상단 배너)
#       - get_wing_banners (윙 배너)
#       - get_square_banners (사각 배너)
#       - get_small_banners (작은 배너)
#
# 사용법:
#   ./test-all-banners.sh                      # 전체 배너 테스트
#   ./test-all-banners.sh wanted               # wanted 카테고리 기준 테스트
#
# 주의: philgo.com은 Cloudflare 보안이 적용되어 있어 curl 테스트가 실패할 수 있습니다.
#       실패 시 브라우저 콘솔 또는 PHP 스크립트를 사용하세요.
# ============================================================================

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# API 엔드포인트
API_URL="https://philgo.com/func.php"

# 카테고리 파라미터 (선택)
CATEGORY="${1:-}"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           필고 광고 배너 API 전체 테스트                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}테스트 날짜:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${YELLOW}API URL:${NC} $API_URL"
if [ -z "$CATEGORY" ]; then
    echo -e "${YELLOW}카테고리:${NC} 없음 (전체 배너)"
else
    echo -e "${YELLOW}카테고리:${NC} $CATEGORY"
fi
echo ""

# Cloudflare 체크 함수
check_cloudflare() {
    if echo "$1" | grep -q "cf_chl"; then
        return 1
    fi
    return 0
}

# API 테스트 함수
test_api() {
    local api_name="$1"
    local display_name="$2"
    local request_data

    if [ -z "$CATEGORY" ]; then
        request_data="{\"func\": \"$api_name\"}"
    else
        request_data="{\"func\": \"$api_name\", \"category\": \"$CATEGORY\"}"
    fi

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}▶ $display_name 테스트${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "$request_data" \
        --max-time 10 \
        2>&1)

    if ! check_cloudflare "$response"; then
        echo -e "${RED}✗ Cloudflare 보안으로 인해 테스트 실패${NC}"
        echo ""
        return 1
    fi

    # 결과 요약 출력
    if command -v python3 &> /dev/null; then
        local summary=$(echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data:
        data = data['data']
    if isinstance(data, dict):
        if 'left' in data and 'right' in data:
            print(f\"왼쪽: {len(data['left'])}개, 오른쪽: {len(data['right'])}개\")
            for i, b in enumerate(data['left'][:3]):
                end_date = b.get('ad_end_date', 'N/A')
                print(f\"  좌측 {i+1}: idx={b.get('idx_company', 'N/A')}, 만료일={end_date}\")
        else:
            print(f\"배너 수: {len(data)}개\")
    elif isinstance(data, list):
        print(f\"배너 수: {len(data)}개\")
        for i, b in enumerate(data[:3]):
            end_date = b.get('ad_end_date', 'N/A')
            print(f\"  {i+1}: idx={b.get('idx_company', 'N/A')}, 만료일={end_date}\")
    else:
        print(f\"응답: {data}\")
except Exception as e:
    print(f\"파싱 에러: {e}\")
" 2>/dev/null)
        if [ -n "$summary" ]; then
            echo -e "${GREEN}$summary${NC}"
        else
            echo "$response" | python3 -m json.tool 2>/dev/null | head -20 || echo "$response" | head -5
        fi
    else
        echo "$response" | head -10
    fi
    echo ""
    return 0
}

# 모든 API 테스트 실행
SUCCESS_COUNT=0
FAIL_COUNT=0

test_api "get_top_banners" "상단 배너 (Top Banner)" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
test_api "get_wing_banners" "윙 배너 (Wing Banner)" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
test_api "get_square_banners" "사각 배너 (Square Banner)" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
test_api "get_small_banners" "작은 배너 (Small Banner)" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# 결과 요약
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                       테스트 결과 요약                        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ 성공: $SUCCESS_COUNT개${NC}"
echo -e "${RED}✗ 실패: $FAIL_COUNT개${NC}"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}대안 테스트 방법:${NC}"
    echo ""
    echo "1. 브라우저에서 philgo.com 접속 후 콘솔(F12)에서 테스트:"
    echo ""
    echo "   // 전체 배너 테스트"
    echo "   func('get_wing_banners', {}).then(r => console.log('윙:', r));"
    echo "   func('get_top_banners', {}).then(r => console.log('상단:', r));"
    echo "   func('get_square_banners', {}).then(r => console.log('사각:', r));"
    echo "   func('get_small_banners', {}).then(r => console.log('작은:', r));"
    echo ""
    echo "2. 로컬 PHP 스크립트로 테스트:"
    echo "   php tests/debug-wing-banner-order.php --db-config=etc/db.config.dev.php"
    echo ""
fi

echo -e "${CYAN}테스트 완료: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
