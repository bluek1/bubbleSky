# bubbleSky 프로젝트 개발 작업 목록 (Task List)

## 📋 프로젝트 개요
- **기준일**: 2025년 9월 5일
- **현재 상태**: 기획 완료, 개발 준비 단계
- **개발 방식**: 단계별 점진적 개발 (4 Phase)
- **우선순위**: 핵심 게임플레이 → 시각 효과 → 게임 시스템 → 폴리싱

## 📚 참조 문서 목록
- `game_design_detailed.md` - 게임 전체 기획서
- `character_panning_launch_system.md` - 캐릭터 패닝 발사 시스템
- `curved_play_area_system.md` - 곡선형 플레이 영역 시스템
- `bubble_character_system.md` - 비눗방울 캐릭터 및 표정 시스템
- `time_weather_stage_system.md` - 시간대별 스테이지 및 날씨 시스템
- `special_effects_counter_system.md` - 특수 효과 및 카운터 시스템
- `bubble_launch_mechanics.md` - 비눗방울 발사 메커니즘

---

## 🎯 Phase 1: 핵심 게임플레이 구현 (Week 1-2)

### 1.1 프로젝트 기본 설정
- [ ] **1.1.1** Xcode 프로젝트 구조 확인 및 정리
  - 📚 참조: `.github/copilot-instructions.md` (파일 구조 규칙)
- [ ] **1.1.2** SpriteKit 기본 설정 완료 상태 확인
  - 📚 참조: `game_design_detailed.md` (게임 개요)
- [ ] **1.1.3** 물리 엔진 기본 설정 (`physicsWorld.gravity`, `contactDelegate`)
  - 📚 참조: `.github/copilot-instructions.md` (물리 엔진 설정)
- [ ] **1.1.4** 디버그 모드 설정 (`showsPhysics`, `showsFPS` 등)
  - 📚 참조: `game_design_detailed.md` (디버깅 도구)

### 1.2 비눗방울 시스템 구현
- [ ] **1.2.1** `BubbleType` enum 정의 (Tiny~Mega, 7단계)
  ```swift
  enum BubbleType: Int, CaseIterable {
      case tiny = 1, small = 2, medium = 3, large = 4
      case huge = 5, giant = 6, mega = 7
  }
  ```
  - 📚 참조: `character_panning_launch_system.md` (랜덤 시스템), `bubble_character_system.md` (캐릭터별 성격)
- [ ] **1.2.2** `BubbleNode` 클래스 생성 (`SKShapeNode` 기반)
  - 📚 참조: `game_design_detailed.md` (게임 메커니즘), `bubble_character_system.md` (표정 시스템)
- [ ] **1.2.3** 비눗방울 크기별 물리 속성 설정 (반지름, 질량, 탄성)
  - 📚 참조: `curved_play_area_system.md` (물리 시뮬레이션), `game_design_detailed.md` (게임 메커니즘)
- [ ] **1.2.4** 비눗방울 색상 시스템 구현 (7색 무지개 팔레트)
  - 📚 참조: `.github/copilot-instructions.md` (색상 팔레트), `bubble_character_system.md` (캐릭터별 색상)
- [ ] **1.2.5** 충돌 감지를 위한 `categoryBitMask`, `contactTestBitMask` 설정
  - 📚 참조: `game_design_detailed.md` (게임 메커니즘)

### 1.3 곡선형 플레이 영역 구현
- [ ] **1.3.1** 상단 곡선 경계 생성 (포물선/타원 형태)
  - 📚 참조: `curved_play_area_system.md` (곡선형 플레이 영역 디자인)
- [ ] **1.3.2** 곡선과 비눗방울 충돌 감지 시스템
  - 📚 참조: `curved_play_area_system.md` (곡선 충돌 처리)
- [ ] **1.3.3** 곡선 경사를 따른 굴러가기 물리 효과
  - 📚 참조: `curved_play_area_system.md` (물리 시뮬레이션 적용)
