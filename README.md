# BubbleSky iOS Game Project

## 프로젝트 개요
BubbleSky는 SpriteKit 프레임워크를 사용하여 개발된 iOS 게임 프로젝트입니다.


## 중요 목표
- 현제 기획중이니 절대 소스코드 만드지 마세요.
- /docs/에 기획문서 작성
- /design/에 디자인 시안 작성
- /assets/에 게임 리소스 추가
- 게임 메커니즘 및 기능 정의

## 프로젝트 구조

### 주요 파일
- `GameScene.swift` - 메인 게임 씬 로직
- `GameViewController.swift` - 게임 뷰 컨트롤러
- `AppDelegate.swift` - 앱 생명주기 관리
- `GameScene.sks` - 게임 씬 시각적 설정
- `Actions.sks` - 게임 액션 정의

### 리소스
- `Assets.xcassets/` - 게임 이미지 및 컬러 리소스
- `Base.lproj/` - 스토리보드 및 지역화 파일

### 테스트
- `bubbleSkyTests/` - 유닛 테스트
- `bubbleSkyUITests/` - UI 테스트

## 개발 환경
- **언어**: Swift
- **프레임워크**: SpriteKit, GameplayKit
- **플랫폼**: iOS
- **개발 도구**: Xcode

## 게임 기능
현재 구현된 기능:
- 터치 인터랙션을 통한 스피닝 노드 생성
- 페이드인 애니메이션이 적용된 라벨 표시
- GameplayKit 엔티티 시스템 준비

## 코딩 규칙 및 가이드라인

### Swift 코딩 스타일
1. **네이밍 규칙**
   - 클래스: PascalCase (예: `GameScene`)
   - 변수/함수: camelCase (예: `lastUpdateTime`)
   - 상수: camelCase (예: `maxSpeed`)

2. **코드 구조**
   - 각 클래스는 기능별로 섹션을 나누어 주석으로 구분
   - 프라이빗 변수는 `private` 키워드 사용
   - 강제 언래핑보다는 옵셔널 바인딩 사용

### SpriteKit 개발 가이드라인
1. **씬 관리**
   - `sceneDidLoad()`에서 초기 설정 수행
   - 노드 계층 구조를 명확하게 설계
   - 메모리 누수 방지를 위한 적절한 노드 제거

2. **애니메이션**
   - `SKAction`을 활용한 부드러운 애니메이션
   - 시퀀스와 반복 액션의 적절한 조합 사용

3. **터치 처리**
   - `touchDown(atPoint:)` 패턴 활용
   - 터치 이벤트에 대한 적절한 피드백 제공

### 성능 최적화
1. **노드 관리**
   - 불필요한 노드는 즉시 제거
   - 노드 풀링 패턴 고려
   - 화면 밖 객체의 업데이트 최소화

2. **메모리 관리**
   - 강한 참조 순환 방지
   - 큰 텍스처의 적절한 해제
   - 백그라운드 진입 시 리소스 정리

### Git 사용 규칙
1. **커밋 메시지**
   - 영어 또는 한국어 일관성 유지
   - 현재형 동사 사용 (예: "Add bubble physics")
   - 기능 단위로 커밋 분리

2. **브랜치 전략**
   - `main`: 안정화된 릴리스 버전
   - `develop`: 개발 중인 기능들
   - `feature/기능명`: 새로운 기능 개발

## 빌드 및 실행
1. Xcode에서 `bubbleSky.xcodeproj` 열기
2. 시뮬레이터 또는 실제 기기 선택
3. Command + R로 빌드 및 실행

## 테스트
```bash
# 유닛 테스트 실행
Command + U

# UI 테스트 실행
Test Navigator에서 UI 테스트 선택 후 실행
```

## 다음 개발 계획
- [ ] 게임 메커니즘 구현
- [ ] 사운드 효과 추가
- [ ] 스코어 시스템 구현
- [ ] 레벨 시스템 추가
- [ ] 파티클 효과 개선

## 문제 해결
일반적인 문제와 해결책:
1. **시뮬레이터에서 터치가 작동하지 않는 경우**: 마우스 클릭으로 터치 시뮬레이션
2. **애니메이션이 끊기는 경우**: frame rate 확인 및 최적화
3. **메모리 경고**: 사용하지 않는 리소스 해제 확인

## 연락처
프로젝트 관련 문의: sang gi kim

---
*Last updated: September 5, 2025*
