# 🥚 Token Monster

Claude Code 토큰을 먹이 삼아 자라는 macOS 메뉴바 펫.
다마고치 × 포켓몬 컨셉.

![status](https://img.shields.io/badge/status-alpha-orange)
![macOS](https://img.shields.io/badge/macOS-13%2B%20arm64-blue)
![license](https://img.shields.io/badge/license-MIT-green)

## What it does

- 메뉴바에 픽셀 몬스터 상주 (Template image, 다크/라이트 자동 대응)
- `~/.claude/projects/*.jsonl` 증분 파싱으로 토큰 실시간 추적
- 토큰 사용량에 따라 **6단계로 진화** (알 → 궁극체)
- 토큰 사용 속도에 따라 애니메이션 자동 가속
- 프로젝트별 누적 토큰 드롭다운
- 진화 시 **햅틱 피드백** (Force Touch 트랙패드) + 아이콘 플래시

## Evolution Stages

| 단계 | 이름 | 임계값 |
|---|---|---|
| 1 | 알 | 0 |
| 2 | Flamkin (유년기) | 30,000,000 |
| 3 | Flamon (성장기) | 150,000,000 |
| 4 | Blazon (성숙기) | 500,000,000 |
| 5 | Infernon (완전체) | 1,500,000,000 |
| 6 | Phoenignis (궁극체) | 4,000,000,000 |

임계값은 앱 설치 시점의 누적 토큰을 baseline(0)으로 삼고, 그 이후에 사용한 토큰만 카운트합니다.

> 다음 진화까지 얼마나 남았는지는 일부러 공개하지 않습니다. 궁금증이 재미입니다.

## Requirements

- macOS 13+ (Apple Silicon, arm64)
- Claude Code 설치 (`~/.claude/projects/` 경로가 존재해야 토큰 추적)
- Swift 5.9+ (빌드 시)

## Build & Run

```bash
git clone https://github.com/stronghuni/tokenmonster.git
cd tokenmonster
swift build -c release
.build/release/TokenMonster &
```

메뉴바 우상단에 흔들거리는 알이 나타납니다. 클릭하면 현재 단계, 누적 토큰, 속도, 프로젝트별 내역을 볼 수 있습니다.

종료: 메뉴의 "종료" 또는 `pkill -f TokenMonster`

## Architecture

```
Sources/TokenMonster/
├── main.swift               # NSApplication.accessory 진입점
├── AppDelegate.swift        # 서비스 와이어링
├── Stage.swift              # 6단계 임계값 정의
├── PixelSprites.swift       # 22x22 픽셀 그리드 (코드 런타임 생성)
├── PixelRenderer.swift      # CGContext → NSImage template
├── SpriteAnimator.swift     # 프레임 타이머, 속도 매핑, 진화 플래시
├── StatusItemController.swift  # NSStatusItem + NSMenu
├── TokenTracker.swift       # JSONL 증분 파서 + baseline + rolling TPM
└── EvolutionFX.swift        # 햅틱 피드백
```

### 동작 원리

1. 시작 시 `~/.claude/projects/**/*.jsonl`을 전부 스캔, 각 파일의 offset을 저장
2. 이후 10초마다 증분 파싱, 새 줄에서 `message.usage.{input,output,cache_*}_tokens` 합산
3. 증분은 1분 rolling window에 들어가 `tokens/min`을 계산
4. 총량이 다음 단계 임계값을 넘으면 onEvolution 콜백 → 햅틱 + 아이콘 플래시
5. 상태는 `~/Library/Application Support/TokenMonster/state.json`에 영속화

## Design philosophy

- **100% 로컬** — 외부 서버 전송 없음
- **리소스 최소** — idle RAM < 50MB, 에셋 파일 0개 (픽셀 그리드를 코드로 생성)
- **단색 실루엣** — Digimon V-Pet 스타일, template image로 다크/라이트 자동 반전

## Roadmap

- [ ] 더 많은 종 (water/grass/electric 등 속성 추가)
- [ ] 상세 대시보드 윈도우
- [ ] 도감 (Pokédex)
- [ ] 자동 실행 (launch at login)
- [ ] DMG 배포 + 코드 서명 + 공증
- [ ] Sparkle 자동 업데이트

## License

MIT — see [LICENSE](LICENSE)
