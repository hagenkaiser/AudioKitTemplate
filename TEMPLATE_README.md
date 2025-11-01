# AudioKit AUv3 Instrument Template

A production-ready template for creating AUv3 (Audio Unit version 3) instruments for iOS and macOS using AudioKit 5 and SwiftUI.

## Features

- ✅ **Full SwiftUI** - Both standalone app and AUv3 extension use SwiftUI
- ✅ **AudioKit 5** - Built on the latest AudioKit framework
- ✅ **MIDI Support** - Full MIDI input with external MIDI device support
- ✅ **Sample Playback** - Uses MIDISampler for EXS24/SoundFont playback
- ✅ **Cross-Platform** - Runs on iOS and macOS
- ✅ **AUv3 Extension** - Ready to load in GarageBand, Logic Pro, AUM, etc.
- ✅ **Parameter Automation** - Built-in reverb parameter with DAW automation support
- ✅ **Factory Presets** - Example preset implementation

## Quick Start

### Option 1: Using the Setup Script (Recommended)

1. Download and run the setup script:
```bash
curl -O https://raw.githubusercontent.com/hagenkaiser/AudioKitTemplate/main/setup-template.sh
chmod +x setup-template.sh
./setup-template.sh
```

2. Follow the prompts to enter:
   - Project name
   - Bundle identifier prefix
   - Manufacturer code (4 characters)
   - Subtype code (4 characters)
   - Destination directory

3. Open the generated project in Xcode and build!

### Option 2: Manual Setup

1. Clone or download this repository:
```bash
git clone --branch SwiftUI_AUv3 https://github.com/hagenkaiser/AudioKitTemplate.git YourProjectName
cd YourProjectName
```

2. Rename all occurrences of "Instrument" to your project name
3. Update the manufacturer and subtype codes in `InstrumentAUv3/Info.plist`
4. Update bundle identifiers in Xcode project settings

## Project Structure

```
YourProject/
├── YourProject/                    # Main app target
│   ├── YourProjectApp.swift       # App entry point
│   ├── YourProjectEXS.swift       # Main view and conductor
│   ├── Conductor.swift            # Audio engine manager
│   ├── ParameterSlider.swift      # Reusable UI component
│   └── SwiftUIKeyboard.swift      # On-screen keyboard
├── YourProjectAUv3/               # AUv3 extension target
│   ├── Audio Unit/
│   │   └── YourProjectAUv3AudioUnit.swift  # Audio unit implementation
│   └── UI/
│       ├── AudioUnitViewController.swift    # SwiftUI host
│       └── YourProjectEXSAUv3View.swift    # Extension UI
└── Sounds/                        # Audio samples
    ├── Square.wav
    └── SquareInstrument.exs
```

## Customization

### Adding Parameters

1. Add a new AUParameter in `InstrumentAUv3AudioUnit.swift`:
```swift
var AUParam2 = AUParameterTree.createParameter(
    withIdentifier: "AUParam2",
    name: "Filter",
    address: 1,
    min: 0.0,
    max: 1.0,
    unit: .generic,
    unitName: nil,
    flags: [.flag_IsReadable, .flag_IsWritable, .flag_CanRamp],
    valueStrings: nil,
    dependentParameters: nil
)
```

2. Update the parameter tree and callbacks
3. Add UI control in the SwiftUI views

### Loading Your Own Sounds

Replace the files in the `Sounds/` directory:
- EXS24 instruments (.exs)
- SoundFonts (.sf2)
- WAV files

Update the file loading code in `Conductor.swift`.

### Changing Audio Processing

Modify the audio engine setup in `Conductor.swift`. AudioKit provides many DSP nodes:
- Filters (LowPassFilter, HighPassFilter, etc.)
- Effects (Reverb, Delay, Distortion, etc.)
- Oscillators and synthesizers
- And much more!

## Building for Distribution

### iOS

1. Update bundle identifiers to match your developer account
2. Configure signing in Xcode
3. Archive and submit to App Store

### macOS

1. Ensure you have a Mac developer certificate
2. Enable hardened runtime
3. Notarize the app for distribution

## Requirements

- Xcode 14.0+
- iOS 15.0+ / macOS 12.0+
- Swift 5.7+
- AudioKit 5 (automatically included via SPM)

## Manufacturer and Subtype Codes

⚠️ **Important**: Before distributing your Audio Unit:

1. Register a unique 4-character manufacturer code with Apple
2. Choose a unique subtype code for your instrument
3. Update these in `YourProjectAUv3/Info.plist`

Using unregistered codes may cause conflicts with other audio units.

## Documentation

For more details, see [CLAUDE.md](CLAUDE.md) which contains:
- Build commands
- Architecture overview
- Implementation details
- Sample rate handling
- MIDI processing flow

## Credits

Based on the [AudioKit](https://github.com/AudioKit/AudioKit) framework.
Original template by Nick Culbertson [@MobyPixel](https://twitter.com/MobyPixel).

## License

See [LICENSE](LICENSE) file.
