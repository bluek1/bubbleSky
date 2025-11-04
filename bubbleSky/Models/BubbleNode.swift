import SpriteKit

class BubbleNode: SKShapeNode {
    
    // MARK: - Properties
    
    /// 비눗방울 타입
    private(set) var bubbleType: BubbleType
    
    /// 원래 반지름 값 (변형 효과 후 복원용)
    private let originalRadius: CGFloat
    
    /// 현재 변형 상태
    private var currentDeformation = CGPoint(x: 1.0, y: 1.0)
    
    /// 압축 상태 여부
    private var isCompressed = false
    
    /// 마지막 충돌 효과 시간 (무한 반복 방지)
    private var lastImpactTime: TimeInterval = 0
    
    /// 충돌 효과 쿨다운 시간 (초)
    private let impactCooldown: TimeInterval = 0.3
    
    /// 합치기 진행 중 플래그 (중복 합치기 방지)
    private(set) var isMerging = false
    
    // MARK: - Initialization
    
    /// 특정 타입의 비눗방울 초기화
    /// - Parameter type: 비눗방울 타입
    init(type: BubbleType) {
        self.bubbleType = type
        // 실제 사용되는 크기로 설정
        self.originalRadius = type.radius * 0.85
        
        super.init()
        
        setupPhysicalAppearance()
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 비눗방울 외관 설정
    private func setupPhysicalAppearance() {
        // 물리 바디와 동일한 크기로 시각적 크기 조정 (겹침 방지)
        let visualRadius = bubbleType.radius * 0.85
        
        // 원형 경로 생성
        let path = CGPath(ellipseIn: CGRect(x: -visualRadius, y: -visualRadius, width: visualRadius * 2, height: visualRadius * 2), transform: nil)
        self.path = path
        
        // 타입별 고정 색상 사용 (BubbleType의 color 속성 직접 사용)
        let fixedColor = bubbleType.color
        self.fillColor = fixedColor
        self.strokeColor = fixedColor.withAlphaComponent(0.8)
        self.lineWidth = 1.0  // 테두리를 얇게 변경
        
        // 간단한 표정 추가 (눈과 입을 직접 그리기)
        addFacialFeatures(radius: visualRadius)
        
        // 반사 효과 (하이라이트) - 크기에 맞게 조정
        addHighlightEffect(radius: visualRadius)
    }
    /// 얼굴 특징 추가 (눈과 입)
    private func addFacialFeatures(radius: CGFloat) {
        // 랜덤 표정 타입 선택 (새로운 표정들 추가)
        let expressionTypes = ["happy", "neutral", "surprised", "sleepy", "excited", "closed_happy", "wink_left", "tired", "half_closed", "sad", "laughing", "worried", "confused"]
        let randomExpression = expressionTypes.randomElement() ?? "neutral"
        
        // 표정 타입을 저장 (눈 뜨기 애니메이션에서 사용)
        self.name = "bubble_\(randomExpression)"
        
        // 눈 추가
        addEyes(radius: radius, expression: randomExpression)
        
        // 입 추가
        addMouth(radius: radius, expression: randomExpression)
        
        // 깜빡이는 애니메이션 시작
        startBlinkingAnimation()
        
        // 감은 눈 표정인 경우 눈 뜨기 애니메이션 시작
        if isClosedEyeExpression(randomExpression) {
            startEyeOpeningAnimation(radius: radius, expression: randomExpression)
        }
    }
    
    /// 눈 그리기 (다양한 표정 지원)
    private func addEyes(radius: CGFloat, expression: String) {
        // 타입에 따라 눈 크기 결정 (Tiny는 작게, 나머지는 크게)
        let eyeRadius: CGFloat
        let pupilRadius: CGFloat
        
        if bubbleType == .tiny {
            eyeRadius = radius * 0.15  // Tiny는 작게 (지름 30%)
            pupilRadius = radius * 0.075
        } else {
            eyeRadius = radius * 0.2  // 나머지는 크게 (지름 40%)
            pupilRadius = radius * 0.1
        }
        
        let eyeOffset = radius * 0.25
        let eyeY = radius * 0.2
        
        switch expression {
        case "closed_happy":  // >_< 표정
            addClosedHappyEyes(radius: radius, eyeOffset: eyeOffset, eyeY: eyeY)
        case "wink_left":     // =_< 표정
            addWinkLeftEyes(radius: radius, eyeOffset: eyeOffset, eyeY: eyeY, eyeRadius: eyeRadius, pupilRadius: pupilRadius)
        case "tired":         // -_- 표정
            addTiredEyes(radius: radius, eyeOffset: eyeOffset, eyeY: eyeY)
        case "half_closed":   // =_- 표정
            addHalfClosedEyes(radius: radius, eyeOffset: eyeOffset, eyeY: eyeY, eyeRadius: eyeRadius, pupilRadius: pupilRadius)
        default:
            // 기본 원형 눈
            addDefaultEyes(radius: radius, eyeOffset: eyeOffset, eyeY: eyeY, eyeRadius: eyeRadius, pupilRadius: pupilRadius)
        }
    }
    
    /// 기본 원형 눈 (기존 코드)
    private func addDefaultEyes(radius: CGFloat, eyeOffset: CGFloat, eyeY: CGFloat, eyeRadius: CGFloat, pupilRadius: CGFloat) {
        // 왼쪽 눈 흰자
        let leftEyeWhite = SKShapeNode(circleOfRadius: eyeRadius)
        leftEyeWhite.fillColor = SKColor.white
        leftEyeWhite.strokeColor = SKColor.black
        leftEyeWhite.lineWidth = 1.5
        leftEyeWhite.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftEyeWhite.zPosition = 10
        leftEyeWhite.name = "leftEye"  // 깜빡임을 위한 이름 설정
        addChild(leftEyeWhite)
        
        // 왼쪽 눈동자
        let leftPupil = SKShapeNode(circleOfRadius: pupilRadius)
        leftPupil.fillColor = SKColor.black
        leftPupil.strokeColor = SKColor.clear
        leftPupil.position = CGPoint(x: 0, y: 0)  // 흰자 중앙에 위치
        leftPupil.zPosition = 11
        leftPupil.name = "leftPupil"
        leftEyeWhite.addChild(leftPupil)
        
        // 오른쪽 눈 흰자
        let rightEyeWhite = SKShapeNode(circleOfRadius: eyeRadius)
        rightEyeWhite.fillColor = SKColor.white
        rightEyeWhite.strokeColor = SKColor.black
        rightEyeWhite.lineWidth = 1.5
        rightEyeWhite.position = CGPoint(x: eyeOffset, y: eyeY)
        rightEyeWhite.zPosition = 10
        rightEyeWhite.name = "rightEye"  // 깜빡임을 위한 이름 설정
        addChild(rightEyeWhite)
        
        // 오른쪽 눈동자
        let rightPupil = SKShapeNode(circleOfRadius: pupilRadius)
        rightPupil.fillColor = SKColor.black
        rightPupil.strokeColor = SKColor.clear
        rightPupil.position = CGPoint(x: 0, y: 0)  // 흰자 중앙에 위치
        rightPupil.zPosition = 11
        rightPupil.name = "rightPupil"
        rightEyeWhite.addChild(rightPupil)
    }
    
    /// >_< 표정 (기쁜 감은 눈)
    private func addClosedHappyEyes(radius: CGFloat, eyeOffset: CGFloat, eyeY: CGFloat) {
        let eyeWidth = radius * 0.3
        let eyeHeight = radius * 0.1
        
        // 왼쪽 눈 (> 모양)
        let leftEyePath = CGMutablePath()
        leftEyePath.move(to: CGPoint(x: -eyeWidth/2, y: 0))
        leftEyePath.addLine(to: CGPoint(x: eyeWidth/2, y: eyeHeight/2))
        leftEyePath.addLine(to: CGPoint(x: eyeWidth/2, y: -eyeHeight/2))
        leftEyePath.closeSubpath()
        
        let leftEye = SKShapeNode(path: leftEyePath)
        leftEye.fillColor = SKColor.black
        leftEye.strokeColor = SKColor.black
        leftEye.lineWidth = 2.0
        leftEye.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftEye.zPosition = 10
        addChild(leftEye)
        
        // 오른쪽 눈 (< 모양)
        let rightEyePath = CGMutablePath()
        rightEyePath.move(to: CGPoint(x: eyeWidth/2, y: 0))
        rightEyePath.addLine(to: CGPoint(x: -eyeWidth/2, y: eyeHeight/2))
        rightEyePath.addLine(to: CGPoint(x: -eyeWidth/2, y: -eyeHeight/2))
        rightEyePath.closeSubpath()
        
        let rightEye = SKShapeNode(path: rightEyePath)
        rightEye.fillColor = SKColor.black
        rightEye.strokeColor = SKColor.black
        rightEye.lineWidth = 2.0
        rightEye.position = CGPoint(x: eyeOffset, y: eyeY)
        rightEye.zPosition = 10
        addChild(rightEye)
    }
    
    /// =_< 표정 (왼쪽 윙크)
    private func addWinkLeftEyes(radius: CGFloat, eyeOffset: CGFloat, eyeY: CGFloat, eyeRadius: CGFloat, pupilRadius: CGFloat) {
        // 왼쪽 눈 (= 모양, 감은 눈)
        let leftEyePath = CGMutablePath()
        let lineWidth = radius * 0.25
        leftEyePath.move(to: CGPoint(x: -lineWidth/2, y: 0))
        leftEyePath.addLine(to: CGPoint(x: lineWidth/2, y: 0))
        
        let leftEye = SKShapeNode(path: leftEyePath)
        leftEye.strokeColor = SKColor.black
        leftEye.lineWidth = 3.0
        leftEye.lineCap = .round
        leftEye.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftEye.zPosition = 10
        addChild(leftEye)
        
        // 오른쪽 눈 (< 모양, 찡긋)
        let rightEyePath = CGMutablePath()
        let eyeHeight = radius * 0.1
        rightEyePath.move(to: CGPoint(x: lineWidth/2, y: 0))
        rightEyePath.addLine(to: CGPoint(x: -lineWidth/2, y: eyeHeight/2))
        rightEyePath.addLine(to: CGPoint(x: -lineWidth/2, y: -eyeHeight/2))
        rightEyePath.closeSubpath()
        
        let rightEye = SKShapeNode(path: rightEyePath)
        rightEye.fillColor = SKColor.black
        rightEye.strokeColor = SKColor.black
        rightEye.lineWidth = 2.0
        rightEye.position = CGPoint(x: eyeOffset, y: eyeY)
        rightEye.zPosition = 10
        addChild(rightEye)
    }
    
    /// -_- 표정 (피곤한 눈)
    private func addTiredEyes(radius: CGFloat, eyeOffset: CGFloat, eyeY: CGFloat) {
        let lineWidth = radius * 0.25
        
        // 왼쪽 눈 (- 모양)
        let leftEyePath = CGMutablePath()
        leftEyePath.move(to: CGPoint(x: -lineWidth/2, y: 0))
        leftEyePath.addLine(to: CGPoint(x: lineWidth/2, y: 0))
        
        let leftEye = SKShapeNode(path: leftEyePath)
        leftEye.strokeColor = SKColor.black
        leftEye.lineWidth = 3.0
        leftEye.lineCap = .round
        leftEye.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftEye.zPosition = 10
        addChild(leftEye)
        
        // 오른쪽 눈 (- 모양)
        let rightEyePath = CGMutablePath()
        rightEyePath.move(to: CGPoint(x: -lineWidth/2, y: 0))
        rightEyePath.addLine(to: CGPoint(x: lineWidth/2, y: 0))
        
        let rightEye = SKShapeNode(path: rightEyePath)
        rightEye.strokeColor = SKColor.black
        rightEye.lineWidth = 3.0
        rightEye.lineCap = .round
        rightEye.position = CGPoint(x: eyeOffset, y: eyeY)
        rightEye.zPosition = 10
        addChild(rightEye)
    }
    
    /// =_- 표정 (반쯤 감은 눈)
    private func addHalfClosedEyes(radius: CGFloat, eyeOffset: CGFloat, eyeY: CGFloat, eyeRadius: CGFloat, pupilRadius: CGFloat) {
        let lineWidth = radius * 0.25
        
        // 왼쪽 눈 (= 모양)
        let leftEyePath = CGMutablePath()
        leftEyePath.move(to: CGPoint(x: -lineWidth/2, y: 0))
        leftEyePath.addLine(to: CGPoint(x: lineWidth/2, y: 0))
        
        let leftEye = SKShapeNode(path: leftEyePath)
        leftEye.strokeColor = SKColor.black
        leftEye.lineWidth = 3.0
        leftEye.lineCap = .round
        leftEye.position = CGPoint(x: -eyeOffset, y: eyeY)
        leftEye.zPosition = 10
        addChild(leftEye)
        
        // 오른쪽 눈 (- 모양)
        let rightEyePath = CGMutablePath()
        rightEyePath.move(to: CGPoint(x: -lineWidth/2, y: 0))
        rightEyePath.addLine(to: CGPoint(x: lineWidth/2, y: 0))
        
        let rightEye = SKShapeNode(path: rightEyePath)
        rightEye.strokeColor = SKColor.black
        rightEye.lineWidth = 3.0
        rightEye.lineCap = .round
        rightEye.position = CGPoint(x: eyeOffset, y: eyeY)
        rightEye.zPosition = 10
        addChild(rightEye)
    }
    
    /// 입 그리기
    private func addMouth(radius: CGFloat, expression: String) {
        let mouthWidth = radius * 0.3
        let mouthY = -radius * 0.7  // 아래에서 방울 크기의 30% 위치 (10% 위로 이동)
        
        let mouth = SKShapeNode()
        mouth.strokeColor = SKColor.black
        mouth.lineWidth = 2.0
        mouth.fillColor = SKColor.clear
        mouth.position = CGPoint(x: 0, y: mouthY)
        mouth.zPosition = 10
        
        // 표정에 따른 입 모양
        let path = CGMutablePath()
        
        switch expression {
        case "happy", "excited":
            // 웃는 입 (위로 볼록한 호)
            path.move(to: CGPoint(x: -mouthWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: 0), 
                             control: CGPoint(x: 0, y: mouthWidth * 0.3))
                             
        case "laughing":
            // 크게 웃는 입 (더 크고 위로 볼록한 호)
            let bigMouthWidth = mouthWidth * 1.3
            path.move(to: CGPoint(x: -bigMouthWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: bigMouthWidth/2, y: 0), 
                             control: CGPoint(x: 0, y: bigMouthWidth * 0.4))
                             
        case "sad":
            // 슬픈 입 (아래로 볼록한 호)
            path.move(to: CGPoint(x: -mouthWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: 0), 
                             control: CGPoint(x: 0, y: -mouthWidth * 0.3))
                             
        case "surprised":
            // 놀란 입 (작은 타원)
            let ovalWidth = mouthWidth * 0.4
            let ovalHeight = mouthWidth * 0.6
            path.addEllipse(in: CGRect(x: -ovalWidth/2, y: -ovalHeight/2, 
                                     width: ovalWidth, height: ovalHeight))
                                     
        case "worried":
            // 걱정하는 입 (물결 모양)
            path.move(to: CGPoint(x: -mouthWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: -mouthWidth * 0.1), 
                             control: CGPoint(x: -mouthWidth/4, y: mouthWidth * 0.1))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: 0), 
                             control: CGPoint(x: mouthWidth/4, y: -mouthWidth * 0.2))
                             
        case "confused":
            // 혼란스러운 입 (S자 곡선)
            path.move(to: CGPoint(x: -mouthWidth/2, y: mouthWidth * 0.1))
            path.addQuadCurve(to: CGPoint(x: 0, y: -mouthWidth * 0.1), 
                             control: CGPoint(x: -mouthWidth/4, y: -mouthWidth * 0.2))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: mouthWidth * 0.1), 
                             control: CGPoint(x: mouthWidth/4, y: mouthWidth * 0.2))
                             
        case "sleepy", "tired":
            // 졸린 입 (작은 가로선)
            path.move(to: CGPoint(x: -mouthWidth/3, y: 0))
            path.addLine(to: CGPoint(x: mouthWidth/3, y: 0))
            
        case "closed_happy":
            // 감은 눈에 맞는 기쁜 입 (작고 위로 볼록)
            let smallWidth = mouthWidth * 0.7
            path.move(to: CGPoint(x: -smallWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: smallWidth/2, y: 0), 
                             control: CGPoint(x: 0, y: smallWidth * 0.25))
                             
        case "half_closed":
            // 반쯤 감은 눈에 맞는 입 (약간 벌린 모양)
            path.move(to: CGPoint(x: -mouthWidth/4, y: mouthWidth * 0.05))
            path.addLine(to: CGPoint(x: mouthWidth/4, y: -mouthWidth * 0.05))
            
        case "wink_left":
            // 윙크에 맞는 장난스러운 입 (한쪽으로 기운 웃음)
            path.move(to: CGPoint(x: -mouthWidth/2, y: -mouthWidth * 0.05))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: mouthWidth * 0.1), 
                             control: CGPoint(x: mouthWidth * 0.1, y: mouthWidth * 0.3))
                             
        default: // neutral
            // 중립적인 입 (약간 아래로 볼록한 호)
            path.move(to: CGPoint(x: -mouthWidth/2, y: 0))
            path.addQuadCurve(to: CGPoint(x: mouthWidth/2, y: 0), 
                             control: CGPoint(x: 0, y: -mouthWidth * 0.1))
        }
        
        mouth.path = path
        addChild(mouth)
    }
    
    /// 물리 바디 설정
    private func setupPhysicsBody() {
        // 시각적 크기와 동일한 물리 바디 생성
        let physicsRadius = bubbleType.radius * 0.85
        self.physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
        
        // 물리 속성 설정 (안정성 향상)
        self.physicsBody?.mass = bubbleType.mass
        self.physicsBody?.restitution = bubbleType.restitution
        self.physicsBody?.friction = bubbleType.friction
        self.physicsBody?.linearDamping = 0.7  // 0.5에서 0.7로 증가 (더 빠른 안정화)
        self.physicsBody?.angularDamping = 0.7  // 0.5에서 0.7로 증가
        self.physicsBody?.allowsRotation = true
        
        // 물리 카테고리 설정
        self.physicsBody?.categoryBitMask = PhysicsCategory.bubble
        self.physicsBody?.collisionBitMask = PhysicsCategory.all
        self.physicsBody?.contactTestBitMask = PhysicsCategory.bubble
        
        // 발사 전에는 비활성화
        self.physicsBody?.isDynamic = false
    }
    
    /// 충돌 시 랜덤 임펄스 추가 (자연스러운 산란)
    func addRandomBounceImpulse() {
        guard let physicsBody = self.physicsBody else { return }
        
        // 작은 랜덤 임펄스 추가 (충돌 시 약간의 흔들림)
        let randomX = CGFloat.random(in: -20...20)
        let randomY = CGFloat.random(in: -10...10)
        let randomImpulse = CGVector(dx: randomX, dy: randomY)
        
        // 회전 임펄스도 추가
        let randomAngular = CGFloat.random(in: -0.3...0.3)
        
        physicsBody.applyImpulse(randomImpulse)
        physicsBody.angularVelocity += randomAngular
    }
    
    /// 비눗방울 하이라이트 효과 추가
    private func addHighlightEffect(radius: CGFloat) {
        // 곡선 하이라이트 생성
        let highlight = SKShapeNode()
        let path = CGMutablePath()
        
        // 곡선 하이라이트 경로 생성 (테두리 쪽으로 이동)
        let startX = -radius * 0.7  // 더 테두리 쪽으로 이동
        let startY = radius * 0.5   // 더 위쪽으로 이동
        let endX = -radius * 0.4    // 더 테두리 쪽으로 이동
        let endY = radius * 0.7     // 더 위쪽으로 이동
        let controlX = -radius * 0.45  // 컨트롤 포인트도 조정
        let controlY = radius * 0.8    // 더 위쪽으로
        
        // 곡선 경로 생성
        path.move(to: CGPoint(x: startX, y: startY))
        path.addQuadCurve(to: CGPoint(x: endX, y: endY), 
                         control: CGPoint(x: controlX, y: controlY))
        
        // 하이라이트 설정
        highlight.path = path
        highlight.strokeColor = .white
        highlight.lineWidth = radius * 0.12  // 약간 더 얇게 조정
        highlight.lineCap = .round  // 둥근 끝
        highlight.alpha = 0.8  // 약간 더 투명하게
        highlight.name = "highlight"
        
        self.addChild(highlight)
    }
    
    /// 하이라이트를 항상 고정된 방향으로 유지
    func updateHighlightRotation() {
        if let highlight = self.childNode(withName: "highlight") {
            // 비눗방울의 회전과 반대로 회전시켜 고정 효과 구현
            highlight.zRotation = -self.zRotation
        }
    }
    
    // MARK: - Public Methods
    
    /// 비눗방울 진화 - 다음 단계로 업그레이드
    /// - Returns: 진화된 새 비눗방울 또는 nil (Mega일 경우)
    func evolve() -> BubbleNode? {
        guard let nextType = bubbleType.nextType else { 
            return nil // 이미 최대 크기인 경우
        }
        
        return BubbleNode(type: nextType)
    }
    
    /// 비눗방울 충돌 시 변형 효과 (탄성 시스템 활용)
    /// - Parameters:
    ///   - scaleX: X축 스케일
    ///   - scaleY: Y축 스케일
    func deform(scaleX: CGFloat, scaleY: CGFloat) {
        // 새로운 탄성 시스템 사용
        applyElasticDeformation(scaleX: scaleX, scaleY: scaleY, impactDirection: nil)
    }

    /// 변형 효과 후 원래 크기로 복원 (부드러운 탄성 복원)
    func resetDeform() {
        // 탄성 복원 애니메이션
        let resetAction = SKAction.scale(to: 1.0, duration: 0.15)
        resetAction.timingMode = .easeOut
        self.run(resetAction, withKey: "resetDeformation")
    }
    
    /// 풀링 시스템을 위한 리셋 메서드
    func reset() {
        self.removeAllActions()
        self.removeAllChildren()
        self.alpha = 1.0
        self.setScale(1.0)
        self.isMerging = false  // 합치기 상태 리셋
        self.setupPhysicalAppearance()
    }
    
    /// 합치기 상태 설정
    func setMerging(_ merging: Bool) {
        isMerging = merging
        if merging {
            // 합치기 중일 때는 물리 바디 비활성화하여 추가 충돌 방지
            physicsBody?.isDynamic = false
        }
    }
    
    /// 눈동자 방향 업데이트 (현재보다 큰 방울 중 가장 가까운 것을 바라보기)
    /// - Parameter allBubbles: 씬의 모든 방울들
    func updatePupilDirection(allBubbles: [BubbleNode]) {
        // 왼쪽과 오른쪽 눈동자 찾기
        guard let leftEyeWhite = children.first(where: { $0.position.x < 0 && $0 is SKShapeNode }),
              let rightEyeWhite = children.first(where: { $0.position.x > 0 && $0 is SKShapeNode }),
              let leftPupil = leftEyeWhite.childNode(withName: "leftPupil"),
              let rightPupil = rightEyeWhite.childNode(withName: "rightPupil") else {
            return
        }
        
        let maxOffset: CGFloat = originalRadius * 0.08  // 눈동자가 움직일 수 있는 최대 거리
        
        // 현재 방울보다 큰 방울들을 찾기
        let largerBubbles = allBubbles.filter { bubble in
            bubble != self && 
            bubble.parent != nil && 
            bubble.bubbleType.rawValue > self.bubbleType.rawValue
        }
        
        if !largerBubbles.isEmpty {
            // 가장 가까운 큰 방울 찾기
            let closestLargerBubble = largerBubbles.min { bubble1, bubble2 in
                let distance1 = hypot(bubble1.position.x - self.position.x, bubble1.position.y - self.position.y)
                let distance2 = hypot(bubble2.position.x - self.position.x, bubble2.position.y - self.position.y)
                return distance1 < distance2
            }
            
            if let target = closestLargerBubble {
                // 목표 방울의 월드 좌표를 현재 방울의 로컬 좌표로 변환
                let targetPosition = self.convert(target.position, from: target.parent!)
                
                // 방향 벡터 계산
                let direction = CGVector(dx: targetPosition.x, dy: targetPosition.y)
                let distance = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
                
                if distance > 0 {
                    // 정규화된 방향 벡터
                    let normalizedDirection = CGVector(dx: direction.dx / distance, dy: direction.dy / distance)
                    
                    // 눈동자 새로운 위치 계산
                    let pupilOffset = CGPoint(
                        x: normalizedDirection.dx * maxOffset,
                        y: normalizedDirection.dy * maxOffset
                    )
                    
                    // 눈동자 이동 애니메이션
                    let moveAction = SKAction.move(to: pupilOffset, duration: 0.2)
                    leftPupil.run(moveAction)
                    rightPupil.run(moveAction)
                    return
                }
            }
        }
        
        // 큰 방울이 없으면 중앙으로 돌아가기
        let centerAction = SKAction.move(to: CGPoint.zero, duration: 0.3)
        leftPupil.run(centerAction)
        rightPupil.run(centerAction)
    }
    
    /// 비눗방울 충돌 효과
    /// - Parameter position: 충돌 위치
    func showCollisionEffect(at position: CGPoint) {
        // 간단한 스케일 애니메이션
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        self.run(pulse)
        
        // 나중에 파티클 효과 추가 예정
    }
    
    /// 충돌 시 찌그러짐 효과 (개선된 버전 - Phase 2.2.8)
    /// - Parameter impactDirection: 충돌 방향 벡터
    func showImpactDeformation(impactDirection: CGVector) {
        // 쿨다운 시간 확인 (무한 반복 방지)
        let currentTime = CACurrentMediaTime()
        if currentTime - lastImpactTime < impactCooldown {
            return
        }
        lastImpactTime = currentTime

        // 충돌 방향에 따른 찌그러짐 계산
        let impactMagnitude = sqrt(impactDirection.dx * impactDirection.dx + impactDirection.dy * impactDirection.dy)

        // 임계값 이하의 약한 충돌은 무시
        guard impactMagnitude > 50.0 else { return }

        let normalizedDirection = CGVector(dx: impactDirection.dx / impactMagnitude, dy: impactDirection.dy / impactMagnitude)

        // 찌그러짐 정도 (속도에 비례, 크기에 따라 차등 적용)
        let sizeModifier = 1.0 / (bubbleType.radius / 30.0) // 작은 방울은 덜 변형
        let deformAmount = min(impactMagnitude * 0.0006 * sizeModifier, 0.2) // 최대 20%

        // 충돌 방향에 따른 X, Y 스케일 조정 (더 자연스러운 변형)
        // 충돌 방향으로는 압축, 수직 방향으로는 확장 (비눗방울의 표면 장력 효과)
        let compressX = 1.0 - (abs(normalizedDirection.dx) * deformAmount)
        let compressY = 1.0 - (abs(normalizedDirection.dy) * deformAmount)
        let expandX = 1.0 + (abs(normalizedDirection.dy) * deformAmount * 0.5) // 수직 방향으로 확장
        let expandY = 1.0 + (abs(normalizedDirection.dx) * deformAmount * 0.5)

        let finalScaleX = compressX * expandX
        let finalScaleY = compressY * expandY

        // 표면 장력 시뮬레이션 (Phase 2.2.9)
        applyElasticDeformation(scaleX: finalScaleX, scaleY: finalScaleY, impactDirection: normalizedDirection)
    }

    /// 탄성 변형 애니메이션 적용 (Phase 2.2.9 & 2.2.10)
    /// - Parameters:
    ///   - scaleX: X축 스케일
    ///   - scaleY: Y축 스케일
    ///   - impactDirection: 충돌 방향 (옵셔널)
    private func applyElasticDeformation(scaleX: CGFloat, scaleY: CGFloat, impactDirection: CGVector? = nil) {
        // 표면 장력 매개변수 (비눗방울 특성 반영)
        let surfaceTension: CGFloat = 0.7 // 표면 장력 강도 (0~1)
        let elasticRebound: CGFloat = 0.12 // 탄성 반발 강도

        // 1단계: 찌그러짐 (빠른 압축)
        let deformDuration: TimeInterval = 0.04
        let deformAction = SKAction.scaleX(to: scaleX, y: scaleY, duration: deformDuration)
        deformAction.timingMode = .easeIn

        // 2단계: 과도한 복원 (탄성으로 원래보다 약간 초과)
        let overRebound: CGFloat = 1.0 + elasticRebound
        let reboundX = 1.0 + (1.0 - scaleX) * elasticRebound
        let reboundY = 1.0 + (1.0 - scaleY) * elasticRebound
        let reboundDuration: TimeInterval = 0.12
        let reboundAction = SKAction.scaleX(to: reboundX, y: reboundY, duration: reboundDuration)
        reboundAction.timingMode = .easeOut

        // 3단계: 작은 진동 (표면 장력에 의한 진동)
        let oscillationCount = 2
        var oscillations: [SKAction] = []

        for i in 0..<oscillationCount {
            let dampingFactor = 1.0 - CGFloat(i) / CGFloat(oscillationCount) // 감쇠
            let oscillationAmount = elasticRebound * 0.3 * dampingFactor

            let oscillateDuration: TimeInterval = 0.08 / Double(i + 1)

            // 축소
            let shrinkAction = SKAction.scaleX(to: 1.0 - oscillationAmount * 0.5,
                                               y: 1.0 - oscillationAmount * 0.5,
                                               duration: oscillateDuration)
            shrinkAction.timingMode = .easeInEaseOut

            // 확대
            let expandAction = SKAction.scaleX(to: 1.0 + oscillationAmount * 0.3,
                                               y: 1.0 + oscillationAmount * 0.3,
                                               duration: oscillateDuration)
            expandAction.timingMode = .easeInEaseOut

            oscillations.append(shrinkAction)
            oscillations.append(expandAction)
        }

        // 4단계: 최종 안정화 (Phase 2.2.10 - 탄성 복원)
        let stabilizeDuration: TimeInterval = 0.1
        let stabilizeAction = SKAction.scale(to: 1.0, duration: stabilizeDuration)
        stabilizeAction.timingMode = .easeOut

        // 전체 변형 시퀀스
        var sequence: [SKAction] = [deformAction, reboundAction]
        sequence.append(contentsOf: oscillations)
        sequence.append(stabilizeAction)

        let elasticSequence = SKAction.sequence(sequence)

        // 약한 진동 효과 (옵셔널)
        var combinedActions: [SKAction] = [elasticSequence]

        if let direction = impactDirection {
            let vibrationStrength: CGFloat = 0.8
            let vibration = SKAction.sequence([
                SKAction.moveBy(x: direction.dx * vibrationStrength,
                               y: direction.dy * vibrationStrength,
                               duration: 0.02),
                SKAction.moveBy(x: -direction.dx * vibrationStrength * 0.5,
                               y: -direction.dy * vibrationStrength * 0.5,
                               duration: 0.02),
                SKAction.moveBy(x: direction.dx * vibrationStrength * 0.25,
                               y: direction.dy * vibrationStrength * 0.25,
                               duration: 0.02),
                SKAction.move(to: position, duration: 0.02) // 원위치
            ])
            combinedActions.append(vibration)
        }

        // 동시 실행
        let impactEffect = SKAction.group(combinedActions)
        self.run(impactEffect, withKey: "elasticDeformation")
    }
    
    /// 공간 압박 시 방울 형태 변형 (Phase 2.2.9 - 표면 장력 시뮬레이션)
    /// - Parameters:
    ///   - availableSpace: 사용 가능한 공간 크기
    ///   - pressureDirection: 압력 방향 (x: 수평, y: 수직)
    func adaptToSpaceConstraints(availableSpace: CGSize, pressureDirection: CGVector) {
        let currentSize = CGSize(width: originalRadius * 2, height: originalRadius * 2)

        // 압박 정도 계산
        let spaceRatioX = availableSpace.width / currentSize.width
        let spaceRatioY = availableSpace.height / currentSize.height

        // 압박이 심한 경우에만 변형 (공간이 85% 미만일 때)
        guard spaceRatioX < 0.85 || spaceRatioY < 0.85 else {
            // 공간이 충분하면 정상 형태로 복원
            if isCompressed {
                restoreNormalShape()
            }
            return
        }

        isCompressed = true

        // 압력 방향에 따른 변형 계산
        let pressureMagnitude = sqrt(pressureDirection.dx * pressureDirection.dx + pressureDirection.dy * pressureDirection.dy)

        if pressureMagnitude > 0 {
            // 압력 방향으로 압축, 수직 방향으로 확장
            let normalizedPressure = CGVector(dx: pressureDirection.dx / pressureMagnitude,
                                             dy: pressureDirection.dy / pressureMagnitude)

            // 변형 계산 (표면 장력으로 인한 제한된 변형)
            let maxDeformation: CGFloat = 0.25 // 최대 25% 변형
            let deformX = max(0.75, min(1.0, spaceRatioX))
            let deformY = max(0.75, min(1.0, spaceRatioY))

            // 압력 방향 반영
            let finalDeformX = 1.0 - (1.0 - deformX) * abs(normalizedPressure.dx)
            let finalDeformY = 1.0 - (1.0 - deformY) * abs(normalizedPressure.dy)

            currentDeformation = CGPoint(x: finalDeformX, y: finalDeformY)
            updateShape()
        } else {
            // 압력 방향 없이 균등한 압축
            let uniformDeform = min(spaceRatioX, spaceRatioY)
            currentDeformation = CGPoint(x: uniformDeform, y: uniformDeform)
            updateShape()
        }
    }
    
    /// 방울 모양을 현재 변형 상태에 맞게 업데이트
    private func updateShape() {
        let visualRadius = originalRadius
        
        // 변형된 타원 생성
        let width = visualRadius * 2 * currentDeformation.x
        let height = visualRadius * 2 * currentDeformation.y
        
        let ellipseRect = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        let ellipsePath = CGPath(ellipseIn: ellipseRect, transform: nil)
        
        // 부드러운 전환을 위한 애니메이션
        let pathAction = SKAction.customAction(withDuration: 0.2) { [weak self] node, elapsedTime in
            guard let self = self else { return }
            
            let progress = elapsedTime / 0.2
            let currentWidth = visualRadius * 2 * (1 + (self.currentDeformation.x - 1) * progress)
            let currentHeight = visualRadius * 2 * (1 + (self.currentDeformation.y - 1) * progress)
            
            let rect = CGRect(x: -currentWidth/2, y: -currentHeight/2, width: currentWidth, height: currentHeight)
            self.path = CGPath(ellipseIn: rect, transform: nil)
        }
        
        self.run(pathAction)
        
        // 압축 상태에 따른 색상 조정
        if isCompressed {
            let brightenAction = SKAction.colorize(with: bubbleType.color.lighter(), colorBlendFactor: 0.3, duration: 0.2)
            self.run(brightenAction)
        } else {
            let normalizeAction = SKAction.colorize(with: bubbleType.color, colorBlendFactor: 1.0, duration: 0.2)
            self.run(normalizeAction)
        }
    }
    
    /// 정상 형태로 복원
    func restoreNormalShape() {
        if currentDeformation != CGPoint(x: 1.0, y: 1.0) {
            currentDeformation = CGPoint(x: 1.0, y: 1.0)
            updateShape()
        }
        isCompressed = false
    }
    
    // MARK: - Blinking Animation
    
    /// 깜빡이는 애니메이션 시작
    private func startBlinkingAnimation() {
        // 랜덤한 깜빡임 간격 (2~8초)
        let randomDelay = Double.random(in: 2.0...8.0)
        
        // 깜빡임 애니메이션 실행
        let blinkAction = SKAction.sequence([
            SKAction.wait(forDuration: randomDelay),
            SKAction.run { [weak self] in
                self?.performBlink()
            }
        ])
        
        // 무한 반복
        let repeatAction = SKAction.repeatForever(blinkAction)
        self.run(repeatAction, withKey: "blinkingAnimation")
    }
    
    /// 깜빡임 실행
    private func performBlink() {
        // 모든 눈 찾기 (이름으로 찾기)
        var eyeNodes: [SKNode] = []
        
        // 자식 노드에서 눈 찾기
        for child in children {
            if let name = child.name, name.contains("Eye") {
                eyeNodes.append(child)
            }
        }
        
        // 눈이 없으면 기본 방식으로 찾기 (흰색 원형 노드)
        if eyeNodes.isEmpty {
            for child in children {
                if let shapeNode = child as? SKShapeNode,
                   shapeNode.fillColor == SKColor.white && 
                   shapeNode.strokeColor == SKColor.black {
                    eyeNodes.append(child)
                }
            }
        }
        
        // 눈이 없으면 종료
        guard !eyeNodes.isEmpty else { return }
        
        // 깜빡임 애니메이션 시퀀스
        let blinkDuration: TimeInterval = 0.15
        
        // 눈을 감는 애니메이션 (스케일 Y를 0으로)
        let closeEyes = SKAction.scaleY(to: 0.1, duration: blinkDuration * 0.5)
        
        // 눈을 뜨는 애니메이션 (스케일 Y를 1로)
        let openEyes = SKAction.scaleY(to: 1.0, duration: blinkDuration * 0.5)
        
        // 깜빡임 시퀀스
        let blinkSequence = SKAction.sequence([closeEyes, openEyes])
        
        // 모든 눈에 애니메이션 적용
        for eyeNode in eyeNodes {
            eyeNode.run(blinkSequence)
        }
        
        // 랜덤하게 다음 깜빡임 시간 설정
        let nextBlinkDelay = Double.random(in: 2.0...8.0)
        let nextBlinkAction = SKAction.sequence([
            SKAction.wait(forDuration: nextBlinkDelay),
            SKAction.run { [weak self] in
                self?.performBlink()
            }
        ])
        
        self.run(nextBlinkAction, withKey: "nextBlink")
    }
    
    /// 깜빡임 애니메이션 중지
    func stopBlinkingAnimation() {
        self.removeAction(forKey: "blinkingAnimation")
        self.removeAction(forKey: "nextBlink")
    }
    
    // MARK: - Eye Opening Animation (for closed eyes)
    
    /// 감은 눈 표정인지 확인
    private func isClosedEyeExpression(_ expression: String) -> Bool {
        return ["closed_happy", "tired", "half_closed"].contains(expression)
    }
    
    /// 감은 눈이 뜨는 애니메이션 시작
    private func startEyeOpeningAnimation(radius: CGFloat, expression: String) {
        // 랜덤한 눈 뜨기 간격 (5~15초)
        let randomDelay = Double.random(in: 5.0...15.0)
        
        let eyeOpenAction = SKAction.sequence([
            SKAction.wait(forDuration: randomDelay),
            SKAction.run { [weak self] in
                self?.performEyeOpening(radius: radius, expression: expression)
            }
        ])
        
        // 무한 반복
        let repeatAction = SKAction.repeatForever(eyeOpenAction)
        self.run(repeatAction, withKey: "eyeOpeningAnimation")
    }
    
    /// 눈 뜨기 실행
    private func performEyeOpening(radius: CGFloat, expression: String) {
        // 현재 감은 눈들을 찾아서 임시로 원형 눈으로 변경
        createTemporaryOpenEyes(radius: radius, expression: expression)
        
        // 랜덤하게 다음 눈 뜨기 시간 설정
        let nextOpenDelay = Double.random(in: 5.0...15.0)
        let nextOpenAction = SKAction.sequence([
            SKAction.wait(forDuration: nextOpenDelay),
            SKAction.run { [weak self] in
                self?.performEyeOpening(radius: radius, expression: expression)
            }
        ])
        
        self.run(nextOpenAction, withKey: "nextEyeOpen")
    }
    
    /// 임시로 열린 눈 생성
    private func createTemporaryOpenEyes(radius: CGFloat, expression: String) {
        // 기존 감은 눈들을 숨기기
        hideClosedEyes()
        
        // 임시 열린 눈 생성
        let eyeRadius = bubbleType == .tiny ? radius * 0.15 : radius * 0.2
        let pupilRadius = bubbleType == .tiny ? radius * 0.075 : radius * 0.1
        let eyeOffset = radius * 0.25
        let eyeY = radius * 0.2
        
        // 왼쪽 임시 눈
        let leftTempEye = createTemporaryEye(
            radius: eyeRadius,
            pupilRadius: pupilRadius,
            position: CGPoint(x: -eyeOffset, y: eyeY),
            name: "tempLeftEye"
        )
        addChild(leftTempEye)
        
        // 오른쪽 임시 눈
        let rightTempEye = createTemporaryEye(
            radius: eyeRadius,
            pupilRadius: pupilRadius,
            position: CGPoint(x: eyeOffset, y: eyeY),
            name: "tempRightEye"
        )
        addChild(rightTempEye)
        
        // 눈 뜨기 애니메이션 (페이드 인)
        [leftTempEye, rightTempEye].forEach { eye in
            eye.alpha = 0
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            eye.run(fadeIn)
        }
        
        // 1~3초 후 다시 감기
        let eyeOpenDuration = Double.random(in: 1.0...3.0)
        let closeAgainAction = SKAction.sequence([
            SKAction.wait(forDuration: eyeOpenDuration),
            SKAction.run { [weak self] in
                self?.closeTemporaryEyes()
            }
        ])
        
        self.run(closeAgainAction, withKey: "closeTemporaryEyes")
    }
    
    /// 임시 눈 노드 생성
    private func createTemporaryEye(radius: CGFloat, pupilRadius: CGFloat, position: CGPoint, name: String) -> SKNode {
        let eyeContainer = SKNode()
        eyeContainer.position = position
        eyeContainer.name = name
        eyeContainer.zPosition = 15  // 기존 눈보다 위에 표시
        
        // 흰자
        let eyeWhite = SKShapeNode(circleOfRadius: radius)
        eyeWhite.fillColor = SKColor.white
        eyeWhite.strokeColor = SKColor.black
        eyeWhite.lineWidth = 1.5
        eyeWhite.position = CGPoint.zero
        eyeContainer.addChild(eyeWhite)
        
        // 눈동자
        let pupil = SKShapeNode(circleOfRadius: pupilRadius)
        pupil.fillColor = SKColor.black
        pupil.strokeColor = SKColor.clear
        pupil.position = CGPoint.zero
        eyeContainer.addChild(pupil)
        
        return eyeContainer
    }
    
    /// 감은 눈들 숨기기
    private func hideClosedEyes() {
        for child in children {
            if let shapeNode = child as? SKShapeNode,
               shapeNode.strokeColor == SKColor.black && 
               shapeNode.fillColor == SKColor.black {
                // 감은 눈으로 보이는 노드들을 임시로 숨기기
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                child.run(fadeOut, withKey: "hideForOpen")
            }
        }
    }
    
    /// 임시 눈들 제거하고 원래 감은 눈 복원
    private func closeTemporaryEyes() {
        // 임시 눈들 제거
        let tempEyes = children.filter { $0.name?.contains("temp") == true }
        tempEyes.forEach { eye in
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeOut, remove])
            eye.run(sequence)
        }
        
        // 원래 감은 눈들 복원
        for child in children {
            if let shapeNode = child as? SKShapeNode,
               shapeNode.strokeColor == SKColor.black && 
               shapeNode.fillColor == SKColor.black {
                let fadeIn = SKAction.fadeIn(withDuration: 0.3)
                child.run(fadeIn, withKey: "restoreClosedEye")
            }
        }
    }
    
    /// 눈 뜨기 애니메이션 중지
    func stopEyeOpeningAnimation() {
        self.removeAction(forKey: "eyeOpeningAnimation")
        self.removeAction(forKey: "nextEyeOpen")
        self.removeAction(forKey: "closeTemporaryEyes")
    }
}

// MARK: - UIColor Extension
extension UIColor {
    func lighter(by amount: CGFloat = 0.2) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: max(0, saturation - amount), brightness: min(1, brightness + amount), alpha: alpha)
        }
        return self
    }
}