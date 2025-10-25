//
//  PhysicsHelper.swift
//  bubbleSky
//
//  물리 엔진 관련 유틸리티 및 헬퍼 함수
//

import SpriteKit
import Foundation

/// 물리 엔진 관련 유틸리티 클래스
class PhysicsHelper {

    // MARK: - Physics Constants

    /// 기본 중력 값 (천정 방향)
    static let defaultGravity = CGVector(dx: 0, dy: 5.0)

    /// 물리 시뮬레이션 속도
    static let physicsSpeed: CGFloat = 0.6

    /// 기본 반발력 (restitution)
    static let defaultRestitution: CGFloat = 0.2

    /// 기본 마찰력 (friction)
    static let defaultFriction: CGFloat = 0.3

    /// 선형 감쇠 (linear damping)
    static let defaultLinearDamping: CGFloat = 0.7

    /// 각속도 감쇠 (angular damping)
    static let defaultAngularDamping: CGFloat = 0.7

    // MARK: - Physics Setup Helpers

    /// 물리 월드 초기 설정
    /// - Parameters:
    ///   - scene: 설정할 씬
    ///   - gravity: 중력 벡터 (기본값: defaultGravity)
    ///   - speed: 물리 시뮬레이션 속도 (기본값: physicsSpeed)
    static func setupPhysicsWorld(for scene: SKScene,
                                 gravity: CGVector = defaultGravity,
                                 speed: CGFloat = physicsSpeed) {
        scene.physicsWorld.gravity = gravity
        scene.physicsWorld.speed = speed
    }

    /// 원형 물리 바디 생성
    /// - Parameters:
    ///   - radius: 반지름
    ///   - mass: 질량
    ///   - restitution: 반발력
    ///   - friction: 마찰력
    /// - Returns: 설정된 물리 바디
    static func createCirclePhysicsBody(radius: CGFloat,
                                       mass: CGFloat,
                                       restitution: CGFloat = defaultRestitution,
                                       friction: CGFloat = defaultFriction) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.mass = mass
        physicsBody.restitution = restitution
        physicsBody.friction = friction
        physicsBody.linearDamping = defaultLinearDamping
        physicsBody.angularDamping = defaultAngularDamping
        physicsBody.allowsRotation = true

