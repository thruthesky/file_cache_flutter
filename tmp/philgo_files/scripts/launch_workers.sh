#!/bin/bash

# 병렬 Worker 런처 스크립트
#
# 여러 Worker를 동시에 실행합니다.
#
# 사용법:
#   ./lib/philgo_files/scripts/launch_workers.sh [worker_count] [options]
#
# 예시:
#   ./lib/philgo_files/scripts/launch_workers.sh 5                      # 5개 Worker 실행
#   ./lib/philgo_files/scripts/launch_workers.sh 10 --province Palawan  # Palawan 지역만 10개 Worker로
#   ./lib/philgo_files/scripts/launch_workers.sh 3 --dry-run            # 3개 Worker dry-run 모드

# 기본 설정
WORKER_COUNT=${1:-5}
shift  # 첫 번째 인자(worker_count) 제거
EXTRA_ARGS="$@"

# 프로젝트 루트 디렉토리로 이동
cd "$(dirname "$0")/../../.."

echo "========================================"
echo "🚀 병렬 Worker 런처"
echo "========================================"
echo ""
echo "설정:"
echo "  Worker 수: $WORKER_COUNT"
echo "  추가 옵션: ${EXTRA_ARGS:-없음}"
echo ""

# Worker 실행
echo "Worker 실행 중..."
echo ""

for i in $(seq 1 $WORKER_COUNT); do
    echo "  Worker $i 시작..."
    dart run lib/philgo_files/scripts/parallel_worker.dart --worker-id $i $EXTRA_ARGS &
    sleep 0.5  # Worker 간 시작 간격
done

echo ""
echo "========================================"
echo "✅ 모든 Worker가 백그라운드에서 실행 중입니다."
echo ""
echo "💡 모니터링:"
echo "   dart run lib/philgo_files/scripts/parallel_monitor.dart --watch"
echo ""
echo "💡 프로세스 확인:"
echo "   ps aux | grep parallel_worker"
echo ""
echo "💡 모든 Worker 종료:"
echo "   pkill -f parallel_worker.dart"
echo "========================================"

# 모든 백그라운드 작업이 완료될 때까지 대기
wait

echo ""
echo "🏁 모든 Worker 작업 완료"
