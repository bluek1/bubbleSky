//
//  ParticleEffects.swift
//  bubbleSky
//
//  파티클 효과 관리 시스템
//

import SpriteKit

/// 파티클 효과 타입
enum ParticleEffectType {
    case bubbleMerge      // 비눗방울 합칠 때
    case bubblePop        // 비눗방울 터질 때
    case bubbleTrail      // 비눗방울 궤적
    case sparkle          // 반짝임 효과
    case rainbow          // 무지개 효과
    case sunshine         // 햇빛 효과
    case confetti         // 축하 효과
    case megaSpecial      // 특수 효과 (UltraBig 합치기)
}

/// 파티클 효과 관리 클래스
class ParticleEffects {

    // MARK: - Singleton

    static let shared = ParticleEffects()
    private init() {}

    // MARK: - Particle Creation Methods

    /// 비눗방울 합치기 효과
    /// - Parameters:
    ///   - position: 생성 위치
    ///   - color: 비눗방울 색상
    /// - Returns: 파티클 노드
    func createBubbleMergeEffect(at position: CGPoint, color: UIColor) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 100
        particles.numParticlesToEmit = 30
        particles.particleLifetime = 0.8
        particles.particleLifetimeRange = 0.3

        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2
        particles.particleSpeed = 100
        particles.particleSpeedRange = 50

        particles.particleScale = 0.3
        particles.particleScaleRange = 0.2
        particles.particleScaleSpeed = -0.2

        particles.particleAlpha = 0.8
        particles.particleAlphaSpeed = -1.0

        particles.particleColor = color
        particles.particleColorBlendFactor = 1.0

        particles.position = position
        particles.zPosition = 50

