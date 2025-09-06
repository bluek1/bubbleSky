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
        
        // 색상 설정
        self.fillColor = bubbleType.color
        self.strokeColor = bubbleType.color.withAlphaComponent(0.7)
        self.lineWidth = 1.5
        
        // 반사 효과 (하이라이트) - 크기에 맞게 조정
        addHighlightEffect(radius: visualRadius)
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
        let highlightSize = radius * 0.6
        
        let highlight = SKShapeNode(circleOfRadius: highlightSize)
        highlight.fillColor = .white
        highlight.alpha = 0.2
        highlight.position = CGPoint(x: -radius * 0.3, y: radius * 0.3) // 왼쪽 위에 위치
        
        self.addChild(highlight)
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
        self.setupPhysicalAppearance()
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