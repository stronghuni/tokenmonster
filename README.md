# 🔥 Token Monster

Claude Code 토큰을 먹이 삼아 자라는 macOS 메뉴바 펫.
다마고치 × 포켓몬 × RunCat 감성.

![status](https://img.shields.io/badge/status-alpha-orange)
![macOS](https://img.shields.io/badge/macOS-13%2B%20arm64-blue)
![license](https://img.shields.io/badge/license-MIT-green)

## What it does

- 메뉴바에 **살아 움직이는 픽셀 몬스터** (꼬리를 쉬지 않고 상하로 흔듦)
- `~/.claude/projects/*.jsonl` 증분 파싱으로 토큰 실시간 추적
- 토큰 누적량에 따라 **6단계 진화** (알 → 궁극체)
- **토큰 사용 속도에 따라 애니메이션 가속** (쓰면 쓸수록 빠르게 움직임)
- 진화 시 **3초 햅틱 진동** + 아이콘 흔들림
- 메뉴바 클릭 → **레트로 RPG 스타일 팝오버 대시보드**
  - 대형 픽셀 캐릭터 (48×48 다색 스프라이트)
  - 오늘 / 이번 주 / 누적 토큰 통계
  - **프로젝트별 주간 토큰 랭킹 + 포켓몬 볼 티어**
    - 🔴 **몬스터볼** (< 5M/week)
    - 🔵 **슈퍼볼** (5M – 20M/week)
    - 🟡 **하이퍼볼** (≥ 20M/week)
  - 몬스터 명대사 로테이션 (20초마다)
- ⌘Q 종료, 우클릭 / ≡ 버튼으로 설정 메뉴
- **로그인 시 자동 실행** 토글 (`SMAppService`)

## Evolution Stages

| 단계 | 이름 | 임계값 | 체감 |
|---|---|---|---|
| 1 | 알 (Egg) | 0 | 시작 |
| 2 | Flamkin (유년기) | 30M | 첫날~이틀 |
| 3 | Flamon (성장기) | 150M | 첫 주 |
| 4 | Blazon (성숙기) | 500M | 첫 달 |
| 5 | Infernon (완전체) | 1.5B | 두 달 |
| 6 | Phoenignis (궁극체) | 4B | **세 달** |

임계값은 **앱 설치 시점의 누적 토큰을 baseline(0)으로 삼고**, 그 이후에 사용한 토큰만 카운트합니다. "새 알 받기" 메뉴로 언제든 리셋 가능.

> 다음 진화까지 얼마나 남았는지는 일부러 공개하지 않습니다. 궁금증이 재미입니다.

## Requirements

- macOS 13+ (Apple Silicon, arm64)
- Claude Code 설치 (`~/.claude/projects/` 경로가 존재해야 토큰 추적 가능)
- Swift 5.9+ (빌드 시)

## Build & Run

### 바이너리 실행 (개발용)
```bash
git clone https://github.com/stronghuni/tokenmonster.git
cd tokenmonster
swift build -c release
.build/release/TokenMonster &
```

### .app 번들 + DMG 배포
```bash
./scripts/build-app.sh   # → dist/TokenMonster.app (ad-hoc signed)
./scripts/build-dmg.sh   # → dist/TokenMonster-0.1.0.dmg
```

DMG 마운트 → TokenMonster를 Applications 폴더로 드래그하면 설치 완료.
메뉴바 우상단에 몬스터가 나타납니다.

**종료**: 메뉴바 아이콘 우클릭 → 종료 (⌘Q), 또는 `pkill -f TokenMonster`

## Architecture

```
Sources/TokenMonster/
├── main.swift                    # NSApp.accessory 진입점, --render-dashboard, --export-previews
├── AppDelegate.swift             # 서비스 와이어링
├── Stage.swift                   # 6단계 임계값 정의
├── StatusItemController.swift    # NSStatusItem + NSPopover + 우클릭 NSMenu
├── SpriteAnimator.swift          # 프레임 타이머, 속도 매핑, 진화 흔들림
│
│ === 캐릭터 스프라이트 ===
├── ColorSprite.swift             # 캐릭터 맵 DSL + NSColor 팔레트
├── SpriteBuilder.swift           # disc/circle/rect/outline 헬퍼
├── ColorSprites.swift            # 메뉴바 22x22 template (4프레임 꼬리 웨이브)
├── LargeSprites.swift            # 대시보드 48x48 다색 (음영 + 하이라이트)
├── BallSprites.swift             # 몬스터볼/슈퍼볼/하이퍼볼 16x16
├── PixelRenderer.swift           # lockFocus 기반 NSImage 렌더러
│
│ === 데이터 ===
├── TokenTracker.swift            # JSONL 증분 파서 + 주간 집계 + baseline
├── CostCalculator.swift          # 모델별 USD 단가
├── EvolutionFX.swift             # NSHapticFeedbackManager 3초 펄스
│
│ === 대시보드 UI (레트로 RPG 스타일) ===
├── DashboardView.swift           # 메인 팝오버 뷰 + PixelStatBox + PixelProjectRow
├── PixelPanel.swift              # 2px 다크 + 1px 골드 더블 보더 패널
├── StatBadge.swift               # 레거시 스탯 배지 (미사용)
│
│ === 기타 ===
├── MonsterQuotes.swift           # 6개 명대사
├── LaunchAtLogin.swift           # SMAppService 연동
└── PreviewExporter.swift         # --export-previews로 스프라이트 시트 PNG 저장
```

### 동작 원리

1. 시작 시 `~/.claude/projects/**/*.jsonl`을 전부 스캔, 각 파일의 offset을 저장
2. **5초마다 증분 파싱**, 새 줄에서 `message.usage.{input,output,cache_*}_tokens` 합산
3. JSONL의 `timestamp` 필드를 ISO8601로 파싱 → **프로젝트별 일별 버킷**에 기록
4. 증분은 **15초 rolling window**에 들어가 `tokens/min` 계산 (분당 정규화)
5. 총량이 다음 단계 임계값을 넘으면 `onEvolution` 콜백 → 햅틱 + 아이콘 흔들림
6. 상태는 `~/Library/Application Support/TokenMonster/state.json`에 영속화
7. 대시보드 주간 집계: 오늘 기준 지난 7일 동안의 day-key를 더해서 프로젝트별 합계 + 티어 분류

## Design Philosophy

- **100% 로컬** — 외부 서버 전송 없음
- **리소스 최소** — idle RAM < 50MB, 에셋 파일 0개 (픽셀 그리드를 전부 코드로 생성)
- **이중 해상도**:
  - 메뉴바: 22×22 template 실루엣 (RunCat 스타일, 다크/라이트 자동 반전)
  - 대시보드: 48×48 10색 팔레트 (음영 + 하이라이트 + 외곽선)
- **레트로 게임 UI**: 깊은 퍼플 배경 + 금색 더블 픽셀 프레임 + 모노스페이스 폰트

## Debug Flags

```bash
# 스프라이트 시트 내보내기
.build/debug/TokenMonster --export-previews
# → samples/previews/00_sheet.png + 각 프레임 PNG

# 대시보드 단독 렌더링
.build/debug/TokenMonster --render-dashboard
# → samples/dashboard.png
```

## Roadmap

- [ ] 더 많은 종 (water/grass/electric 등 속성 추가)
- [ ] 도감 (Pokédex) — 부화했던 몬스터 기록
- [ ] 진화 임계값 커스터마이징 (설정 창)
- [ ] Developer ID 서명 + 공증 (배포 시 경고 제거)
- [ ] Sparkle 자동 업데이트
- [ ] 외부 PNG 에셋 import 경로 (Aseprite로 그린 커스텀 스프라이트 지원)

## License

MIT — see [LICENSE](LICENSE)