        return particles
    }

    /// 비눗방울 터지기 효과
    /// - Parameters:
    ///   - position: 생성 위치
    ///   - color: 비눗방울 색상
    /// - Returns: 파티클 노드
    func createBubblePopEffect(at position: CGPoint, color: UIColor) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 200
        particles.numParticlesToEmit = 50
        particles.particleLifetime = 0.5
        particles.particleLifetimeRange = 0.2

        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2
        particles.particleSpeed = 150
        particles.particleSpeedRange = 80

        particles.particleScale = 0.2
        particles.particleScaleRange = 0.15
        particles.particleScaleSpeed = -0.3

        particles.particleAlpha = 1.0
        particles.particleAlphaSpeed = -2.0

        particles.particleColor = color
        particles.particleColorBlendFactor = 1.0

        particles.position = position
        particles.zPosition = 50

        return particles
    }

    /// 비눗방울 궤적 효과 (연속 생성용)
    /// - Parameter color: 궤적 색상
    /// - Returns: 파티클 노드
    func createBubbleTrailEffect(color: UIColor) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 20
        particles.particleLifetime = 0.4
        particles.particleLifetimeRange = 0.2

        particles.emissionAngle = .pi
        particles.emissionAngleRange = .pi / 4
        particles.particleSpeed = 20
        particles.particleSpeedRange = 10

        particles.particleScale = 0.15
        particles.particleScaleRange = 0.1
        particles.particleScaleSpeed = -0.2

        particles.particleAlpha = 0.6
        particles.particleAlphaSpeed = -1.5

        particles.particleColor = color
        particles.particleColorBlendFactor = 1.0

        particles.zPosition = 5

        return particles
    }

    /// 반짝임 효과
    /// - Parameter position: 생성 위치
    /// - Returns: 파티클 노드
    func createSparkleEffect(at position: CGPoint) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 30
        particles.numParticlesToEmit = 15
        particles.particleLifetime = 0.6
        particles.particleLifetimeRange = 0.3

        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2
        particles.particleSpeed = 30
        particles.particleSpeedRange = 20

        particles.particleScale = 0.25
        particles.particleScaleRange = 0.15
        particles.particleScaleSpeed = -0.15

        particles.particleAlpha = 0.9
        particles.particleAlphaSpeed = -1.5

        particles.particleColor = .white
        particles.particleColorBlendFactor = 1.0

        particles.position = position
        particles.zPosition = 50

        return particles
    }

    /// 무지개 효과
    /// - Parameter position: 생성 위치
    /// - Returns: 파티클 노드
    func createRainbowEffect(at position: CGPoint) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 50
        particles.numParticlesToEmit = 100
        particles.particleLifetime = 1.5
        particles.particleLifetimeRange = 0.5

        particles.emissionAngle = .pi / 2
        particles.emissionAngleRange = .pi / 3
        particles.particleSpeed = 80
        particles.particleSpeedRange = 40

        particles.particleScale = 0.4
        particles.particleScaleRange = 0.2
        particles.particleScaleSpeed = -0.2

        particles.particleAlpha = 0.7
        particles.particleAlphaSpeed = -0.5

        // 무지개 색상 키프레임
        particles.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                UIColor.red,
                UIColor.orange,
                UIColor.yellow,
                UIColor.green,
                UIColor.blue,
                UIColor.purple
            ],
            times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        )

        particles.position = position
        particles.zPosition = 50

        return particles
    }

    /// 햇빛 효과 (배경용 연속 생성)
    /// - Parameter position: 생성 위치
    /// - Returns: 파티클 노드
    func createSunshineEffect(at position: CGPoint) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 5
        particles.particleLifetime = 3.0
        particles.particleLifetimeRange = 1.0

        particles.emissionAngle = -.pi / 2
        particles.emissionAngleRange = .pi / 6
        particles.particleSpeed = 20
        particles.particleSpeedRange = 10

        particles.particleScale = 0.3
        particles.particleScaleRange = 0.2
        particles.particleScaleSpeed = -0.05

        particles.particleAlpha = 0.3
        particles.particleAlphaSpeed = -0.1

        particles.particleColor = .yellow
        particles.particleColorBlendFactor = 1.0

        particles.position = position
        particles.zPosition = -10

        return particles
    }

    /// 축하 효과 (색종이)
    /// - Parameter position: 생성 위치
    /// - Returns: 파티클 노드
    func createConfettiEffect(at position: CGPoint) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 100
        particles.numParticlesToEmit = 200
        particles.particleLifetime = 2.0
        particles.particleLifetimeRange = 0.5

        particles.emissionAngle = .pi / 2
        particles.emissionAngleRange = .pi / 4
        particles.particleSpeed = 200
        particles.particleSpeedRange = 100

        particles.particleScale = 0.3
        particles.particleScaleRange = 0.2

        particles.particleAlpha = 0.9
        particles.particleAlphaSpeed = -0.45

        particles.particleRotation = 0
        particles.particleRotationRange = .pi * 2
        particles.particleRotationSpeed = .pi

        // 다양한 색상
        particles.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                UIColor.red,
                UIColor.blue,
                UIColor.green,
                UIColor.yellow,
                UIColor.purple,
                UIColor.orange
            ],
            times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        )

        particles.position = position
        particles.zPosition = 100

        return particles
    }

    /// 메가 스페셜 효과 (UltraBig 합치기)
    /// - Parameter position: 생성 위치
    /// - Returns: 파티클 노드
    func createMegaSpecialEffect(at position: CGPoint) -> SKEmitterNode {
        let particles = SKEmitterNode()

        particles.particleTexture = SKTexture(imageNamed: "spark")
        particles.particleBirthRate = 300
        particles.numParticlesToEmit = 500
        particles.particleLifetime = 1.5
        particles.particleLifetimeRange = 0.5

        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2
        particles.particleSpeed = 250
        particles.particleSpeedRange = 150

        particles.particleScale = 0.5
        particles.particleScaleRange = 0.3
        particles.particleScaleSpeed = -0.3

        particles.particleAlpha = 1.0
        particles.particleAlphaSpeed = -0.7

        // 화려한 색상 효과
        particles.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                UIColor.white,
                UIColor.yellow,
                UIColor.orange,
                UIColor.red,
                UIColor.purple
            ],
            times: [0.0, 0.25, 0.5, 0.75, 1.0]
        )

        particles.position = position
        particles.zPosition = 100

        return particles
    }

    // MARK: - Convenience Methods

    /// 파티클 효과 추가 및 자동 제거
    /// - Parameters:
    ///   - particle: 파티클 노드
    ///   - scene: 추가할 씬
    ///   - duration: 지속 시간 (기본값: 2초)
    func addParticle(_ particle: SKEmitterNode, to scene: SKScene, duration: TimeInterval = 2.0) {
        scene.addChild(particle)

        // 일정 시간 후 자동 제거
        let waitAction = SKAction.wait(forDuration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([waitAction, removeAction])

        particle.run(sequence)
    }

    /// 파티클 효과 생성 및 자동 추가
    /// - Parameters:
    ///   - type: 파티클 효과 타입
    ///   - position: 생성 위치
    ///   - scene: 추가할 씬
    ///   - color: 색상 (선택)
    func showEffect(_ type: ParticleEffectType,
                   at position: CGPoint,
                   in scene: SKScene,
                   color: UIColor = .white) {
        let particle: SKEmitterNode

        switch type {
        case .bubbleMerge:
            particle = createBubbleMergeEffect(at: position, color: color)
        case .bubblePop:
            particle = createBubblePopEffect(at: position, color: color)
        case .bubbleTrail:
            particle = createBubbleTrailEffect(color: color)
            particle.position = position
        case .sparkle:
            particle = createSparkleEffect(at: position)
        case .rainbow:
            particle = createRainbowEffect(at: position)
        case .sunshine:
            particle = createSunshineEffect(at: position)
        case .confetti:
            particle = createConfettiEffect(at: position)
        case .megaSpecial:
            particle = createMegaSpecialEffect(at: position)
        }

        addParticle(particle, to: scene)
    }

    /// 기본 spark 텍스처 생성 (리소스가 없을 경우)
    func createDefaultSparkTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        return SKTexture(image: image)
    }
}