- [ ] **1.3.4** 좌우 직선 벽면 구현
  - 📚 참조: `curved_play_area_system.md` (곡선형 플레이 영역 디자인)
- [ ] **1.3.5** 하단 발사 영역 설정
  - 📚 참조: `character_panning_launch_system.md` (패닝 조작 시스템)

### 1.4 캐릭터 패닝 발사 시스템 구현
- [ ] **1.4.1** 기본 발사 캐릭터 노드 생성 및 배치 (화면 하단 중앙)
  - 📚 참조: `character_panning_launch_system.md` (캐릭터 시스템)
- [ ] **1.4.2** 랜덤 비눗방울 생성 시스템 구현
  - Tiny(30%), Small(30%), Medium(25%), Large(10%), Huge(5%)
  - Giant, Mega는 생성 안됨
  - 📚 참조: `character_panning_launch_system.md` (확률 분포)
- [ ] **1.4.3** 패닝 제스처 인식 및 처리 (`UIPanGestureRecognizer`)
  - 📚 참조: `character_panning_launch_system.md` (패닝 조작 시스템), `bubble_launch_mechanics.md` (발사 방법)
- [ ] **1.4.4** 비눗방울 좌우 이동 제한 (화면 너비 90% 내)
  - 📚 참조: `character_panning_launch_system.md` (이동 제한)
- [ ] **1.4.5** 터치 해제 시 수직 발사 메커니즘
  - 📚 참조: `character_panning_launch_system.md` (게임 플레이 흐름)
- [ ] **1.4.6** 크기별 초기 속도 차등 적용
  - 📚 참조: `character_panning_launch_system.md` (물리 시뮬레이션)

### 1.5 합치기(Merge) 로직 구현
- [ ] **1.5.1** 같은 크기 비눗방울 충돌 감지 (`didBegin(_:)`)
  - 📚 참조: `game_design_detailed.md` (게임 메커니즘)
- [ ] **1.5.2** 충돌한 두 비눗방울 제거 로직
  - 📚 참조: `game_design_detailed.md` (게임 플레이 흐름)
- [ ] **1.5.3** 한 단계 큰 비눗방울 생성 로직
  - 📚 참조: `bubble_character_system.md` (비눗방울 크기별 특징)
- [ ] **1.5.4** Mega+Mega 특수 처리 (소멸 효과)
  - 📚 참조: `special_effects_counter_system.md` (Mega+Mega 특수 효과 시스템)
- [ ] **1.5.5** 연속 방지 시스템 (같은 크기 3번 연속 제한)
  - 📚 참조: `character_panning_launch_system.md` (연속 방지 시스템)

### 1.6 게임 오버 시스템
- [ ] **1.6.1** 화면 상단 게임 오버 라인 설정
  - 📚 참조: `game_design_detailed.md` (게임 플레이 흐름)
- [ ] **1.6.2** 비눗방울이 라인을 넘었을 때 감지
  - 📚 참조: `curved_play_area_system.md` (곡선형 플레이 영역)
- [ ] **1.6.3** 일정 시간 유지 시 게임 오버 처리
  - 📚 참조: `game_design_detailed.md` (게임 플레이 흐름)
- [ ] **1.6.4** 게임 재시작 로직
  - 📚 참조: `game_design_detailed.md` (UI 구성)

---

## 🎨 Phase 2: 시각 효과 및 사운드 (Week 3)

### 2.1 캐릭터 애니메이션 시스템
- [ ] **2.1.1** 기본 캐릭터 스프라이트 제작/적용
  - 📚 참조: `character_panning_launch_system.md` (캐릭터 종류 및 특성)
- [ ] **2.1.2** 대기 상태 애니메이션 (위아래 떠다니기)
  - 📚 참조: `character_panning_launch_system.md` (캐릭터별 애니메이션)
