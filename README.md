# One Big Thing

**What's your one big thing for today?**

The one thing that, if you accomplished it today, would make it a productive day.

## What is this?

A macOS app that forces you to focus. Every morning, a full-screen prompt asks for your one big thing. Once you enter it, a floating toast stays on your screen—always visible, impossible to ignore—until you mark it complete.

It's meant to be obnoxious. That's the point.

## Install

```bash
cd OneBigThing
./create-app.sh
mv OneBigThing.app /Applications/
```

## Setup Daily Prompt

```bash
cp com.onebigthing.morning.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.onebigthing.morning.plist
```

This runs the prompt at 8am daily and on login.
