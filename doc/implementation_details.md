# bubbleSky 구현 세부 사항

**작성일**: 2025년 9월 6일  
**목적**: 개발된 기능의 기술적 구현 상세 설명

---

## 📁 프로젝트 파일 구조

```
bubbleSky/
├── bubbleSky/                          # 메인 소스 코드 (4,396 라인)
│   ├── GameScene.swift                 # 1,111 라인 - 메인 게임 로직
│   ├── GameManager.swift               #   226 라인 - 게임 상태 관리
│   ├── GameViewController.swift        #    48 라인 - 뷰 컨트롤러
│   ├── AppDelegate.swift               #    40 라인 - 앱 델리게이트
│   │
│   ├── Models/                         # 1,436 라인 - 게임 오브젝트
│   │   ├── BubbleNode.swift            #   932 라인 - 비눗방울 노드 (표정 포함)
│   │   ├── BubbleType.swift            #   112 라인 - 비눗방울 타입 정의
│   │   ├── CharacterNode.swift         #   381 라인 - 캐릭터 노드 (애니메이션)
│   │   └── PhysicsCategory.swift       #    11 라인 - 물리 카테고리
│   │
│   ├── Extensions/                     # 613 라인 - 유틸리티 확장
│   │   ├── SKNode+Extensions.swift     #   269 라인 - SpriteKit 노드 확장
│   │   └── CGPoint+Extensions.swift    #   344 라인 - 좌표 계산 확장
│   │
│   ├── PhysicsHelper.swift             # 254 라인 - 물리 엔진 헬퍼
│   ├── AudioManager.swift              # 274 라인 - 사운드 관리 (프레임워크)
│   ├── ParticleEffects.swift           # 394 라인 - 파티클 효과 (프레임워크)
│   │
│   ├── Assets.xcassets/                # 리소스
│   ├── Base.lproj/                     # 스토리보드
│   ├── GameScene.sks                   # 씬 에디터 파일
│   └── Actions.sks                     # 액션 에디터 파일
│
├── doc/                                # 기획 및 문서 (10개 파일)
│   ├── development_task_list.md        # 작업 목록 및 진행 상황
│   ├── game_design_detailed.md         # 게임 전체 기획서
│   ├── bubble_character_system.md      # 캐릭터 및 표정 시스템
│   ├── character_panning_launch_system.md
│   ├── curved_play_area_system.md
│   ├── time_weather_stage_system.md
│   ├── special_effects_counter_system.md
│   ├── bubble_launch_mechanics.md
│   ├── bubble_character_system_updates.md
│   ├── summer_theme_update.md
│   ├── progress_investigation_report.md  # 진행 상황 조사 보고서
│   └── implementation_details.md         # 현재 파일
│
├── bubbleSkyTests/                     # 유닛 테스트
└── bubbleSkyUITests/                   # UI 테스트
```

---

## 🎮 핵심 클래스 구현 상세

### 1. GameScene.swift (1,111 라인)

**역할**: 메인 게임 화면 및 로직 관리

#### 주요 속성
```swift
// 게임 매니저
private let gameManager = GameManager.shared

// 게임 오브젝트
private var currentBubble: BubbleNode?          // 발사 준비 중인 비눗방울
private var launchCharacter: CharacterNode?     // 발사 캐릭터
private var topCurvedBoundary: SKShapeNode?     // 곡선형 상단 경계
private var leftWall/rightWall: SKNode?         // 좌우 벽면

// UI 요소
private var scoreLabel: SKLabelNode?            // 점수 표시
private var timeLabel: SKLabelNode?             // 시간 표시
private var levelLabel: SKLabelNode?            // 레벨 표시
private var bestScoreLabel: SKLabelNode?        // 최고점수 표시
private var bubbleCountLabel: SKLabelNode?      // 방울 개수 표시
```