- [ ] **2.1.3** 비눗방울 생성 애니메이션 (입으로 불기)
  - 📚 참조: `character_panning_launch_system.md` (게임 플레이 흐름)
- [ ] **2.1.4** 심호흡 준비 모션
  - 📚 참조: `character_panning_launch_system.md` (캐릭터별 애니메이션)
- [ ] **2.1.5** 발사 후 만족 표정 애니메이션
  - 📚 참조: `bubble_character_system.md` (감정 상호작용)

### 2.2 비눗방울 표정 및 상호작용 효과
- [ ] **2.2.1** 캐릭터별 기본 표정 구현 (7단계별 성격)
  - 📚 참조: `bubble_character_system.md` (비눗방울 캐릭터별 성격과 표정)
- [ ] **2.2.2** 상황별 표정 변화 시스템
  - 대기: 기본 표정 + 눈 깜빡임
  - 충돌: 놀란 표정 (0.2초)
  - 합체: 기대감 → 기쁨 표정
  - 📚 참조: `bubble_character_system.md` (표정 변화 시스템)
- [ ] **2.2.3** 비눗방울 변형 효과 (충돌 시 찌그러짐)
  - 📚 참조: `game_design_detailed.md` (상호작용 효과)
- [ ] **2.2.4** 표면 장력 시뮬레이션 효과
  - 📚 참조: `game_design_detailed.md` (물리적 상호작용 효과)
- [ ] **2.2.5** 분리 시 탄성 복원 애니메이션
  - 📚 참조: `game_design_detailed.md` (상호작용 효과)

### 2.3 동적 스테이지 시스템
- [ ] **2.3.1** 시간 감지 시스템 (`Date()` 활용)
  - 📚 참조: `time_weather_stage_system.md` (시간/날씨 연동 시스템)
- [ ] **2.3.2** 아침/점심/저녁 배경 자동 전환
  - 📚 참조: `time_weather_stage_system.md` (시간대별 스테이지 시스템)
- [ ] **2.3.3** 시간대별 색상 팔레트 적용
  - 📚 참조: `time_weather_stage_system.md` (시간대별 스테이지)
- [ ] **2.3.4** 날씨 효과 파티클 시스템 (비, 눈, 바람)
  - 📚 참조: `time_weather_stage_system.md` (날씨 시스템)
- [ ] **2.3.5** 구름 애니메이션 및 햇빛 효과
  - 📚 참조: `time_weather_stage_system.md` (시간대별 특수 효과)

### 2.4 특수 효과 시스템
- [ ] **2.4.1** 비눗방울 합체 시 터지는 파티클 효과
  - 📚 참조: `game_design_detailed.md` (특수 효과)
- [ ] **2.4.2** Mega+Mega 소멸 시 무지개 효과 구현
  - 📚 참조: `special_effects_counter_system.md` (무지개 소멸 효과)
- [ ] **2.4.3** 화면 전체 반투명 무지개 오버레이
  - 📚 참조: `special_effects_counter_system.md` (무지개 효과 GUI)
- [ ] **2.4.4** 무지개 파동 애니메이션 (중앙→외곽)
  - 📚 참조: `special_effects_counter_system.md` (소멸 애니메이션)
- [ ] **2.4.5** 크기별 발사/착지 파티클 효과
  - 📚 참조: `bubble_launch_mechanics.md` (특수 발사 효과)

### 2.5 사운드 시스템
- [ ] **2.5.1** 기본 효과음 제작/수집
  - 비눗방울 발사: "퐁!"
  - 합체: "뿅!"
  - Mega 소멸: 신비로운 종소리
  - 📚 참조: `game_design_detailed.md` (사운드 디자인), `special_effects_counter_system.md` (사운드 효과)
- [ ] **2.5.2** 시간대별 배경 음악 시스템
  - 📚 참조: `time_weather_stage_system.md` (시간대별 캐릭터 반응)
