//
//  GameManager.swift
//  bubbleSky
//
//  Created by sang gi kim on 9/6/25.
//

import Foundation
import SpriteKit

/// 게임 상태 열거형
enum GameState {
    case ready      // 게임 시작 준비
    case playing    // 게임 진행 중
    case paused     // 일시정지
    case gameOver   // 게임 오버
}

/// 게임 전체 상태 및 로직 관리 클래스
class GameManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = GameManager()
    private init() {}
    
    // MARK: - Properties
    
    /// 현재 게임 상태
    @Published var gameState: GameState = .ready
    
    /// 현재 점수
    @Published var score: Int = 0
    
    /// 최고 점수
    @Published var bestScore: Int = 0
    
    /// 게임 시간 (초)
    @Published var gameTime: TimeInterval = 0
    
    /// 합친 비눗방울 개수 통계
    @Published var mergeStats: [BubbleType: Int] = [:]
    
    /// 연속 발사 횟수
    private var shotCount: Int = 0
    
    /// 게임 시작 시간
    private var gameStartTime: Date?
    
    /// 게임 타이머
    private var gameTimer: Timer?
    
    // MARK: - Game Control Methods
    
    /// 새 게임 시작
    func startNewGame() {
        gameState = .playing
        score = 0
        gameTime = 0
        shotCount = 0
        mergeStats.removeAll()
        gameStartTime = Date()
        startGameTimer()
        
        // 베스트 스코어 로드
        loadBestScore()
    }
    
    /// 게임 일시정지
    func pauseGame() {
        guard gameState == .playing else { return }
        gameState = .paused
        stopGameTimer()
    }
    
    /// 게임 재개
    func resumeGame() {
        guard gameState == .paused else { return }
        gameState = .playing
        startGameTimer()
    }
    
    /// 게임 오버 처리
    func endGame() {
        gameState = .gameOver
        stopGameTimer()
        
        // 베스트 스코어 업데이트
        if score > bestScore {
            bestScore = score
            saveBestScore()
        }
    }
    
    /// 게임 재시작
    func restartGame() {
        startNewGame()
    }
    
    // MARK: - Score Management
    
    /// 비눗방울 합치기 시 점수 추가
    /// - Parameter bubbleType: 합쳐진 비눗방울 타입
    func addScoreForMerge(bubbleType: BubbleType) {
        let baseScore = bubbleType.rawValue * 10
        let bonusMultiplier = calculateBonusMultiplier()
        let finalScore = baseScore * bonusMultiplier
        
        score += finalScore
        
        // 통계 업데이트
        mergeStats[bubbleType, default: 0] += 1
    }
    
    /// 보너스 배율 계산 (연속 합치기 등)
    private func calculateBonusMultiplier() -> Int {
        // 기본 배율 1배, 추후 콤보 시스템 등 추가 가능
        return 1
    }
    
    /// UltraBig+UltraBig 특수 효과 점수 (최대 타입 소멸 보너스)
    func addScoreForMegaSpecial() {
        let specialScore = 1000
        score += specialScore
    }
    
    /// 연쇄 반응 보너스 점수
    func addScoreForChainBonus() {
        let chainBonus = 50 // 연쇄 보너스 점수
        score += chainBonus
    }
    
    // MARK: - Statistics
    
    /// 발사 횟수 증가
    func incrementShotCount() {
        shotCount += 1
    }
    
    /// 총 발사 횟수 반환
    func getTotalShots() -> Int {
        return shotCount
    }
    
    /// 합치기 성공률 계산
    func getMergeSuccessRate() -> Double {
        let totalMerges = mergeStats.values.reduce(0, +)
        guard shotCount > 0 else { return 0.0 }
        return Double(totalMerges) / Double(shotCount) * 100.0
    }
    
    // MARK: - Timer Management
    
    /// 게임 타이머 시작
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateGameTime()
        }
    }
    
    /// 게임 타이머 정지
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    /// 게임 시간 업데이트
    private func updateGameTime() {
        guard let startTime = gameStartTime else { return }
        gameTime = Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Data Persistence
    
    /// 베스트 스코어 저장
    private func saveBestScore() {
        UserDefaults.standard.set(bestScore, forKey: "BestScore")
    }
    
    /// 베스트 스코어 로드
    private func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: "BestScore")
    }
    
    // MARK: - Utility Methods
    
    /// 게임 상태가 활성 상태인지 확인
    var isGameActive: Bool {
        return gameState == .playing
    }
    
    /// 게임 시간을 포맷된 문자열로 반환
    func getFormattedGameTime() -> String {
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 점수를 포맷된 문자열로 반환
    func getFormattedScore() -> String {
        return NumberFormatter.localizedString(from: NSNumber(value: score), number: .decimal)
    }
}

// MARK: - GameManager Extensions

extension GameManager {
    
    /// 게임 통계 요약 반환
    func getGameSummary() -> String {
        var summary = "Game Summary:\n"
        summary += "Score: \(getFormattedScore())\n"
        summary += "Time: \(getFormattedGameTime())\n"
        summary += "Total Shots: \(shotCount)\n"
        summary += "Success Rate: \(String(format: "%.1f%%", getMergeSuccessRate()))\n"
        
        if !mergeStats.isEmpty {
            summary += "\nMerge Statistics:\n"
            for (bubbleType, count) in mergeStats.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
                summary += "\(bubbleType.name): \(count)\n"
            }
        }
        
        return summary
    }
}
