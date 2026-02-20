# Save System Setup Guide

## Overview

I've implemented a DDLC-style save/load system for Nocturnal Tots with the following features:

- **4 Save Slots**: 1 Autosave + 3 Manual Save Slots
- **VN-Only Saving**: Saves only work during Visual Novel sections (not during platformer/rhythm gameplay)
- **Autosave**: Automatically saves every 60 seconds during VN sections
- **Manual Saves**: Players can manually save to Slots 1-3 during VN sections

## What I've Done

### 1. Created Core Scripts ✓

- **`Scripts/save_manager.gd`** - Global save manager (added as autoload)
- **`Scripts/save_load_menu.gd`** - Save/Load menu UI controller
- **`Scripts/save_slot_button.gd`** - Individual save slot button

### 2. Updated Existing Scripts ✓

- **`project.godot`** - Added SaveManager as autoload
- **`Scripts/visual_novel.gd`** - Enables saving in VN, disables when entering gameplay
- **`Scripts/olivia_path.gd`** - Re-enables saving after rhythm game
- **`Scripts/sophia_path.gd`** - Enables saving in Sophia's route

### 3. How It Works

#### Saving During VN Sections:
- When in `visual_novel.tscn`, `olivia_path.tscn`, or `sophia_path.tscn`, saving is **enabled**
- Autosave runs every 60 seconds automatically
- Players can manually save to Slots 1-3

#### No Saving During Gameplay:
- When transitioning to platformer (`S_level1.tscn`) or rhythm game (`rhythm.tscn`), saving is **disabled**
- Dialogic dialogue within rhythm game (between songs) does NOT save
- When gameplay ends and returns to VN, saving is **re-enabled**

## What You Need to Do in Godot

### Step 1: Create the Save/Load Menu Scene

1. Open Godot and create a new scene
2. Add the following node structure:

```
Control (name: SaveLoadMenu)
└─ Panel
   └─ MarginContainer
      └─ VBoxContainer
         ├─ Label (name: TitleLabel, text: "Save/Load Game")
         ├─ VBoxContainer (name: SlotContainer)
         └─ Button (name: BackButton, text: "Back")
```

3. Configure the nodes:
   - **Control (SaveLoadMenu)**:
     - Anchor Preset: Full Rect
     - Layout: Fill

   - **Panel**:
     - Anchor Preset: Center
     - Custom Minimum Size: 800 x 600

   - **MarginContainer**:
     - All margins: 20

   - **TitleLabel**:
     - Font Size: 32
     - Horizontal Alignment: Center

   - **BackButton**:
     - Text: "Back to Title"

4. Attach the script `res://Scripts/save_load_menu.gd` to the **SaveLoadMenu** (Control) node

5. Save the scene as `res://scenes/save_load_menu.tscn`

### Step 2: Add Continue/Load Button to Title Screen

You have two options:

#### Option A: Simple - Add "Load Game" button to existing title screen

1. Open `res://scenes/title_screen.tscn` in Godot
2. Add a new button next to the "Play" button
3. Name it "LoadButton"
4. Set text to "Continue" or "Load Game"
5. Connect its `pressed` signal to the title screen script
6. Add this code to `Scripts/title_screen.gd`:

```gdscript
@onready var load_button: Button = $LoadButton  # Adjust path as needed

func _ready() -> void:
	# ... existing code ...

	# Set up load button
	load_button.pressed.connect(_on_load_pressed)

	# Hide load button if no saves exist
	if not SaveManager.has_any_save():
		load_button.visible = false

func _on_load_pressed():
	# Load the save/load menu
	var save_menu = load("res://scenes/save_load_menu.tscn").instantiate()
	save_menu.mode = 0  # 0 = LOAD mode
	get_tree().root.add_child(save_menu)
```

#### Option B: Advanced - Create a full menu system

If you want a more elaborate menu with separate "New Game", "Continue", "Load", "Save" options, I can help you design that too.

### Step 3: Add Save Menu Access During VN

To allow players to manually save during the visual novel:

1. **Option 1: Add a save button to your VN UI**
   - Add a button to your Dialogic layout
   - Connect it to call `SaveManager.show_save_menu()`

2. **Option 2: Use ESC key to open save menu**
   - Add this to `Scripts/visual_novel.gd`:

```gdscript
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		if SaveManager.saving_enabled:
			# Show save menu
			var save_menu = load("res://scenes/save_load_menu.tscn").instantiate()
			save_menu.mode = 1  # 1 = SAVE mode
			get_tree().root.add_child(save_menu)
```

### Step 4: Test the System

1. Run your game from the title screen
2. Start a new game
3. During the visual novel, check that:
   - Autosave creates saves in the autosave slot every 60 seconds
   - Manual save menu allows saving to Slots 1-3
4. When you enter platformer or rhythm game:
   - Autosave should stop
   - Manual saves should be disabled
5. Return to title screen and verify "Continue" button appears
6. Click "Continue" and verify it loads your save

## Save File Locations

Saves are stored in:
- **Windows**: `%APPDATA%\Godot\app_userdata\Home Sweet Hell\dialogic\saves\`
- **Linux**: `~/.local/share/godot/app_userdata/Home Sweet Hell/dialogic/saves/`
- **Mac**: `~/Library/Application Support/Godot/app_userdata/Home Sweet Hell/dialogic/saves/`

Each slot has its own folder:
- `autosave/` - Autosave slot
- `slot_1/` - Manual save slot 1
- `slot_2/` - Manual save slot 2
- `slot_3/` - Manual save slot 3

## Customization

### Change Autosave Interval

Edit `project.godot`:
```
[dialogic]
save/autosave_delay=60.0  # Change to desired seconds
```

### Customize Save Slot Appearance

Edit `Scripts/save_load_menu.gd` and modify the `create_slot_button()` function to change:
- Button size
- Font size
- Colors
- Layout

### Add More Save Slots

Edit `Scripts/save_manager.gd`:
1. Add new slot constants (e.g., `const SLOT_4 = "slot_4"`)
2. Update functions to handle the new slots
3. Update `Scripts/save_load_menu.gd` to display 5 slots instead of 4

## Troubleshooting

### "SaveManager not found" error
- Make sure you reopened Godot after editing `project.godot`
- Check that SaveManager is listed in Project Settings > Autoload

### Saves not working in VN
- Check the console for `[SaveManager] Saving ENABLED` message
- Verify Dialogic autosave is enabled in project settings

### Saves working during gameplay
- This shouldn't happen if scripts are correctly updated
- Check that `SaveManager.disable_saving()` is called before scene transitions

### Load doesn't resume from correct position
- Make sure you're using `Dialogic.start()` only when NOT loading from save
- The updated `visual_novel.gd` handles this automatically

## Next Steps

After completing the Godot setup steps above:
1. Test thoroughly
2. Consider adding visual feedback (save icon, save confirmation)
3. Add save slot deletion functionality
4. Create a better UI design matching your game's aesthetic

Let me know if you need help with any of these steps!