#### 주요 메서드
- `setupSummerBackground()`: 여름 테마 배경 설정
- `setupPhysicsWorld()`: 물리 엔진 초기화
- `setupPlayArea()`: 곡선형 플레이 영역 생성
- `setupUI()`: 정보 패널 UI 구성
- `setupLaunchSystem()`: 발사 시스템 초기화
- `touchesBegan/Moved/Ended()`: 터치 입력 처리
- `didBegin(_ contact:)`: 충돌 감지 및 합체 로직
- `update(_ currentTime:)`: 매 프레임 업데이트

#### 곡선형 경계 구현
```swift
// 포물선 형태의 상단 경계
let path = CGMutablePath()
for i in 0...segments {
    let t = CGFloat(i) / CGFloat(segments)
    let x = -width/2 + width * t
    let y = topY - curveDepth * (1 - pow(2*t - 1, 2))  // 포물선 공식
    // ...
}
```

---

### 2. BubbleNode.swift (932 라인)

**역할**: 비눗방울 오브젝트 및 표정 시스템

#### 표정 시스템 구조
```swift
enum ExpressionType {
    case neutral, happy, surprised, excited, worried, 
         confused, laughing, sad, angry, sleepy, 
         winking, halfClosed
}

// 얼굴 구성 요소
private var face: SKShapeNode?          // 얼굴 컨테이너
private var leftEye: SKShapeNode?       // 왼쪽 눈 (흰자)
private var rightEye: SKShapeNode?      // 오른쪽 눈 (흰자)
private var leftPupil: SKShapeNode?     // 왼쪽 동공
private var rightPupil: SKShapeNode?    // 오른쪽 동공
private var mouth: SKShapeNode?         // 입
private var highlight: SKShapeNode?     // 하이라이트
```

#### 주요 메서드
- `setupFacialExpression()`: 얼굴 요소 초기화
- `updateExpression(_ type:)`: 표정 변경
- `updatePupilDirection()`: 동적 눈동자 방향 계산
- `startBlinkingAnimation()`: 눈 깜빡임 애니메이션
- `showHappyExpression()`: 기쁨 표정
- `showExcitedExpression()`: 흥분 표정
- `showSurprisedExpression()`: 놀람 표정

#### 눈 깜빡임 구현
```swift
private func startBlinkingAnimation() {
    let randomDelay = TimeInterval.random(in: 2...8)
    let wait = SKAction.wait(forDuration: randomDelay)
    
    let blink = SKAction.sequence([
        SKAction.scaleY(to: 0.1, duration: 0.1),  // 눈 감기
        SKAction.wait(forDuration: 0.1),
        SKAction.scaleY(to: 1.0, duration: 0.1)   // 눈 뜨기
    ])
    
    let blinkSequence = SKAction.sequence([wait, blink])
    let repeatBlink = SKAction.repeatForever(blinkSequence)
    
    leftEye?.run(repeatBlink)
    rightEye?.run(repeatBlink)
}
```

#### 동적 눈동자 추적
```swift
func updatePupilDirection() {
    // 반경 200pt 내의 더 큰 비눗방울 찾기
    let nearbyBubbles = scene?.children
        .compactMap { $0 as? BubbleNode }
        .filter { bubble in
            bubble != self &&
            bubble.bubbleType.rawValue > self.bubbleType.rawValue &&
            distance(to: bubble.position) < 200
        }
    
    if let closest = nearbyBubbles.min(by: { 
        distance(to: $0.position) < distance(to: $1.position) 
    }) {
        // 방향 계산 및 눈동자 이동 애니메이션
        let angle = atan2(direction.y, direction.x)
        let moveDistance = radius * 0.15
        // ...
    }
}
```

---

### 3. CharacterNode.swift (381 라인)

**역할**: 비눗방울 요정 캐릭터 및 애니메이션

#### 캐릭터 구조
```swift
private var body: SKShapeNode?          // 몸체 (그라데이션)
private var face: SKShapeNode?          // 얼굴
private var leftEye: SKShapeNode?       // 왼쪽 눈
private var rightEye: SKShapeNode?      // 오른쪽 눈
private var mouth: SKShapeNode?         // 입
private var leftWing: SKShapeNode?      // 왼쪽 날개
private var rightWing: SKShapeNode?     // 오른쪽 날개
private var glowEffect: SKShapeNode?    // 광채 효과
```

