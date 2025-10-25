# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BubbleSky is an iOS puzzle game built with SpriteKit, similar to Suika Game mechanics. Players shoot bubbles upward to merge matching bubbles, creating larger ones in a physics-based environment.

**Key Technologies:**
- **Language**: Swift
- **Frameworks**: SpriteKit, GameplayKit
- **Platform**: iOS
- **IDE**: Xcode

## Development Commands

### Building and Running
```bash
# Open project in Xcode
open bubbleSky.xcodeproj

# Build and run from command line
xcodebuild -project bubbleSky.xcodeproj -scheme bubbleSky -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run tests
xcodebuild test -project bubbleSky.xcodeproj -scheme bubbleSky -destination 'platform=iOS Simulator,name=iPhone 15'
```

### In Xcode
- **Build & Run**: `Command + R`
- **Run Tests**: `Command + U`
- **Clean Build**: `Command + Shift + K`

## Architecture Overview

### Core Components

**GameScene.swift** - Main game scene handling:
- Physics world setup with upward gravity (bubbles rise to ceiling)
- Touch input for bubble launching with panning controls
- Collision detection and bubble merging logic
- UI updates (score, time, bubble count)
- Game over detection based on bubble position relative to bottom line
- Chain reaction system for consecutive merges
- Bubble overlap prevention and deformation effects

**GameManager.swift** - Singleton managing:
- Game state machine (ready, playing, paused, gameOver)
- Score calculation with merge bonuses and chain bonuses
- Time tracking and formatting
- Statistics (shots, merge success rate, merge counts by type)
- Best score persistence via UserDefaults
- Published properties for reactive UI updates

**Models Directory**:
- `BubbleNode.swift`: Custom SKShapeNode with physics, facial expressions, deformation effects, and highlight rendering
- `CharacterNode.swift`: Launch character at bottom of screen with animations
- `BubbleType.swift`: Enum defining bubble sizes (tiny → small → medium → large → huge → giant → mega → ultraBig)
- `PhysicsCategory.swift`: Bit masks for collision detection (bubble, wall, ground)

### Key Design Patterns

1. **Singleton Pattern**: GameManager.shared provides centralized state management
2. **Delegate Pattern**: GameScene conforms to SKPhysicsContactDelegate for collision handling
3. **Scene Lifecycle**: Setup methods called in didMove(to:) - setupPhysicsWorld(), setupPlayArea(), setupUI(), setupLaunchSystem()
4. **Component Separation**: UI updates separated into extension, physics handling in another extension

### Physics System

- **Gravity**: Upward (dy: 5.0) so bubbles float to ceiling
- **Collision Categories**: Bubbles detect contact with other bubbles and walls
- **Merge Logic**: Same-type bubbles merge into next size on contact
- **Speed Limiting**: physicsWorld.speed = 0.6 to prevent boundary clipping
- **Restitution**: Low (0.2) to reduce bouncing
- **Chain Reactions**: New merged bubbles automatically check for adjacent same-type bubbles

### Play Area Design

- **Curved Top Boundary**: Parabolic ceiling using edge chain physics body
- **Game Over Line**: Bottom blue line - bubbles falling below trigger 2-second countdown
- **Play Area**: 77% of screen width, 80% of screen height, centered slightly below middle
- **Coordinate System**: Anchor point at (0.5, 0.5) for center-based positioning

## Project Structure Conventions

### File Organization
```
bubbleSky/
├── GameScene.swift          # Main game logic
├── GameViewController.swift # View controller bridging UIKit to SpriteKit
├── GameManager.swift        # State management
├── AppDelegate.swift        # App lifecycle
├── Models/
│   ├── BubbleNode.swift
│   ├── CharacterNode.swift
│   ├── BubbleType.swift
│   └── PhysicsCategory.swift
├── Assets.xcassets/         # Images and color resources
└── Base.lproj/              # Storyboards

doc/                         # Planning documents (Korean)
├── development_task_list.md # Main task tracking
├── game_design_detailed.md
├── bubble_launch_mechanics.md
└── [other design docs]
```

### Code Organization with MARK Comments
All Swift files use `// MARK: -` comments to organize code sections:
- `// MARK: - Properties`
- `// MARK: - Initialization`
- `// MARK: - Setup Methods`
- `// MARK: - Game Logic`
- `// MARK: - SKPhysicsContactDelegate`

