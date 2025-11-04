//
//  TimeManager.swift
//  bubbleSky
//
//  Phase 2.3: 동적 스테이지 시스템 - 시간 감지
//

import Foundation
import SpriteKit

/// 시간대 구분
enum TimeOfDay: String, CaseIterable {
    case dawn       // 새벽 (5:00 - 6:59)
    case morning    // 아침 (7:00 - 10:59)
    case day        // 낮 (11:00 - 16:59)
    case evening    // 저녁 (17:00 - 19:59)
    case night      // 밤 (20:00 - 4:59)

    /// 시간대별 표시 이름
    var displayName: String {
        switch self {
        case .dawn: return "새벽"
        case .morning: return "아침"
        case .day: return "낮"
        case .evening: return "저녁"
        case .night: return "밤"
        }
    }

    /// 시간대별 하늘 색상 (상단)
    var skyTopColor: UIColor {
        switch self {
        case .dawn:
            // 새벽: 어두운 보라-핑크
            return UIColor(red: 0.4, green: 0.2, blue: 0.5, alpha: 1.0)
        case .morning:
            // 아침: 밝은 하늘색
            return UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
        case .day:
            // 낮: 선명한 파란 하늘
            return UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        case .evening:
            // 저녁: 주황-핑크
            return UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0)
        case .night:
            // 밤: 어두운 남색
            return UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
        }
    }

    /// 시간대별 하늘 색상 (하단)
    var skyBottomColor: UIColor {
        switch self {
        case .dawn:
            // 새벽: 밝은 핑크-오렌지
            return UIColor(red: 1.0, green: 0.6, blue: 0.5, alpha: 1.0)
        case .morning:
            // 아침: 연한 청록색
            return UIColor(red: 0.6, green: 0.85, blue: 1.0, alpha: 1.0)
        case .day:
            // 낮: 밝은 하늘색
            return UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        case .evening:
            // 저녁: 진한 주황
            return UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
        case .night:
            // 밤: 검은 남색
            return UIColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1.0)
        }
    }

    /// 시간대별 구름 색상
    var cloudColor: UIColor {
        switch self {
        case .dawn:
            // 새벽: 핑크빛 구름
            return UIColor(red: 1.0, green: 0.7, blue: 0.8, alpha: 0.7)
        case .morning:
            // 아침: 밝은 흰 구름
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        case .day:
            // 낮: 순백 구름
            return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
        case .evening:
            // 저녁: 주황빛 구름
            return UIColor(red: 1.0, green: 0.6, blue: 0.4, alpha: 0.75)
        case .night:
            // 밤: 어두운 회색 구름
            return UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.6)
        }
    }

    /// 시간대별 별 표시 여부
    var showStars: Bool {
        switch self {
        case .night, .dawn:
            return true
        default:
            return false
        }
    }
}

/// 날씨 타입
enum WeatherType: String, CaseIterable {
    case clear      // 맑음
    case cloudy     // 흐림
    case rainy      // 비
    case snowy      // 눈 (겨울 테마 시)

    var displayName: String {
        switch self {
        case .clear: return "맑음"
        case .cloudy: return "흐림"
        case .rainy: return "비"
        case .snowy: return "눈"
        }
    }
}

/// 시간 및 날씨 관리 싱글톤
class TimeManager {

    // MARK: - Singleton

    static let shared = TimeManager()

    private init() {
        updateCurrentTime()
    }

    // MARK: - Properties

    /// 현재 시간대
    private(set) var currentTimeOfDay: TimeOfDay = .day

    /// 현재 날씨 (랜덤 또는 설정)
    private(set) var currentWeather: WeatherType = .clear

    /// 시간 업데이트 타이머
    private var updateTimer: Timer?

    /// 시간대 변경 콜백
    var onTimeChanged: ((TimeOfDay) -> Void)?

    /// 날씨 변경 콜백
    var onWeatherChanged: ((WeatherType) -> Void)?

    // MARK: - Public Methods

    /// 자동 시간 업데이트 시작 (1분마다 확인)
    func startAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }
    }

    /// 자동 업데이트 중지
    func stopAutoUpdate() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    /// 현재 시간 기반으로 시간대 업데이트
    func updateCurrentTime() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())

        let newTimeOfDay = getTimeOfDay(for: hour)

        if newTimeOfDay != currentTimeOfDay {
            currentTimeOfDay = newTimeOfDay
            onTimeChanged?(currentTimeOfDay)
        }
    }

    /// 시간대 강제 설정 (테스트용)
    func setTimeOfDay(_ timeOfDay: TimeOfDay) {
        currentTimeOfDay = timeOfDay
        onTimeChanged?(currentTimeOfDay)
    }

    /// 날씨 랜덤 변경
    func randomizeWeather() {
        // 시간대에 따른 날씨 확률
        let weatherProbabilities: [WeatherType: Double]

        switch currentTimeOfDay {
        case .dawn, .night:
            // 새벽/밤: 맑음 높은 확률
            weatherProbabilities = [.clear: 0.7, .cloudy: 0.2, .rainy: 0.1]
        case .morning, .day:
            // 아침/낮: 다양한 날씨
            weatherProbabilities = [.clear: 0.5, .cloudy: 0.3, .rainy: 0.2]
        case .evening:
            // 저녁: 흐림 가능성 높음
            weatherProbabilities = [.clear: 0.4, .cloudy: 0.4, .rainy: 0.2]
        }

        let random = Double.random(in: 0...1)
        var accumulated: Double = 0

        for (weather, probability) in weatherProbabilities {
            accumulated += probability
            if random <= accumulated {
                setWeather(weather)
                return
            }
        }

        // 기본값
        setWeather(.clear)
    }

    /// 날씨 강제 설정
    func setWeather(_ weather: WeatherType) {
        if weather != currentWeather {
            currentWeather = weather
            onWeatherChanged?(currentWeather)
        }
    }

    // MARK: - Private Methods

    /// 시간(hour)으로부터 시간대 계산
    private func getTimeOfDay(for hour: Int) -> TimeOfDay {
        switch hour {
        case 5...6:
            return .dawn
        case 7...10:
            return .morning
        case 11...16:
            return .day
        case 17...19:
            return .evening
        default: // 20...23, 0...4
            return .night
        }
    }
}
