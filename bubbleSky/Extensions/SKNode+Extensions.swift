//
//  SKNode+Extensions.swift
//  bubbleSky
//
//  SKNode 클래스 확장
//

import SpriteKit

extension SKNode {

    // MARK: - Position Helpers

    /// 노드의 월드 좌표 반환
    var worldPosition: CGPoint {
        if let parent = parent {
            return parent.convert(position, to: scene!)
        }
        return position
    }

    /// 특정 노드로부터의 거리 계산
    /// - Parameter node: 대상 노드
    /// - Returns: 거리
    func distance(to node: SKNode) -> CGFloat {
        let dx = node.position.x - position.x
        let dy = node.position.y - position.y
        return sqrt(dx * dx + dy * dy)
    }

    /// 특정 위치로부터의 거리 계산
    /// - Parameter point: 대상 위치
    /// - Returns: 거리
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return sqrt(dx * dx + dy * dy)
    }

    // MARK: - Animation Helpers

    /// 페이드 인 애니메이션
    /// - Parameters:
    ///   - duration: 지속 시간
    ///   - completion: 완료 핸들러
    func fadeIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        alpha = 0
        let fadeAction = SKAction.fadeIn(withDuration: duration)
        run(fadeAction) {
            completion?()
        }
    }

    /// 페이드 아웃 애니메이션
    /// - Parameters:
    ///   - duration: 지속 시간
    ///   - completion: 완료 핸들러
    func fadeOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let fadeAction = SKAction.fadeOut(withDuration: duration)
        run(fadeAction) {
            completion?()
        }
    }

    /// 펄스 애니메이션 (크기 변화)
    /// - Parameters:
    ///   - scale: 최대 스케일
    ///   - duration: 지속 시간
    func pulse(to scale: CGFloat = 1.2, duration: TimeInterval = 0.3) {
        let scaleUp = SKAction.scale(to: scale, duration: duration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration / 2)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        run(sequence)
    }

    /// 깜빡임 애니메이션
    /// - Parameters:
    ///   - duration: 한 번 깜빡이는 시간
    ///   - count: 반복 횟수
    func blink(duration: TimeInterval = 0.5, count: Int = 3) {
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: duration / 2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration / 2)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        let repeat_action = SKAction.repeat(sequence, count: count)
        run(repeat_action)
    }

    /// 흔들기 애니메이션
    /// - Parameters:
    ///   - amount: 흔들림 정도
    ///   - duration: 지속 시간
    func shake(amount: CGFloat = 5.0, duration: TimeInterval = 0.5) {
        let originalPosition = position

        let moveLeft = SKAction.moveBy(x: -amount, y: 0, duration: duration / 8)
        let moveRight = SKAction.moveBy(x: amount * 2, y: 0, duration: duration / 4)
        let moveBack = SKAction.moveBy(x: -amount, y: 0, duration: duration / 8)

        let sequence = SKAction.sequence([moveLeft, moveRight, moveLeft, moveRight, moveBack])
        run(sequence) { [weak self] in
            self?.position = originalPosition
        }
    }

    /// 회전 애니메이션
    /// - Parameters:
    ///   - angle: 회전 각도 (라디안)
    ///   - duration: 지속 시간
    func rotate(by angle: CGFloat, duration: TimeInterval = 0.5) {
        let rotateAction = SKAction.rotate(byAngle: angle, duration: duration)
        run(rotateAction)
    }

    /// 무한 회전 애니메이션
    /// - Parameter duration: 한 바퀴 회전 시간
    func rotateForever(duration: TimeInterval = 2.0) {
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: duration)
        let repeatAction = SKAction.repeatForever(rotateAction)
        run(repeatAction)
    }

    // MARK: - Convenience Methods

    /// 모든 자식 노드 제거 (애니메이션 포함)
    /// - Parameter duration: 페이드 아웃 시간
    func removeAllChildrenWithFade(duration: TimeInterval = 0.3) {
        for child in children {
            child.fadeOut(duration: duration) {
                child.removeFromParent()
            }
        }
    }

    /// 부모로부터 제거 (애니메이션 포함)
    /// - Parameter duration: 페이드 아웃 시간
    func removeFromParentWithFade(duration: TimeInterval = 0.3) {
        fadeOut(duration: duration) { [weak self] in
            self?.removeFromParent()
        }
    }

    /// Z 포지션 설정 (체이닝 가능)
    /// - Parameter zPosition: Z 위치
    /// - Returns: 자기 자신
    @discardableResult
    func with(zPosition: CGFloat) -> Self {
        self.zPosition = zPosition
        return self
    }

    /// 위치 설정 (체이닝 가능)
    /// - Parameters:
    ///   - x: X 좌표
    ///   - y: Y 좌표
    /// - Returns: 자기 자신
    @discardableResult
    func with(x: CGFloat, y: CGFloat) -> Self {
        position = CGPoint(x: x, y: y)
        return self
    }

    /// 알파 설정 (체이닝 가능)
    /// - Parameter alpha: 투명도
    /// - Returns: 자기 자신
    @discardableResult
    func with(alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }

    /// 스케일 설정 (체이닝 가능)
    /// - Parameter scale: 스케일
    /// - Returns: 자기 자신
    @discardableResult
    func with(scale: CGFloat) -> Self {
        setScale(scale)
        return self
    }

    // MARK: - Debugging Helpers

    /// 노드 정보 출력
    func printInfo() {
        print("""
        ===== Node Info =====
        Name: \(name ?? "nil")
        Position: \(position)
        Z-Position: \(zPosition)
        Alpha: \(alpha)
        Scale: (x: \(xScale), y: \(yScale))
        Children: \(children.count)
        ====================
        """)
    }
}

