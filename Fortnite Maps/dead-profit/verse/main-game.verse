# ============================================================================
# MAIN GAME CONTROLLER — DEAD PROFIT
# ============================================================================
# Master controller that ties all systems together. Initializes everything,
# manages the core game flow, and handles win/lose conditions.
#
# GAME FLOW:
#   1. Players spawn in lobby
#   2. Game starts → Day 1 begins
#   3. Day phase: ParkManager generates income, players build/buy
#   4. Dusk: Warning, players prepare
#   5. Night: EntityAI activates, players survive
#   6. Dawn: Score tally, bonuses, damage report
#   7. Repeat for 5 nights
#   8. Win (survive Night 5) or Lose (all players eliminated)
#
# THIS DEVICE REFERENCES ALL OTHER DEVICES:
#   - DayNightCycle (day_night_cycle_device)
#   - ParkManager (park_manager_device)
#   - EntityAI (entity_ai_device)
#   - SurvivalTools (survival_tools_device)
#   - Economy (economy_device)
#   - Progression (progression_device)
#   - UIManager (ui_manager_device)
#
# SETUP IN UEFN:
#   1. Place ONE main_game_device in your level
#   2. Wire all other system devices to it via the @editable references
#   3. This device orchestrates everything — other devices should NOT
#      start themselves (they wait for MainGame to call them)
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# GAME STATE
# ============================================================================
main_game_state := enum:
    WaitingForPlayers
    Starting
    InProgress
    GameWon
    GameLost
    Resetting

