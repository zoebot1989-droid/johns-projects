# ============================================================================
# PROGRESSION SYSTEM — DEAD PROFIT
# ============================================================================
# 5-night progression that scales difficulty. Each night introduces new
# mechanics, entity types, and challenges. Night 5 is the boss encounter.
#
# NIGHT PROGRESSION TABLE:
#   Night 1: 1.0x income, Easy (Wanderers only), Tutorial prompts
#   Night 2: 1.5x income, + Mimics, Trap crafting unlocked
#   Night 3: 2.0x income, + Conductor, Ride upgrades available
#   Night 4: 3.0x income, + Hollow Kids, Secret area accessible
#   Night 5: 5.0x income, THE OWNER (boss), Final stand mechanic
#
# SCALING:
#   - Night duration increases each night
#   - Entity count increases
#   - Power outage events start at Night 3
#   - Day duration slightly decreases on later nights (pressure)
#
# INTEGRATION:
#   - DayNightCycle: Adjusts day/night durations per night
#   - EntityAI: Controls which entity types spawn
#   - Economy: Sets income multipliers
#   - ParkManager: Unlocks higher-tier attraction upgrades
#   - UIManager: Shows progression status, night number, unlocks
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# NIGHT CONFIGURATION — Defines what each night looks like
# ============================================================================
night_config := struct:
    NightNumber : int
    # Phase durations (seconds)
    DayDuration : float
    NightDuration : float
    # Income multiplier for this night
    IncomeMultiplier : float
    # Entity counts
    WandererCount : int
    MimicCount : int
    ConductorCount : int
    HollowKidCount : int
    SpawnBoss : logic
    # Special events
    PowerOutageEnabled : logic
    PowerOutageCount : int          # How many blackouts during the night
    PowerOutageDuration : float     # Seconds per blackout
    # Unlocks
    UnlockMessage : string          # Shown at start of day before this night