#### 주요 애니메이션
1. **대기 애니메이션** (Idle)
```swift
private func startIdleAnimation() {
    // 위아래 떠다니기
    let floatUp = SKAction.moveBy(x: 0, y: 15, duration: 1.5)
    floatUp.timingMode = .easeInEaseOut
    let floatDown = floatUp.reversed()
    let floatSequence = SKAction.sequence([floatUp, floatDown])
    run(SKAction.repeatForever(floatSequence))
    
    // 날개 파닥임
    let wingFlap = SKAction.sequence([
        SKAction.scaleY(to: 0.8, duration: 0.3),
        SKAction.scaleY(to: 1.0, duration: 0.3)
    ])
    leftWing?.run(SKAction.repeatForever(wingFlap))
    rightWing?.run(SKAction.repeatForever(wingFlap))
}
```

2. **비눗방울 생성 애니메이션**
```swift
func performBubbleCreationAnimation() {
    // 입 모양 변화 (불기)
    let openMouth = SKAction.scaleY(to: 1.5, duration: 0.3)
    let closeMouth = SKAction.scaleY(to: 1.0, duration: 0.2)
    
    // 날개 빠르게 움직임
    let fastFlap = SKAction.sequence([...])
    
    // 순차적으로 실행
    mouth?.run(SKAction.sequence([openMouth, closeMouth]))
    leftWing?.run(fastFlap)
    rightWing?.run(fastFlap)
}
```

3. **만족 표정 애니메이션**
```swift
func performSatisfactionAnimation() {
    // 눈을 ^_^ 모양으로 변경
    leftEye?.run(SKAction.scaleY(to: 0.5, duration: 0.2))
    
    // 입을 웃는 모양으로
    mouth?.run(SKAction.scale(to: 1.3, duration: 0.3))
    
    // 기쁨 표현 후 원래대로
    let wait = SKAction.wait(forDuration: 1.0)
    let restore = SKAction.group([...])
    run(SKAction.sequence([wait, restore]))
}
```

---

### 4. GameManager.swift (226 라인)

**역할**: 게임 상태 및 데이터 관리

#### 싱글톤 패턴
```swift
static let shared = GameManager()
private init() { loadBestScore() }
```

#### 관리 데이터
```swift
private(set) var currentScore: Int = 0
private(set) var bestScore: Int = 0
private(set) var gameTime: TimeInterval = 0
private(set) var currentLevel: Int = 1
private(set) var bubbleCount: Int = 0
private(set) var isGameActive: Bool = false
```

#### 주요 메서드
- `startNewGame()`: 새 게임 시작
- `addScore(_ points:)`: 점수 추가
- `updateBubbleCount(_ count:)`: 비눗방울 개수 업데이트
- `updateLevel()`: 레벨 계산 및 업데이트
- `endGame()`: 게임 종료 처리
- `saveBestScore()`: 최고점수 저장 (UserDefaults)
- `loadBestScore()`: 최고점수 로드

---

## 🔧 헬퍼 시스템

### PhysicsHelper.swift (254 라인)

**유틸리티 메서드 제공**

```swift
// 물리 월드 설정
static func setupPhysicsWorld(for scene: SKScene) {
    scene.physicsWorld.gravity = CGVector(dx: 0, dy: 5.0)
    scene.physicsWorld.speed = 0.6
}

// 물리 바디 생성
static func createCircleBody(radius: CGFloat, 
                             category: UInt32,
                             contact: UInt32) -> SKPhysicsBody {
    let body = SKPhysicsBody(circleOfRadius: radius)
    body.categoryBitMask = category
    body.contactTestBitMask = contact
    body.restitution = 0.2  // 탄성
    body.friction = 0.3     // 마찰
    return body
}

// 거리 계산
static func distance(from: CGPoint, to: CGPoint) -> CGFloat {
    let dx = to.x - from.x
    let dy = to.y - from.y
    return sqrt(dx*dx + dy*dy)
}
```

---

### AudioManager.swift (274 라인)

**사운드 관리 프레임워크** (현재 미사용)

