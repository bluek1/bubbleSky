//
//  GameScene.swift
//  bubbleSky
//
//  Created by sang gi kim on 9/5/25.
//

import SpriteKit
import Foundation

class GameScene: SKScene {
    
    // MARK: - Properties
    
    /// 게임 매니저
    private let gameManager = GameManager.shared
    
    /// 현재 발사 준비 중인 비눗방울
    private var currentBubble: BubbleNode?
    
    /// 발사 캐릭터 노드
    private var launchCharacter: CharacterNode?
    
    /// 곡선형 상단 경계
    private var topCurvedBoundary: SKShapeNode?
    
    /// 좌우 벽면
    private var leftWall: SKNode?
    private var rightWall: SKNode?
    
    /// 게임 오버 라인
    private var gameOverLine: SKShapeNode?
    
    /// UI 요소들
    private var scoreLabel: SKLabelNode?
    private var timeLabel: SKLabelNode?
    private var levelLabel: SKLabelNode?
    private var bestScoreLabel: SKLabelNode?
    private var bubbleCountLabel: SKLabelNode?
    private var nextBubbleLabel: SKLabelNode?
    
    /// 게임 상태 (GameManager로 이관됨)
    private var isGameActive = true
    
    /// 게임 오버 관련
    private var gameOverTimer: Timer?
    private var bubblesAboveLine: Set<BubbleNode> = []
    
    /// 연속 방지 시스템
    private var consecutiveBubbleCount = 0
    private var lastBubbleType: BubbleType?
    
    /// 터치 관련 (패닝 대체)
    private var isDragging = false
    private var currentTouchLocation: CGPoint = .zero
    
    /// 플레이 영역 정보
    private var playAreaBounds: CGRect = CGRect.zero
    private var initialTouchPosition: CGPoint = .zero

    /// 동적 배경 시스템 (Phase 2.3)
    private var backgroundGradient: SKSpriteNode?
    private var clouds: [SKShapeNode] = []
    private var starsNode: SKNode?
    private var weatherParticleNode: SKEmitterNode?
    private let timeManager = TimeManager.shared

    // MARK: - Scene Lifecycle
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // 좌표계를 화면 중앙 기준으로 설정
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // 좌표계를 화면 중앙 기준으로 설정
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    override func didMove(to view: SKView) {
        setupDynamicBackground()
        setupPhysicsWorld()
        setupPlayArea()
        setupUI()
        setupLaunchSystem()

        // TimeManager 설정 (Phase 2.3)
        setupTimeManager()

        // 게임 시작
        gameManager.startNewGame()
    }
    
    
    // MARK: - Setup Methods
    
    /// 동적 배경 설정 (Phase 2.3)
    private func setupDynamicBackground() {
        // 초기 배경색 설정
        backgroundColor = .black

        // 그라데이션 배경 생성
        let gradientSize = CGSize(width: size.width, height: size.height)
        let texture = createGradientTexture(
            size: gradientSize,
            topColor: timeManager.currentTimeOfDay.skyTopColor,
            bottomColor: timeManager.currentTimeOfDay.skyBottomColor
        )

        backgroundGradient = SKSpriteNode(texture: texture)
        backgroundGradient?.position = CGPoint.zero
        backgroundGradient?.zPosition = -100
        if let gradient = backgroundGradient {
            addChild(gradient)
        }

        // 별 추가 (밤/새벽만)
        if timeManager.currentTimeOfDay.showStars {
            addStars()
        }

        // 구름 효과 추가
        addFloatingClouds()
    }

    /// TimeManager 설정 및 콜백 등록 (Phase 2.3)
    private func setupTimeManager() {
        // 시간 변경 콜백
        timeManager.onTimeChanged = { [weak self] newTime in
            self?.updateBackgroundForTime(newTime)
        }

        // 날씨 변경 콜백 (추후 구현)
        timeManager.onWeatherChanged = { [weak self] newWeather in
            self?.updateWeatherEffects(newWeather)
        }

        // 자동 업데이트 시작 (1분마다)
        timeManager.startAutoUpdate()

        // 초기 날씨 설정
        timeManager.randomizeWeather()
    }