### Naming Conventions
- **Classes**: PascalCase (GameScene, BubbleNode)
- **Variables/Functions**: camelCase (currentBubble, launchBubble())
- **Constants**: camelCase (maxBubbleSize, playAreaWidth)
- **Private Properties**: Use `private` or `private(set)` modifiers
- **Node Naming**: Descriptive suffixes (bubbleNode, scoreLabel, gameOverLine)

## Important Development Guidelines

### Planning-First Approach
This project follows a documentation-first workflow:
- **DO NOT** create new source code features without checking GitHub issues first
- **Review** `/doc/development_task_list.md` for current development priorities
- **Update** planning documents when adding features
- Game design documents are in Korean - respect bilingual codebase (Korean comments for game logic, English for technical terms)

### Resource Management
- Currently using placeholder graphics (circles with facial features)
- Assets designed to be easily replaceable with proper artwork later
- Resource paths and loading code should be maintainable for future asset updates

### Physics Tuning
When modifying physics:
- Test with multiple bubble sizes (velocity multipliers vary by type)
- Verify boundaries prevent clipping (current speed: 0.6)
- Check overlap prevention doesn't cause jittering
- Ensure merge detection works reliably without duplicates (isMerging flag prevents race conditions)

### Performance Considerations
- Bubble overlap prevention runs at reduced frequency (20 FPS check, not 60)
- Deformation effects have cooldown timers to prevent excessive calculations
- Chain reactions use 0.1s delay to prevent frame drops
- Debug mode shows physics bodies, FPS, and node count (`#if DEBUG`)

### Testing Guidelines
- Unit tests in `bubbleSkyTests/` focus on game logic (merge calculations, scoring)
- UI tests in `bubbleSkyUITests/` verify touch interactions and game flow
- Physics-based gameplay requires simulator or device testing (not just unit tests)

## Common Development Tasks

### Adding New Bubble Type
1. Add case to `BubbleType` enum with radius, color, velocity multiplier
2. Update `nextType` computed property
3. Update score calculation in GameManager if needed
4. Test merge chain all the way to new type

### Modifying Scoring System
- Score logic centralized in `GameManager.addScoreForMerge(bubbleType:)`
- Bonus multipliers in `calculateBonusMultiplier()`
- Special scores: `addScoreForMegaSpecial()` (UltraBig merge), `addScoreForChainBonus()`

### Adjusting Play Area
- Modify ratios in `setupPlayBoundary()`: playAreaWidth, playAreaHeight
- Update `setupTopCurvedBoundary()` to match new dimensions
- Adjust `setupGameOverLine()` position accordingly
- Coordinate changes between setupPlayArea() and setupUI() to prevent overlap

### Debug Visualization
Enable in GameScene.setupPhysicsWorld():
```swift
#if DEBUG
self.view?.showsPhysics = true
self.view?.showsFPS = true
self.view?.showsNodeCount = true
#endif
```

## GitHub Workflow

### Branch Strategy
- `main`: Stable release versions
- `develop`: Active development (not currently present in repo)
- `claude/*`: Feature branches created by Claude Code (must start with 'claude/' and end with session ID)
- `feature/*`: Manual feature development

### Commit Guidelines
- Use English or Korean consistently within a commit
- Present tense verbs ("Add bubble physics", "Fix merge detection")
- Separate commits by feature/fix scope
- Include emoji in commits when specifically requested (see recent commits with 🌈)

### Task Tracking
Development tasks managed in `/doc/development_task_list.md` - check this file before starting new features to align with project roadmap.

## Game-Specific Mechanics

### Bubble Launching
1. Character at bottom creates bubble with animation
2. Player drags horizontally to position launcher (constrained to play area)
3. Release to launch upward with random horizontal impulse and angular velocity
4. New bubble created after 0.5s delay

### Merge System
- Same-type bubbles merge on contact into next type
- UltraBig + UltraBig = special destruction (no next type)
- Merge triggers score increase, removes old bubbles, creates new bubble at midpoint
- New bubble can trigger chain reaction if adjacent same-type exists

### Game Over Condition
- Blue line at bottom of play area marks danger zone
- Bubbles below line for 2+ seconds = game over
- Line blinks as warning during countdown
- Timer cancels if bubbles return above line

### Visual Effects
- Bubbles have facial expressions (randomized on creation)
- Impact deformation on strong collisions (>100 velocity)
- Highlight effect always faces upward regardless of rotation
- Pupils track larger nearby bubbles
- Summer theme with clouds, sky gradient, transparent bubbles