- [ ] **2.5.3** 날씨별 환경음 (빗소리, 바람소리)
  - 📚 참조: `time_weather_stage_system.md` (날씨 시스템)
- [ ] **2.5.4** `AudioManager` 클래스 구현
  - 📚 참조: `.github/copilot-instructions.md` (사운드 시스템)
- [ ] **2.5.5** 음량 조절 및 음소거 기능
  - 📚 참조: `bubble_character_system.md` (사운드와 표정 연동)

---

## 🎮 Phase 3: 게임 시스템 및 UI (Week 4)

### 3.1 점수 및 카운터 시스템
- [ ] **3.1.1** 기본 점수 계산 로직 (크기별 차등)
  - 📚 참조: `game_design_detailed.md` (점수 시스템)
- [ ] **3.1.2** 연속 합체(콤보) 보너스 시스템
  - 📚 참조: `game_design_detailed.md` (점수 시스템)
- [ ] **3.1.3** 무지개 카운터 시스템 구현
  - 📚 참조: `special_effects_counter_system.md` (카운터 시스템)
- [ ] **3.1.4** 카운터 증가 애니메이션 (펄스 효과)
  - 📚 참조: `special_effects_counter_system.md` (카운터 디스플레이)
- [ ] **3.1.5** 최고 점수 기록 및 저장
  - 📚 참조: `game_design_detailed.md` (UI 구성)

### 3.2 사용자 인터페이스 (UI)
- [ ] **3.2.1** 상단 점수 표시 레이블
  - 📚 참조: `game_design_detailed.md` (UI 구성)
- [ ] **3.2.2** 무지개 카운터 UI (`🌈 x 숫자`)
  - 📚 참조: `special_effects_counter_system.md` (카운터 디스플레이)
- [ ] **3.2.3** 다음 비눗방울 미리보기 UI
  - 📚 참조: `character_panning_launch_system.md` (UI/UX 디자인)
- [ ] **3.2.4** 패닝 시 가이드라인 시스템
  - 세로 가이드라인
  - 착지 예상 영역 하이라이트
  - 최적 위치 색상 변화
  - 📚 참조: `character_panning_launch_system.md` (시각적 가이드), `bubble_launch_mechanics.md` (시각적 가이드 시스템)
- [ ] **3.2.5** 게임 오버 화면 UI
  - 최종 점수 표시
  - 최고 점수 표시
  - 다시 시작 버튼
  - 📚 참조: `game_design_detailed.md` (UI 구성)

### 3.3 데이터 저장 시스템
- [ ] **3.3.1** `UserDefaults`를 이용한 데이터 저장
  - 📚 참조: `special_effects_counter_system.md` (카운터 데이터 저장)
- [ ] **3.3.2** 최고 점수 저장/로드
  - 📚 참조: `game_design_detailed.md` (리소스 관리)
- [ ] **3.3.3** 무지개 카운터 영구 저장
  - 📚 참조: `special_effects_counter_system.md` (카운터 데이터 저장)
- [ ] **3.3.4** 게임 설정 저장 (음량, 진동 등)
  - 📚 참조: `time_weather_stage_system.md` (수동 설정 옵션)
- [ ] **3.3.5** 업적 달성 상태 저장
  - 📚 참조: `special_effects_counter_system.md` (업적 시스템)

### 3.4 보상 및 업적 시스템
- [ ] **3.4.1** 무지개 카운터 마일스톤 시스템
  - 5회: Medium 이상 5발 보장
  - 20회: 레인보우 모드 (5분간)
  - 100회: 프리즘 캐릭터 해제
  - 📚 참조: `special_effects_counter_system.md` (카운터 특전 시스템)
- [ ] **3.4.2** 업적 팝업 시스템
  - 📚 참조: `special_effects_counter_system.md` (마일스톤 알림)
- [ ] **3.4.3** 레인보우 모드 구현 (점수 2배, 특별 BGM)
  - 📚 참조: `special_effects_counter_system.md` (레인보우 모드)
