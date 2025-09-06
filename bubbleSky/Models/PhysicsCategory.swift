import Foundation

/// 물리 충돌 카테고리 정의
struct PhysicsCategory {
    static let none:      UInt32 = 0          // 0000
    static let bubble:    UInt32 = 0x1 << 0   // 0001 (비눗방울)
    static let wall:      UInt32 = 0x1 << 1   // 0010 (좌우 벽)
    static let ceiling:   UInt32 = 0x1 << 2   // 0100 (상단 곡선 경계)
    static let floor:     UInt32 = 0x1 << 3   // 1000 (하단 발사 영역)
    static let all:       UInt32 = UInt32.max // 1111
}
