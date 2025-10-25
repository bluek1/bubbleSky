//
//  AudioManager.swift
//  bubbleSky
//
//  사운드 및 음악 관리 시스템
//

import AVFoundation
import SpriteKit

/// 사운드 효과 열거형
enum SoundEffect: String {
    case bubbleShoot = "bubble_shoot.wav"
    case bubbleMerge = "bubble_merge.wav"
    case bubblePop = "bubble_pop.wav"
    case backgroundMusic = "peaceful_sky.mp3"
    case gameOver = "game_over.wav"
    case chainReaction = "chain_reaction.wav"
    case megaSpecial = "mega_special.wav"

    /// 사운드 파일명
    var filename: String {
        return self.rawValue
    }

    /// 사운드 파일명 (확장자 제외)
    var nameWithoutExtension: String {
        return String(rawValue.split(separator: ".").first ?? "")
    }

    /// 파일 확장자
    var fileExtension: String {
        return String(rawValue.split(separator: ".").last ?? "")
    }
}

/// 오디오 관리 클래스
class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()
    private init() {
        loadSoundEffects()
    }

    // MARK: - Properties

    /// 음악 플레이어
    private var backgroundMusicPlayer: AVAudioPlayer?

    /// 효과음 플레이어들
    private var soundEffectPlayers: [SoundEffect: AVAudioPlayer] = [:]

    /// 음악 볼륨 (0.0 ~ 1.0)
    var musicVolume: Float = 0.5 {
        didSet {
            backgroundMusicPlayer?.volume = musicVolume
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
        }
    }

    /// 효과음 볼륨 (0.0 ~ 1.0)
    var soundEffectVolume: Float = 0.7 {
        didSet {
            for (_, player) in soundEffectPlayers {
                player.volume = soundEffectVolume
            }
            UserDefaults.standard.set(soundEffectVolume, forKey: "soundEffectVolume")
        }
    }

    /// 음악 활성화 여부
    var isMusicEnabled: Bool = true {
        didSet {
            if isMusicEnabled {
                resumeBackgroundMusic()
            } else {
                pauseBackgroundMusic()
            }
            UserDefaults.standard.set(isMusicEnabled, forKey: "isMusicEnabled")
        }
    }

    /// 효과음 활성화 여부
    var isSoundEffectEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isSoundEffectEnabled, forKey: "isSoundEffectEnabled")
        }
    }

    // MARK: - Setup Methods

    /// 사운드 효과 사전 로드
    private func loadSoundEffects() {
        // UserDefaults에서 설정 로드
        musicVolume = UserDefaults.standard.float(forKey: "musicVolume")
        soundEffectVolume = UserDefaults.standard.float(forKey: "soundEffectVolume")
        isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
        isSoundEffectEnabled = UserDefaults.standard.bool(forKey: "isSoundEffectEnabled")

        // 기본값 설정 (처음 실행 시)
        if musicVolume == 0 {
            musicVolume = 0.5
        }
        if soundEffectVolume == 0 {
            soundEffectVolume = 0.7
        }

        // 각 사운드 효과 사전 로드
        for soundEffect in [SoundEffect.bubbleShoot, .bubbleMerge, .bubblePop,
                            .gameOver, .chainReaction, .megaSpecial] {
            preloadSoundEffect(soundEffect)
        }
    }

    /// 특정 사운드 효과 사전 로드
    /// - Parameter soundEffect: 로드할 사운드 효과
    private func preloadSoundEffect(_ soundEffect: SoundEffect) {
        guard let url = Bundle.main.url(forResource: soundEffect.nameWithoutExtension,
                                       withExtension: soundEffect.fileExtension) else {
            #if DEBUG
            print("⚠️ Sound file not found: \(soundEffect.filename)")
            #endif
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = soundEffectVolume
            player.prepareToPlay()
            soundEffectPlayers[soundEffect] = player
        } catch {
            #if DEBUG
            print("❌ Error loading sound effect \(soundEffect.filename): \(error)")
            #endif
        }
    }

    // MARK: - Background Music Methods

    /// 배경 음악 재생
    /// - Parameter loop: 반복 재생 여부 (기본값: true)
    func playBackgroundMusic(loop: Bool = true) {
        guard isMusicEnabled else { return }

        guard let url = Bundle.main.url(forResource: SoundEffect.backgroundMusic.nameWithoutExtension,
                                       withExtension: SoundEffect.backgroundMusic.fileExtension) else {
            #if DEBUG
            print("⚠️ Background music file not found")
            #endif
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()

            #if DEBUG
            print("🎵 Background music started")
            #endif
        } catch {
            #if DEBUG
            print("❌ Error playing background music: \(error)")
            #endif
        }
    }

    /// 배경 음악 일시정지
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    /// 배경 음악 재개
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }

    /// 배경 음악 정지
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }

    // MARK: - Sound Effect Methods

    /// 효과음 재생
    /// - Parameter soundEffect: 재생할 효과음
    func playSoundEffect(_ soundEffect: SoundEffect) {
        guard isSoundEffectEnabled else { return }

        if let player = soundEffectPlayers[soundEffect] {
            player.currentTime = 0
            player.volume = soundEffectVolume
            player.play()
        } else {
            // 사전 로드되지 않은 경우 즉시 로드 후 재생
            preloadSoundEffect(soundEffect)
            soundEffectPlayers[soundEffect]?.play()
        }
    }

    /// SpriteKit 액션으로 효과음 재생
    /// - Parameter soundEffect: 재생할 효과음
    /// - Returns: SKAction
    func soundEffectAction(_ soundEffect: SoundEffect) -> SKAction {
        return SKAction.run { [weak self] in
            self?.playSoundEffect(soundEffect)
        }
    }

    // MARK: - Convenience Methods

    /// 비눗방울 발사 사운드 재생
    func playBubbleShootSound() {
        playSoundEffect(.bubbleShoot)
    }

    /// 비눗방울 합치기 사운드 재생
    func playBubbleMergeSound() {
        playSoundEffect(.bubbleMerge)
    }

    /// 비눗방울 터지기 사운드 재생
    func playBubblePopSound() {
        playSoundEffect(.bubblePop)
    }

    /// 게임 오버 사운드 재생
    func playGameOverSound() {
        playSoundEffect(.gameOver)
    }

    /// 연쇄 반응 사운드 재생
    func playChainReactionSound() {
        playSoundEffect(.chainReaction)
    }

    /// 메가 스페셜 사운드 재생
    func playMegaSpecialSound() {
        playSoundEffect(.megaSpecial)
    }

    // MARK: - Utility Methods

    /// 모든 사운드 정지
    func stopAllSounds() {
        stopBackgroundMusic()
        for (_, player) in soundEffectPlayers {
            player.stop()
        }
    }

    /// 오디오 세션 설정
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)

            #if DEBUG
            print("🔊 Audio session configured")
            #endif
        } catch {
            #if DEBUG
            print("❌ Error setting up audio session: \(error)")
            #endif
        }
    }
}