- [ ] **3.4.4** 특별 캐릭터 해제 시스템
  - 📚 참조: `character_panning_launch_system.md` (특별 캐릭터들)

### 3.5 시각적 가이드 시스템
- [ ] **3.5.1** 패닝 중 이동 트레일 효과
  - 📚 참조: `character_panning_launch_system.md` (시각적 가이드)
- [ ] **3.5.2** 그림자 표시 시스템
  - 📚 참조: `character_panning_launch_system.md` (시각적 피드백)
- [ ] **3.5.3** 터치 피드백 (비주얼, 햅틱)
  - 📚 참조: `character_panning_launch_system.md` (터치 피드백)
- [ ] **3.5.4** 최적 위치 표시 시스템
  - 📚 참조: `bubble_launch_mechanics.md` (조작 보조 기능)
- [ ] **3.5.5** 스냅 기능 (경계 근처 자동 조정)
  - 📚 참조: `character_panning_launch_system.md` (이동 제한)

---

## ✨ Phase 4: 폴리싱 및 고급 기능 (Week 5)

### 4.1 성능 최적화
- [ ] **4.1.1** `BubblePool` 오브젝트 풀링 시스템 구현
  - 📚 참조: `.github/copilot-instructions.md` (메모리 관리)
- [ ] **4.1.2** 화면 밖 객체 컬링 시스템
  - 📚 참조: `.github/copilot-instructions.md` (프레임률 최적화)
- [ ] **4.1.3** 파티클 시스템 최적화
  - 📚 참조: `special_effects_counter_system.md` (성능 최적화)
- [ ] **4.1.4** 텍스처 아틀라스 적용
  - 📚 참조: `.github/copilot-instructions.md` (프레임률 최적화)
- [ ] **4.1.5** 메모리 사용량 모니터링 및 최적화
  - 📚 참조: `special_effects_counter_system.md` (성능 최적화)

### 4.2 고급 게임플레이 기능
- [ ] **4.2.1** 특별 캐릭터 시스템 구현
  - 꼬마 드래곤 (작은 크기 전문)
  - 마법사 토끼 (중간 크기 특화)
  - 고래 캐릭터 (큰 크기 전문)
  - 📚 참조: `character_panning_launch_system.md` (특별 캐릭터들)
- [ ] **4.2.2** 캐릭터 스킬 시스템
  - 크기 선택
  - 2연발
  - 거대화
  - 📚 참조: `character_panning_launch_system.md` (특수 기능)
- [ ] **4.2.3** 파워업 아이템 시스템
  - 📚 참조: `character_panning_launch_system.md` (파워업 아이템)
- [ ] **4.2.4** 난이도별 곡선 형태 변경
  - 📚 참조: `curved_play_area_system.md` (게임 모드별 곡선 적용)

### 4.3 사용자 경험 개선
- [ ] **4.3.1** 햅틱 피드백 시스템 (`UIImpactFeedbackGenerator`)
  - 📚 참조: `bubble_launch_mechanics.md` (접근성 기능)
- [ ] **4.3.2** 접근성 기능 (VoiceOver 지원)
  - 📚 참조: `bubble_launch_mechanics.md` (접근성 기능)
- [ ] **4.3.3** 다양한 화면 크기 대응 (iPhone/iPad)
  - 📚 참조: `bubble_launch_mechanics.md` (기술적 구현 고려사항)
- [ ] **4.3.4** 60FPS 보장을 위한 프레임률 최적화
  - 📚 참조: `bubble_launch_mechanics.md` (사용자 인터페이스)
- [ ] **4.3.5** 배터리 사용량 최적화
  - 📚 참조: `special_effects_counter_system.md` (성능 최적화)

### 4.4 게임 밸런스 조정
- [ ] **4.4.1** 비눗방울 생성 확률 밸런스 테스트
  - 📚 참조: `character_panning_launch_system.md` (확률 분포), `special_effects_counter_system.md` (밸런스 고려사항)
