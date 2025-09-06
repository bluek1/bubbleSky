# bubbleSky 프로젝트 코파일럿 지침서

## 프로젝트 개요
- **프로젝트명**: bubbleSky
- **플랫폼**: iOS
- **언어**: Swift
- **프레임워크**: SpriteKit, GameplayKit
- **개발환경**: Xcode
- **타겟**: iPhone/iPad 게임 앱

## 즁요 목표
- 현제 임시버젼 이니 그리픽 리소스 없이 작성
- /doc/ 디렉토리에 기획서, 아트워크, 사운드 등 리소스 관리
- /doc/development_task_list.md 에 개발 작업 목록 관리
- 나중에 리소스 추가 가능하도록 코드 작성

## 프로젝트 목표
수박 게임(Suika Game)과 유사한 메커니즘으로 천정을 향해 비눗방울을 쏘아서 합치는 퍼즐 게임 개발

## 코딩 스타일 가이드

### Swift 네이밍 규칙
- **클래스명**: PascalCase (예: `GameScene`, `BubbleNode`)
- **변수/함수명**: camelCase (예: `currentScore`, `updateBubblePosition()`)
- **상수명**: camelCase (예: `maxBubbleSize`, `gameSpeed`)
- **열거형**: PascalCase (예: `BubbleType`, `GameState`)

### SpriteKit 관련 규칙
- 노드 네이밍: `bubbleNode`, `backgroundNode`, `scoreLabel`
- 물리 바디 카테고리: `BubbleCategory`, `WallCategory`, `GroundCategory`
- 액션 네이밍: `moveUpAction`, `mergeAnimation`, `popEffect`

### 파일 구조 규칙
```
bubbleSky/
├── GameScene.swift          // 메인 게임 로직
├── BubbleNode.swift         // 비눗방울 노드 클래스
├── GameManager.swift        // 게임 상태 관리
├── PhysicsHelper.swift      // 물리 엔진 헬퍼
├── AudioManager.swift       // 사운드 관리
├── ParticleEffects.swift    // 파티클 효과
└── Extensions/
    ├── SKNode+Extensions.swift
    └── CGPoint+Extensions.swift
```


### 물리 시뮬레이션
- `SKPhysicsWorld` 사용
- 중력: `physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)`
- 충돌 감지: 같은 타입 비눗방울 합치기
- 벽면 바운스: 부드러운 반사

### 게임 플레이 흐름
1. 화면 하단에서 비눗방울 발사
2. 천정 방향으로 물리 시뮬레이션
3. 같은 크기 비눗방울 충돌 시 합치기
4. 더 큰 비눗방울로 진화
5. 게임 오버 조건: 비눗방울이 화면 상단 넘칠 때

## 시각적 디자인 가이드

### 색상 팔레트
```swift
struct BubbleColors {
    static let tiny = UIColor.systemBlue.withAlphaComponent(0.3)
    static let small = UIColor.systemGreen.withAlphaComponent(0.3)
    static let medium = UIColor.systemYellow.withAlphaComponent(0.3)
    static let large = UIColor.systemOrange.withAlphaComponent(0.3)
    static let huge = UIColor.systemRed.withAlphaComponent(0.3)
    static let giant = UIColor.systemPurple.withAlphaComponent(0.3)
    static let mega = UIColor.systemPink.withAlphaComponent(0.3)
}
```

### 배경 테마
- 푸른 하늘 그라데이션
- 떠다니는 구름 애니메이션
- 햇빛 파티클 효과
- 무지개 효과 (특별한 순간)

### 비눗방울 효과
- 반투명한 원형 노드
- 광택 효과 (하이라이트)
- 합쳐질 때 터지는 파티클
- 부드러운 바운스 애니메이션

## 성능 최적화 가이드

### 메모리 관리
```swift
// 비눗방울 풀링 시스템
class BubblePool {
    private var availableBubbles: [BubbleNode] = []
    
    func getBubble() -> BubbleNode {
        if availableBubbles.isEmpty {
            return BubbleNode()
        } else {
            return availableBubbles.removeLast()
        }
    }
    
    func returnBubble(_ bubble: BubbleNode) {
        bubble.removeFromParent()
        bubble.reset()
        availableBubbles.append(bubble)
    }
}
```

### 프레임률 최적화
- 불필요한 노드 업데이트 최소화
- 화면 밖 객체 컬링
- 파티클 시스템 최적화
- 텍스처 아틀라스 사용

## 사운드 시스템

### 필요한 사운드 효과
```swift
enum SoundEffect: String {
    case bubbleShoot = "bubble_shoot.wav"
    case bubbleMerge = "bubble_merge.wav"
    case bubblePop = "bubble_pop.wav"
    case backgroundMusic = "peaceful_sky.mp3"
    case gameOver = "game_over.wav"
}
```

## 테스트 가이드

### 단위 테스트
- 비눗방울 합치기 로직 테스트
- 점수 계산 로직 테스트
- 게임 상태 전환 테스트

### UI 테스트
- 터치 입력 테스트
- 게임 오버 시나리오 테스트
- 점수 저장/로드 테스트

## 개발 우선순위

### 물리 엔진 설정
```swift
// GameScene에서 물리 월드 설정
physicsWorld.contactDelegate = self
physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
```

이 지침서를 참고하여 일관성 있는 코드를 작성하고, 게임의 품질을 높이는 데 집중해주세요.

