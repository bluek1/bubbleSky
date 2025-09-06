import SpriteKit

/// 발사 캐릭터 노드 클래스
/// 비눗방울 요정이 비눗방울을 생성하고 발사하는 캐릭터
class CharacterNode: SKNode {
    
    // MARK: - Properties
    
    /// 캐릭터 바디 (메인 요정 몸체)
    private var characterBody: SKShapeNode!
    
    /// 캐릭터 얼굴 요소들
    private var leftEye: SKShapeNode!
    private var rightEye: SKShapeNode!
    private var mouth: SKShapeNode!
    
    /// 날개 요소들
    private var leftWing: SKShapeNode!
    private var rightWing: SKShapeNode!
    
    /// 마법 지팡이 (선택적)
    private var magicWand: SKNode?
    
    /// 캐릭터 상태
    private var isBlowing = false
    private var isIdle = true
    
    /// 애니메이션 액션들
    private var idleAction: SKAction!
    private var blowingAction: SKAction!
    private var wingFlapAction: SKAction!
    
    /// 원래 위치 저장 (idle 애니메이션 기준점)
    private var originalPosition: CGPoint = CGPoint.zero
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupCharacterVisuals()
        setupAnimations()
        startIdleAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// 캐릭터 시각적 요소 설정
    private func setupCharacterVisuals() {
        setupBody()
        setupFace()
        setupWings()
        setupMagicWand()
    }
    
    /// 캐릭터 몸체 설정
    private func setupBody() {
        // 메인 몸체 (동그란 요정 모습)
        characterBody = SKShapeNode(circleOfRadius: 25)
        characterBody.fillColor = SKColor(red: 0.9, green: 0.8, blue: 1.0, alpha: 0.9) // 연보라색
        characterBody.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1.0)
        characterBody.lineWidth = 2.0
        characterBody.position = CGPoint.zero
        characterBody.zPosition = 1
        
        // 몸체에 반짝이는 효과 추가
        let sparkle = SKShapeNode(circleOfRadius: 15)
        sparkle.fillColor = SKColor.white.withAlphaComponent(0.3)
        sparkle.strokeColor = SKColor.clear
        sparkle.position = CGPoint(x: -5, y: 5)
        characterBody.addChild(sparkle)
        