- [ ] **4.4.2** 점수 시스템 밸런스 조정
  - 📚 참조: `special_effects_counter_system.md` (보상 가치)
- [ ] **4.4.3** 게임 난이도 곡선 조정
  - 📚 참조: `bubble_launch_mechanics.md` (플레이어 학습 곡선)
- [ ] **4.4.4** 무지개 카운터 마일스톤 재조정
  - 📚 참조: `special_effects_counter_system.md` (밸런스 고려사항)
- [ ] **4.4.5** 물리 파라미터 미세 조정
  - 📚 참조: `curved_play_area_system.md` (밸런스 조정)

### 4.5 품질 보증 및 테스트
- [ ] **4.5.1** 단위 테스트 작성
  - 비눗방울 합치기 로직 테스트
  - 점수 계산 로직 테스트
  - 데이터 저장/로드 테스트
  - 📚 참조: `.github/copilot-instructions.md` (테스트 가이드)
- [ ] **4.5.2** UI 테스트 작성
  - 터치 입력 테스트
  - 게임 오버 시나리오 테스트
  - 📚 참조: `.github/copilot-instructions.md` (테스트 가이드)
- [ ] **4.5.3** 메모리 누수 테스트
  - 📚 참조: `special_effects_counter_system.md` (기술적 구현)
- [ ] **4.5.4** 다양한 기기에서의 성능 테스트
  - 📚 참조: `time_weather_stage_system.md` (기술적 구현 방안)
- [ ] **4.5.5** 버그 수정 및 안정성 개선
  - 📚 참조: `.github/copilot-instructions.md` (개발 우선순위)

---

## 📝 추가 고려사항

### 개발 도구 및 리소스
- [ ] **Asset 준비**: 캐릭터 스프라이트, 비눗방울 텍스처, 파티클 이미지
- [ ] **사운드 리소스**: 효과음, 배경음악 파일
- [ ] **색상 팔레트**: 7단계 무지개 색상 정의
- [ ] **애니메이션 시퀀스**: 캐릭터 및 비눗방울 애니메이션

### 기술적 도전 과제
- [ ] **곡선 충돌 감지**: 정확한 곡선-원 충돌 알고리즘
- [ ] **물리 시뮬레이션**: 자연스러운 굴러가기 효과
- [ ] **실시간 변형**: 비눗방울 찌그러짐 효과
- [ ] **파티클 시스템**: 화려한 무지개 효과

### 향후 확장 계획
- [ ] **계절 시스템**: 봄/여름/가을/겨울 테마
- [ ] **멀티플레이어**: 친구와 점수 경쟁
- [ ] **커스터마이징**: 캐릭터 및 테마 꾸미기
- [ ] **클라우드 저장**: iCloud를 통한 진행상황 동기화

---

## 🎯 마일스톤 일정

### Week 1 (9/5 - 9/12): Phase 1.1 ~ 1.3
- 기본 설정 및 비눗방울 시스템 완성
- 곡선 플레이 영역 구현

### Week 2 (9/12 - 9/19): Phase 1.4 ~ 1.6
- 패닝 발사 시스템 완성
- 기본 게임플레이 동작 확인

### Week 3 (9/19 - 9/26): Phase 2 전체
- 모든 시각 효과 및 사운드 완성
- 완전한 게임 경험 제공

### Week 4 (9/26 - 10/3): Phase 3 전체
- UI 및 게임 시스템 완성
- 데이터 저장 및 보상 시스템

### Week 5 (10/3 - 10/10): Phase 4 전체
- 최적화 및 폴리싱
- 최종 테스트 및 배포 준비

---

이 작업 목록을 따라 단계별로 개발을 진행하면 완성도 높은 bubbleSky 게임을 체계적으로 구현할 수 있습니다.