```swift
class AudioManager {
    static let shared = AudioManager()
    
    // AVAudioPlayer 인스턴스 관리
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    // 볼륨 설정
    var backgroundMusicVolume: Float = 0.5
    var soundEffectVolume: Float = 0.7
    
    func playBackgroundMusic(_ filename: String) { }
    func stopBackgroundMusic() { }
    func playSoundEffect(_ filename: String) { }
}
```

---

### ParticleEffects.swift (394 라인)

**파티클 효과 프레임워크** (현재 미사용)

```swift
class ParticleEffects {
    // 비눗방울 합치기 효과
    static func createMergeEffect(at position: CGPoint, 
                                  color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 100
        emitter.particleLifetime = 0.5
        emitter.particleColor = color
        // ...
        return emitter
    }
    
    // 비눗방울 터지기 효과
    static func createPopEffect(...) -> SKEmitterNode { }
    
    // 무지개 효과
    static func createRainbowEffect(...) -> SKEmitterNode { }
}
```

---

## 🎨 시각 효과 구현

### 여름 테마 배경

```swift
private func setupSummerBackground() {
    // 하늘색 배경
    backgroundColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
    
    // 구름 생성
    addFloatingClouds()
}

private func addFloatingClouds() {
    for _ in 0..<5 {
        let cloud = createCloud()
        cloud.position = CGPoint(
            x: CGFloat.random(in: -size.width/2...size.width/2),
            y: CGFloat.random(in: 0...size.height/2)
        )
        
        // 구름 이동 애니메이션
        let moveAction = SKAction.moveBy(
            x: size.width + 200, 
            y: 0, 
            duration: 30
        )
        let resetAction = SKAction.moveTo(
            x: -size.width/2 - 100, 
            duration: 0
        )
        let sequence = SKAction.sequence([moveAction, resetAction])
        cloud.run(SKAction.repeatForever(sequence))
        
        addChild(cloud)
    }
}
```

### 하이라이트 효과

```swift
private func setupHighlight() {
    let path = CGMutablePath()
    
    // 소시지 모양 곡선
    let startPoint = CGPoint(x: -radius * 0.5, y: radius * 0.6)
    path.move(to: startPoint)
    
    let controlPoint = CGPoint(x: -radius * 0.2, y: radius * 0.8)
    let endPoint = CGPoint(x: radius * 0.1, y: radius * 0.5)
    path.addQuadCurve(to: endPoint, control: controlPoint)
    
    highlight = SKShapeNode(path: path)
    highlight?.strokeColor = UIColor(white: 1.0, alpha: 0.8)
    highlight?.lineWidth = 2.0
    highlight?.zPosition = 3
    
    // 회전 독립성 - 항상 왼쪽 위 고정
    highlight?.zRotation = -zRotation
}
```

---

## 🎯 물리 시뮬레이션

### 중력 설정
```swift
physicsWorld.gravity = CGVector(dx: 0, dy: 5.0)  // 천정 방향
physicsWorld.speed = 0.6  // 안정성 향상
```

### 충돌 카테고리
```swift
struct PhysicsCategory {
    static let bubble: UInt32 = 0x1 << 0     // 비눗방울
    static let wall: UInt32 = 0x1 << 1       // 벽면
    static let boundary: UInt32 = 0x1 << 2   // 곡선 경계
    static let gameOverLine: UInt32 = 0x1 << 3  // 게임오버 라인
}
```

### 합치기 로직
```swift
func didBegin(_ contact: SKPhysicsContact) {
    guard let bubbleA = contact.bodyA.node as? BubbleNode,
          let bubbleB = contact.bodyB.node as? BubbleNode else { return }
    
    // 같은 크기인지 확인
    guard bubbleA.bubbleType == bubbleB.bubbleType else { return }
    
    // 중복 합치기 방지
    guard !bubbleA.isMerging && !bubbleB.isMerging else { return }
    
    // 합치기 플래그 설정
    bubbleA.isMerging = true
    bubbleB.isMerging = true
    
    // 새로운 비눗방울 생성
    let newType = bubbleA.bubbleType.nextType()
    let newBubble = BubbleNode(type: newType)
    
    // 충돌 지점에 배치
    let midPoint = CGPoint(
        x: (bubbleA.position.x + bubbleB.position.x) / 2,
        y: (bubbleA.position.y + bubbleB.position.y) / 2
    )
    newBubble.position = midPoint
    
    // 기존 비눗방울 제거
    bubbleA.removeFromParent()
    bubbleB.removeFromParent()
    
    // 새 비눗방울 추가
    addChild(newBubble)
    
    // 점수 추가
    gameManager.addScore(newType.rawValue * 10)
}
```

