# One Big Thing

**What's your one big thing for today?**

The one thing that, if you accomplished it today, would make it a productive day.

## What is this?

A macOS app that forces you to focus. Every morning, a full-screen prompt asks for your one big thing. Once you enter it, a floating toast stays on your screen—always visible, impossible to ignore—until you mark it complete.

It's meant to be obnoxious. That's the point.

## Install

```bash
cd OneBigThingFloat
swift build -c release
mkdir -p /Applications/OneBigThingFloat.app/Contents/MacOS
cp .build/release/OneBigThingFloat /Applications/OneBigThingFloat.app/Contents/MacOS/
```

## Setup Daily Prompt

```bash
cp com.onebighing.morning.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.onebighing.morning.plist
```

This runs the prompt at 9am daily and on login.
