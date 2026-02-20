# ============================================================================
# HORROR MECHANICS — Verse Template for UEFN
# ============================================================================
# Essential horror game systems: flashlight with battery, jumpscare triggers,
# ambient sound control, and a darkness/fog system.
#
# HOW TO USE:
#   1. Add this device to your UEFN project
#   2. Wire up audio players, VFX spawners, and light devices in the editor
#   3. Place trigger volumes in your map for jumpscare zones
#   4. Customize battery drain rate, scare cooldowns, and ambient settings
#
# TIPS FOR HORROR MAPS:
#   - Use narrow corridors and limited visibility
#   - Vary the timing between scares (unpredictability = tension)
#   - Ambient sound is 80% of the horror atmosphere
#   - Less is more — suggest danger rather than showing it constantly
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# FLASHLIGHT SYSTEM
# ============================================================================
# Simulates a flashlight with limited battery that drains over time.
# Uses a light_device toggled on/off, with a timer for battery drain.
# ============================================================================

flashlight_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # The actual light in the world (place a light_device in your map)
    @editable
    FlashlightLight : light_device = light_device{}

    # Button to toggle flashlight on/off
    @editable
    ToggleButton : button_device = button_device{}

    # Timer that ticks to drain battery (set to repeat in editor, e.g., every 1 second)
    @editable
    DrainTimer : timer_device = timer_device{}

    # HUD device to show battery level
    @editable
    BatteryHUD : hud_message_device = hud_message_device{}

    # Audio player for flashlight click sound
    @editable
    ClickSound : audio_player_device = audio_player_device{}

    # Audio player for "battery low" warning beep
    @editable
    LowBatterySound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # Maximum battery (100 = full)
    @editable
    MaxBattery : float = 100.0

    # Battery drained per timer tick (lower = longer lasting)
    @editable
    DrainPerTick : float = 1.0

    # Battery level that triggers "low battery" warning
    @editable
    LowBatteryThreshold : float = 20.0

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var CurrentBattery : float = 100.0
    var IsOn : logic = false
    var HasWarnedLowBattery : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Flashlight: Initializing...")

        set CurrentBattery = MaxBattery

        # Start with flashlight off
        FlashlightLight.TurnOff()

        # Listen for toggle
        ToggleButton.InteractedWithEvent.Subscribe(OnToggle)

        # Listen for drain ticks
        DrainTimer.SuccessEvent.Subscribe(OnDrainTick)

        UpdateBatteryHUD()
        Print("Flashlight: Ready. Battery: {CurrentBattery}/{MaxBattery}")

    # ========================================================================
    # TOGGLE ON/OFF
    # ========================================================================
    OnToggle(Agent : agent) : void =
        if (IsOn?):
            # Turn off
            set IsOn = false
            FlashlightLight.TurnOff()
            DrainTimer.Pause()
            ClickSound.Play()
            Print("Flashlight: OFF")
        else:
            # Turn on — but only if we have battery
            if (CurrentBattery > 0.0):
                set IsOn = true
                FlashlightLight.TurnOn()
                DrainTimer.Start()
                ClickSound.Play()
                Print("Flashlight: ON")
            else:
                # Dead battery — play a sad click
                ClickSound.Play()
                Print("Flashlight: Battery dead!")

        UpdateBatteryHUD()

    # ========================================================================
    # BATTERY DRAIN
    # ========================================================================
    OnDrainTick(MaybeAgent : ?agent) : void =
        if (IsOn?):
            set CurrentBattery -= DrainPerTick

            # Clamp to zero
            if (CurrentBattery < 0.0):
                set CurrentBattery = 0.0

            # Low battery warning
            if (CurrentBattery <= LowBatteryThreshold):
                if (not HasWarnedLowBattery?):
                    set HasWarnedLowBattery = true
                    LowBatterySound.Play()
                    Print("Flashlight: LOW BATTERY WARNING!")

            # Battery dead — force off
            if (CurrentBattery <= 0.0):
                set IsOn = false
                FlashlightLight.TurnOff()
                DrainTimer.Pause()
                Print("Flashlight: Battery depleted! Darkness...")

            UpdateBatteryHUD()

    # Recharge the flashlight (call from a pickup or station)
    RechargeBattery(Amount : float) : void =
        set CurrentBattery += Amount
        if (CurrentBattery > MaxBattery):
            set CurrentBattery = MaxBattery
        set HasWarnedLowBattery = false
        UpdateBatteryHUD()
        Print("Flashlight: Recharged! Battery: {CurrentBattery}")

    # ========================================================================
    # HUD
    # ========================================================================
    UpdateBatteryHUD() : void =
        # Show battery as a percentage bar
        BatteryPercent := (CurrentBattery / MaxBattery * 100.0)
        StatusText := if (IsOn?) then "ON" else "OFF"
        BatteryHUD.SetText(
            StringToMessage("🔦 [{StatusText}] Battery: {BatteryPercent}%")
        )

