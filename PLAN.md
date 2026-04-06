# Token Monster — Development Plan

## Vision
Claude Code 토큰 사용량을 먹이 삼아 자라는 macOS 메뉴바 펫. 다마고치 × 포켓몬 컨셉.

## Scope — v0.1 (MVP 공개 가능 버전)

### Must-have
- [x] 메뉴바 상주 (.accessory)
- [x] JSONL 증분 파서 + baseline 기반 성장
- [x] 프로젝트별 토큰 집계
- [x] 토큰 속도 기반 애니메이션 가속
- [x] 알 흔들림 idle 애니메이션
- [x] "새 알 받기" 리셋
- [ ] **6단계 × 2프레임 스프라이트 (fire 속성 "Flamimon" 라인)**
- [ ] **진화 감지 + 햅틱 피드백 + 상태 아이콘 플래시**
- [ ] 현재 스테이지 영속화 (state.json)
- [ ] 상세 대시보드 윈도우 (프로젝트별 차트)
- [ ] 자동 실행 (ServiceManagement)
- [ ] 다크/라이트 메뉴바 대응 (template image — 이미 적용됨)

### Should-have
- [ ] 설정 창 (토글, 기준값)
- [ ] 종료 시 상태 저장
- [ ] macOS 네이티브 알림 (진화 시)

### Release prep
- [ ] LICENSE (MIT)
- [ ] README.md
- [ ] .gitignore
- [ ] Git init + 초기 커밋
- [ ] DMG 빌드 스크립트
- [ ] Developer ID 서명 + 공증 (문서화)

## Character Design — Flamimon Line (Fire attribute)

22x22 pixel, template (흰 실루엣). 참고 레퍼런스:
- Pokemon Gen 1 mini sprites (3x3 ~ 22x22 한계에서의 실루엣 원리)
- Digimon Virtual Pet (16x16 원형 — 세대별 실루엣 대비)
- Tamagotchi (신체 비율 강조로 성장 표현)
- Dragon Warrior Monsters (작은 크기에서도 두드러지는 턱/뿔/꼬리)

### 디자인 원칙 (template 단색 제약)
1. **실루엣 우선** — 세부보다 외곽선이 전부를 결정
2. **성장 = 수직 확장** — 단계가 올라갈수록 캔버스 세로를 더 채움
3. **특징부 점진적 추가** — tuft → horns → mane → wings → aura
4. **1~2px 디테일만** — 더 많으면 22x22에서 뭉개짐
5. **비대칭으로 생명감** — 완전 대칭은 로봇스러움

### 6 Stages

| Stage | Name | Silhouette Key | Canvas Usage |
|---|---|---|---|
| 1. Egg | — | 타원, 왼쪽 기울임 (wobble) | y 3-19 |
| 2. Baby | Flamkin | 둥근 몸통 + 머리 tuft 1개, 껍질 흔적 | y 2-19 |
| 3. Child | Flamon | 이족보행, 뿔 tuft 2개, 팔 등장 | y 2-20 |
| 4. Teen | Blazon | 갈기 확장, 꼬리, 뿔 뚜렷 | y 1-20 |
| 5. Adult | Infernon | 등에 날개 스텁, 어깨 망토 불꽃 | y 0-21 |
| 6. Ultimate | Phoenignis | 반쯤 펼친 날개, 불꽃 관 | y 0-21 (전폭) |

### Animation
- 각 스테이지는 idle 2프레임 (A/B, 0.4s 주기)
- Frame B는 1px 바운스 + 눈 깜빡임 + 불꽃 미세 변형
- 토큰 속도 → 프레임 간격 1.0x~6.0x 가속

## Evolution Feedback
1. 총량이 다음 임계값 돌파 감지
2. `NSHapticFeedbackManager.perform(.levelChange)` × 3 (200ms 간격)
3. 상태아이콘 1초간 플래시 (흰 실루엣 → 반전 → 원복)
4. 메뉴 힌트 문구가 "... 뭔가 변했다!"로 잠시 교체
5. 도감(나중에) + 알림(나중에)

## 배포
- Swift Package → `swift build -c release` → arm64 binary
- `TokenMonster.app` 번들 수동 구성 (Contents/MacOS/ + Info.plist with LSUIElement)
- Developer ID Application 인증서로 `codesign`
- `xcrun notarytool submit` → staple
- `create-dmg` 또는 `hdiutil`로 DMG 생성
- GitHub Releases 업로드

## Not in v0.1
- 여러 종(물/풀/전기 등) — 1종만
- 도감 창
- 다국어
- 자동 업데이트(Sparkle)
- 비용(USD) 표시 — 토큰만