// MARK: - SKSpriteNode Extensions

extension SKSpriteNode {

    /// 텍스처 변경 애니메이션
    /// - Parameters:
    ///   - texture: 새 텍스처
    ///   - duration: 지속 시간
    func changeTexture(to texture: SKTexture, duration: TimeInterval = 0.2) {
        let changeAction = SKAction.setTexture(texture, resize: false)
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: duration / 2)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration / 2)

        let sequence = SKAction.sequence([fadeOut, changeAction, fadeIn])
        run(sequence)
    }

    /// 색상 변경 애니메이션
    /// - Parameters:
    ///   - color: 새 색상
    ///   - duration: 지속 시간
    func changeColor(to color: UIColor, duration: TimeInterval = 0.3) {
        let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: duration)
        run(colorAction)
    }
}

// MARK: - SKLabelNode Extensions

extension SKLabelNode {

    /// 텍스트 변경 애니메이션
    /// - Parameters:
    ///   - newText: 새 텍스트
    ///   - duration: 지속 시간
    func changeText(to newText: String, duration: TimeInterval = 0.2) {
        let scaleDown = SKAction.scale(to: 0.8, duration: duration / 2)
        let changeText = SKAction.run { [weak self] in
            self?.text = newText
        }
        let scaleUp = SKAction.scale(to: 1.0, duration: duration / 2)

        let sequence = SKAction.sequence([scaleDown, changeText, scaleUp])
        run(sequence)
    }

    /// 카운트 업 애니메이션
    /// - Parameters:
    ///   - from: 시작 숫자
    ///   - to: 종료 숫자
    ///   - duration: 지속 시간
    func countUp(from: Int, to: Int, duration: TimeInterval = 0.5) {
        let steps = abs(to - from)
        guard steps > 0 else {
            text = "\(to)"
            return
        }

        let stepDuration = duration / Double(steps)
        var currentValue = from

        let updateAction = SKAction.run { [weak self] in
            currentValue += (to > from) ? 1 : -1
            self?.text = "\(currentValue)"
        }

        let waitAction = SKAction.wait(forDuration: stepDuration)
        let sequence = SKAction.sequence([updateAction, waitAction])
        let repeatAction = SKAction.repeat(sequence, count: steps)

        run(repeatAction)
    }
}
