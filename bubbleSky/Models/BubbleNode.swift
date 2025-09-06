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
        let expressionTypes = ["happy", "neutral", "surprised", "sleepy", "excited", "closed_happy", "wink_left", "tired", "half_closed"]
        let randomExpression = expressionTypes.randomElement() ?? "neutral"
        
        // 눈 추가
        addEyes(radius: radius, expression: randomExpression)
        
        // 입 추가
        addMouth(radius: radius, expression: randomExpression)
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
        case "surprised":
            // 놀란 입 (작은 원)
            path.addEllipse(in: CGRect(x: -mouthWidth/4, y: -mouthWidth/4, 
                                     width: mouthWidth/2, height: mouthWidth/2))
        case "sleepy":
            // 졸린 입 (작은 가로선)
            path.move(to: CGPoint(x: -mouthWidth/3, y: 0))
            path.addLine(to: CGPoint(x: mouthWidth/3, y: 0))
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
    
    /// 비눗방울 충돌 시 변형 효과
    /// - Parameters:
    ///   - scaleX: X축 스케일
    ///   - scaleY: Y축 스케일
    func deform(scaleX: CGFloat, scaleY: CGFloat) {
        let deformAction = SKAction.scaleX(to: scaleX, y: scaleY, duration: 0.1)
        self.run(deformAction)
    }
    
    /// 변형 효과 후 원래 크기로 복원
    func resetDeform() {
        let resetAction = SKAction.scale(to: 1.0, duration: 0.1)
        self.run(resetAction)
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
    
    /// 충돌 시 찌그러짐 효과
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
        
        // 찌그러짐 정도 (속도에 비례, 강도 감소)
        let deformAmount = min(impactMagnitude * 0.0005, 0.15) // 최대 15%로 감소
        
        // 충돌 방향에 따른 X, Y 스케일 조정
        let scaleX = 1.0 - (abs(normalizedDirection.dx) * deformAmount)
        let scaleY = 1.0 - (abs(normalizedDirection.dy) * deformAmount)
        
        // 찌그러짐 애니메이션 (시간 단축)
        let deformAction = SKAction.sequence([
            SKAction.scaleX(to: scaleX, y: scaleY, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.08)
        ])
        
        // 진동 효과 축소
        let vibration = SKAction.sequence([
            SKAction.moveBy(x: normalizedDirection.dx * 1, y: normalizedDirection.dy * 1, duration: 0.025),
            SKAction.moveBy(x: -normalizedDirection.dx * 1, y: -normalizedDirection.dy * 1, duration: 0.025)
        ])
        
        // 동시 실행
        let impactEffect = SKAction.group([deformAction, vibration])
        self.run(impactEffect)
    }
    
    /// 공간 압박 시 방울 형태 변형 (비활성화됨 - 자연스러운 물리 상호작용을 위해)
    /// - Parameters:
    ///   - availableSpace: 사용 가능한 공간 크기
    ///   - pressureDirection: 압력 방향 (x: 수평, y: 수직)
    func adaptToSpaceConstraints(availableSpace: CGSize, pressureDirection: CGVector) {
        // 형태 변형 비활성화 - 물리 엔진에만 의존
        return
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