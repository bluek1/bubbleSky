# 캐릭터 PNG 스프라이트 애니메이션 시스템 전환 계획

**작성일**: 2025-11-05
**목표**: 코드 기반 캐릭터 렌더링을 PNG 스프라이트 시트 기반 애니메이션으로 전환

---

## 📋 목차

1. [현재 상태 분석](#현재-상태-분석)
2. [필요한 리소스](#필요한-리소스)
3. [스프라이트 시트 구조](#스프라이트-시트-구조)
4. [구현 전략](#구현-전략)
5. [코드 구조 변경](#코드-구조-변경)
6. [구현 단계](#구현-단계)
7. [리소스 제작 가이드](#리소스-제작-가이드)

---

## 🔍 현재 상태 분석

### 현재 캐릭터 시스템 (CharacterNode.swift)

**구성 요소**:
- 몸체 (Body): SKShapeNode (원형, 25pt 반지름)
- 얼굴: 눈 2개, 입 1개
- 날개: 좌우 2개
- 마법 지팡이 (선택적)

**애니메이션 종류**:
1. **Idle Animation** (대기)
   - 위아래 떠다니기 (±8pt, 2초 주기)
   - 날개 파닥임 (π/8 회전, 1.2초 주기)
   - 마법 지팡이 반짝임

2. **Bubble Creation Animation** (비눗방울 생성)
   - 입 모양 변경 (미소 → O 모양)
   - 몸체 크기 변화 (1.0 → 1.1 → 1.0)
   - 지속 시간: 약 0.8초

3. **Satisfaction Animation** (만족 표정)
   - 오른쪽 눈 윙크
   - 지속 시간: 0.5초

4. **Wing Flap Animation** (날개 파닥임)
   - 회전 각도: π/8 → -π/4 → π/8
   - 지속 시간: 1.2초
   - 무한 반복

---

## 🎨 필요한 리소스

### 방법 1: 스프라이트 시트 (권장)

**장점**:
- 메모리 효율적
- 텍스처 스왑 최소화
- 로딩 속도 빠름

**단점**:
- 제작 시간 필요
- 프레임 크기 제한

### 방법 2: 개별 PNG 파일

**장점**:
- 제작 및 수정 용이
- 프레임별 독립적 관리

**단점**:
- 메모리 사용량 증가
- 파일 관리 복잡

**→ 결론: 스프라이트 시트 방식 채택**

---

## 📐 스프라이트 시트 구조

### 제안 구조

```
fairy_character_spritesheet.png (2048x2048)
├─ Row 1: Idle Animation (10 frames)
│  └─ 각 프레임: 128x128px
├─ Row 2: Blowing Animation (8 frames)
│  └─ 각 프레임: 128x128px
├─ Row 3: Satisfaction Animation (6 frames)
│  └─ 각 프레임: 128x128px
└─ Row 4: Wing Flap Emphasis (8 frames)
   └─ 각 프레임: 128x128px
```

### 대안: 개별 스프라이트 시트

```
1. fairy_idle_sheet.png (1280x128) - 10 frames
2. fairy_blowing_sheet.png (1024x128) - 8 frames
3. fairy_satisfaction_sheet.png (768x128) - 6 frames
4. fairy_wing_flap_sheet.png (1024x128) - 8 frames
```

**→ 권장: 대안 방식 (애니메이션별 분리)**

---

## 🎬 애니메이션별 프레임 설계

### 1. Idle Animation (10 frames, 2초 루프)

**프레임 구성**:
```
Frame 1-3:  기본 위치에서 위로 이동 (날개 위로)
Frame 4-5:  최고점 (날개 수평)
Frame 6-8:  아래로 이동 (날개 아래로)
Frame 9-10: 최저점에서 복귀 (날개 수평)
```

**특징**:
- 부드러운 떠다니는 느낌
- 날개와 몸체 동기화
- 얼굴 표정: 부드러운 미소

### 2. Blowing Animation (8 frames, 0.8초)

**프레임 구성**:
```
Frame 1:    준비 (입 닫힘, 눈 정상)
Frame 2-3:  숨 들이쉬기 (몸체 약간 커짐, 입 작게 열림)
Frame 4-5:  불기 (입 O 모양, 몸체 최대, 뺨 부풀림)
Frame 6-7:  내뿜기 (입 더 벌어짐, 비눗방울 생성 효과)
Frame 8:    복귀 (원래 상태로)
```

**특징**:
- 뺨 부풀어오르는 효과
- 입 모양 변화 (미소 → O 모양)
- 비눗방울 생성 타이밍: Frame 6-7

### 3. Satisfaction Animation (6 frames, 0.5초)

**프레임 구성**:
```
Frame 1:    정상 표정
Frame 2-3:  오른쪽 눈 감기 시작
Frame 4:    완전히 윙크 (^_<)
Frame 5:    눈 뜨기 시작
Frame 6:    정상 표정 복귀
```

**특징**:
- 귀여운 윙크 표정
- 입은 활짝 웃는 모양
- 빠른 재생 (0.5초)

### 4. Wing Flap Emphasis (8 frames, 1.2초)

**프레임 구성**:
```
Frame 1-2:  날개 수평
Frame 3-4:  날개 위로 (최대 각도)
Frame 5-6:  날개 아래로 (최대 각도)
Frame 7-8:  날개 수평 복귀
```

**특징**:
- 강조된 날개 움직임
- Idle과 별도로 사용 가능

---

## 🏗️ 구현 전략

### Phase 1: 리소스 준비 및 로딩 시스템

**단계**:
1. Assets.xcassets에 스프라이트 시트 추가
2. SKTextureAtlas 생성 및 로딩
3. 프레임별 SKTexture 배열 생성
4. 리소스 매니저 클래스 구현

**파일**: `CharacterResourceManager.swift` (새 파일)

### Phase 2: CharacterNode 리팩토링

**변경 사항**:
1. SKShapeNode 기반 → SKSpriteNode 기반 전환
2. setupCharacterVisuals() 제거
3. 스프라이트 기반 초기화 추가
4. 애니메이션 메서드 수정

**파일**: `CharacterNode.swift` (수정)

### Phase 3: 애니메이션 시스템 통합

**구현 내용**:
1. SKAction.animate(with:) 활용
2. 애니메이션 타이밍 최적화
3. 전환 애니메이션 부드럽게 처리
4. 애니메이션 큐 관리

### Phase 4: 테스트 및 최적화

**확인 사항**:
1. 메모리 사용량 측정
2. FPS 영향 확인
3. 애니메이션 부드러움 검증
4. 기존 기능 호환성 테스트

---

## 💻 코드 구조 변경

### 새로운 파일: CharacterResourceManager.swift

```swift
/// 캐릭터 리소스 관리자 (싱글톤)
class CharacterResourceManager {
    static let shared = CharacterResourceManager()

    // 애니메이션별 텍스처 배열
    private(set) var idleFrames: [SKTexture] = []
    private(set) var blowingFrames: [SKTexture] = []
    private(set) var satisfactionFrames: [SKTexture] = []
    private(set) var wingFlapFrames: [SKTexture] = []

    private init() {
        loadTextures()
    }

    // 텍스처 로딩
    private func loadTextures() {
        // 스프라이트 시트에서 프레임 추출
        idleFrames = loadFrames(from: "fairy_idle_sheet", count: 10)
        blowingFrames = loadFrames(from: "fairy_blowing_sheet", count: 8)
        satisfactionFrames = loadFrames(from: "fairy_satisfaction_sheet", count: 6)
        wingFlapFrames = loadFrames(from: "fairy_wing_flap_sheet", count: 8)
    }

    // 프레임 추출 헬퍼
    private func loadFrames(from imageName: String, count: Int) -> [SKTexture] {
        var frames: [SKTexture] = []

        // 방법 1: 개별 파일
        for i in 0..<count {
            let textureName = "\(imageName)_\(i)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .linear
            frames.append(texture)
        }

        // 방법 2: 스프라이트 시트 (추후 구현)
        // let atlas = SKTextureAtlas(named: imageName)
        // ...

        return frames
    }

    // 애니메이션 액션 생성
    func createIdleAnimation() -> SKAction {
        let animate = SKAction.animate(with: idleFrames, timePerFrame: 0.2)
        return SKAction.repeatForever(animate)
    }

    func createBlowingAnimation() -> SKAction {
        return SKAction.animate(with: blowingFrames, timePerFrame: 0.1)
    }

    func createSatisfactionAnimation() -> SKAction {
        return SKAction.animate(with: satisfactionFrames, timePerFrame: 0.083)
    }

    func createWingFlapAnimation() -> SKAction {
        let animate = SKAction.animate(with: wingFlapFrames, timePerFrame: 0.15)
        return SKAction.repeatForever(animate)
    }
}
```

### 수정된 CharacterNode.swift

```swift
class CharacterNode: SKNode {

    // MARK: - Properties

    /// 메인 스프라이트 노드
    private var characterSprite: SKSpriteNode!

    /// 리소스 매니저
    private let resourceManager = CharacterResourceManager.shared

    /// 애니메이션 액션들
    private var idleAction: SKAction!
    private var blowingAction: SKAction!

    // MARK: - Initialization

    override init() {
        super.init()
        setupCharacterSprite()
        setupAnimations()
        startIdleAnimation()
    }

    // MARK: - Setup Methods

    /// 캐릭터 스프라이트 설정
    private func setupCharacterSprite() {
        // 첫 프레임으로 초기화
        let initialTexture = resourceManager.idleFrames.first!
        characterSprite = SKSpriteNode(texture: initialTexture)
        characterSprite.size = CGSize(width: 80, height: 80)  // 크기 조정
        characterSprite.zPosition = 1
        addChild(characterSprite)
    }

    /// 애니메이션 설정
    private func setupAnimations() {
        idleAction = resourceManager.createIdleAnimation()
        blowingAction = resourceManager.createBlowingAnimation()
    }

    // MARK: - Animation Control

    func startIdleAnimation() {
        characterSprite.run(idleAction, withKey: "idleAnimation")

        // 떠다니는 위치 애니메이션 (기존과 동일)
        let moveUp = SKAction.moveTo(y: position.y + 8, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SKAction.moveTo(y: position.y - 8, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut
        let float = SKAction.sequence([moveUp, moveDown])
        run(SKAction.repeatForever(float), withKey: "floatAnimation")
    }

    func performBubbleCreationAnimation(completion: @escaping () -> Void) {
        // Idle 중지
        characterSprite.removeAction(forKey: "idleAnimation")

        // Blowing 애니메이션 실행
        characterSprite.run(blowingAction) {
            // 완료 후 Idle 복귀
            self.startIdleAnimation()
            completion()
        }
    }

    func performSatisfactionAnimation() {
        let satisfactionAction = resourceManager.createSatisfactionAnimation()
        characterSprite.run(satisfactionAction)
    }
}
```

---

## 📝 구현 단계

### Step 1: 리소스 매니저 구현 (1-2시간)

**작업**:
- [ ] `CharacterResourceManager.swift` 생성
- [ ] 텍스처 로딩 로직 구현
- [ ] 애니메이션 액션 생성 메서드 구현
- [ ] 메모리 관리 및 캐싱 로직

**산출물**:
- CharacterResourceManager.swift

### Step 2: CharacterNode 리팩토링 (2-3시간)

**작업**:
- [ ] SKSpriteNode 기반으로 전환
- [ ] setupCharacterVisuals() 제거
- [ ] setupCharacterSprite() 구현
- [ ] 애니메이션 메서드 수정
- [ ] 기존 인터페이스 유지 (호환성)

**산출물**:
- 수정된 CharacterNode.swift

### Step 3: 임시 리소스로 테스트 (1시간)

**작업**:
- [ ] 단색 PNG 프레임 생성 (테스트용)
- [ ] Assets.xcassets에 추가
- [ ] 애니메이션 동작 확인
- [ ] 버그 수정

**산출물**:
- 테스트 리소스 파일
- 동작 검증 완료

### Step 4: 실제 리소스 제작 (4-8시간)

**작업**:
- [ ] 캐릭터 디자인 (Idle 기본 포즈)
- [ ] Idle 애니메이션 프레임 제작 (10장)
- [ ] Blowing 애니메이션 프레임 제작 (8장)
- [ ] Satisfaction 애니메이션 프레임 제작 (6장)
- [ ] Wing Flap 애니메이션 프레임 제작 (8장)
- [ ] 스프라이트 시트 조합

**산출물**:
- 고품질 PNG 스프라이트 시트 4개
- 또는 개별 PNG 파일 32개

### Step 5: 최종 통합 및 최적화 (1-2시간)

**작업**:
- [ ] 실제 리소스 교체
- [ ] 애니메이션 타이밍 미세 조정
- [ ] 메모리 프로파일링
- [ ] FPS 최적화
- [ ] 최종 테스트

**산출물**:
- 완성된 PNG 기반 캐릭터 시스템

---

## 🎨 리소스 제작 가이드

### 캐릭터 디자인 가이드라인

**스타일**:
- 귀여운 비눗방울 요정
- 둥근 몸체, 큰 눈
- 투명한 날개
- 파스텔 톤 색상

**색상 팔레트**:
```
주 색상: 연보라 (#E5CCFF)
보조 색상: 하늘색 (#B3D9FF)
강조 색상: 핑크 (#FFB3D9)
날개: 반투명 하늘색 (alpha 0.6)
```

**크기 사양**:
- 원본 해상도: 128x128px (프레임당)
- 내보내기: @1x, @2x, @3x (iOS)
- 여백: 상하좌우 10px
- 실제 캐릭터 크기: 108x108px

### 애니메이션 원칙

1. **Squash and Stretch** (찌그러짐과 늘어남)
   - 비눗방울을 불 때 몸체가 부풀어오름
   - 아래로 내려갈 때 살짝 찌그러짐

2. **Anticipation** (예비 동작)
   - 불기 전 숨을 들이쉬는 동작
   - 날개 치기 전 약간 뒤로

3. **Follow Through** (여운)
   - 날개가 몸체보다 약간 늦게 멈춤
   - 머리카락/안테나가 있다면 흔들림

4. **Ease In/Out** (가속/감속)
   - 모든 동작은 부드럽게 시작하고 끝남
   - 급격한 움직임 지양

### 제작 도구 추천

**픽셀 아트**:
- Aseprite (유료, 최고)
- Piskel (무료, 웹)
- GraphicsGale (무료)

**벡터 아트**:
- Adobe Illustrator
- Affinity Designer
- Inkscape (무료)

**2D 애니메이션**:
- Spine (유료, 본 애니메이션)
- DragonBones (무료, 본 애니메이션)
- Synfig Studio (무료)

**스프라이트 시트 제작**:
- TexturePacker (유료, 최적화)
- ShoeBox (무료)
- Leshy SpriteSheet Tool (무료, 웹)

### 파일 명명 규칙

```
개별 파일 방식:
fairy_idle_0.png
fairy_idle_1.png
...
fairy_idle_9.png

fairy_blowing_0.png
...
fairy_blowing_7.png

스프라이트 시트 방식:
fairy_idle_sheet.png
fairy_blowing_sheet.png
fairy_satisfaction_sheet.png
fairy_wing_flap_sheet.png
```

### Assets.xcassets 구조

```
Assets.xcassets/
└── Characters/
    └── Fairy/
        ├── Idle/
        │   ├── fairy_idle_0.imageset/
        │   ├── fairy_idle_1.imageset/
        │   └── ...
        ├── Blowing/
        │   └── ...
        ├── Satisfaction/
        │   └── ...
        └── WingFlap/
            └── ...
```

---

## 🔄 폴백(Fallback) 전략

### 리소스 미제공 시 대응

**방법 1**: 기존 코드 기반 렌더링 유지
```swift
if resourceManager.idleFrames.isEmpty {
    // 기존 SKShapeNode 기반 렌더링
    setupLegacyCharacterVisuals()
} else {
    // 스프라이트 기반 렌더링
    setupCharacterSprite()
}
```

**방법 2**: 프로그래매틱 텍스처 생성
```swift
// 단색 원형 텍스처를 코드로 생성
func createFallbackTexture() -> SKTexture {
    let size = CGSize(width: 128, height: 128)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        // 원형 그리기
        UIColor.purple.setFill()
        let rect = CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20)
        context.cgContext.fillEllipse(in: rect)
    }
    return SKTexture(image: image)
}
```

---

## 📊 성능 고려사항

### 메모리 사용량 추정

**스프라이트 시트 방식**:
```
4개 시트 × 평균 1MB = 약 4MB
+ 텍스처 캐시 = 약 8MB
총: 약 12MB
```

**개별 파일 방식**:
```
32개 파일 × 평균 50KB = 약 1.6MB
+ 텍스처 캐시 = 약 3.2MB
총: 약 5MB
```

### 최적화 팁

1. **텍스처 압축**: PVRTC 또는 ASTC 사용
2. **미리 로딩**: 게임 시작 시 모든 텍스처 로드
3. **Texture Atlas**: SKTextureAtlas 활용
4. **필터링 모드**: .linear (부드러움) vs .nearest (픽셀 아트)
5. **캐싱**: 한 번 생성한 SKAction 재사용

---

## ✅ 체크리스트

### 리소스 준비
- [ ] 캐릭터 디자인 완료
- [ ] Idle 프레임 10장 제작
- [ ] Blowing 프레임 8장 제작
- [ ] Satisfaction 프레임 6장 제작
- [ ] Wing Flap 프레임 8장 제작
- [ ] 스프라이트 시트 조합 (선택적)
- [ ] Assets.xcassets에 추가

### 코드 구현
- [ ] CharacterResourceManager.swift 생성
- [ ] 텍스처 로딩 로직 구현
- [ ] CharacterNode.swift 리팩토링
- [ ] 애니메이션 시스템 통합
- [ ] 폴백 로직 구현

### 테스트
- [ ] 애니메이션 부드러움 확인
- [ ] 메모리 사용량 측정
- [ ] FPS 영향 확인
- [ ] 다양한 기기에서 테스트
- [ ] 게임플레이 호환성 검증

---

## 📚 참고 자료

### Apple 공식 문서
- [SKTexture - Apple Developer](https://developer.apple.com/documentation/spritekit/sktexture)
- [SKAction.animate(with:timePerFrame:) - Apple Developer](https://developer.apple.com/documentation/spritekit/skaction/1417663-animate)
- [SKTextureAtlas - Apple Developer](https://developer.apple.com/documentation/spritekit/sktextureatlas)

### 애니메이션 원칙
- [12 Principles of Animation](https://en.wikipedia.org/wiki/Twelve_basic_principles_of_animation)
- [Sprite Animation Tutorial](https://www.raywenderlich.com/71-spritekit-animations-and-texture-atlases-in-swift)

---

## 🎯 우선순위 및 일정

### 즉시 시작 가능 (리소스 없이)
1. CharacterResourceManager.swift 구현
2. 폴백 텍스처 생성 로직
3. CharacterNode.swift 리팩토링 (구조만)

### 리소스 제작 필요
4. 실제 PNG 프레임 제작 (4-8시간)
5. 최종 통합 및 테스트

### 예상 총 소요 시간
- **코드 구현**: 4-6시간
- **리소스 제작**: 4-8시간 (디자인 역량에 따라)
- **테스트 및 최적화**: 1-2시간
- **총계**: 9-16시간

---

## 💡 결론

PNG 스프라이트 애니메이션 시스템으로 전환하면:

**장점**:
✅ 더 풍부하고 자연스러운 애니메이션
✅ 디자이너 협업 용이
✅ 향후 캐릭터 추가/변경 쉬움
✅ 다양한 표정/동작 표현 가능

**단점**:
❌ 초기 리소스 제작 시간 필요
❌ 메모리 사용량 증가 (약 12MB)
❌ 관리해야 할 파일 증가

**권장 접근 방식**:
1. 먼저 코드 구조만 리팩토링 (폴백 포함)
2. 임시 단색 프레임으로 동작 검증
3. 실제 리소스 제작 (시간 있을 때)
4. 점진적 교체

이 접근 방식으로 리소스 없이도 시스템을 구축하고, 나중에 리소스를 추가할 수 있습니다!
