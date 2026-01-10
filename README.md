# One Big Thing

A productivity system that helps you focus on your one most important task each day.

## Components

1. **Raycast Extension** - Set, view, and complete your daily task
2. **Floating Window App** - Always-on-top reminder you can't ignore
3. **Morning Schedule** - Blocking prompt that forces you to set your task

## Setup Instructions

### 1. Build the Floating Window App

```bash
cd ~/Documents/MyProjects/one-big-thing/OneBigThingFloat
swift build -c release

# Create the app bundle
./create-app.sh
```

Then move `OneBigThingFloat.app` to `/Applications/`.

### 2. Install the Raycast Extension

```bash
cd ~/Documents/MyProjects/one-big-thing/raycast-extension
npm install
npm run dev
```

This will open the extension in Raycast development mode. You can then import it permanently.

### 3. Set Up the Morning Schedule (Optional)

Copy the launch agent to your LaunchAgents folder:

```bash
cp ~/Documents/MyProjects/one-big-thing/com.onebighing.morning.plist ~/Library/LaunchAgents/

# Edit the time if needed (default is 8:00 AM)
# Then load it:
launchctl load ~/Library/LaunchAgents/com.onebighing.morning.plist
```

To change the time, edit the plist file and modify the `Hour` and `Minute` values.

To disable the morning prompt:
```bash
launchctl unload ~/Library/LaunchAgents/com.onebighing.morning.plist
```

## Usage

### Set Your One Big Thing
1. Open Raycast and search for "Set One Big Thing"
2. Enter your task and press Enter
3. The floating reminder will appear on your screen

### Complete Your Task
1. Open Raycast and search for "One Big Thing"
2. Press Enter to mark it complete
3. Confetti will celebrate your accomplishment!

### Morning Prompt (if scheduled)
Every morning at your scheduled time, a full-screen prompt will appear asking for your one big thing. You must enter a task before you can continue.

## Customization

### Change Floating App Location
In Raycast, go to Extensions > One Big Thing > Preferences to set a custom path for the floating app.

### Change Morning Schedule Time
Edit `~/Library/LaunchAgents/com.onebighing.morning.plist`:
- `Hour`: 0-23 (24-hour format)
- `Minute`: 0-59

Reload after editing:
```bash
launchctl unload ~/Library/LaunchAgents/com.onebighing.morning.plist
launchctl load ~/Library/LaunchAgents/com.onebighing.morning.plist
```

### Run Only on Weekdays
Add this inside the `StartCalendarInterval` dict in the plist:
```xml
<key>Weekday</key>
<integer>1</integer>  <!-- 1=Mon, 2=Tue, ..., 5=Fri -->
```

You'll need multiple `StartCalendarInterval` entries for multiple days.
