# ============================================================================
# DAY/NIGHT CYCLE MANAGER — DEAD PROFIT
# ============================================================================
# Controls the core day/night loop that drives the entire game.
# Day phase = tycoon/building. Night phase = horror survival.
# Manages lighting transitions, entity spawning triggers, and phase events.
#
# PHASES:
#   DAY (default 180s)   → Players build, earn, upgrade
#   DUSK (30s)           → Warning period, visitors flee, tension builds
#   NIGHT (default 120s) → Entities spawn, survival mode
#   DAWN (15s)           → Score screen, bonus rewards, reset
#
# INTEGRATION:
#   - Fires events that other systems subscribe to (ParkManager, EntityAI, etc.)
#   - Controls fog_device, light_device arrays for atmosphere
#   - Sends phase change notifications to UIManager for HUD updates
#
# DEVICE WIRING (in UEFN editor):
#   - Wire DayTimer, DuskTimer, NightTimer, DawnTimer to timer_devices
#   - Wire SunLight to a directional light (the "sun")
#   - Wire AmbientLights[] to all park lights
#   - Wire NightFog to a fog_device
#   - Wire phase audio players to audio_player_devices
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# PHASE ENUM — Current time-of-day state
# ============================================================================
day_phase := enum:
    Day         # Full daylight, tycoon mode active
    Dusk        # Transition warning — visitors leaving, prepare defenses
    Night       # Horror mode — entities active, survival
    Dawn        # Post-night — score tally, brief safe period

