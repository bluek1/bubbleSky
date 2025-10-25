//
//  CGPoint+Extensions.swift
//  bubbleSky
//
//  CGPoint 구조체 확장
//

import CoreGraphics
import Foundation

extension CGPoint {

    // MARK: - Distance and Direction

    /// 다른 점까지의 거리 계산
    /// - Parameter point: 대상 점
    /// - Returns: 거리
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return sqrt(dx * dx + dy * dy)
    }

    /// 다른 점까지의 거리 제곱 (성능 최적화용)
    /// - Parameter point: 대상 점
    /// - Returns: 거리의 제곱
    func distanceSquared(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return dx * dx + dy * dy
    }

    /// 다른 점으로의 방향 벡터 계산
    /// - Parameter point: 대상 점
    /// - Returns: 방향 벡터 (CGVector)
    func direction(to point: CGPoint) -> CGVector {
        let dx = point.x - x
        let dy = point.y - y
        let distance = sqrt(dx * dx + dy * dy)

        guard distance > 0 else { return .zero }

        return CGVector(dx: dx / distance, dy: dy / distance)
    }

    /// 다른 점으로의 각도 계산 (라디안)
    /// - Parameter point: 대상 점
    /// - Returns: 각도 (라디안)
    func angle(to point: CGPoint) -> CGFloat {
        let dx = point.x - x
        let dy = point.y - y
        return atan2(dy, dx)
    }

    // MARK: - Vector Operations

    /// 벡터 더하기
    /// - Parameter vector: 더할 벡터
    /// - Returns: 결과 점
    func adding(_ vector: CGVector) -> CGPoint {
        return CGPoint(x: x + vector.dx, y: y + vector.dy)
    }

    /// 벡터 빼기
    /// - Parameter vector: 뺄 벡터
    /// - Returns: 결과 점
    func subtracting(_ vector: CGVector) -> CGPoint {
        return CGPoint(x: x - vector.dx, y: y - vector.dy)
    }

    /// 점 더하기
    /// - Parameter point: 더할 점
    /// - Returns: 결과 점
    func adding(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: x + point.x, y: y + point.y)
    }

    /// 점 빼기
    /// - Parameter point: 뺄 점
    /// - Returns: 결과 점
    func subtracting(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: x - point.x, y: y - point.y)
    }

    /// 스케일 곱하기
    /// - Parameter scale: 배율
    /// - Returns: 결과 점
    func multiplying(by scale: CGFloat) -> CGPoint {
        return CGPoint(x: x * scale, y: y * scale)
    }

    /// 스케일 나누기
    /// - Parameter scale: 배율
    /// - Returns: 결과 점
    func dividing(by scale: CGFloat) -> CGPoint {
        guard scale != 0 else { return self }
        return CGPoint(x: x / scale, y: y / scale)
    }

    // MARK: - Interpolation

    /// 선형 보간
    /// - Parameters:
    ///   - point: 목표 점
    ///   - t: 보간 비율 (0.0 ~ 1.0)
    /// - Returns: 보간된 점
    func lerp(to point: CGPoint, t: CGFloat) -> CGPoint {
        let clampedT = max(0, min(1, t))
        return CGPoint(
            x: x + (point.x - x) * clampedT,
            y: y + (point.y - y) * clampedT
        )
    }

    /// 중간점 계산
    /// - Parameter point: 대상 점
    /// - Returns: 중간점
    func midpoint(to point: CGPoint) -> CGPoint {
        return lerp(to: point, t: 0.5)
    }

    // MARK: - Clamping and Constraints

    /// 범위 제한
    /// - Parameters:
    ///   - minX: 최소 X
    ///   - maxX: 최대 X
    ///   - minY: 최소 Y
    ///   - maxY: 최대 Y
    /// - Returns: 제한된 점
    func clamped(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGPoint {
        return CGPoint(
            x: max(minX, min(maxX, x)),
            y: max(minY, min(maxY, y))
        )
    }

    /// 사각형 범위 제한
    /// - Parameter rect: 제한 사각형
    /// - Returns: 제한된 점
    func clamped(to rect: CGRect) -> CGPoint {
        return clamped(minX: rect.minX, maxX: rect.maxX, minY: rect.minY, maxY: rect.maxY)
    }

    // MARK: - Offset and Transform

    /// X 오프셋 적용
    /// - Parameter offset: X 오프셋
    /// - Returns: 결과 점
    func offsetBy(x offset: CGFloat) -> CGPoint {
        return CGPoint(x: x + offset, y: y)
    }

    /// Y 오프셋 적용
    /// - Parameter offset: Y 오프셋
    /// - Returns: 결과 점
    func offsetBy(y offset: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y + offset)
    }

    /// X, Y 오프셋 적용
    /// - Parameters:
    ///   - dx: X 오프셋
    ///   - dy: Y 오프셋
    /// - Returns: 결과 점
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }

    // MARK: - Geometric Checks

    /// 사각형 내부에 있는지 확인
    /// - Parameter rect: 확인할 사각형
    /// - Returns: 내부 여부
    func isInside(_ rect: CGRect) -> Bool {
        return rect.contains(self)
    }

    /// 원 내부에 있는지 확인
    /// - Parameters:
    ///   - center: 원의 중심
    ///   - radius: 원의 반지름
    /// - Returns: 내부 여부
    func isInside(circleCenter center: CGPoint, radius: CGFloat) -> Bool {
        return distance(to: center) <= radius
    }

    // MARK: - Utility

    /// 원점으로부터의 거리 (magnitude)
    var magnitude: CGFloat {
        return sqrt(x * x + y * y)
    }

    /// 정규화된 점 (단위 벡터)
    var normalized: CGPoint {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return CGPoint(x: x / mag, y: y / mag)
    }

    /// 반전된 점 (부호 반대)
    var inverted: CGPoint {
        return CGPoint(x: -x, y: -y)
    }

    /// 절대값 점
    var absolute: CGPoint {
        return CGPoint(x: abs(x), y: abs(y))
    }

    /// CGVector로 변환
    var asVector: CGVector {
        return CGVector(dx: x, dy: y)
    }

    // MARK: - Random

    /// 랜덤 점 생성
    /// - Parameters:
    ///   - minX: 최소 X
    ///   - maxX: 최대 X
    ///   - minY: 최소 Y
    ///   - maxY: 최대 Y
    /// - Returns: 랜덤 점
    static func random(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }

    /// 사각형 내 랜덤 점 생성
    /// - Parameter rect: 사각형
    /// - Returns: 랜덤 점
    static func random(in rect: CGRect) -> CGPoint {
        return random(minX: rect.minX, maxX: rect.maxX, minY: rect.minY, maxY: rect.maxY)
    }

    // MARK: - String Conversion

    /// 읽기 쉬운 문자열로 변환
    var readableString: String {
        return String(format: "(%.1f, %.1f)", x, y)
    }
}

