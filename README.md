# Wordflick: A Fast-Paced, Addictive Word Game

Wordflick is an engaging and competitive word game originally released during the launch of the iPad. Featuring fast-paced gameplay, multi-touch controls, and dynamically rendered tiles, Wordflick combines simplicity and strategy to deliver an addictive experience.

Now, we're open-sourcing Wordflick under the MIT License! We invite developers, educators, and enthusiasts to contribute, enhance, and maintain this piece of iOS gaming history.

---

## Gameplay Demo

<img src="assets/screenshot-sim.png" alt="Wordflick Introduction" width="240">
<img src="assets/foutput_320.gif" alt="Wordflick Gameplay" width="220">

---

## 🚀 Game Overview

- **Addictive Gameplay**: Drag and drop letter tiles to the board and spell words. The longer and more complex the word, the higher your score.
- **Fast-Paced Fun**: Players race against a 3-minute timer to achieve high scores and progress through increasingly challenging levels.
- **Educational Value**: Loved by educators, Wordflick appeals to kids and adults alike. It makes learning fun and encourages vocabulary building.

### Key Features:

- **Dynamic Tile Rendering**: Game tiles, styled like Scrabble tiles, are drawn dynamically using Quartz programming for a polished look.
- **Multi-Touch Interactivity**: Makes full use of iOS’s multi-touch capabilities, providing a smooth and intuitive experience.
- **Scalable Difficulty**: Players can spell words of varying lengths to earn points, with increasingly challenging levels as they progress.

---

## 📂 Project Details

This open-source release includes the core game functionality as it exists today:

- **Platform**: iOS application.
- **Codebase**: Written in Objective-C, C, and C++.
- **Database**: Utilizes SQLite for word data.
- **Development Environment**: Builds with Xcode 14.2, targeting iOS 16.2.
- **Removed Features**: Background music has been stripped, and some APIs and features have been deprecated for compatibility.

---

## 🛠️ Getting Started

### Prerequisites

- Xcode 14.2 or newer.
- macOS with development tools for iOS apps.

### Building the Project

1. Clone the repository:

```bash
git clone https://github.com/mthomason/wordflick-ios.git
cd wordflick
```

2. Open the project in Xcode:

```bash
open wordPuzzle.xcodeproj
```
 
3. Build and run the app on a compatible iOS simulator or device.

### Known Issues

- The game timer is currently slowed for testing purposes.
- Some URLs and APIs require updates (`#warning` comments are present in the code).
- There may be unused or commented-out code from deprecated features.

---

## 🤝 Contributing

We welcome contributions of all kinds! Whether you're fixing bugs, optimizing code, or introducing new features, your help is greatly appreciated.

### How to Contribute

1. Fork the repository.
2. Create a new branch for your feature or bug fix:

```bash
git checkout -b feature-or-fix-name
```

3. Commit your changes and push them to your fork:

```bash
git commit -m "Add detailed description of your changes"
git push origin feature-or-fix-name
```

4. Submit a pull request with a clear description of your updates.

### Contribution Ideas

- Update deprecated APIs.
- Reimplement or suggest improvements for removed features.
- Add support for modern iOS design patterns and Swift compatibility.
- Enhance game visuals or gameplay mechanics.
- Fix existing bugs or optimize performance.

---

## 📖 License

This project is licensed under the MIT License. See the LICENSE.md file for details.

### Name and Logo Usage

The name "Wordflick" and associated logos are not covered by the MIT License and may not be used without explicit permission from the copyright holder.

---

## 🙌 Acknowledgments

Wordflick was a hit on the App Store during the iPad's early days, beloved for its intuitive controls and engaging gameplay. With this open-source release, we hope to keep the spirit of Wordflick alive and inspire a new generation of players and developers.

Thank you for helping us bring Wordflick back to life!

---

## 📧 Contact

Have questions, suggestions, or feedback? Reach out to us or open an issue in the repository.