# ============================================================================
# DAY/NIGHT CYCLE DEVICE
# ============================================================================
day_night_cycle_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: TIMERS
    # Each timer controls one phase's duration.
    # Set these in the UEFN editor's details panel.
    # ------------------------------------------

    # Timer for the Day phase (default: 180 seconds / 3 minutes)
    @editable
    DayTimer : timer_device = timer_device{}

    # Timer for Dusk transition (default: 30 seconds)
    @editable
    DuskTimer : timer_device = timer_device{}

    # Timer for Night phase (default: 120 seconds / 2 minutes)
    @editable
    NightTimer : timer_device = timer_device{}

    # Timer for Dawn wrap-up (default: 15 seconds)
    @editable
    DawnTimer : timer_device = timer_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: LIGHTING
    # ------------------------------------------

    # The main directional "sun" light
    @editable
    SunLight : light_device = light_device{}

    # Moon/ambient night light (dim, blue-ish)
    @editable
    MoonLight : light_device = light_device{}

    # All park lights (lampposts, ride lights, etc.)
    # These flicker during dusk and turn off during blackouts
    @editable
    AmbientLights : []light_device = array{}

    # Fog device for night atmosphere
    @editable
    NightFog : fog_device = fog_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: AUDIO
    # ------------------------------------------

    # Cheerful daytime park ambience (crowds, music, rides)
    @editable
    DayAmbience : audio_player_device = audio_player_device{}

    # Warning siren that plays during Dusk
    @editable
    DuskSiren : audio_player_device = audio_player_device{}

    # Creepy night ambient (wind, distant screams, creaking)
    @editable
    NightAmbience : audio_player_device = audio_player_device{}

    # Dawn relief sound (birds chirping, triumphant sting)
    @editable
    DawnSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: HUD
    # ------------------------------------------

    # HUD message device for showing phase name and time remaining
    @editable
    PhaseHUD : hud_message_device = hud_message_device{}

    # HUD for the countdown timer display
    @editable
    CountdownHUD : hud_message_device = hud_message_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: ENTITY SPAWN POINTS
    # Entity spawners are activated at Night, deactivated at Dawn.
    # Wire these to creature_spawner_device or guard_spawner_device.
    # ------------------------------------------
    @editable
    EntitySpawners : []creature_spawner_device = array{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # Duration overrides (in seconds) — also set on the timer devices
    @editable
    DayDurationSeconds : float = 180.0      # 3 minutes

    @editable
    DuskDurationSeconds : float = 30.0      # 30 seconds

    @editable
    NightDurationSeconds : float = 120.0    # 2 minutes

    @editable
    DawnDurationSeconds : float = 15.0      # 15 seconds

    # How many seconds before night ends to flash a "dawn approaching" warning
    @editable
    DawnWarningSeconds : float = 15.0

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    # Current phase
    var CurrentPhase : day_phase = day_phase.Day

    # Current night number (1-5). Incremented each time Night begins.
    var CurrentNight : int = 0

    # Is the cycle running?
    var IsRunning : logic = false

    # Elapsed time within current phase (tracked by countdown coroutine)
    var PhaseElapsedSeconds : float = 0.0

    # ========================================================================
    # EVENTS — Other systems subscribe to these
    # ========================================================================
    # These are the primary integration points. ParkManager, EntityAI,
    # Economy, Progression, and UIManager all listen to these.

    # Fired when Day phase begins
    DayStartedEvent : event() = event(){}

    # Fired when Dusk phase begins (warning period)
    DuskStartedEvent : event() = event(){}

    # Fired when Night phase begins (horror mode)
    NightStartedEvent : event() = event(){}

    # Fired when Dawn phase begins (post-night)
    DawnStartedEvent : event() = event(){}

    # Fired every second with remaining time in current phase
    PhaseTickEvent : event(float) = event(float){}

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("DayNightCycle: Initializing DEAD PROFIT day/night system...")

        # Subscribe to timer completion events
        DayTimer.SuccessEvent.Subscribe(OnDayTimerEnd)
        DuskTimer.SuccessEvent.Subscribe(OnDuskTimerEnd)
        NightTimer.SuccessEvent.Subscribe(OnNightTimerEnd)
        DawnTimer.SuccessEvent.Subscribe(OnDawnTimerEnd)

        # Start with everything in daytime state
        SetDaytimeLighting()

        Print("DayNightCycle: Ready. Waiting for StartCycle() call from MainGame.")

    # ========================================================================
    # CYCLE CONTROL — Called by main-game.verse
    # ========================================================================

    # Begin the day/night cycle. Called once when the game starts.
    StartCycle() : void =
        set IsRunning = true
        set CurrentNight = 0
        EnterDay()
        Print("DayNightCycle: Cycle started!")

    # Stop the cycle (game over, pause, etc.)
    StopCycle() : void =
        set IsRunning = false
        DayTimer.Pause()
        DuskTimer.Pause()
        NightTimer.Pause()
        DawnTimer.Pause()
        Print("DayNightCycle: Cycle stopped.")

    # ========================================================================
    # PHASE TRANSITIONS
    # ========================================================================

    # --- DAY PHASE ---
    # Players build attractions, earn tickets, prepare for night.
    EnterDay() : void =
        set CurrentPhase = day_phase.Day
        Print("DayNightCycle: ☀️ === DAY PHASE === (Night {CurrentNight} survived)")

        # Lighting: bright, cheerful
        SetDaytimeLighting()

        # Audio: park ambience
        NightAmbience.Stop()
        DayAmbience.Play()

        # HUD update
        PhaseHUD.SetText(StringToMessage("☀️ DAY — Build & Earn"))
        PhaseHUD.Show()

        # Deactivate entity spawners (safety)
        DeactivateEntitySpawners()

        # Fire event for other systems
        DayStartedEvent.Signal()

        # Start day timer
        DayTimer.Start()

        # Start countdown coroutine
        spawn { RunPhaseCountdown(DayDurationSeconds) }

    OnDayTimerEnd(MaybeAgent : ?agent) : void =
        if (IsRunning? and CurrentPhase = day_phase.Day):
            EnterDusk()

    # --- DUSK PHASE ---
    # Warning period. Visitors flee, lights flicker, tension builds.
    EnterDusk() : void =
        set CurrentPhase = day_phase.Dusk
        Print("DayNightCycle: 🌅 === DUSK PHASE === Prepare yourselves!")

        # Audio: warning siren
        DayAmbience.Stop()
        DuskSiren.Play()

        # HUD
        PhaseHUD.SetText(StringToMessage("🌅 DUSK — Visitors fleeing! Prepare defenses!"))

        # Start light flickering effect
        spawn { FlickerLights() }

        # Fire event
        DuskStartedEvent.Signal()

        # Start dusk timer
        DuskTimer.Start()
        spawn { RunPhaseCountdown(DuskDurationSeconds) }

    OnDuskTimerEnd(MaybeAgent : ?agent) : void =
        if (IsRunning? and CurrentPhase = day_phase.Dusk):
            EnterNight()

    # --- NIGHT PHASE ---
    # Horror mode. Entities spawn, players must survive.
    EnterNight() : void =
        set CurrentNight += 1
        set CurrentPhase = day_phase.Night
        Print("DayNightCycle: 🌙 === NIGHT {CurrentNight} === They're coming...")

        # Lighting: dark, fog, moon
        SetNighttimeLighting()

        # Audio: creepy ambience
        DuskSiren.Stop()
        NightAmbience.Play()

        # HUD
        PhaseHUD.SetText(StringToMessage("🌙 NIGHT {CurrentNight} — SURVIVE"))

        # Activate entity spawners
        ActivateEntitySpawners()

        # Fire event (EntityAI, Progression, etc. respond to this)
        NightStartedEvent.Signal()

        # Start night timer
        NightTimer.Start()
        spawn { RunPhaseCountdown(NightDurationSeconds) }

    OnNightTimerEnd(MaybeAgent : ?agent) : void =
        if (IsRunning? and CurrentPhase = day_phase.Night):
            EnterDawn()

    # --- DAWN PHASE ---
    # Night survived! Brief score screen, bonus rewards.
    EnterDawn() : void =
        set CurrentPhase = day_phase.Dawn
        Print("DayNightCycle: 🌄 === DAWN === You survived Night {CurrentNight}!")

        # Lighting: transition back to day
        SetDaytimeLighting()

        # Audio: relief sound
        NightAmbience.Stop()
        DawnSound.Play()

        # HUD
        PhaseHUD.SetText(StringToMessage("🌄 DAWN — Night {CurrentNight} Survived!"))

        # Deactivate entities
        DeactivateEntitySpawners()

        # Fire event (Progression tallies score, Economy grants bonuses)
        DawnStartedEvent.Signal()

        # Start dawn timer
        DawnTimer.Start()
        spawn { RunPhaseCountdown(DawnDurationSeconds) }

    OnDawnTimerEnd(MaybeAgent : ?agent) : void =
        if (IsRunning? and CurrentPhase = day_phase.Dawn):
            # Loop back to Day (MainGame checks if Night 5 was completed)
            EnterDay()

    # ========================================================================
    # LIGHTING CONTROL
    # ========================================================================

    # Set all lighting to bright daytime state
    SetDaytimeLighting() : void =
        SunLight.TurnOn()
        MoonLight.TurnOff()
        NightFog.Disable()
        for (Light : AmbientLights):
            Light.TurnOn()
        Print("DayNightCycle: Lighting → Daytime")

    # Set all lighting to dark nighttime state
    SetNighttimeLighting() : void =
        SunLight.TurnOff()
        MoonLight.TurnOn()
        NightFog.Enable()
        # Turn off most ambient lights for darkness
        for (Index -> Light : AmbientLights):
            # Keep every 4th light on for minimal visibility
            if (Mod[Index, 4] = 0):
                Light.TurnOn()
            else:
                Light.TurnOff()
        Print("DayNightCycle: Lighting → Nighttime")

    # Flicker lights during Dusk for tension
    FlickerLights()<suspends> : void =
        var FlickerCount : int = 0
        loop:
            if (FlickerCount >= 6 or not (CurrentPhase = day_phase.Dusk)):
                break
            # Turn lights off briefly
            for (Light : AmbientLights):
                Light.TurnOff()
            Sleep(0.3)
            # Turn them back on
            for (Light : AmbientLights):
                Light.TurnOn()
            Sleep(1.5)
            set FlickerCount += 1

    # ========================================================================
    # ENTITY SPAWNER CONTROL
    # ========================================================================

    ActivateEntitySpawners() : void =
        for (Spawner : EntitySpawners):
            Spawner.Enable()
        Print("DayNightCycle: Entity spawners ACTIVATED ({EntitySpawners.Length} spawners)")

    DeactivateEntitySpawners() : void =
        for (Spawner : EntitySpawners):
            Spawner.Disable()
        Print("DayNightCycle: Entity spawners DEACTIVATED")

    # ========================================================================
    # COUNTDOWN COROUTINE
    # Ticks every second, updates HUD with remaining time.
    # ========================================================================
    RunPhaseCountdown(TotalSeconds : float)<suspends> : void =
        var Remaining : float = TotalSeconds
        loop:
            if (Remaining <= 0.0):
                break
            # Update countdown HUD
            Minutes := Floor[Remaining / 60.0]
            Seconds := Floor[Mod[Remaining, 60.0]]
            CountdownHUD.SetText(StringToMessage("{Minutes}:{Seconds}"))
            CountdownHUD.Show()

            # Fire tick event for UI and other systems
            PhaseTickEvent.Signal(Remaining)

            Sleep(1.0)
            set Remaining -= 1.0

    # ========================================================================
    # PUBLIC GETTERS — Used by other systems
    # ========================================================================

    GetCurrentPhase() : day_phase =
        return CurrentPhase

    GetCurrentNight() : int =
        return CurrentNight

    IsDay() : logic =
        return CurrentPhase = day_phase.Day

    IsNight() : logic =
        return CurrentPhase = day_phase.Night

    IsDusk() : logic =
        return CurrentPhase = day_phase.Dusk

    # Get the total duration of night for the current night number
    # Later nights are longer (Progression system can override this)
    GetNightDuration() : float =
        return NightDurationSeconds

    # Adjust night duration (called by Progression for harder nights)
    SetNightDuration(NewDuration : float) : void =
        set NightDurationSeconds = NewDuration
        Print("DayNightCycle: Night duration set to {NewDuration}s")

    # Adjust day duration
    SetDayDuration(NewDuration : float) : void =
        set DayDurationSeconds = NewDuration
        Print("DayNightCycle: Day duration set to {NewDuration}s")