// MARK: - Operators

extension CGPoint {

    /// 점 더하기 연산자
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs.adding(rhs)
    }

    /// 점 빼기 연산자
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs.subtracting(rhs)
    }

    /// 점 곱하기 연산자
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs.multiplying(by: rhs)
    }

    /// 점 나누기 연산자
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return lhs.dividing(by: rhs)
    }

    /// 점 더하기 대입 연산자
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs.adding(rhs)
    }

    /// 점 빼기 대입 연산자
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs.subtracting(rhs)
    }

    /// 점 곱하기 대입 연산자
    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs.multiplying(by: rhs)
    }

    /// 점 나누기 대입 연산자
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs.dividing(by: rhs)
    }
}

// MARK: - CGVector Extensions

extension CGVector {

    /// 크기 계산
    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    /// 정규화된 벡터
    var normalized: CGVector {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return CGVector(dx: dx / mag, dy: dy / mag)
    }

    /// 반전된 벡터
    var inverted: CGVector {
        return CGVector(dx: -dx, dy: -dy)
    }

    /// CGPoint로 변환
    var asPoint: CGPoint {
        return CGPoint(x: dx, y: dy)
    }

    /// 각도 (라디안)
    var angle: CGFloat {
        return atan2(dy, dx)
    }

    /// 벡터 더하기
    static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    /// 벡터 빼기
    static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }

    /// 벡터 곱하기
    static func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }

    /// 벡터 나누기
    static func / (lhs: CGVector, rhs: CGFloat) -> CGVector {
        guard rhs != 0 else { return lhs }
        return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }
}