# ============================================================================
# JUMPSCARE SYSTEM
# ============================================================================
# Place trigger volumes around your map. When a player enters, a scare fires.
# Supports cooldowns so scares don't repeat too quickly.
# ============================================================================

jumpscare_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Trigger zone — player walks in, scare fires
    @editable
    ScareZone : trigger_device = trigger_device{}

    # Audio for the scare (loud stinger, monster roar, etc.)
    @editable
    ScareAudio : audio_player_device = audio_player_device{}

    # VFX spawner for visual scare (particle effect, creature popup, etc.)
    @editable
    ScareVFX : vfx_spawner_device = vfx_spawner_device{}

    # Optional: Cinematic sequence device for scripted scares
    @editable
    ScareSequence : cinematic_sequence_device = cinematic_sequence_device{}

    # Optional: Creature/prop that appears during scare
    @editable
    ScareCreatureMover : prop_mover_device = prop_mover_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # Cooldown in seconds before this scare can trigger again
    @editable
    CooldownSeconds : float = 30.0

    # Should this scare only trigger once ever?
    @editable
    OneTimeOnly : logic = false

    # Should the scare play a cinematic sequence?
    @editable
    UseSequence : logic = false

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var IsOnCooldown : logic = false
    var HasTriggered : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Jumpscare: Zone armed and ready.")
        ScareZone.TriggeredEvent.Subscribe(OnPlayerEnterZone)

    # ========================================================================
    # SCARE TRIGGER
    # ========================================================================
    OnPlayerEnterZone(Agent : ?agent) : void =
        # Check cooldown and one-time restrictions
        if (IsOnCooldown?):
            return
        if (OneTimeOnly? and HasTriggered?):
            return

        # FIRE THE SCARE!
        Print("Jumpscare: TRIGGERED!")
        set HasTriggered = true

        # Play audio (the most important part of any jumpscare)
        ScareAudio.Play()

        # Play visual effects
        ScareVFX.Enable()

        # Move the scare creature/prop into view
        ScareCreatureMover.Begin()

        # Play cinematic if configured
        if (UseSequence?):
            ScareSequence.Play()

        # Start cooldown
        StartCooldown()

    # ========================================================================
    # COOLDOWN
    # ========================================================================
    StartCooldown() : void =
        set IsOnCooldown = true
        # In a real implementation, use a timer device or Sleep()
        # to reset IsOnCooldown after CooldownSeconds
        spawn { CooldownRoutine() }

    CooldownRoutine()<suspends> : void =
        Sleep(CooldownSeconds)
        set IsOnCooldown = false
        # Reset VFX and creature for next scare
        ScareVFX.Disable()
        Print("Jumpscare: Cooldown complete. Re-armed.")

    # Manually reset this scare (useful for game resets)
    ResetScare() : void =
        set HasTriggered = false
        set IsOnCooldown = false
        ScareVFX.Disable()
        Print("Jumpscare: Reset.")

# ============================================================================
# AMBIENT SOUND CONTROLLER
# ============================================================================
# Manages layered ambient audio — background drones, random sound events,
# and intensity escalation as the game progresses.
# ============================================================================