        return physicsBody
    }

    /// 경계선 물리 바디 생성
    /// - Parameters:
    ///   - rect: 경계 사각형
    ///   - restitution: 반발력
    ///   - friction: 마찰력
    /// - Returns: 설정된 경계선 물리 바디
    static func createBoundaryPhysicsBody(rect: CGRect,
                                         restitution: CGFloat = defaultRestitution,
                                         friction: CGFloat = defaultFriction) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        physicsBody.restitution = restitution
        physicsBody.friction = friction

        return physicsBody
    }

    // MARK: - Collision Detection Helpers

    /// 두 물리 바디가 충돌했는지 확인
    /// - Parameters:
    ///   - contact: 충돌 정보
    ///   - categoryA: 첫 번째 카테고리
    ///   - categoryB: 두 번째 카테고리
    /// - Returns: 충돌 여부와 정렬된 바디 튜플
    static func checkCollision(_ contact: SKPhysicsContact,
                              between categoryA: UInt32,
                              and categoryB: UInt32) -> (Bool, SKPhysicsBody, SKPhysicsBody)? {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        if bodyA.categoryBitMask == categoryA && bodyB.categoryBitMask == categoryB {
            return (true, bodyA, bodyB)
        } else if bodyA.categoryBitMask == categoryB && bodyB.categoryBitMask == categoryA {
            return (true, bodyB, bodyA)
        }

        return nil
    }

    /// 충돌 강도 계산
    /// - Parameter contact: 충돌 정보
    /// - Returns: 충돌 강도 값
    static func calculateImpactStrength(_ contact: SKPhysicsContact) -> CGFloat {
        let relativeVelocity = CGVector(
            dx: contact.bodyA.velocity.dx - contact.bodyB.velocity.dx,
            dy: contact.bodyA.velocity.dy - contact.bodyB.velocity.dy
        )

        return sqrt(relativeVelocity.dx * relativeVelocity.dx +
                   relativeVelocity.dy * relativeVelocity.dy)
    }

    // MARK: - Distance and Direction Helpers

    /// 두 점 사이의 거리 계산
    /// - Parameters:
    ///   - point1: 첫 번째 점
    ///   - point2: 두 번째 점
    /// - Returns: 거리
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }

    /// 두 점 사이의 방향 벡터 계산 (정규화)
    /// - Parameters:
    ///   - from: 시작점
    ///   - to: 끝점
    /// - Returns: 정규화된 방향 벡터
    static func direction(from: CGPoint, to: CGPoint) -> CGVector {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance > 0 else { return CGVector.zero }

        return CGVector(dx: dx / distance, dy: dy / distance)
    }

    /// 벡터의 크기 계산
    /// - Parameter vector: 벡터
    /// - Returns: 벡터 크기
    static func magnitude(of vector: CGVector) -> CGFloat {
        return sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
    }

    /// 벡터 정규화
    /// - Parameter vector: 벡터
    /// - Returns: 정규화된 벡터
    static func normalize(_ vector: CGVector) -> CGVector {
        let mag = magnitude(of: vector)
        guard mag > 0 else { return CGVector.zero }
        return CGVector(dx: vector.dx / mag, dy: vector.dy / mag)
    }

    // MARK: - Impulse Helpers

    /// 랜덤 임펄스 생성
    /// - Parameters:
    ///   - minX: X축 최소값
    ///   - maxX: X축 최대값
    ///   - minY: Y축 최소값
    ///   - maxY: Y축 최대값
    /// - Returns: 랜덤 임펄스 벡터
    static func randomImpulse(minX: CGFloat = -20, maxX: CGFloat = 20,
                             minY: CGFloat = -10, maxY: CGFloat = 10) -> CGVector {
        return CGVector(
            dx: CGFloat.random(in: minX...maxX),
            dy: CGFloat.random(in: minY...maxY)
        )
    }

    /// 물리 바디에 랜덤 임펄스 적용
    /// - Parameters:
    ///   - physicsBody: 적용할 물리 바디
    ///   - impulse: 임펄스 벡터
    ///   - angularImpulse: 회전 임펄스 (선택)
    static func applyRandomImpulse(to physicsBody: SKPhysicsBody,
                                  impulse: CGVector,
                                  angularImpulse: CGFloat? = nil) {
        physicsBody.applyImpulse(impulse)

        if let angular = angularImpulse {
            physicsBody.angularVelocity += angular
        }
    }

    // MARK: - Velocity Helpers

    /// 속도 제한
    /// - Parameters:
    ///   - physicsBody: 제한할 물리 바디
    ///   - maxSpeed: 최대 속도
    static func limitVelocity(of physicsBody: SKPhysicsBody, maxSpeed: CGFloat) {
        let velocity = physicsBody.velocity
        let speed = magnitude(of: velocity)

        if speed > maxSpeed {
            let normalized = normalize(velocity)
            physicsBody.velocity = CGVector(
                dx: normalized.dx * maxSpeed,
                dy: normalized.dy * maxSpeed
            )
        }
    }

    /// 각속도 제한
    /// - Parameters:
    ///   - physicsBody: 제한할 물리 바디
    ///   - maxAngularSpeed: 최대 각속도
    static func limitAngularVelocity(of physicsBody: SKPhysicsBody, maxAngularSpeed: CGFloat) {
        if abs(physicsBody.angularVelocity) > maxAngularSpeed {
            physicsBody.angularVelocity = maxAngularSpeed * (physicsBody.angularVelocity > 0 ? 1 : -1)
        }
    }

    // MARK: - Boundary Helpers

    /// 점이 사각형 내부에 있는지 확인
    /// - Parameters:
    ///   - point: 확인할 점
    ///   - rect: 사각형
    ///   - margin: 여백 (기본값: 0)
    /// - Returns: 내부 여부
    static func isPoint(_ point: CGPoint, insideRect rect: CGRect, margin: CGFloat = 0) -> Bool {
        return point.x >= rect.minX + margin &&
               point.x <= rect.maxX - margin &&
               point.y >= rect.minY + margin &&
               point.y <= rect.maxY - margin
    }

    /// 점을 사각형 내부로 제한
    /// - Parameters:
    ///   - point: 제한할 점
    ///   - rect: 사각형
    ///   - margin: 여백
    /// - Returns: 제한된 점
    static func clamp(_ point: CGPoint, toRect rect: CGRect, margin: CGFloat = 0) -> CGPoint {
        return CGPoint(
            x: max(rect.minX + margin, min(rect.maxX - margin, point.x)),
            y: max(rect.minY + margin, min(rect.maxY - margin, point.y))
        )
    }
}
