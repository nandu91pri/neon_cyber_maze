# Neon Cyber Maze Monster — Flutter/Dart Development Bundle

This bundle consolidates the available conversation archive and Dart code for the **Neon Cyber Maze Monster** project.

## Contents

- `lib/main.dart` — original single-file playable prototype: neon maze, energy orbs, score, lives, timer, monster pathfinding, keyboard and touch controls.
- `lib/game/heart_power_up.dart` — animated parametric neon-heart widget. It is a reusable visual component, not yet connected to maze collision or extra-life rules.
- `lib/heart_demo_main.dart` — optional standalone screen for previewing the heart animation.
- `docs/CONVERSATION_ARCHIVE.md` — consolidated conversation notes, setup/testing instructions, and the original code discussion.

## Open in VS Code

1. Install Flutter and verify `flutter doctor`.
2. In a terminal, create a project: `flutter create neon_cyber_maze`.
3. Copy this bundle's `lib/` folder into the new project, replacing its generated `lib/main.dart` and adding the other files.
4. From the project root run:

   ```bash
   flutter pub get
   flutter analyze
   flutter devices
   flutter run
   ```

The prototype uses only Flutter SDK libraries, so no extra dependency is required by this code. Use a connected Android device/emulator or configured desktop target.

## Preview the heart animation separately

The normal game entry point is `lib/main.dart`. To preview the heart alone, temporarily copy the contents of `lib/heart_demo_main.dart` into `lib/main.dart`, run `flutter run`, and then restore the game `main.dart` afterwards. Alternatively, use a separate Flutter demo project and copy `lib/game/heart_power_up.dart` into it.

## Important development notes

- The heart curve code interprets the ambiguous `cos^1(2t)` expression as `cos²(2t)`. If you meant ordinary cosine, change the y equation in `heart_power_up.dart` to `4 * math.cos(t) - 1.5 * math.cos(2 * t)`.
- The current maze is a prototype, not a finished commercial game. Run it, test every corridor and control, and use `flutter analyze` before adding features.
- The heart widget is not yet a collectible in the maze. To make it one, the game needs a heart position in the map, collision detection, a life/shield effect, and drawing/overlay integration. The archive records the proposed next steps.
- The code archive reflects the conversations and code available for this project; it cannot include messages that are not accessible in the conversation history.

## Suggested next implementation order

1. Verify maze reachability and all movement paths.
2. Stabilize monster movement, collision, restart, and timer behavior.
3. Refactor `main.dart` into map, player, monster, HUD, and controls files.
4. Add the heart as a collectible and implement its game effect.
5. Add sound, levels, pause/settings, accessibility, and device-size testing.
6. Add automated tests and release/build configuration before publishing.
