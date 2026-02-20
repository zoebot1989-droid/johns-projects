# ============================================================================
# UI MANAGER — DEAD PROFIT
# ============================================================================
# Centralized HUD management. Displays currency, time of day, countdown,
# minimap markers, entity proximity warning, and phase-specific UI elements.
#
# HUD LAYOUT (conceptual):
#   ┌─────────────────────────────────────────────┐
#   │ 🎟️ 1,234 Tickets (2.0x)  │  ☀️ DAY  2:15  │  TOP BAR
#   ├─────────────────────────────────────────────┤
#   │                                             │
#   │              GAME VIEW                      │
#   │                                             │
#   │  ⚠️ ENTITY NEARBY                          │  LEFT: WARNINGS
#   │                                             │
#   ├─────────────────────────────────────────────┤
#   │ 🔦 ON 78% | 🧱x2 | 📢x3 | 🔥x1          │  BOTTOM: TOOLS
#   │ Night Progress: ✅✅🔴⬜⬜ (3/5)          │
#   └─────────────────────────────────────────────┘
#
# INTEGRATION:
#   - All other systems call into UIManager to update their HUD elements
#   - DayNightCycle: phase display, countdown timer
#   - Economy: currency display
#   - SurvivalTools: tool inventory bar
#   - Progression: night progress indicator
#   - EntityAI: proximity warning
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# UI MANAGER DEVICE
# ============================================================================
ui_manager_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: HUD MESSAGE DEVICES
    # Each represents a different section of the HUD.
    # Position them in UEFN's HUD layout editor.
    # ------------------------------------------

    # Top-left: Currency display
    @editable
    CurrencyHUD : hud_message_device = hud_message_device{}

    # Top-center: Phase name + countdown timer
    @editable
    PhaseTimerHUD : hud_message_device = hud_message_device{}

    # Top-right: Park rating / visitor count
    @editable
    ParkRatingHUD : hud_message_device = hud_message_device{}

    # Center: Large announcements (phase changes, night number, unlocks)
    @editable
    AnnouncementHUD : hud_message_device = hud_message_device{}

    # Left: Entity proximity warning
    @editable
    ProximityWarningHUD : hud_message_device = hud_message_device{}

    # Bottom-center: Tool inventory bar
    @editable
    ToolBarHUD : hud_message_device = hud_message_device{}

    # Bottom-left: Night progress indicator
    @editable
    NightProgressHUD : hud_message_device = hud_message_device{}

    # Bottom-right: Minimap / compass markers
    @editable
    MinimapHUD : hud_message_device = hud_message_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: MAP MARKERS
    # Use map_indicator_device for key locations
    # ------------------------------------------

    # Marker for Central Plaza (shop/armory)
    @editable
    PlazaMarker : map_indicator_device = map_indicator_device{}

    # Markers for entity spawn points (shown during night)
    @editable
    EntitySpawnMarkers : []map_indicator_device = array{}

    # Markers for hiding spots
    @editable
    HidingSpotMarkers : []map_indicator_device = array{}

    # Marker for secret area entrance (shown after Night 4)
    @editable
    SecretAreaMarker : map_indicator_device = map_indicator_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: AUDIO FOR UI EVENTS
    # ------------------------------------------

    # Proximity warning heartbeat (gets faster as entity approaches)
    @editable
    HeartbeatSlow : audio_player_device = audio_player_device{}

    @editable
    HeartbeatFast : audio_player_device = audio_player_device{}

    # Timer tick sound (last 10 seconds of a phase)
    @editable
    TimerTickSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: BILLBOARDS FOR WORLD-SPACE UI
    # ------------------------------------------

    # Billboard at the shop showing prices
    @editable
    ShopPriceboard : billboard_device = billboard_device{}

    # Billboard showing score/results between nights
    @editable
    ScoreBoard : billboard_device = billboard_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # How close an entity must be to trigger proximity warning (units)
    @editable
    ProximityWarningDistance : float = 1500.0

    # Seconds remaining to start showing timer urgency (red countdown)
    @editable
    UrgentTimerThreshold : float = 10.0

    # Timer for proximity check (repeating, every 0.5s)
    @editable
    ProximityCheckTimer : timer_device = timer_device{}

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var CurrentPhaseText : string = "☀️ DAY"
    var CurrentTimeRemaining : float = 0.0
    var IsProximityActive : logic = false
    var AnnouncementVisible : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("UIManager: Initializing DEAD PROFIT HUD system...")

        # Start with clean HUD
        HideAllHUD()

        # Set up proximity check timer
        ProximityCheckTimer.SuccessEvent.Subscribe(OnProximityCheck)

        # Hide entity markers initially
        for (Marker : EntitySpawnMarkers):
            Marker.Disable()
        SecretAreaMarker.Disable()

        # Show plaza marker always
        PlazaMarker.Enable()

        # Set up shop priceboard
        UpdateShopDisplay()

        Print("UIManager: Ready.")

    # ========================================================================
    # PHASE DISPLAY — Called by DayNightCycle
    # ========================================================================

    # Update the phase display (called on each phase transition)
    SetPhase(PhaseText : string) : void =
        set CurrentPhaseText = PhaseText
        PhaseTimerHUD.SetText(StringToMessage(PhaseText))
        PhaseTimerHUD.Show()

    # Update the countdown timer (called every second by DayNightCycle)
    UpdateTimer(SecondsRemaining : float) : void =
        set CurrentTimeRemaining = SecondsRemaining
        Minutes := Floor[SecondsRemaining / 60.0]
        Seconds := Floor[Mod[SecondsRemaining, 60.0]]

        # Urgency formatting for last 10 seconds
        if (SecondsRemaining <= UrgentTimerThreshold):
            PhaseTimerHUD.SetText(StringToMessage(
                "⚠️ {CurrentPhaseText} — {Minutes}:{Seconds} ⚠️"
            ))
            TimerTickSound.Play()
        else:
            PhaseTimerHUD.SetText(StringToMessage(
                "{CurrentPhaseText} — {Minutes}:{Seconds}"
            ))

    # ========================================================================
    # CURRENCY DISPLAY — Called by Economy
    # ========================================================================

    UpdateCurrency(Player : player, Tickets : int, Multiplier : float) : void =
        MultiplierText := if (Multiplier > 1.0) then " ({Multiplier}x)" else ""
        CurrencyHUD.SetText(StringToMessage(
            "🎟️ {Tickets} Tickets{MultiplierText}"
        ))
        CurrencyHUD.Show(Player)

    # ========================================================================
    # PARK RATING DISPLAY — Called by ParkManager
    # ========================================================================

    UpdateParkRating(Rating : int, Visitors : int, IncomeRate : int) : void =
        Stars := MakeStarString(Rating)
        ParkRatingHUD.SetText(StringToMessage(
            "{Stars} | 👥 {Visitors} | +{IncomeRate}/tick"
        ))
        ParkRatingHUD.Show()

    MakeStarString(Stars : int) : string =
        if (Stars >= 5): return "★★★★★"
        if (Stars >= 4): return "★★★★☆"
        if (Stars >= 3): return "★★★☆☆"
        if (Stars >= 2): return "★★☆☆☆"
        if (Stars >= 1): return "★☆☆☆☆"
        return "☆☆☆☆☆"

    # ========================================================================
    # TOOL BAR DISPLAY — Called by SurvivalTools
    # ========================================================================

    UpdateToolBar(Player : player, FlashlightOn : logic, Battery : float,
                  Barricades : int, NoiseMakers : int, Flares : int, IsHiding : logic) : void =
        FlashStatus := if (FlashlightOn?) then "ON" else "OFF"
        BatteryPct := Floor[Battery]
        HidingText := if (IsHiding?) then " | 🫥 HIDING" else ""

        ToolBarHUD.SetText(StringToMessage(
            "🔦 {FlashStatus} {BatteryPct}% | 🧱 x{Barricades} | 📢 x{NoiseMakers} | 🔥 x{Flares}{HidingText}"
        ))
        ToolBarHUD.Show(Player)

    # ========================================================================
    # NIGHT PROGRESS — Called by Progression
    # ========================================================================

    UpdateNightProgress(CurrentNight : int, NightsCompleted : int) : void =
        var Dots : string = ""
        var I : int = 1
        loop:
            if (I > 5): break
            if (I <= NightsCompleted):
                set Dots += "✅"
            else if (I = CurrentNight):
                set Dots += "🔴"
            else:
                set Dots += "⬜"
            set I += 1

        NightProgressHUD.SetText(StringToMessage("Night: {Dots} ({CurrentNight}/5)"))
        NightProgressHUD.Show()

    # ========================================================================
    # ANNOUNCEMENTS — Large center-screen messages
    # ========================================================================

    # Show a large announcement (auto-hides after duration)
    ShowAnnouncement(Text : string, DurationSeconds : float) : void =
        set AnnouncementVisible = true
        AnnouncementHUD.SetText(StringToMessage(Text))
        AnnouncementHUD.Show()
        spawn { HideAnnouncementAfter(DurationSeconds) }

    HideAnnouncementAfter(Seconds : float)<suspends> : void =
        Sleep(Seconds)
        AnnouncementHUD.Hide()
        set AnnouncementVisible = false

    # Specific announcement helpers
    AnnouncePhaseChange(PhaseName : string) : void =
        ShowAnnouncement(PhaseName, 3.0)

    AnnounceNightStart(NightNumber : int) : void =
        if (NightNumber = 5):
            ShowAnnouncement("⚠️ NIGHT 5 — THE OWNER IS COMING ⚠️", 4.0)
        else:
            ShowAnnouncement("🌙 NIGHT {NightNumber}", 3.0)

    AnnounceUnlock(UnlockText : string) : void =
        ShowAnnouncement("🔓 {UnlockText}", 5.0)

    AnnounceGameWon() : void =
        ShowAnnouncement("🏆 YOU SURVIVED ALL 5 NIGHTS!\nMalmouth Funland is free!", 10.0)

    AnnounceGameOver(NightsSurvived : int) : void =
        ShowAnnouncement("💀 GAME OVER\nNights Survived: {NightsSurvived}/5", 10.0)

    # ========================================================================
    # ENTITY PROXIMITY WARNING
    # ========================================================================

    # Enable proximity warning system (called when Night starts)
    EnableProximityWarning() : void =
        set IsProximityActive = true
        ProximityCheckTimer.Start()
        # Show entity spawn markers on map
        for (Marker : EntitySpawnMarkers):
            Marker.Enable()

    # Disable proximity warning (called when Dawn starts)
    DisableProximityWarning() : void =
        set IsProximityActive = false
        ProximityCheckTimer.Pause()
        ProximityWarningHUD.Hide()
        HeartbeatSlow.Stop()
        HeartbeatFast.Stop()
        # Hide entity spawn markers
        for (Marker : EntitySpawnMarkers):
            Marker.Disable()

    # Proximity check tick
    OnProximityCheck(MaybeAgent : ?agent) : void =
        if (IsProximityActive?):
            # In a full implementation, this would check distance between
            # each player and each active entity using GetTransform().
            # For now, the trigger_devices on entities handle detection,
            # and we just display the warning when EntityAI signals us.
            pass

    # Called by EntityAI when a player is in danger
    ShowProximityWarning(Player : player, Distance : float) : void =
        if (Distance < ProximityWarningDistance / 3.0):
            ProximityWarningHUD.SetText(StringToMessage("⚠️⚠️⚠️ ENTITY VERY CLOSE ⚠️⚠️⚠️"))
            HeartbeatFast.Play()
            HeartbeatSlow.Stop()
        else if (Distance < ProximityWarningDistance / 1.5):
            ProximityWarningHUD.SetText(StringToMessage("⚠️ Entity nearby..."))
            HeartbeatSlow.Play()
            HeartbeatFast.Stop()
        else:
            ProximityWarningHUD.Hide()
            HeartbeatSlow.Stop()
            HeartbeatFast.Stop()
        ProximityWarningHUD.Show(Player)

    ClearProximityWarning(Player : player) : void =
        ProximityWarningHUD.Hide()
        HeartbeatSlow.Stop()
        HeartbeatFast.Stop()

    # ========================================================================
    # SCORE SCREEN — Shown at Dawn between nights
    # ========================================================================

    ShowScoreScreen(NightNumber : int, TicketsEarned : int, EntitiesEliminated : int,
                    AttractionsDestroyed : int, ParkRating : int) : void =
        Stars := MakeStarString(ParkRating)
        ScoreBoard.SetText(StringToMessage(
            "=== NIGHT {NightNumber} RESULTS ===\n" +
            "🎟️ Tickets Earned: {TicketsEarned}\n" +
            "👹 Entities Eliminated: {EntitiesEliminated}\n" +
            "💥 Attractions Damaged: {AttractionsDestroyed}\n" +
            "⭐ Park Rating: {Stars}\n" +
            "========================="
        ))

    # ========================================================================
    # SHOP DISPLAY
    # ========================================================================

    UpdateShopDisplay() : void =
        ShopPriceboard.SetText(StringToMessage(
            "=== SURVIVAL SHOP ===\n" +
            "🧱 Barricade: 30 Tickets\n" +
            "📢 Noise Maker: 20 Tickets\n" +
            "🔥 Emergency Flare: 75 Tickets\n" +
            "🔋 Battery Refill: 15 Tickets\n" +
            "====================="
        ))

    # ========================================================================
    # MAP MARKERS
    # ========================================================================

    ShowSecretAreaMarker() : void =
        SecretAreaMarker.Enable()

    ShowHidingSpots() : void =
        for (Marker : HidingSpotMarkers):
            Marker.Enable()

    HideHidingSpots() : void =
        for (Marker : HidingSpotMarkers):
            Marker.Disable()

    # ========================================================================
    # UTILITY
    # ========================================================================

    HideAllHUD() : void =
        CurrencyHUD.Hide()
        PhaseTimerHUD.Hide()
        ParkRatingHUD.Hide()
        AnnouncementHUD.Hide()
        ProximityWarningHUD.Hide()
        ToolBarHUD.Hide()
        NightProgressHUD.Hide()
        MinimapHUD.Hide()

    ShowGameHUD() : void =
        CurrencyHUD.Show()
        PhaseTimerHUD.Show()
        ParkRatingHUD.Show()
        NightProgressHUD.Show()

    # Show Day-specific HUD elements
    ShowDayHUD() : void =
        ShowGameHUD()
        ToolBarHUD.Hide()  # Tools not needed during day
        ProximityWarningHUD.Hide()

    # Show Night-specific HUD elements
    ShowNightHUD() : void =
        ShowGameHUD()
        ToolBarHUD.Show()
        # Proximity warning activates via EnableProximityWarning()