ambient_sound_controller := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Base ambient layer (constant low drone, wind, etc.)
    @editable
    BaseAmbient : audio_player_device = audio_player_device{}

    # Secondary tension layer (heartbeat, creaking, whispers)
    @editable
    TensionLayer : audio_player_device = audio_player_device{}

    # Random one-shot sounds (footsteps, door creaks, distant screams)
    # Add as many as you want — one will play at random intervals
    @editable
    RandomSounds : []audio_player_device = array{}

    # Timer for triggering random sounds
    @editable
    RandomSoundTimer : timer_device = timer_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # Should tension layer start immediately or be triggered later?
    @editable
    StartWithTension : logic = false

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var TensionActive : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Ambient Sound: Starting atmosphere...")

        # Always play the base ambient layer
        BaseAmbient.Play()

        # Optionally start tension layer
        if (StartWithTension?):
            ActivateTension()

        # Set up random sound events
        RandomSoundTimer.SuccessEvent.Subscribe(OnRandomSoundTick)
        RandomSoundTimer.Start()

        Print("Ambient Sound: {RandomSounds.Length} random sounds loaded.")

    # ========================================================================
    # TENSION CONTROL
    # ========================================================================

    # Call this to escalate the atmosphere (e.g., when player enters a scary area)
    ActivateTension() : void =
        if (not TensionActive?):
            set TensionActive = true
            TensionLayer.Play()
            Print("Ambient Sound: Tension layer ACTIVATED")

    # Call this to de-escalate (e.g., player reaches a safe room)
    DeactivateTension() : void =
        if (TensionActive?):
            set TensionActive = false
            TensionLayer.Stop()
            Print("Ambient Sound: Tension layer deactivated")

    # ========================================================================
    # RANDOM SOUNDS
    # ========================================================================
    OnRandomSoundTick(MaybeAgent : ?agent) : void =
        if (RandomSounds.Length > 0):
            # Pick a random sound and play it
            RandomIndex := GetRandomInt(0, RandomSounds.Length - 1)
            if (Sound := RandomSounds[RandomIndex]):
                Sound.Play()
                Print("Ambient Sound: Random sound #{RandomIndex} played")

# ============================================================================
# DARKNESS SYSTEM
# ============================================================================
# Controls map-wide darkness/fog for horror atmosphere.
# Can gradually increase darkness over time for escalating tension.
# ============================================================================

darkness_system := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Fog device for atmosphere
    @editable
    FogDevice : fog_device = fog_device{}

    # Array of lights that can be turned off for "blackout" events
    @editable
    ControllableLights : []light_device = array{}

    # Timer for gradual darkness increase
    @editable
    DarknessTimer : timer_device = timer_device{}

    # Audio for blackout event (power failure sound, etc.)
    @editable
    BlackoutSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var CurrentDarknessLevel : int = 0  # 0 = normal, higher = darker
    var IsBlackout : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Darkness System: Initializing...")
        DarknessTimer.SuccessEvent.Subscribe(OnDarknessTick)

    # ========================================================================
    # BLACKOUT EVENT
    # ========================================================================

    # Trigger a full blackout — all lights go off!
    TriggerBlackout() : void =
        if (not IsBlackout?):
            set IsBlackout = true
            BlackoutSound.Play()

            # Turn off all controllable lights
            for (Light : ControllableLights):
                Light.TurnOff()

            Print("Darkness System: ⚫ BLACKOUT!")

    # Restore lights after a blackout
    EndBlackout() : void =
        if (IsBlackout?):
            set IsBlackout = false

            # Turn lights back on
            for (Light : ControllableLights):
                Light.TurnOn()

            Print("Darkness System: Lights restored.")

    # Timed blackout — lights go off, then come back after a delay
    TimedBlackout(DurationSeconds : float)<suspends> : void =
        TriggerBlackout()
        Sleep(DurationSeconds)
        EndBlackout()

    # ========================================================================
    # GRADUAL DARKNESS
    # ========================================================================
    OnDarknessTick(MaybeAgent : ?agent) : void =
        set CurrentDarknessLevel += 1
        Print("Darkness System: Darkness level now {CurrentDarknessLevel}")

        # Turn off lights progressively as darkness increases
        # Each tick, turn off one more light
        if (CurrentDarknessLevel <= ControllableLights.Length):
            if (Light := ControllableLights[CurrentDarknessLevel - 1]):
                Light.TurnOff()
                Print("Darkness System: Light #{CurrentDarknessLevel} went out...")

    # Start the gradual darkness escalation
    BeginDarknessEscalation() : void =
        DarknessTimer.Start()
        Print("Darkness System: Escalation started. Lights will go out one by one...")

    # Reset everything back to normal
    ResetDarkness() : void =
        set CurrentDarknessLevel = 0
        set IsBlackout = false
        DarknessTimer.Pause()
        for (Light : ControllableLights):
            Light.TurnOn()
        Print("Darkness System: Reset. All lights on.")