    /// 시간대 변경 시 배경 업데이트 (Phase 2.3)
    private func updateBackgroundForTime(_ timeOfDay: TimeOfDay) {
        guard let gradient = backgroundGradient else { return }

        // 새로운 그라데이션 텍스처 생성
        let newTexture = createGradientTexture(
            size: CGSize(width: size.width, height: size.height),
            topColor: timeOfDay.skyTopColor,
            bottomColor: timeOfDay.skyBottomColor
        )

        // 부드러운 전환 애니메이션 (30초)
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 15.0)
        let changeTexture = SKAction.run {
            gradient.texture = newTexture
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 15.0)
        let sequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])

        gradient.run(sequence)

        // 구름 색상 업데이트
        updateCloudsColor(for: timeOfDay)

        // 별 표시/숨김
        if timeOfDay.showStars && starsNode == nil {
            addStars()
        } else if !timeOfDay.showStars && starsNode != nil {
            removeStars()
        }
    }

    /// 그라데이션 텍스처 생성 (Phase 2.3)
    private func createGradientTexture(size: CGSize, topColor: UIColor, bottomColor: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            var topR: CGFloat = 0, topG: CGFloat = 0, topB: CGFloat = 0, topA: CGFloat = 0
            var bottomR: CGFloat = 0, bottomG: CGFloat = 0, bottomB: CGFloat = 0, bottomA: CGFloat = 0

            topColor.getRed(&topR, green: &topG, blue: &topB, alpha: &topA)
            bottomColor.getRed(&bottomR, green: &bottomG, blue: &bottomB, alpha: &bottomA)

            let colors = [
                topColor.cgColor,
                bottomColor.cgColor
            ] as CFArray

            let locations: [CGFloat] = [0.0, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: size.width / 2, y: size.height),
                    end: CGPoint(x: size.width / 2, y: 0),
                    options: []
                )
            }
        }

        return SKTexture(image: image)
    }

    /// 별 효과 추가 (밤/새벽) (Phase 2.3)
    private func addStars() {
        guard starsNode == nil else { return }

        let stars = SKNode()
        stars.zPosition = -90

        // 랜덤 별 생성 (50~100개)
        let starCount = Int.random(in: 50...100)

        for _ in 0..<starCount {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.0...2.5))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...1.0)

            // 랜덤 위치 (화면 전체)
            let randomX = CGFloat.random(in: -size.width/2...size.width/2)
            let randomY = CGFloat.random(in: -size.height/2...size.height/2)
            star.position = CGPoint(x: randomX, y: randomY)

            // 깜빡임 애니메이션
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1.0...3.0))
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1.0...3.0))
            let blink = SKAction.sequence([fadeOut, fadeIn])
            let repeatBlink = SKAction.repeatForever(blink)
            star.run(repeatBlink)

            stars.addChild(star)
        }

        starsNode = stars
        addChild(stars)

        // 페이드 인 효과
        stars.alpha = 0.0
        stars.run(SKAction.fadeIn(withDuration: 10.0))
    }

    /// 별 효과 제거 (Phase 2.3)
    private func removeStars() {
        guard let stars = starsNode else { return }

        // 페이드 아웃 후 제거
        let fadeOut = SKAction.fadeOut(withDuration: 10.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeOut, remove])

        stars.run(sequence) { [weak self] in
            self?.starsNode = nil
        }
    }

    /// 구름 색상 업데이트 (Phase 2.3)
    private func updateCloudsColor(for timeOfDay: TimeOfDay) {
        let newColor = timeOfDay.cloudColor

        for cloud in clouds {
            let colorAction = SKAction.run {
                cloud.fillColor = newColor
            }
            cloud.run(colorAction)
        }
    }

    /// 날씨 효과 업데이트 (Phase 2.3)
    private func updateWeatherEffects(_ weather: WeatherType) {
        // 기존 날씨 파티클 제거
        if let existingWeather = weatherParticleNode {
            let fadeOut = SKAction.fadeOut(withDuration: 2.0)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([fadeOut, remove])
            existingWeather.run(sequence)
            weatherParticleNode = nil
        }

        // 새로운 날씨 효과 추가
        switch weather {
        case .clear:
            // 맑음: 파티클 없음
            break

        case .cloudy:
            // 흐림: 구름이 더 많아보이도록 (이미 구름이 있으므로 추가 효과 없음)
            // 추후 구름 개수 증가 로직 추가 가능
            break

        case .rainy:
            // 비: 빗방울 파티클
            let rain = ParticleEffects.shared.createRainEffect(sceneSize: size)
            weatherParticleNode = rain
            addChild(rain)

            // 페이드 인
            rain.alpha = 0.0
            rain.run(SKAction.fadeIn(withDuration: 2.0))

        case .snowy:
            // 눈: 눈송이 파티클
            let snow = ParticleEffects.shared.createSnowEffect(sceneSize: size)
            weatherParticleNode = snow
            addChild(snow)

            // 페이드 인
            snow.alpha = 0.0
            snow.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    /// 떠다니는 구름 효과 추가 (Phase 2.3 개선)
    private func addFloatingClouds() {
        let cloudCount = 5  // 구름 개수 증가

        for i in 0..<cloudCount {
            let cloud = createCloud()

            // 구름 위치 설정 (화면 상단 영역)
            let randomX = CGFloat.random(in: -size.width/2...size.width/2)
            let randomY = CGFloat.random(in: size.height/4...size.height/2)
            cloud.position = CGPoint(x: randomX, y: randomY)

            // 구름 애니메이션 (천천히 좌우로 이동)
            let moveDistance = CGFloat.random(in: -80...80)
            let moveDuration = TimeInterval.random(in: 10...20)
            let moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
            let reverseAction = moveAction.reversed()
            let floatAction = SKAction.sequence([moveAction, reverseAction])
            let repeatAction = SKAction.repeatForever(floatAction)

            cloud.run(repeatAction)
            cloud.zPosition = -50 - CGFloat(i) * 2  // 깊이감 추가

            // clouds 배열에 추가 (Phase 2.3)
            clouds.append(cloud)

            addChild(cloud)
        }
    }

    /// 구름 모양 생성 (Phase 2.3 개선)
    private func createCloud() -> SKShapeNode {
        let cloudPath = CGMutablePath()

        // 간단한 구름 모양 (3개의 원을 조합)
        let sizeMultiplier = CGFloat.random(in: 0.8...1.3)  // 크기 다양화
        let centerRadius: CGFloat = 25 * sizeMultiplier
        let sideRadius: CGFloat = 20 * sizeMultiplier

        cloudPath.addEllipse(in: CGRect(x: -centerRadius, y: -centerRadius/2, width: centerRadius*2, height: centerRadius))
        cloudPath.addEllipse(in: CGRect(x: -centerRadius*1.5, y: -sideRadius/2, width: sideRadius*2, height: sideRadius))
        cloudPath.addEllipse(in: CGRect(x: centerRadius*0.5, y: -sideRadius/2, width: sideRadius*2, height: sideRadius))

        let cloud = SKShapeNode(path: cloudPath)

        // 시간대별 색상 적용 (Phase 2.3)
        cloud.fillColor = timeManager.currentTimeOfDay.cloudColor
        cloud.strokeColor = UIColor.clear

        return cloud
    }
    
    /// 물리 월드 설정
    private func setupPhysicsWorld() {
        physicsWorld.contactDelegate = self
        // 비눗방울이 천정으로 올라가도록 중력을 위쪽으로 설정
        physicsWorld.gravity = CGVector(dx: 0, dy: 5.0)
        
        // 속도 제한 설정 (경계선 겹침 방지)
        physicsWorld.speed = 0.6  // 물리 시뮬레이션 속도를 60%로 제한 (80%에서 30% 감소)
        
        // 디버그 모드 (개발 중에만 활성화)
        #if DEBUG
        self.view?.showsPhysics = true
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
        #endif
    }
    
    /// 곡선형 플레이 영역 설정
    private func setupPlayArea() {
        setupPlayBoundary()
        setupTopCurvedBoundary()
        setupSideWalls()
        setupGameOverLine()
    }
    
    /// 플레이 영역 경계 설정 (빨간색 박스 영역)
    private func setupPlayBoundary() {
        let screenWidth = size.width
        let screenHeight = size.height
        
                // 플레이 영역 크기 (화면 대비 비율)
        let playAreaWidth = screenWidth * 0.77  // 0.7에서 0.77로 10% 증가
        let playAreaHeight = screenHeight * 0.8
        
        // 플레이 영역 위치 (화면 중앙에서 약간 아래쪽)
        let playAreaRect = CGRect(
            x: -playAreaWidth/2,
            y: -playAreaHeight/2 + screenHeight * 0.05, // 약간 아래쪽으로 이동
            width: playAreaWidth,
            height: playAreaHeight
        )
        
        // 플레이 영역 정보 저장
        playAreaBounds = playAreaRect
        
        // 플레이 영역 물리 경계 설정
        let playBoundary = SKPhysicsBody(edgeLoopFrom: playAreaRect)
        playBoundary.categoryBitMask = PhysicsCategory.wall
        playBoundary.restitution = 0.2  // 0.4에서 0.2로 감소하여 반발력 줄임
        playBoundary.friction = 0.3
        
        // 플레이 영역 노드 생성
        let playAreaNode = SKNode()
        playAreaNode.physicsBody = playBoundary
        addChild(playAreaNode)
        
        // 시각적 가이드 (빨간색 박스)
        let debugBorder = SKShapeNode(rect: playAreaRect)
        debugBorder.strokeColor = .systemRed
        debugBorder.lineWidth = 3.0
        debugBorder.fillColor = .clear
        debugBorder.alpha = 0.8
        debugBorder.zPosition = 1
        addChild(debugBorder)
    }
    
    /// 상단 곡선 경계 생성 (플레이 영역에 맞게 조정)
    private func setupTopCurvedBoundary() {
        let path = CGMutablePath()
        let screenWidth = size.width
        let screenHeight = size.height
        
        // 플레이 영역 크기
        let playAreaWidth = screenWidth * 0.77  // 0.7에서 0.77로 10% 증가
        let playAreaHeight = screenHeight * 0.8
        let playAreaY = -playAreaHeight/2 + screenHeight * 0.05
        
        // 곡선 설정 (플레이 영역 상단 85% 지점)
        let curveHeight = playAreaY + playAreaHeight * 0.85
        let curveDepth = playAreaHeight * 0.08   // 곡선 깊이
        
        // 곡선 범위 (플레이 영역 너비에 맞게)
        let startX = -playAreaWidth * 0.48  // 약간 여유 공간
        let endX = playAreaWidth * 0.48
        
        path.move(to: CGPoint(x: startX, y: curveHeight))
        
        // 포물선을 여러 점으로 근사
        let segments = 20
        for i in 0...segments {
            let t = Double(i) / Double(segments)
            let x = startX + t * (endX - startX)
            
            // 포물선 공식
            let normalizedX = x / (playAreaWidth * 0.48)
            let y = curveHeight - curveDepth * (1 - normalizedX * normalizedX)
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        topCurvedBoundary = SKShapeNode(path: path)
        topCurvedBoundary?.strokeColor = .systemBlue
        topCurvedBoundary?.lineWidth = 3.0
        topCurvedBoundary?.fillColor = .clear
        
        // 물리 바디 설정
        topCurvedBoundary?.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        topCurvedBoundary?.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topCurvedBoundary?.physicsBody?.restitution = 0.2  // 0.4에서 0.2로 감소하여 반발력 줄임
        
        addChild(topCurvedBoundary!)
    }
    
    /// 좌우 직선 벽면 구현 (플레이 영역 제거 - 이미 setupPlayBoundary에서 처리됨)
    private func setupSideWalls() {
        // 플레이 영역 경계가 이미 좌우 벽을 포함하므로 별도 벽 불필요
    }
    
    /// 게임 오버 라인 설정 (플레이 영역에 맞게 조정)
    private func setupGameOverLine() {
        let screenWidth = size.width
        let screenHeight = size.height
        let playAreaWidth = screenWidth * 0.7
        let playAreaHeight = screenHeight * 0.8
        let playAreaY = -playAreaHeight/2 + screenHeight * 0.05
        
        // 게임 오버 라인을 플레이 영역 하단 파란 라인으로 설정
        let lineY = playAreaY  // 플레이 영역 바닥
        
        gameOverLine = SKShapeNode(rectOf: CGSize(width: playAreaWidth * 0.9, height: 4))
        gameOverLine?.fillColor = .systemBlue
        gameOverLine?.strokeColor = .systemBlue
        gameOverLine?.position = CGPoint(x: 0, y: lineY)
        gameOverLine?.alpha = 0.9
        gameOverLine?.zPosition = 10
        addChild(gameOverLine!)
    }
    
    /// UI 요소 설정 (정보 패널과 플레이 영역으로 분리)
    private func setupUI() {
        let _ = size.width  // screenWidth를 사용하지 않으므로 _로 대체
        let screenHeight = size.height
        let playAreaHeight = screenHeight * 0.8
        let playAreaY = -playAreaHeight/2 + screenHeight * 0.05
        
        // 상단 정보 패널 설정
        setupInfoPanel()
        
        // 다음 비눗방울 미리보기 라벨 (플레이 영역 아래쪽)
        nextBubbleLabel = SKLabelNode(text: "Next")
        nextBubbleLabel?.fontName = "Arial"
        nextBubbleLabel?.fontSize = 16
        nextBubbleLabel?.fontColor = .lightGray
        nextBubbleLabel?.position = CGPoint(x: 0, y: playAreaY - 80)
        nextBubbleLabel?.horizontalAlignmentMode = .center
        nextBubbleLabel?.zPosition = 50
        addChild(nextBubbleLabel!)
    }
    
    /// 상단 정보 패널 설정 (파란색 박스 영역 활용)
    private func setupInfoPanel() {
        let screenWidth = size.width
        let screenHeight = size.height
        
        // 정보 패널 배경 (파란색 박스)
        let panelHeight: CGFloat = screenHeight * 0.15
        let panelY = screenHeight/2 - panelHeight/2
        
        let infoPanel = SKShapeNode(rect: CGRect(
            x: -screenWidth/2,
            y: panelY,
            width: screenWidth,
            height: panelHeight
        ))
        infoPanel.fillColor = SKColor.systemBlue.withAlphaComponent(0.9)
        infoPanel.strokeColor = .clear
        infoPanel.zPosition = 5
        addChild(infoPanel)
        
        // 점수 라벨 (왼쪽)
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel?.fontName = "Arial-Bold"
        scoreLabel?.fontSize = 24
        scoreLabel?.fontColor = .white
        scoreLabel?.position = CGPoint(x: -screenWidth/4, y: panelY + panelHeight/2 + 10)
        scoreLabel?.horizontalAlignmentMode = .center
        scoreLabel?.zPosition = 55
        addChild(scoreLabel!)
        
        // 시간 라벨 (왼쪽 아래)
        timeLabel = SKLabelNode(text: "Time: 00:00")
        timeLabel?.fontName = "Arial"
        timeLabel?.fontSize = 16
        timeLabel?.fontColor = .white
        timeLabel?.position = CGPoint(x: -screenWidth/4, y: panelY + panelHeight/2 - 15)
        timeLabel?.horizontalAlignmentMode = .center
        timeLabel?.zPosition = 55
        addChild(timeLabel!)
        
        // 레벨 라벨 (중앙)
        levelLabel = SKLabelNode(text: "Level 1")
        levelLabel?.fontName = "Arial-Bold"
        levelLabel?.fontSize = 20
        levelLabel?.fontColor = .white
        levelLabel?.position = CGPoint(x: 0, y: panelY + panelHeight/2 + 5)
        levelLabel?.horizontalAlignmentMode = .center
        levelLabel?.zPosition = 55
        addChild(levelLabel!)
        
        // 최고 점수 라벨 (오른쪽)
        bestScoreLabel = SKLabelNode(text: "Best: 0")
        bestScoreLabel?.fontName = "Arial"
        bestScoreLabel?.fontSize = 18
        bestScoreLabel?.fontColor = .white
        bestScoreLabel?.position = CGPoint(x: screenWidth/4, y: panelY + panelHeight/2 + 10)
        bestScoreLabel?.horizontalAlignmentMode = .center
        bestScoreLabel?.zPosition = 55
        addChild(bestScoreLabel!)
        
        // 방울 개수 라벨 (오른쪽 아래)
        bubbleCountLabel = SKLabelNode(text: "Bubbles: 0")
        bubbleCountLabel?.fontName = "Arial"
        bubbleCountLabel?.fontSize = 14
        bubbleCountLabel?.fontColor = .white
        bubbleCountLabel?.position = CGPoint(x: screenWidth/4, y: panelY + panelHeight/2 - 15)
        bubbleCountLabel?.horizontalAlignmentMode = .center
        bubbleCountLabel?.zPosition = 55
        addChild(bubbleCountLabel!)
    }
    
    /// 발사 시스템 설정
    private func setupLaunchSystem() {
        setupLaunchCharacter()
        createNewBubble()
    }
    
    /// 발사 캐릭터 노드 생성 (화면 하단)
    private func setupLaunchCharacter() {
        let screenHeight = size.height
        
        // 새로운 캐릭터 노드 생성
        launchCharacter = CharacterNode()
        // 화면 하단에서 80포인트 위에 위치
        launchCharacter?.position = CGPoint(x: 0, y: -screenHeight/2 + 80)
        launchCharacter?.zPosition = 20
        addChild(launchCharacter!)
    }
    
    /// 새로운 비눗방울 생성 (플레이 영역 하단에서 시작)
    private func createNewBubble() {
        var randomType = BubbleType.randomLaunchType()
        
        // 연속 방지 시스템: 같은 크기 3번 연속 제한
        if let lastType = lastBubbleType, lastType == randomType {
            consecutiveBubbleCount += 1
            
            if consecutiveBubbleCount >= 3 {
                // 다른 타입 강제 선택
                let availableTypes = BubbleType.allCases.filter { 
                    $0 != randomType && $0.rawValue <= BubbleType.huge.rawValue 
                }
                randomType = availableTypes.randomElement() ?? .tiny
                consecutiveBubbleCount = 1
            }
        } else {
            consecutiveBubbleCount = 1
        }
        
        lastBubbleType = randomType
        
        // 캐릭터 비눗방울 생성 애니메이션 실행
        launchCharacter?.performBubbleCreationAnimation { [weak self] in
            // 애니메이션 완료 후 비눗방울 생성
            self?.createBubbleAfterAnimation(type: randomType)
        }
    }
    
    /// 애니메이션 후 실제 비눗방울 생성
    private func createBubbleAfterAnimation(type: BubbleType) {
        currentBubble = BubbleNode(type: type)
        
        if let bubble = currentBubble, let character = launchCharacter {
            // 캐릭터 바로 위에서 시작
            bubble.position = CGPoint(x: character.position.x, y: character.position.y + 60)
            bubble.zPosition = 15
            
            // 표정 설정 (Phase 2.2 테스트)
            // bubble.showHappyExpression() // 임시 주석 처리
            
            addChild(bubble)
        }
    }
    
    /// 비눗방울 발사
    private func launchBubble() {
        guard let bubble = currentBubble else { return }
        
        // 발사 횟수 증가
        gameManager.incrementShotCount()
        
        // 캐릭터 만족 표정 애니메이션 실행
        launchCharacter?.performSatisfactionAnimation()
        
        // 크기별 초기 속도 차등 적용 (속도를 낮춰서 충돌 안정성 향상)
        let baseVelocity: CGFloat = 420.0  // 600.0에서 420.0으로 30% 감소 (70%로 조정)
        let velocityMultiplier = bubble.bubbleType.velocityMultiplier
        
        // 랜덤성 추가: 수평 방향 임펄스와 회전 추가
        let randomHorizontalImpulse = CGFloat.random(in: -50...50)  // 좌우 ±50의 랜덤 임펄스
        let randomAngularImpulse = CGFloat.random(in: -0.5...0.5)   // 회전 임펄스
        
        let launchVelocity = CGVector(
            dx: randomHorizontalImpulse, 
            dy: baseVelocity * velocityMultiplier
        )
        
        // 물리 바디 활성화 및 속도 적용
        bubble.physicsBody?.isDynamic = true
        bubble.physicsBody?.velocity = launchVelocity
        
        // 랜덤 회전 추가 (더 자연스러운 움직임)
        bubble.physicsBody?.angularVelocity = randomAngularImpulse
        
        // 새로운 비눗방울 준비
        currentBubble = nil
        
        // 다음 비눗방울 생성 (약간의 딜레이)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.createNewBubble()
        }
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        handleBubbleCollision(contact)
        checkGameOver()
    }
    
    /// 비눗방울 충돌 처리
    private func handleBubbleCollision(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // 비눗방울끼리의 충돌인지 확인
        guard bodyA.categoryBitMask == PhysicsCategory.bubble,
              bodyB.categoryBitMask == PhysicsCategory.bubble,
              let nodeA = bodyA.node as? BubbleNode,
              let nodeB = bodyB.node as? BubbleNode else { return }
        
        // 이미 제거 예정인 노드들은 처리하지 않음 (중복 합치기 방지)
        guard nodeA.parent != nil, nodeB.parent != nil else { return }
        
        // 충돌 강도 확인 (약한 충돌은 시각적 효과 생략)
        let relativeVelocity = CGVector(
            dx: (bodyA.velocity.dx - bodyB.velocity.dx),
            dy: (bodyA.velocity.dy - bodyB.velocity.dy)
        )
        let impactStrength = sqrt(relativeVelocity.dx * relativeVelocity.dx + relativeVelocity.dy * relativeVelocity.dy)
        
        // 임계값 이상의 강한 충돌에만 시각적 효과 적용
        if impactStrength > 100.0 {
            // 충돌 방향 계산 (A에서 B로의 방향)
            let impactVector = CGVector(
                dx: nodeB.position.x - nodeA.position.x,
                dy: nodeB.position.y - nodeA.position.y
            )
            
            // 시각적 충돌 효과 적용
            nodeA.showImpactDeformation(impactDirection: impactVector)
            
            // 반대 방향으로 B에게도 효과 적용
            let reverseImpactVector = CGVector(dx: -impactVector.dx, dy: -impactVector.dy)
            nodeB.showImpactDeformation(impactDirection: reverseImpactVector)
            
            // 랜덤 바운스 임펄스 추가 (자연스러운 산란 효과)
            nodeA.addRandomBounceImpulse()
            nodeB.addRandomBounceImpulse()
        }
        
        // 같은 크기인지 확인 (합치기 처리)
        guard nodeA.bubbleType == nodeB.bubbleType else { return }
        
        // 이미 합치기가 진행 중인지 다시 한번 확인
        guard nodeA.parent != nil, nodeB.parent != nil,
              !nodeA.isMerging, !nodeB.isMerging else { return }
        
        // UltraBig+UltraBig 특수 처리 (최대 타입이므로 소멸)
        if nodeA.bubbleType == .ultraBig {
            handleUltraBigMerge(nodeA, nodeB)
        } else {
            handleNormalMerge(nodeA, nodeB)
        }
    }
    
    /// 일반 합치기 처리
    private func handleNormalMerge(_ bubbleA: BubbleNode, _ bubbleB: BubbleNode) {
        // 다시 한번 부모 노드 존재 확인 (중복 합치기 방지)
        guard bubbleA.parent != nil, bubbleB.parent != nil,
              !bubbleA.isMerging, !bubbleB.isMerging else { return }
        
        // 합치기 상태 설정 (추가 충돌 방지)
        bubbleA.setMerging(true)
        bubbleB.setMerging(true)
        
        let mergePosition = CGPoint(
            x: (bubbleA.position.x + bubbleB.position.x) / 2,
            y: (bubbleA.position.y + bubbleB.position.y) / 2
        )
        
        // 점수 추가
        gameManager.addScoreForMerge(bubbleType: bubbleA.bubbleType)
        
        // 기존 비눗방울 즉시 제거 (물리 바디도 비활성화)
        bubbleA.physicsBody?.isDynamic = false
        bubbleB.physicsBody?.isDynamic = false
        bubbleA.removeFromParent()
        bubbleB.removeFromParent()
        
        // 한 단계 큰 비눗방울 생성
        if let nextType = bubbleA.bubbleType.nextType {
            let newBubble = BubbleNode(type: nextType)
            newBubble.position = mergePosition
            
            // 새로 생성된 비눗방울의 물리 바디 활성화
            newBubble.physicsBody?.isDynamic = true
            
            // 초기 속도를 제한하여 안정성 향상
            newBubble.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            
            // 합병 성공 표정 설정
            // newBubble.showExcitedExpression() // 임시 주석 처리
            
            addChild(newBubble)
            
            // 새로 생성된 비눗방울의 연쇄 반응 확인
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkChainReaction(for: newBubble)
            }
        }
    }
    
    /// UltraBig+UltraBig 특수 처리 (소멸 효과)
    private func handleUltraBigMerge(_ bubbleA: BubbleNode, _ bubbleB: BubbleNode) {
        // 특수 점수 추가
        gameManager.addScoreForMegaSpecial()
        
        // 특수 효과 후 소멸
        bubbleA.removeFromParent()
        bubbleB.removeFromParent()
        
        // TODO: 특수 효과 추가 (Phase 2에서 구현)
    }
    
    /// 게임 오버 확인 (파란 라인 아래로 떨어지면 게임오버)
    private func checkGameOver() {
        guard let gameOverY = gameOverLine?.position.y else { 
            #if DEBUG
            print("❌ gameOverLine is nil in checkGameOver!")
            #endif
            return 
        }
        
        var currentBubblesBelowLine: Set<BubbleNode> = []
        
        // 게임 오버 라인(파란 라인) 아래로 떨어진 비눗방울 찾기
        for child in children {
            if let bubble = child as? BubbleNode,
               bubble.position.y < gameOverY {
                currentBubblesBelowLine.insert(bubble)
                #if DEBUG
                print("🔵 Bubble below line: y=\(bubble.position.y), lineY=\(gameOverY)")
                #endif
            }
        }
        
        bubblesAboveLine = currentBubblesBelowLine  // 변수명은 유지하되 아래로 떨어진 것들을 저장
        
        if !bubblesAboveLine.isEmpty {
            #if DEBUG
            print("⚠️ Game Over condition detected: \(bubblesAboveLine.count) bubbles below line")
            #endif
            // 처음 라인 아래로 떨어졌을 때 타이머 시작
            if gameOverTimer == nil {
                startGameOverTimer()
            }
        } else {
            // 모든 비눗방울이 라인 위로 돌아왔을 때 타이머 취소
            cancelGameOverTimer()
        }
    }
    
    /// 게임 오버 타이머 시작 (2초 후 게임 오버)
    private func startGameOverTimer() {
        gameOverTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.triggerGameOver()
        }
        
        // 게임 오버 라인(파란 라인)을 더 밝게 깜빡이게 함
        gameOverLine?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.3),
            SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        ])))
    }
    
    /// 게임 오버 타이머 취소
    private func cancelGameOverTimer() {
        gameOverTimer?.invalidate()
        gameOverTimer = nil
        
        // 게임 오버 라인 깜빡임 중지
        gameOverLine?.removeAllActions()
        gameOverLine?.alpha = 0.9
    }
    
    /// 게임 오버 처리
    private func triggerGameOver() {
        guard gameManager.isGameActive else { return }
        
        gameManager.endGame()
        
        // 게임 오버 UI 표시
        showGameOverScreen()
        
        // 모든 비눗방울 물리 정지
        for child in children {
            if let bubble = child as? BubbleNode {
                bubble.physicsBody?.isDynamic = false
            }
        }
    }
    
    /// 게임 오버 화면 표시
    private func showGameOverScreen() {
        // 반투명 배경
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = .black
        overlay.alpha = 0.5
        overlay.zPosition = 100
        addChild(overlay)
        
        // Game Over 라벨
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontName = "Arial-Bold"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 101
        addChild(gameOverLabel)
        
        // 재시작 버튼
        let restartLabel = SKLabelNode(text: "Tap to Restart")
        restartLabel.fontName = "Arial"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .systemBlue
        restartLabel.position = CGPoint(x: 0, y: -50)
        restartLabel.zPosition = 101
        restartLabel.name = "restartButton"
        addChild(restartLabel)
        
        // 깜빡이는 효과
        let blinkAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        restartLabel.run(blinkAction)
    }
    
    /// 게임 재시작
    private func restartGame() {
        // 모든 자식 노드 제거
        removeAllChildren()
        
        // 게임 매니저를 통한 재시작
        gameManager.restartGame()
        
        // 게임 상태 초기화
        currentBubble = nil
        consecutiveBubbleCount = 0
        lastBubbleType = nil
        bubblesAboveLine.removeAll()
        cancelGameOverTimer()
        
        // 게임 재설정
        setupPhysicsWorld()
        setupPlayArea()
        setupLaunchSystem()
    }
    
    /// 터치 시작 처리 (패닝 또는 발사, 게임 오버 시 재시작)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if gameManager.isGameActive {
            // 게임 중일 때: 패닝 시작 또는 비눗방울 발사
            if currentBubble != nil {
                isDragging = true
                initialTouchPosition = location
                currentTouchLocation = location
            }
        } else {
            // 게임 오버일 때: 재시작 버튼 처리
            let touchedNode = atPoint(location)
            if touchedNode.name == "restartButton" {
                restartGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, gameManager.isGameActive, let bubble = currentBubble else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        currentTouchLocation = location
        
        // 플레이 영역 너비에 맞게 좌우 이동 제한
        let playAreaWidth = size.width * 0.7
        let maxX = playAreaWidth * 0.4  // 플레이 영역의 80% 범위
        let minX = -playAreaWidth * 0.4
        let newX = max(minX, min(maxX, location.x))
        
        bubble.position.x = newX
        launchCharacter?.position.x = newX
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDragging && gameManager.isGameActive && currentBubble != nil {
            isDragging = false
            launchBubble()
        }
    }
}