---

## 📊 성능 최적화 전략

### 현재 구현
1. **물리 엔진 속도 조절**: `physicsWorld.speed = 0.6`
2. **중복 충돌 방지**: `isMerging` 플래그
3. **모듈화된 코드**: 기능별 파일 분리

### 향후 최적화 계획
1. **오브젝트 풀링**: BubblePool 클래스 구현 예정
2. **화면 밖 컬링**: 보이지 않는 객체 업데이트 생략
3. **파티클 최적화**: 파티클 수 제한 및 재사용
4. **텍스처 아틀라스**: 메모리 최적화

---

## 🔐 데이터 저장

### UserDefaults 사용
```swift
private func saveBestScore() {
    UserDefaults.standard.set(bestScore, forKey: "BestScore")
    UserDefaults.standard.synchronize()
}

private func loadBestScore() {
    bestScore = UserDefaults.standard.integer(forKey: "BestScore")
}
```

---

## 🎮 입력 처리

### 터치 이벤트
```swift
override func touchesBegan(_ touches: Set<UITouch>, 
                          with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    
    // 현재 비눗방울 터치 확인
    if let bubble = currentBubble,
       bubble.contains(location) {
        isDragging = true
        initialTouchPosition = location
    }
}

override func touchesMoved(_ touches: Set<UITouch>, 
                          with event: UIEvent?) {
    guard isDragging, 
          let touch = touches.first else { return }
    let location = touch.location(in: self)
    
    // 비눗방울 이동 (좌우만)
    let newX = location.x.clamped(
        to: -size.width * 0.45...size.width * 0.45
    )
    currentBubble?.position.x = newX
}

override func touchesEnded(_ touches: Set<UITouch>, 
                          with event: UIEvent?) {
    guard isDragging else { return }
    isDragging = false
    
    // 비눗방울 발사
    launchBubble()
}
```

---

## 📝 코드 품질

### 명명 규칙 준수
- **클래스**: PascalCase (GameScene, BubbleNode)
- **변수/함수**: camelCase (currentBubble, updateExpression)
- **상수**: camelCase (maxBubbleSize, gameSpeed)

### 문서화
- 주요 클래스 및 메서드에 주석 추가
- 복잡한 로직에 설명 주석
- 매직 넘버 최소화

### 코드 구조
- MARK 주석으로 섹션 구분
- private/public 접근 제어 명확화
- 기능별 파일 분리

---

## 🚀 확장성

### 모듈화 설계
- 각 기능이 독립적인 파일로 분리
- 헬퍼 클래스로 재사용성 향상
- Extension으로 기능 확장 용이

### 향후 추가 용이한 기능
- 새로운 비눗방울 타입 추가
- 다양한 캐릭터 추가
- 새로운 파티클 효과 추가
- 사운드 리소스 추가

---

## 📚 참고 자료

### Apple 프레임워크
- **SpriteKit**: 2D 게임 엔진
- **GameplayKit**: 게임 로직 및 AI
- **AVFoundation**: 오디오 재생
- **UserDefaults**: 데이터 저장

### 사용된 디자인 패턴
- **싱글톤**: GameManager, AudioManager
- **팩토리**: BubbleNode 생성
- **옵저버**: 게임 상태 변화 알림 (미래)
- **컴포지트**: 노드 계층 구조

---

이 문서는 bubbleSky 프로젝트의 기술적 구현을 상세히 설명합니다.
각 클래스와 메서드의 역할, 구현 방식, 그리고 향후 확장 계획을 포함하고 있습니다.