# ============================================================================
# MAIN GAME DEVICE
# ============================================================================
main_game_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: SYSTEM REFERENCES
    # Wire each system device to these slots in UEFN.
    # ------------------------------------------

    @editable
    DayNightCycle : day_night_cycle_device = day_night_cycle_device{}

    @editable
    ParkManager : park_manager_device = park_manager_device{}

    @editable
    EntityAI : entity_ai_device = entity_ai_device{}

    @editable
    SurvivalTools : survival_tools_device = survival_tools_device{}

    @editable
    Economy : economy_device = economy_device{}

    @editable
    Progression : progression_device = progression_device{}

    @editable
    UIManager : ui_manager_device = ui_manager_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: LOBBY & FLOW CONTROL
    # ------------------------------------------

    # Timer for lobby countdown (auto-start when enough players)
    @editable
    LobbyTimer : timer_device = timer_device{}

    # Teleporter: lobby → park entrance
    @editable
    LobbyToGameTeleporter : teleporter_device = teleporter_device{}

    # Teleporter: game → lobby (for game over / restart)
    @editable
    GameToLobbyTeleporter : teleporter_device = teleporter_device{}

    # Start button (optional — for manual start)
    @editable
    StartButton : button_device = button_device{}

    # End/reset button (for testing)
    @editable
    ResetButton : button_device = button_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: GAME AUDIO
    # ------------------------------------------

    # Opening music (plays in lobby / game intro)
    @editable
    IntroMusic : audio_player_device = audio_player_device{}

    # Victory music
    @editable
    VictoryMusic : audio_player_device = audio_player_device{}

    # Game over music
    @editable
    GameOverMusic : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: HUD
    # ------------------------------------------

    @editable
    LobbyHUD : hud_message_device = hud_message_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    @editable
    MinPlayersToStart : int = 1     # Set to 1 for testing, 2+ for production

    @editable
    LobbyCountdownSeconds : float = 10.0

    @editable
    TotalNights : int = 5

    @editable
    PostGameDelaySeconds : float = 15.0

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var GameState : main_game_state = main_game_state.WaitingForPlayers
    var CurrentNight : int = 0

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("===========================================")
        Print("   DEAD PROFIT — Main Game Controller")
        Print("   \"The park wants your money.")
        Print("    The Entity wants your soul.\"")
        Print("===========================================")

        # Wire up lobby controls
        LobbyTimer.SuccessEvent.Subscribe(OnLobbyTimerEnd)
        StartButton.InteractedWithEvent.Subscribe(OnStartButtonPressed)
        ResetButton.InteractedWithEvent.Subscribe(OnResetButtonPressed)

        # Wire up DayNightCycle phase events
        DayNightCycle.DayStartedEvent.Subscribe(OnDayStarted)
        DayNightCycle.DuskStartedEvent.Subscribe(OnDuskStarted)
        DayNightCycle.NightStartedEvent.Subscribe(OnNightStarted)
        DayNightCycle.DawnStartedEvent.Subscribe(OnDawnStarted)

        # Player events
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

        # Enter lobby
        EnterLobby()

        Print("MainGame: Initialization complete. Waiting for players...")

    # ========================================================================
    # LOBBY PHASE
    # ========================================================================

    EnterLobby() : void =
        set GameState = main_game_state.WaitingForPlayers
        IntroMusic.Play()

        LobbyHUD.SetText(StringToMessage(
            "🎪 DEAD PROFIT 🎪\n" +
            "\"The park wants your money. The Entity wants your soul.\"\n\n" +
            "Waiting for players... ({GetPlayspace().GetPlayers().Length}/{MinPlayersToStart})"
        ))
        LobbyHUD.Show()

        CheckPlayerCount()

    OnPlayerJoined(Player : player) : void =
        Print("MainGame: Player joined!")
        if (GameState = main_game_state.WaitingForPlayers):
            LobbyHUD.SetText(StringToMessage(
                "🎪 DEAD PROFIT 🎪\n" +
                "Waiting for players... ({GetPlayspace().GetPlayers().Length}/{MinPlayersToStart})"
            ))
            CheckPlayerCount()

    CheckPlayerCount() : void =
        if (GetPlayspace().GetPlayers().Length >= MinPlayersToStart):
            if (GameState = main_game_state.WaitingForPlayers):
                Print("MainGame: Enough players! Starting lobby countdown...")
                LobbyHUD.SetText(StringToMessage(
                    "🎪 DEAD PROFIT 🎪\nGame starting soon..."
                ))
                LobbyTimer.Start()

    OnLobbyTimerEnd(MaybeAgent : ?agent) : void =
        if (GameState = main_game_state.WaitingForPlayers):
            StartGame()

    OnStartButtonPressed(Agent : agent) : void =
        if (GameState = main_game_state.WaitingForPlayers):
            LobbyTimer.Pause()
            StartGame()
            Print("MainGame: Force-started by player!")

    # ========================================================================
    # GAME START
    # ========================================================================

    StartGame() : void =
        set GameState = main_game_state.Starting
        set CurrentNight = 0
        Print("MainGame: === STARTING DEAD PROFIT ===")

        # Hide lobby HUD
        LobbyHUD.Hide()
        IntroMusic.Stop()

        # Teleport players to park entrance
        # LobbyToGameTeleporter.Teleport(...)  # All players

        # Show intro announcement
        UIManager.ShowAnnouncement(
            "🎪 DEAD PROFIT 🎪\n" +
            "Welcome to Malmouth Funland.\n" +
            "Build by day. Survive by night.\n" +
            "Good luck.", 5.0
        )

        # Initialize all systems
        Economy.ResetEconomy()
        ParkManager.ResetPark()
        SurvivalTools.ResetAllTools()
        Progression.ResetProgression()

        # Small delay for intro, then start the cycle
        spawn { DelayedStart() }

    DelayedStart()<suspends> : void =
        Sleep(5.0)
        set GameState = main_game_state.InProgress

        # Show game HUD
        UIManager.ShowGameHUD()

        # Start the day/night cycle (begins with Day 1)
        DayNightCycle.StartCycle()

        Print("MainGame: Game is now IN PROGRESS.")

    # ========================================================================
    # PHASE EVENT HANDLERS — Respond to DayNightCycle events
    # ========================================================================

    # --- DAY STARTED ---
    OnDayStarted() : void =
        if (not (GameState = main_game_state.InProgress)):
            return

        set CurrentNight = DayNightCycle.GetCurrentNight()
        Print("MainGame: Day started (after Night {CurrentNight})")

        # Check if we just survived Night 5
        if (CurrentNight >= TotalNights):
            # Player survived all nights!
            OnGameWon()
            return

        # Prepare progression for next night
        NextNightConfig := Progression.PrepareNextNight()

        # Set economy multiplier for next night
        Economy.SetNightMultiplier(CurrentNight + 1)

        # Adjust day/night durations based on progression
        DayNightCycle.SetDayDuration(NextNightConfig.DayDuration)
        DayNightCycle.SetNightDuration(NextNightConfig.NightDuration)

        # Start park income generation
        ParkManager.StartIncomeGeneration()

        # Update UI
        UIManager.ShowDayHUD()
        UIManager.SetPhase("☀️ DAY")
        UIManager.AnnouncePhaseChange("☀️ DAY — Build & Earn")
        UIManager.UpdateNightProgress(CurrentNight + 1, CurrentNight)

        Print("MainGame: Day phase active. Next night: {CurrentNight + 1}")

    # --- DUSK STARTED ---
    OnDuskStarted() : void =
        if (not (GameState = main_game_state.InProgress)):
            return

        Print("MainGame: DUSK — Visitors fleeing!")

        # Stop income generation
        ParkManager.StopIncomeGeneration()

        # Update UI
        UIManager.SetPhase("🌅 DUSK")
        UIManager.AnnouncePhaseChange("🌅 DUSK — They're coming. Prepare.")

    # --- NIGHT STARTED ---
    OnNightStarted() : void =
        if (not (GameState = main_game_state.InProgress)):
            return

        NightNumber := DayNightCycle.GetCurrentNight()
        Print("MainGame: === NIGHT {NightNumber} ===")

        # Start night in Progression
        Progression.StartNight(NightNumber)

        # Activate entities via EntityAI
        EntityAI.ActivateEntities(NightNumber)

        # Update UI
        UIManager.ShowNightHUD()
        UIManager.SetPhase("🌙 NIGHT {NightNumber}")
        UIManager.AnnounceNightStart(NightNumber)
        UIManager.EnableProximityWarning()

        # Reset barricades for this night
        SurvivalTools.ResetBarricades()

    # --- DAWN STARTED ---
    OnDawnStarted() : void =
        if (not (GameState = main_game_state.InProgress)):
            return

        NightNumber := DayNightCycle.GetCurrentNight()
        Print("MainGame: DAWN — Night {NightNumber} survived!")

        # Deactivate entities
        EntityAI.DeactivateEntities()

        # Disable proximity warnings
        UIManager.DisableProximityWarning()

        # Grant night survival bonus
        Economy.GrantNightBonus(NightNumber, EntityAI.GetEntitiesEliminated())

        # Mark night as completed in progression
        Progression.CompleteNight(NightNumber)

        # Show score screen
        UIManager.ShowScoreScreen(
            NightNumber,
            100,  # TODO: Get actual tickets earned this night
            EntityAI.GetEntitiesEliminated(),
            ParkManager.GetDamagedCount(),
            ParkManager.GetParkRating()
        )

        UIManager.SetPhase("🌄 DAWN")
        UIManager.AnnouncePhaseChange("🌄 DAWN — You survived Night {NightNumber}!")

    # ========================================================================
    # WIN / LOSE
    # ========================================================================

    OnGameWon() : void =
        set GameState = main_game_state.GameWon
        Print("MainGame: 🏆🏆🏆 GAME WON! ALL {TotalNights} NIGHTS SURVIVED! 🏆🏆🏆")

        # Stop the cycle
        DayNightCycle.StopCycle()
        EntityAI.DeactivateEntities()
        ParkManager.StopIncomeGeneration()

        # Play victory
        VictoryMusic.Play()
        UIManager.AnnounceGameWon()
        Progression.OnGameWon()

        # Return to lobby after delay
        spawn { PostGameReturn() }

    OnAllPlayersEliminated() : void =
        set GameState = main_game_state.GameLost
        Print("MainGame: 💀 GAME OVER — All players eliminated!")

        # Stop everything
        DayNightCycle.StopCycle()
        EntityAI.DeactivateEntities()
        ParkManager.StopIncomeGeneration()

        # Play game over
        GameOverMusic.Play()
        UIManager.AnnounceGameOver(Progression.GetNightsCompleted())
        Progression.OnGameLost()

        # Return to lobby after delay
        spawn { PostGameReturn() }

    PostGameReturn()<suspends> : void =
        Sleep(PostGameDelaySeconds)

        # Teleport all players back to lobby
        # GameToLobbyTeleporter.Teleport(...)

        # Reset for a new game
        set GameState = main_game_state.Resetting
        Sleep(2.0)
        EnterLobby()
        Print("MainGame: Returned to lobby. Ready for new game.")

    # ========================================================================
    # PLAYER ELIMINATION HANDLER
    # ========================================================================

    # Called when a player dies during Night phase.
    # In UEFN, wire this to the elimination event.
    OnPlayerEliminated(Player : player) : void =
        Print("MainGame: Player eliminated during Night!")
        Progression.OnPlayerEliminated(Player)

        # Check if all players are dead
        if (Progression.IsGameLost?):
            OnAllPlayersEliminated()

    # ========================================================================
    # RESET (for testing)
    # ========================================================================

    OnResetButtonPressed(Agent : agent) : void =
        Print("MainGame: Manual reset triggered!")
        DayNightCycle.StopCycle()
        EntityAI.DeactivateEntities()
        ParkManager.StopIncomeGeneration()
        Economy.ResetEconomy()
        ParkManager.ResetPark()
        SurvivalTools.ResetAllTools()
        Progression.ResetProgression()
        UIManager.HideAllHUD()
        VictoryMusic.Stop()
        GameOverMusic.Stop()
        EnterLobby()

    # ========================================================================
    # PUBLIC GETTERS
    # ========================================================================

    GetGameState() : main_game_state = GameState
    GetCurrentNight() : int = CurrentNight
    IsGameInProgress() : logic = GameState = main_game_state.InProgress