// MARK: - UI Updates

extension GameScene {
    
    /// UI 업데이트
    func updateUI() {
        // 점수 업데이트
        let currentScore = gameManager.score
        scoreLabel?.text = "Score: \(currentScore)"
        
        // 시간 업데이트
        timeLabel?.text = "Time: \(gameManager.getFormattedGameTime())"
        
        // 레벨 업데이트 (나중에 레벨 시스템 구현 시 사용)
        levelLabel?.text = "Level 1"
        
        // 방울 개수 업데이트
        let bubbleCount = children.compactMap { $0 as? BubbleNode }.count
        bubbleCountLabel?.text = "Bubbles: \(bubbleCount)"
        
        // 최고 점수 업데이트
        let savedBest = UserDefaults.standard.integer(forKey: "bestScore")
        let bestScore = max(currentScore, savedBest)
        bestScoreLabel?.text = "Best: \(bestScore)"
        
        // 디버깅: UI 라벨들이 존재하는지 확인
        #if DEBUG
        if scoreLabel == nil {
            print("❌ scoreLabel is nil!")
        }
        if timeLabel == nil {
            print("❌ timeLabel is nil!")
        }
        if gameOverLine == nil {
            print("❌ gameOverLine is nil!")
        }
        #endif
    }
    
    /// 게임 루프 업데이트
    override func update(_ currentTime: TimeInterval) {
        updateUI()
        
        // 게임 오버 체크
        checkGameOver()
        
        // 모든 비눗방울의 하이라이트 방향 업데이트 (회전과 독립적으로 고정)
        let allBubbles = children.compactMap { $0 as? BubbleNode }
        allBubbles.forEach { bubble in
            bubble.updateHighlightRotation()
        }
        
        // 겹침 방지를 더 적게 실행 (60FPS 대신 20FPS로)
        if Int(currentTime * 20) % 3 == 0 {
            preventBubbleOverlap()
        }
    }
    