# ============================================================================
# PROGRESSION DEVICE
# ============================================================================
progression_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: UI & FEEDBACK
    # ------------------------------------------

    @editable
    ProgressionHUD : hud_message_device = hud_message_device{}

    @editable
    UnlockHUD : hud_message_device = hud_message_device{}

    @editable
    NightAnnouncementHUD : hud_message_device = hud_message_device{}

    # Audio: new unlock jingle
    @editable
    UnlockSound : audio_player_device = audio_player_device{}

    # Audio: night announcement (dramatic sting)
    @editable
    NightAnnouncementSound : audio_player_device = audio_player_device{}

    # Audio: victory fanfare (beat Night 5)
    @editable
    VictorySound : audio_player_device = audio_player_device{}

    # Audio: game over sound
    @editable
    GameOverSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: AREA UNLOCKS
    # ------------------------------------------

    # Barrier blocking the secret underground tunnels (unlocked Night 4)
    @editable
    SecretAreaBarrier : barrier_device = barrier_device{}

    # Prop mover to reveal the secret entrance
    @editable
    SecretEntranceRevealer : prop_mover_device = prop_mover_device{}

    # Barriers for Tier 3 attraction zones (unlocked Night 3)
    @editable
    Tier3ZoneBarriers : []barrier_device = array{}

    # ------------------------------------------
    # EDITOR-EXPOSED: POWER OUTAGE SYSTEM
    # ------------------------------------------

    # All controllable lights (shared with DayNightCycle)
    @editable
    ParkLights : []light_device = array{}

    # Blackout sound effect
    @editable
    BlackoutSound : audio_player_device = audio_player_device{}

    # Power restore sound
    @editable
    PowerRestoreSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # CONFIGURATION: NIGHT DEFINITIONS
    # ------------------------------------------

    NightConfigs : []night_config = array:
        # --- NIGHT 1: TUTORIAL ---
        night_config:
            NightNumber := 1
            DayDuration := 180.0        # 3 minutes (generous)
            NightDuration := 90.0       # 1.5 minutes (short)
            IncomeMultiplier := 1.0
            WandererCount := 3
            MimicCount := 0
            ConductorCount := 0
            HollowKidCount := 0
            SpawnBoss := false
            PowerOutageEnabled := false
            PowerOutageCount := 0
            PowerOutageDuration := 0.0
            UnlockMessage := "Welcome to Malmouth Funland! Build attractions during the day. Survive the night."

        # --- NIGHT 2: MIMICS APPEAR ---
        night_config:
            NightNumber := 2
            DayDuration := 170.0
            NightDuration := 105.0
            IncomeMultiplier := 1.5
            WandererCount := 4
            MimicCount := 2
            ConductorCount := 0
            HollowKidCount := 0
            SpawnBoss := false
            PowerOutageEnabled := false
            PowerOutageCount := 0
            PowerOutageDuration := 0.0
            UnlockMessage := "🔓 TRAP CRAFTING unlocked! New entity spotted: MIMICS — they disguise as park objects!"

        # --- NIGHT 3: CONDUCTOR + POWER OUTAGES ---
        night_config:
            NightNumber := 3
            DayDuration := 160.0
            NightDuration := 120.0      # 2 minutes
            IncomeMultiplier := 2.0
            WandererCount := 5
            MimicCount := 3
            ConductorCount := 1
            HollowKidCount := 0
            SpawnBoss := false
            PowerOutageEnabled := true
            PowerOutageCount := 1
            PowerOutageDuration := 10.0
            UnlockMessage := "🔓 RIDE UPGRADES available! New entity: THE CONDUCTOR — it possesses rides! ⚡ Power outages may occur!"

        # --- NIGHT 4: HOLLOW KIDS + SECRET AREA ---
        night_config:
            NightNumber := 4
            DayDuration := 150.0
            NightDuration := 135.0
            IncomeMultiplier := 3.0
            WandererCount := 6
            MimicCount := 4
            ConductorCount := 1
            HollowKidCount := 8
            SpawnBoss := false
            PowerOutageEnabled := true
            PowerOutageCount := 2
            PowerOutageDuration := 12.0
            UnlockMessage := "🔓 SECRET TUNNELS discovered! New entity: HOLLOW KIDS — fast and numerous! The park's history runs deeper than you thought..."

        # --- NIGHT 5: THE OWNER (BOSS) ---
        night_config:
            NightNumber := 5
            DayDuration := 140.0
            NightDuration := 150.0      # 2.5 minutes (longest night)
            IncomeMultiplier := 5.0
            WandererCount := 8
            MimicCount := 5
            ConductorCount := 2
            HollowKidCount := 10
            SpawnBoss := true
            PowerOutageEnabled := true
            PowerOutageCount := 3
            PowerOutageDuration := 15.0
            UnlockMessage := "⚠️ FINAL NIGHT. The Owner is coming. He made a deal to keep this park running forever. Tonight, you end it — or become part of the attraction."

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var CurrentNight : int = 0
    var NightsCompleted : int = 0
    var GameWon : logic = false
    var GameLost : logic = false
    var AllPlayersDead : logic = false

    # Player alive tracking
    var PlayersAlive : [player]logic = map{}

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Progression: Initializing DEAD PROFIT progression system...")

        # Lock secret areas initially
        SecretAreaBarrier.Enable()
        for (Barrier : Tier3ZoneBarriers):
            Barrier.Enable()

        # Register players
        for (Player : GetPlayspace().GetPlayers()):
            if (set PlayersAlive[Player] = true) {}
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        Print("Progression: Ready. 5 nights configured.")

    OnPlayerAdded(Player : player) : void =
        if (set PlayersAlive[Player] = true) {}

    # ========================================================================
    # NIGHT PROGRESSION — Called by MainGame / DayNightCycle
    # ========================================================================

    # Prepare for the next night. Called at the start of each Day phase.
    PrepareNextNight() : night_config =
        NextNight := CurrentNight + 1
        Print("Progression: Preparing for Night {NextNight}...")

        # Get config for next night
        if (Config := NightConfigs[NextNight - 1]):
            # Show unlock message
            UnlockHUD.SetText(StringToMessage(Config.UnlockMessage))
            UnlockHUD.Show()
            UnlockSound.Play()

            # Process unlocks based on night number
            ProcessUnlocks(NextNight)

            Print("Progression: Night {NextNight} config loaded — Wanderers: {Config.WandererCount}, Mimics: {Config.MimicCount}")
            return Config

        # Fallback (shouldn't happen)
        return NightConfigs[0]

    # Called when a night actually starts
    StartNight(NightNumber : int) : void =
        set CurrentNight = NightNumber
        Print("Progression: === NIGHT {NightNumber} STARTED ===")

        NightAnnouncementHUD.SetText(StringToMessage("🌙 NIGHT {NightNumber}"))
        NightAnnouncementHUD.Show()
        NightAnnouncementSound.Play()

        # Start power outage events if enabled
        if (Config := NightConfigs[NightNumber - 1]):
            if (Config.PowerOutageEnabled?):
                spawn { RunPowerOutages(Config.PowerOutageCount, Config.PowerOutageDuration, Config.NightDuration) }

        # Update progression HUD
        UpdateProgressionHUD()

    # Called when a night is survived
    CompleteNight(NightNumber : int) : void =
        set NightsCompleted = NightNumber
        Print("Progression: ✅ Night {NightNumber} COMPLETED!")

        # Check for game win
        if (NightNumber >= 5):
            OnGameWon()

    # ========================================================================
    # AREA UNLOCKS
    # ========================================================================

    ProcessUnlocks(NightNumber : int) : void =
        # Night 3: Unlock Tier 3 attraction zones
        if (NightNumber = 3):
            for (Barrier : Tier3ZoneBarriers):
                Barrier.Disable()
            Print("Progression: 🔓 Tier 3 zones unlocked!")

        # Night 4: Unlock secret underground tunnels
        if (NightNumber = 4):
            SecretAreaBarrier.Disable()
            SecretEntranceRevealer.Begin()
            Print("Progression: 🔓 Secret tunnels unlocked!")

    # ========================================================================
    # POWER OUTAGE EVENTS
    # ========================================================================

    RunPowerOutages(Count : int, Duration : float, NightLength : float)<suspends> : void =
        # Space outages evenly through the night
        IntervalSeconds := NightLength / (Count + 1)

        var OutagesTriggered : int = 0
        loop:
            if (OutagesTriggered >= Count):
                break

            # Wait for next outage
            Sleep(IntervalSeconds)

            # Trigger blackout
            TriggerPowerOutage(Duration)
            set OutagesTriggered += 1

    TriggerPowerOutage(Duration : float)<suspends> : void =
        Print("Progression: ⚡ POWER OUTAGE!")
        BlackoutSound.Play()

        # Turn off all lights
        for (Light : ParkLights):
            Light.TurnOff()

        # Wait for duration
        Sleep(Duration)

        # Restore power
        for (Light : ParkLights):
            Light.TurnOn()
        PowerRestoreSound.Play()
        Print("Progression: Power restored.")

    # ========================================================================
    # WIN / LOSE CONDITIONS
    # ========================================================================

    OnGameWon() : void =
        set GameWon = true
        Print("Progression: 🏆 GAME WON! All 5 nights survived!")

        VictorySound.Play()
        ProgressionHUD.SetText(StringToMessage(
            "🏆 CONGRATULATIONS!\nYou survived all 5 nights!\nMalmouth Funland is finally free!"
        ))
        ProgressionHUD.Show()

    OnGameLost() : void =
        set GameLost = true
        Print("Progression: 💀 GAME OVER!")

        GameOverSound.Play()
        ProgressionHUD.SetText(StringToMessage(
            "💀 GAME OVER\nThe park claims another crew...\nNights Survived: {NightsCompleted}/5"
        ))
        ProgressionHUD.Show()

    # Called when a player is eliminated
    OnPlayerEliminated(Player : player) : void =
        if (set PlayersAlive[Player] = false) {}
        Print("Progression: Player eliminated!")

        # Check if all players are dead
        var AnyAlive : logic = false
        for (_ -> Alive : PlayersAlive):
            if (Alive?):
                set AnyAlive = true
                break

        if (not AnyAlive?):
            set AllPlayersDead = true
            OnGameLost()

    # ========================================================================
    # HUD
    # ========================================================================

    UpdateProgressionHUD() : void =
        var NightDots : string = ""
        var I : int = 1
        loop:
            if (I > 5): break
            if (I <= NightsCompleted):
                set NightDots += "✅"
            else if (I = CurrentNight):
                set NightDots += "🔴"
            else:
                set NightDots += "⬜"
            set I += 1

        ProgressionHUD.SetText(StringToMessage(
            "Night Progress: {NightDots} ({CurrentNight}/5)"
        ))
        ProgressionHUD.Show()

    # ========================================================================
    # PUBLIC GETTERS
    # ========================================================================

    GetCurrentNight() : int = CurrentNight
    GetNightsCompleted() : int = NightsCompleted
    IsGameWon() : logic = GameWon
    IsGameLost() : logic = GameLost

    GetNightConfig(NightNumber : int) : ?night_config =
        if (Config := NightConfigs[NightNumber - 1]):
            return option{Config}
        return false

    # ========================================================================
    # RESET
    # ========================================================================

    ResetProgression() : void =
        set CurrentNight = 0
        set NightsCompleted = 0
        set GameWon = false
        set GameLost = false
        set AllPlayersDead = false

        # Re-lock areas
        SecretAreaBarrier.Enable()
        for (Barrier : Tier3ZoneBarriers):
            Barrier.Enable()

        # Reset player alive states
        for (Player -> _ : PlayersAlive):
            if (set PlayersAlive[Player] = true) {}

        Print("Progression: Full reset.")
