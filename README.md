# GD-FocusSpinBox
A custom Godot node that allows deeper focus control of a SpinBox, with extra customization sprinkled on the side.

Here's a table of differences between this and regular Spinbox:

Feature | FocusSpinBox | Regular Spinbox
--------|-----------------|--------------
Step rounding | ✅ | ✅ 
Max/Min Values | ✅ | ✅ 
Forbid certain characters on input | ✅ | ✅ 
Exp Edit |  | ✅ 
Allow Lesser/Greater |  | ✅ 
Page value |  | ✅ 
Prefixes/Suffixes |  | ✅
Click & drag input |  | ✅ 
Custom updown icon in Theme Editor |  | ✅ 
Custom out-of-spinbox label | ✅ |  
Custom forbidden characters | ✅ |  
Cycle focus on individual buttons | ✅ |  
Optional wide buttons | ✅ |  
Enter value on TAB | soon |  
Signal for focus lost on all children | ✅ |  

This was an experiment of mine to try and create a custom node with setget editor functions. Unfortunately there's a few bugs that I don't know how to resolve. I feel that someone who knows what they're doing with Godot tool scripts would find an easy way to resolve it.

1. The starting value updates in the editor, but not in-game
2. The optional labels appear in the editor, but not in game
3. Output claims missing get_node reference error for editor (edit_) scripts, even though these references are used successfully in editor scripts
