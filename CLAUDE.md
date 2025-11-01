# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AUv3 (Audio Unit version 3) instrument for iOS/macOS built with AudioKit 5 and SwiftUI. It's a minimal example that uses the MIDISampler to load and play EXS24 instrument files, with a built-in reverb effect and MIDI support.

**Current Branch**: `SwiftUI_AUv3` - This branch uses SwiftUI for both the standalone app and the AUv3 extension UI. The `master` branch uses UIKit with storyboards for the AUv3 extension.

## Build and Run

### Building the Project
```bash
xcodebuild -scheme Instrument -configuration Debug build
```

### Building the AUv3 Extension
```bash
xcodebuild -scheme InstrumentAUv3 -configuration Debug build
```

### Running Tests
```bash
# Run unit tests
xcodebuild test -scheme Instrument -destination 'platform=iOS Simulator,name=iPhone 15'

# Run UI tests
xcodebuild test -scheme InstrumentUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

### Dual-Target Structure
The project has two main targets:
- **Instrument**: The standalone SwiftUI app that hosts the instrument
- **InstrumentAUv3**: The Audio Unit extension that can be loaded by DAWs

### Core Components

**Conductor.swift**
- Central audio engine manager that owns the AudioKit `AudioEngine` and `MIDISampler`
- Loads the EXS instrument file from `Sounds/SquareInstrument.exs`
- Manages the reverb effect chain: `MIDISampler -> Reverb -> AudioEngine.output`

**InstrumentAUv3AudioUnit.swift**
- The AUv3 audio unit implementation that handles real-time audio rendering
- Uses manual rendering mode with `AVAudioEngine.manualRenderingBlock`
- Implements the render callback in `setInternalRenderingBlock()` which processes MIDI events and produces audio
- Manages AUParameter for reverb (AUParam1) with automation support
- Factory presets: "No Reverb" (0.0) and "Full Reverb" (1.0)

**InstrumentEXSConductor/InstrumentEXSView**
- Standalone app UI layer that wraps the Conductor
- Implements `MIDIListener` protocol to receive external MIDI input
- Handles app lifecycle (background mode, audio interruptions)
- Uses SwiftUI Keyboard component for on-screen piano

**AudioUnitViewController.swift (AUv3 Extension)**
- Wraps SwiftUI views using `UIHostingController` (iOS) or `NSHostingController` (macOS)
- Creates and manages the `InstrumentEXSAUv3View` SwiftUI view
- Bridges AUParameter changes to SwiftUI via `AudioParameter` observable object
- Cross-platform compatible with conditional compilation for iOS/macOS

**InstrumentEXSAUv3View.swift**
- SwiftUI view for the AUv3 extension UI
- Uses the shared `ParameterSlider` component (same as standalone app)
- Bidirectional parameter binding: DAW ↔ AUParameter ↔ SwiftUI view

### Audio Unit Configuration
The AUv3 extension is defined in [InstrumentAUv3/Info.plist](InstrumentAUv3/Info.plist):
- Type: `aumu` (Music Instrument)
- Manufacturer: `TEST`
- Subtype: `test`
- Factory function: `AudioUnitViewController.createAudioUnit`

### Sample Rate Handling
Platform-specific sample rates are set in [InstrumentApp.swift](Instrument/InstrumentApp.swift):
- iOS 18+: 48,000 Hz (native iOS devices only, not Mac Catalyst or iOS on Mac)
- macOS 15+: 48,000 Hz
- Default: 44,100 Hz

### Dependencies
Managed via Swift Package Manager:
- **AudioKit** (main branch): Core audio engine and DSP
- **Keyboard** (main branch): SwiftUI piano keyboard component
- **Tonic** (1.0.7): Music theory primitives (Pitch, Note)

## Key Implementation Details

### MIDI Processing
- MIDI events are processed in the audio render callback via `handleMIDI(midiEvent:timestamp:)`
- Supports note on/off, pitch bend, and CC#1 (mod wheel)
- The audio unit receives MIDI through `AURenderEvent` in the render block

### State Management
- The audio engine must be started in `allocateRenderResources()` before rendering
- The first note may be delayed if engine startup takes time (see `confirmEngineStarted` flag)
- Audio interruptions (phone calls) are handled with `AVAudioSession.interruptionNotification`

### UI Layer
- **Both the AUv3 extension and standalone app use SwiftUI** (this is the `SwiftUI_AUv3` branch)
- The AUv3 extension hosts SwiftUI via `UIHostingController`/`NSHostingController`
- Both UIs share the same `ParameterSlider` component for consistency
- Parameter changes are synchronized bidirectionally:
  - Host DAW automation → `AUParameter` → `parameterObserverToken` callback → `updateParameterValue()` → SwiftUI `@Published` value
  - SwiftUI slider → `onChange` → `AudioParameter.updateValue()` → `AUParameter.setValue()` → Audio engine
- The `AudioParameter` class acts as the bridge between AUParameter and SwiftUI's `@ObservedObject` system