        addChild(characterBody)
    }
    
    /// 얼굴 요소 설정
    private func setupFace() {
        // 왼쪽 눈
        leftEye = SKShapeNode(circleOfRadius: 4)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -8, y: 5)
        leftEye.zPosition = 2
        characterBody.addChild(leftEye)
        
        // 오른쪽 눈
        rightEye = SKShapeNode(circleOfRadius: 4)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 8, y: 5)
        rightEye.zPosition = 2
        characterBody.addChild(rightEye)
        
        // 입 (기본 상태: 작은 미소)
        let mouthPath = CGMutablePath()
        mouthPath.addArc(center: CGPoint(x: 0, y: -5), 
                        radius: 6, 
                        startAngle: .pi, 
                        endAngle: 0, 
                        clockwise: false)
        
        mouth = SKShapeNode(path: mouthPath)
        mouth.fillColor = .clear
        mouth.strokeColor = .black
        mouth.lineWidth = 2.0
        mouth.position = CGPoint.zero
        mouth.zPosition = 2
        characterBody.addChild(mouth)
    }
    
    /// 날개 설정
    private func setupWings() {
        // 왼쪽 날개
        let leftWingPath = createWingPath()
        leftWing = SKShapeNode(path: leftWingPath)
        leftWing.fillColor = SKColor.cyan.withAlphaComponent(0.6)
        leftWing.strokeColor = SKColor.blue.withAlphaComponent(0.8)
        leftWing.lineWidth = 1.5
        leftWing.position = CGPoint(x: -20, y: 0)
        leftWing.zPosition = 0 // 몸체 뒤에
        addChild(leftWing)
        
        // 오른쪽 날개 (왼쪽을 뒤집어서 사용)
        rightWing = SKShapeNode(path: leftWingPath)
        rightWing.fillColor = SKColor.cyan.withAlphaComponent(0.6)
        rightWing.strokeColor = SKColor.blue.withAlphaComponent(0.8)
        rightWing.lineWidth = 1.5
        rightWing.position = CGPoint(x: 20, y: 0)
        rightWing.xScale = -1 // 수평 뒤집기
        rightWing.zPosition = 0
        addChild(rightWing)
    }
    
    /// 날개 모양 패스 생성
    private func createWingPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: 15, y: 10), control: CGPoint(x: 20, y: 5))
        path.addQuadCurve(to: CGPoint(x: 10, y: 20), control: CGPoint(x: 18, y: 15))
        path.addQuadCurve(to: CGPoint(x: 0, y: 15), control: CGPoint(x: 5, y: 18))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), control: CGPoint(x: -2, y: 8))
        return path
    }
    
    /// 마법 지팡이 설정 (선택적 장식)
    private func setupMagicWand() {
        // 지팡이 막대
        let wandStick = SKShapeNode(rect: CGRect(x: -1, y: 0, width: 2, height: 15))
        wandStick.fillColor = SKColor.brown
        wandStick.strokeColor = .clear
        
        // 지팡이 끝의 별
        let starPath = createStarPath()
        let wandStar = SKShapeNode(path: starPath)
        wandStar.fillColor = SKColor.yellow
        wandStar.strokeColor = SKColor.orange
        wandStar.lineWidth = 1.0
        wandStar.position = CGPoint(x: 0, y: 15)
        
        magicWand = SKNode()
        magicWand?.addChild(wandStick)
        magicWand?.addChild(wandStar)
        magicWand?.position = CGPoint(x: 30, y: 0)
        magicWand?.zPosition = 1
        
        if let wand = magicWand {
            addChild(wand)
        }
    }
    
    /// 별 모양 패스 생성
    private func createStarPath() -> CGPath {
        let path = CGMutablePath()
        let radius: CGFloat = 5
        let innerRadius: CGFloat = 2.5
        let points = 5
        
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points)
            let currentRadius = i % 2 == 0 ? radius : innerRadius
            let x = currentRadius * cos(angle - .pi / 2)
            let y = currentRadius * sin(angle - .pi / 2)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    // MARK: - Animation Setup
    
    /// 애니메이션 액션들 설정
    private func setupAnimations() {
        setupIdleAnimation()
        setupBlowingAnimation()
        setupWingAnimation()
    }
    
    /// 대기 상태 애니메이션 설정
    private func setupIdleAnimation() {
        // 원래 위치 저장
        originalPosition = position
        
        // 위아래 진동 애니메이션 (순환)
        let moveUp = SKAction.run { [weak self] in
            guard let self = self else { return }
            let action = SKAction.moveTo(
                y: self.originalPosition.y + 8, 
                duration: 2.0
            )
            action.timingMode = .easeInEaseOut
            self.run(action)
        }
        
        let waitUp = SKAction.wait(forDuration: 2.0)
        
        let moveDown = SKAction.run { [weak self] in
            guard let self = self else { return }
            let action = SKAction.moveTo(
                y: self.originalPosition.y - 8, 
                duration: 2.0
            )
            action.timingMode = .easeInEaseOut
            self.run(action)
        }
        
        let waitDown = SKAction.wait(forDuration: 2.0)
        
        let sequence = SKAction.sequence([moveUp, waitUp, moveDown, waitDown])
        idleAction = SKAction.repeatForever(sequence)
    }
    
    /// 비눗방울 불기 애니메이션 설정
    private func setupBlowingAnimation() {
        // 입 모양 변경 (O 모양으로)
        let mouthBlowPath = CGMutablePath()
        mouthBlowPath.addEllipse(in: CGRect(x: -3, y: -8, width: 6, height: 6))
        
        let changeToBlowMouth = SKAction.run { [weak self] in
            self?.mouth.path = mouthBlowPath
        }
        
        // 원래 입 모양으로 복원
        let originalMouthPath = createOriginalMouthPath()
        let restoreOriginalMouth = SKAction.run { [weak self] in
            self?.mouth.path = originalMouthPath
        }
        
        // 호흡 효과 (몸체 크기 변화)
        let breatheIn = SKAction.scale(to: 1.1, duration: 0.5)
        breatheIn.timingMode = .easeOut
        
        let breatheOut = SKAction.scale(to: 1.0, duration: 0.3)
        breatheOut.timingMode = .easeIn
        
        let wait = SKAction.wait(forDuration: 0.2)
        
        blowingAction = SKAction.sequence([
            changeToBlowMouth,
            breatheIn,
            wait,
            breatheOut,
            restoreOriginalMouth
        ])
    }
    
    /// 원래 입 모양 패스 생성
    private func createOriginalMouthPath() -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: -5), 
                   radius: 6, 
                   startAngle: .pi, 
                   endAngle: 0, 
                   clockwise: false)
        return path
    }
    
    /// 날개 펄럭이기 애니메이션 설정
    private func setupWingAnimation() {
        let flapUp = SKAction.rotate(byAngle: .pi / 8, duration: 0.3)
        let flapDown = SKAction.rotate(byAngle: -.pi / 4, duration: 0.6)
        let flapRestore = SKAction.rotate(byAngle: .pi / 8, duration: 0.3)
        
        let flapSequence = SKAction.sequence([flapUp, flapDown, flapRestore])
        wingFlapAction = SKAction.repeatForever(flapSequence)
    }
    
    // MARK: - Animation Control
    
    /// 대기 상태 애니메이션 시작
    func startIdleAnimation() {
        guard isIdle else { return }
        
        run(idleAction, withKey: "idleAnimation")
        leftWing.run(wingFlapAction, withKey: "wingFlap")
        rightWing.run(wingFlapAction, withKey: "wingFlap")
        
        // 마법 지팡이가 있으면 반짝이기
        if let wand = magicWand {
            let twinkle = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 1.0),
                SKAction.fadeAlpha(to: 1.0, duration: 1.0)
            ])
            wand.run(SKAction.repeatForever(twinkle), withKey: "twinkle")
        }
    }
    
    /// 대기 상태 애니메이션 중지
    func stopIdleAnimation() {
        removeAction(forKey: "idle")
        leftWing.removeAction(forKey: "wingFlap")
        rightWing.removeAction(forKey: "wingFlap")
        magicWand?.removeAction(forKey: "twinkle")
        isIdle = false
    }
    
    /// 비눗방울 생성 애니메이션 실행
    func performBubbleCreationAnimation(completion: @escaping () -> Void) {
        stopIdleAnimation()
        isBlowing = true
        
        // 비눗방울 생성 애니메이션 실행
        run(blowingAction) { [weak self] in
            self?.isBlowing = false
            self?.isIdle = true
            completion()
            // 애니메이션 완료 후 대기 상태로 복귀
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.startIdleAnimation()
            }
        }
    }
    
    /// 만족 표정 애니메이션 (발사 후)
    func performSatisfactionAnimation() {
        let wink = SKAction.run { [weak self] in
            self?.rightEye.alpha = 0.2
        }
        let restoreEye = SKAction.run { [weak self] in
            self?.rightEye.alpha = 1.0
        }
        let wait = SKAction.wait(forDuration: 0.5)
        
        let satisfactionSequence = SKAction.sequence([wink, wait, restoreEye])
        run(satisfactionSequence)
    }
    
    /// 위치가 변경되었을 때 원래 위치 업데이트
    override var position: CGPoint {
        didSet {
            // 새로운 위치로 이동할 때 애니메이션을 다시 설정
            originalPosition = position
            if isIdle {
                restartIdleAnimation()
            }
        }
    }
    
    /// idle 애니메이션 재시작
    private func restartIdleAnimation() {
        removeAction(forKey: "idleAnimation")
        setupIdleAnimation()
        run(idleAction, withKey: "idleAnimation")
    }
    
    /// 캐릭터 위치 리셋 (게임 재시작 등에 사용)
    func resetPosition(to newPosition: CGPoint) {
        removeAllActions()
        position = newPosition
        originalPosition = newPosition
        isIdle = true
        startIdleAnimation()
    }
}
