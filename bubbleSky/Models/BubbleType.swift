import UIKit
import SpriteKit

/// 비눗방울 크기별 타입 정의
enum BubbleType: Int, CaseIterable {
    case tiny = 1      // 가장 작은 비눗방울
    case small = 2
    case medium = 3
    case large = 4
    case huge = 5
    case giant = 6
    case mega = 7
    case superBig = 8  // 새로 추가된 더 큰 비눗방울
    case ultraBig = 9  // 새로 추가된 가장 큰 비눗방울
    
    /// 비눗방울 반지름 값 (tiny는 50% 증가)
    var radius: CGFloat {
        let baseRadius = CGFloat(rawValue * 10) * 1.17
        
        // tiny 방울만 50% 크게 만들기
        if self == .tiny {
            return baseRadius * 1.5
        } else {
            return baseRadius
        }
    }
    
    /// 비눗방울 색상 정의 - 여름 느낌의 투명한 색상
    var color: UIColor {
        switch self {
        case .tiny:      return UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 0.25)   // 여름 하늘 파랑
        case .small:     return UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 0.25)   // 여름 잔디 초록
        case .medium:    return UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.25)   // 여름 햇살 노랑
        case .large:     return UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.25)   // 여름 석양 오렌지
        case .huge:      return UIColor(red: 1.0, green: 0.3, blue: 0.4, alpha: 0.25)   // 여름 수박 빨강
        case .giant:     return UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 0.25)   // 여름 라벤더 보라
        case .mega:      return UIColor(red: 1.0, green: 0.4, blue: 0.8, alpha: 0.25)   // 여름 코스모스 분홍
        case .superBig:  return UIColor(red: 0.2, green: 1.0, blue: 0.8, alpha: 0.25)   // 여름 바다 시안
        case .ultraBig:  return UIColor(red: 0.4, green: 1.0, blue: 0.6, alpha: 0.25)   // 여름 민트
        }
    }
    
    /// 다음 단계 비눗방울 타입
    var nextType: BubbleType? {
        guard rawValue < BubbleType.ultraBig.rawValue else { return nil }
        return BubbleType(rawValue: rawValue + 1)
    }
    
    /// 타입 이름 (디버깅용)
    var name: String {
        switch self {
        case .tiny: return "Tiny"
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .huge: return "Huge"
        case .giant: return "Giant"
        case .mega: return "Mega"
        case .superBig: return "SuperBig"
        case .ultraBig: return "UltraBig"
        }
    }
    
    /// 비눗방울 질량 - 크기에 따라 증가
    var mass: CGFloat {
        return CGFloat(rawValue) * 0.5
    }
    
    /// 비눗방울 탄성 - 경계선 겹침 방지를 위해 낮춤 + 랜덤성 추가
    var restitution: CGFloat {
        let baseRestitution: CGFloat = 0.3  // 0.5에서 0.3으로 감소하여 반발력 줄임
        let randomVariation = CGFloat.random(in: -0.1...0.1)  // ±0.1의 랜덤 변화
        return max(0.1, min(0.5, baseRestitution + randomVariation))  // 0.1~0.5 범위로 조정
    }
    
    /// 비눗방울 마찰력 - 안정성을 위해 증가 + 랜덤성 추가
    var friction: CGFloat {
        let baseFriction = 0.3 + CGFloat(rawValue) * 0.05
        let randomVariation = CGFloat.random(in: -0.05...0.05)  // ±0.05의 랜덤 변화
        return max(0.1, min(0.6, baseFriction + randomVariation))  // 0.1~0.6 범위로 제한
    }
    
    /// 발사 속도 배율 - 크기가 클수록 느리게
    var velocityMultiplier: CGFloat {
        switch self {
        case .tiny: return 1.2
        case .small: return 1.1
        case .medium: return 1.0
        case .large: return 0.9
        case .huge: return 0.8
        case .giant: return 0.8  // Giant, Mega, SuperBig, UltraBig는 발사되지 않음
        case .mega: return 0.8
        case .superBig: return 0.8
        case .ultraBig: return 0.8
        }
    }
    
    /// 랜덤 발사용 비눗방울 타입 생성
    /// Tiny(30%), Small(30%), Medium(25%), Large(10%), Huge(5%)
    /// Giant, Mega, SuperBig, UltraBig는 생성되지 않음 (합쳐서만 만들어짐)
    static func randomLaunchType() -> BubbleType {
        let randomValue = Int.random(in: 1...100)
        
        switch randomValue {
        case 1...30:    return .tiny
        case 31...60:   return .small
        case 61...85:   return .medium
        case 86...95:   return .large
        case 96...100:  return .huge
        default:        return .tiny
        }
    }
}