    /// 물리 시뮬레이션 후 눈동자 업데이트
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        // 모든 방울의 눈동자 방향을 실시간으로 업데이트
        updateAllPupilDirections()
    }
    
    /// 모든 방울의 눈동자 방향 업데이트
    private func updateAllPupilDirections() {
        let allBubbles = children.compactMap { $0 as? BubbleNode }
        
        for bubble in allBubbles {
            // 각 방울이 모든 방울 정보를 받아서 자신보다 큰 방울을 찾아 바라보도록 함
            bubble.updatePupilDirection(allBubbles: allBubbles)
        }
    }
    
    /// 방울 겹침 방지 시스템 (더 자연스럽게 개선)
    private func preventBubbleOverlap() {
        var bubbles: [BubbleNode] = []
        
        // 모든 방울 노드 수집
        enumerateChildNodes(withName: "*") { node, _ in
            if let bubble = node as? BubbleNode {
                bubbles.append(bubble)
            }
        }
        
        // 심각한 겹침만 해결 (형태 변형은 제거)
        for i in 0..<bubbles.count {
            for j in (i+1)..<bubbles.count {
                let bubble1 = bubbles[i]
                let bubble2 = bubbles[j]
                resolveOverlap(between: bubble1, and: bubble2)
            }
        }
    }
    
    /// 방울 주변의 사용 가능한 공간 분석
    private func analyzeAvailableSpace(for bubble: BubbleNode, allBubbles: [BubbleNode]) -> CGSize {
        let bubblePos = bubble.position
        let bubbleRadius = bubble.frame.width / 2
        
        var minDistanceLeft: CGFloat = bubblePos.x - playAreaBounds.minX
        var minDistanceRight: CGFloat = playAreaBounds.maxX - bubblePos.x
        var minDistanceUp: CGFloat = playAreaBounds.maxY - bubblePos.y
        var minDistanceDown: CGFloat = bubblePos.y - playAreaBounds.minY
        
        // 다른 방울들과의 거리 확인 (더 가까운 거리에서만)
        for otherBubble in allBubbles {
            if otherBubble == bubble { continue }
            
            let otherPos = otherBubble.position
            let otherRadius = otherBubble.frame.width / 2
            
            let dx = otherPos.x - bubblePos.x
            let dy = otherPos.y - bubblePos.y
            let distance = sqrt(dx * dx + dy * dy)
            
            // 실제로 가까운 방울들만 고려 (10포인트로 감소)
            if distance < bubbleRadius + otherRadius + 10 {
                // 방향별 최소 거리 업데이트
                if dx > 0 { // 오른쪽에 있는 방울
                    minDistanceRight = min(minDistanceRight, abs(dx) - otherRadius)
                } else { // 왼쪽에 있는 방울
                    minDistanceLeft = min(minDistanceLeft, abs(dx) - otherRadius)
                }
                
                if dy > 0 { // 위쪽에 있는 방울
                    minDistanceUp = min(minDistanceUp, abs(dy) - otherRadius)
                } else { // 아래쪽에 있는 방울
                    minDistanceDown = min(minDistanceDown, abs(dy) - otherRadius)
                }
            }
        }
        
        let availableWidth = minDistanceLeft + minDistanceRight
        let availableHeight = minDistanceUp + minDistanceDown
        
        return CGSize(width: max(bubbleRadius * 1.8, availableWidth), height: max(bubbleRadius * 1.8, availableHeight))
    }
    
    /// 방울에 가해지는 압력 방향 계산
    private func calculatePressureDirection(for bubble: BubbleNode, allBubbles: [BubbleNode]) -> CGVector {
        let bubblePos = bubble.position
        let bubbleRadius = bubble.frame.width / 2
        
        var totalPressure = CGVector.zero
        
        for otherBubble in allBubbles {
            if otherBubble == bubble { continue }
            
            let otherPos = otherBubble.position
            let otherRadius = otherBubble.frame.width / 2
            
            let dx = bubblePos.x - otherPos.x
            let dy = bubblePos.y - otherPos.y
            let distance = sqrt(dx * dx + dy * dy)
            
            // 실제로 겹치는 경우에만 압력 계산 (더 가깝게)
            let minDistance = bubbleRadius + otherRadius - 8  // -3에서 -8로 변경
            
            if distance < minDistance && distance > 0 {
                // 압력 강도 (더 부드럽게)
                let pressureStrength = (minDistance - distance) / minDistance * 0.3 // 0.5에서 0.3으로 감소
                let normalizedX = dx / distance
                let normalizedY = dy / distance
                
                totalPressure.dx += normalizedX * pressureStrength * 30 // 50에서 30으로 감소
                totalPressure.dy += normalizedY * pressureStrength * 30
            }
        }
        
        // 경계에서의 압력 감소
        let boundaryMargin: CGFloat = 15 // 30에서 15로 감소
        if bubblePos.x - bubbleRadius < playAreaBounds.minX + boundaryMargin {
            totalPressure.dx += 25 // 50에서 25로 감소
        }
        if bubblePos.x + bubbleRadius > playAreaBounds.maxX - boundaryMargin {
            totalPressure.dx -= 25
        }
        if bubblePos.y - bubbleRadius < playAreaBounds.minY + boundaryMargin {
            totalPressure.dy += 25
        }
        if bubblePos.y + bubbleRadius > playAreaBounds.maxY - boundaryMargin {
            totalPressure.dy -= 25
        }
        
        return totalPressure
    }
    
    /// 두 방울 간 겹침 해결 (더 자연스럽게 개선)
    private func resolveOverlap(between bubbleA: BubbleNode, and bubbleB: BubbleNode) {
        let posA = bubbleA.position
        let posB = bubbleB.position
        
        let radiusA = bubbleA.frame.width / 2
        let radiusB = bubbleB.frame.width / 2
        let minDistance = radiusA + radiusB - 5.0 // 약간의 겹침 허용
        
        let dx = posB.x - posA.x
        let dy = posB.y - posA.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // 실제 심각한 겹침이 발생한 경우에만 분리 (물리 엔진 우선)
        if distance < minDistance && distance > 0 {
            let overlap = minDistance - distance
            
            // 심각한 겹침만 해결 (15포인트 이상)
            if overlap > 15.0 {
                // 물리 바디를 통한 자연스러운 분리
                if let physicsA = bubbleA.physicsBody,
                   let physicsB = bubbleB.physicsBody {
                    
                    // 정규화된 방향 벡터
                    let normalX = dx / distance
                    let normalY = dy / distance
                    
                    // 가벼운 밀어내는 힘만 적용
                    let pushForce: CGFloat = overlap * 2.0
                    
                    physicsA.applyImpulse(CGVector(dx: -normalX * pushForce, dy: -normalY * pushForce))
                    physicsB.applyImpulse(CGVector(dx: normalX * pushForce, dy: normalY * pushForce))
                }
            }
        }
    }
    
    /// 방울을 플레이 영역 내로 제한
    private func constrainToBounds(_ position: CGPoint, radius: CGFloat) -> CGPoint {
        let margin: CGFloat = 10.0
        
        let minX = playAreaBounds.minX + radius + margin
        let maxX = playAreaBounds.maxX - radius - margin
        let minY = playAreaBounds.minY + radius + margin
        let maxY = playAreaBounds.maxY - radius - margin
        
        return CGPoint(
            x: max(minX, min(maxX, position.x)),
            y: max(minY, min(maxY, position.y))
        )
    }
    
    // MARK: - Chain Reaction System
    
    /// 연쇄 반응 확인
    private func checkChainReaction(for newBubble: BubbleNode) {
        guard newBubble.physicsBody != nil else { return }
        
        // 새 비눗방울과 충돌하는 모든 비눗방울 찾기
        let contactBubbles = findContactingBubbles(with: newBubble)
        
        // 같은 타입의 비눗방울들과 연쇄 합치기
        for contactBubble in contactBubbles {
            if contactBubble.bubbleType == newBubble.bubbleType {
                // 연쇄 합치기 실행
                handleChainMerge(newBubble, contactBubble)
                return // 한 번에 하나씩만 처리
            }
        }
    }
    
    /// 주변 비눗방울들 찾기
    private func findContactingBubbles(with targetBubble: BubbleNode) -> [BubbleNode] {
        var contactBubbles: [BubbleNode] = []
        let targetPosition = targetBubble.position
        let targetRadius = targetBubble.frame.width / 2
        
        // 씬의 모든 비눗방울 노드 검사
        enumerateChildNodes(withName: "*") { node, _ in
            if let bubble = node as? BubbleNode,
               bubble != targetBubble {
                
                let distance = hypot(
                    bubble.position.x - targetPosition.x,
                    bubble.position.y - targetPosition.y
                )
                
                let bubbleRadius = bubble.frame.width / 2
                let combinedRadius = targetRadius + bubbleRadius
                
                // 겹치는지 확인 (약간의 여유 공간 포함)
                if distance <= combinedRadius + 5.0 {
                    contactBubbles.append(bubble)
                }
            }
        }
        
        return contactBubbles
    }
    
    /// 연쇄 합치기 처리
    private func handleChainMerge(_ bubbleA: BubbleNode, _ bubbleB: BubbleNode) {
        let mergePosition = CGPoint(
            x: (bubbleA.position.x + bubbleB.position.x) / 2,
            y: (bubbleA.position.y + bubbleB.position.y) / 2
        )
        
        // 연쇄 점수 보너스
        gameManager.addScoreForMerge(bubbleType: bubbleA.bubbleType)
        gameManager.addScoreForChainBonus() // 추가 보너스
        
        // 기존 비눗방울 제거
        bubbleA.removeFromParent()
        bubbleB.removeFromParent()
        
        // 한 단계 큰 비눗방울 생성
        if let nextType = bubbleA.bubbleType.nextType {
            let newBubble = BubbleNode(type: nextType)
            newBubble.position = mergePosition
            
            // 새로 생성된 비눗방울의 물리 바디 활성화
            newBubble.physicsBody?.isDynamic = true
            
            addChild(newBubble)
            
            // 또 다른 연쇄 반응 확인 (재귀적 연쇄)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkChainReaction(for: newBubble)
            }
        } else if bubbleA.bubbleType == .ultraBig {
            // UltraBig+UltraBig의 경우 특수 처리 (최대 타입이므로 소멸)
            gameManager.addScoreForMegaSpecial()
        }
    }
}
