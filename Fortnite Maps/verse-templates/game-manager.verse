# ============================================================================
# GAME MANAGER — Verse Template for UEFN
# ============================================================================
# Round-based game management: lobby phase, countdown, game start/end,
# team assignment, and round cycling.
#
# GAME FLOW:
#   LOBBY → COUNTDOWN → PLAYING → ROUND_END → (back to LOBBY or GAME_OVER)
#
# HOW TO USE:
#   1. Add this device to your UEFN project
#   2. Wire up timer devices, teleporters, and HUD elements
#   3. Customize round settings (duration, team sizes, max rounds)
#   4. Call into this from other systems (leaderboard, pickups, etc.)
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Teams }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# GAME STATE ENUM
# ============================================================================

game_state := enum:
    Lobby       # Waiting for players, pre-game
    Countdown   # Game is about to start (3, 2, 1...)
    Playing     # Active gameplay
    RoundEnd    # Round just ended, showing results
    GameOver    # All rounds complete

# ============================================================================
# MAIN GAME MANAGER DEVICE
# ============================================================================

game_manager_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Timer for the main game round duration
    @editable
    RoundTimer : timer_device = timer_device{}

    # Timer for the pre-game countdown
    @editable
    CountdownTimer : timer_device = timer_device{}

    # Timer for the lobby wait (auto-start after enough players)
    @editable
    LobbyTimer : timer_device = timer_device{}

    # HUD for showing game state messages
    @editable
    GameStateHUD : hud_message_device = hud_message_device{}

    # HUD for showing countdown numbers
    @editable
    CountdownHUD : hud_message_device = hud_message_device{}

    # Teleporter to move players from lobby to arena
    @editable
    ArenaTeleporer : teleporter_device = teleporter_device{}

    # Teleporter to return players to lobby after round
    @editable
    LobbyTeleporter : teleporter_device = teleporter_device{}

    # Audio for countdown beeps
    @editable
    CountdownBeep : audio_player_device = audio_player_device{}

    # Audio for game start horn/buzzer
    @editable
    GameStartSound : audio_player_device = audio_player_device{}

    # Audio for round end
    @editable
    RoundEndSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # GAME CONFIGURATION
    # ------------------------------------------

    # Minimum players needed to start the game
    @editable
    MinPlayersToStart : int = 2

    # Round duration in seconds (set this on the RoundTimer device too)
    @editable
    RoundDurationSeconds : float = 180.0

    # Countdown duration before round starts
    @editable
    CountdownSeconds : int = 5

    # Total number of rounds before game over
    @editable
    MaxRounds : int = 3

    # Number of teams (0 = free for all, 2+ = team mode)
    @editable
    NumberOfTeams : int = 2

    # Seconds to show results between rounds
    @editable
    ResultsDisplaySeconds : float = 10.0

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var CurrentState : game_state = game_state.Lobby
    var CurrentRound : int = 0
    var PlayersReady : int = 0

    # Team assignments (player → team index)
    var TeamAssignments : [player]int = map{}

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Game Manager: Initializing...")

        # Set up event listeners
        RoundTimer.SuccessEvent.Subscribe(OnRoundTimerEnd)
        CountdownTimer.SuccessEvent.Subscribe(OnCountdownTick)
        LobbyTimer.SuccessEvent.Subscribe(OnLobbyTimerEnd)

        # Player tracking
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        # Start in lobby state
        EnterLobby()

        Print("Game Manager: Ready. Waiting for {MinPlayersToStart} players.")

    # ========================================================================
    # GAME STATE MACHINE
    # ========================================================================

    # --- LOBBY PHASE ---
    EnterLobby() : void =
        set CurrentState = game_state.Lobby
        Print("Game Manager: === LOBBY PHASE ===")

        GameStateHUD.SetText(StringToMessage("⏳ Waiting for players... ({PlayersReady}/{MinPlayersToStart})"))
        GameStateHUD.Show()

        # Check if we have enough players to start
        CheckPlayerCount()

    # Check if enough players are present to begin
    CheckPlayerCount() : void =
        AllPlayers := GetPlayspace().GetPlayers()
        set PlayersReady = AllPlayers.Length

        if (CurrentState = game_state.Lobby):
            GameStateHUD.SetText(
                StringToMessage("⏳ Waiting for players... ({PlayersReady}/{MinPlayersToStart})")
            )
            if (PlayersReady >= MinPlayersToStart):
                Print("Game Manager: Enough players! Starting lobby timer...")
                LobbyTimer.Start()

    # Called when lobby wait is over
    OnLobbyTimerEnd(MaybeAgent : ?agent) : void =
        if (CurrentState = game_state.Lobby):
            StartCountdown()

    # --- COUNTDOWN PHASE ---
    StartCountdown() : void =
        set CurrentState = game_state.Countdown
        Print("Game Manager: === COUNTDOWN PHASE ===")

        # Assign teams before the game starts
        if (NumberOfTeams > 0):
            AssignTeams()

        # Start countdown
        spawn { RunCountdown() }

    # Countdown coroutine: 5, 4, 3, 2, 1, GO!
    RunCountdown()<suspends> : void =
        var SecondsLeft : int = CountdownSeconds
        loop:
            if (SecondsLeft <= 0):
                break

            # Display countdown number
            CountdownHUD.SetText(StringToMessage("{SecondsLeft}"))
            CountdownHUD.Show()
            CountdownBeep.Play()

            Print("Game Manager: {SecondsLeft}...")
            Sleep(1.0)
            set SecondsLeft -= 1

        # GO!
        CountdownHUD.SetText(StringToMessage("GO!"))
        GameStartSound.Play()
        Sleep(1.0)
        CountdownHUD.Hide()

        # Start the round
        StartRound()

    # --- PLAYING PHASE ---
    StartRound() : void =
        set CurrentRound += 1
        set CurrentState = game_state.Playing
        Print("Game Manager: === ROUND {CurrentRound} START ===")

        GameStateHUD.SetText(StringToMessage("🎮 Round {CurrentRound}/{MaxRounds}"))

        # Teleport players to arena
        # ArenaTeleporer.Teleport(...)  # Teleport all players

        # Start the round timer
        RoundTimer.Start()

        # ----------------------------------------------------------
        # ADD YOUR ROUND START LOGIC HERE
        # Examples:
        #   - Enable item spawners
        #   - Open barriers
        #   - Start objective timers
        #   - Enable scoring
        # ----------------------------------------------------------

    # Called when the round timer expires
    OnRoundTimerEnd(MaybeAgent : ?agent) : void =
        if (CurrentState = game_state.Playing):
            EndRound()

    # Call this to end the round early (e.g., all objectives complete)
    EndRound() : void =
        set CurrentState = game_state.RoundEnd
        Print("Game Manager: === ROUND {CurrentRound} END ===")

        RoundTimer.Pause()
        RoundEndSound.Play()

        GameStateHUD.SetText(StringToMessage("🏁 Round {CurrentRound} Complete!"))

        # ----------------------------------------------------------
        # ADD YOUR ROUND END LOGIC HERE
        # Examples:
        #   - Calculate scores
        #   - Show MVP
        #   - Disable item spawners
        #   - Close barriers
        # ----------------------------------------------------------

        # Show results, then either next round or game over
        spawn { PostRoundSequence() }

    PostRoundSequence()<suspends> : void =
        # Display results for a few seconds
        Sleep(ResultsDisplaySeconds)

        if (CurrentRound >= MaxRounds):
            EndGame()
        else:
            # Teleport players back to lobby for next round
            EnterLobby()

    # --- GAME OVER ---
    EndGame() : void =
        set CurrentState = game_state.GameOver
        Print("Game Manager: === GAME OVER ===")

        GameStateHUD.SetText(StringToMessage("🏆 GAME OVER! Final results..."))

        # ----------------------------------------------------------
        # ADD YOUR GAME OVER LOGIC HERE
        # Examples:
        #   - Show final leaderboard
        #   - Grant winner rewards
        #   - Play victory cinematic
        #   - Restart after delay
        # ----------------------------------------------------------

    # ========================================================================
    # TEAM ASSIGNMENT
    # ========================================================================

    # Assigns players to teams using round-robin distribution
    AssignTeams() : void =
        AllPlayers := GetPlayspace().GetPlayers()
        var TeamIndex : int = 0

        for (Player : AllPlayers):
            if (set TeamAssignments[Player] = TeamIndex) {}
            Print("Game Manager: Player assigned to Team {TeamIndex + 1}")

            # Round-robin: cycle through teams
            set TeamIndex = (TeamIndex + 1) % NumberOfTeams

        Print("Game Manager: {AllPlayers.Length} players assigned to {NumberOfTeams} teams.")

    # Get a player's team (returns -1 if not assigned)
    GetPlayerTeam(Player : player) : int =
        if (Team := TeamAssignments[Player]):
            return Team
        return -1

    # Get all players on a specific team
    GetTeamPlayers(TeamIndex : int) : []player =
        var TeamPlayers : []player = array{}
        for (Player -> Team : TeamAssignments):
            if (Team = TeamIndex):
                set TeamPlayers += array{Player}
        return TeamPlayers

    # ========================================================================
    # PLAYER EVENTS
    # ========================================================================

    OnPlayerAdded(Player : player) : void =
        Print("Game Manager: Player joined.")
        CheckPlayerCount()

    OnPlayerRemoved(Player : player) : void =
        Print("Game Manager: Player left.")
        # Remove from team assignments
        # Check if game should end due to insufficient players

    # ========================================================================
    # UTILITY
    # ========================================================================

    # Force-start the game (skip lobby wait, e.g., from an admin button)
    ForceStart() : void =
        if (CurrentState = game_state.Lobby):
            LobbyTimer.Pause()
            StartCountdown()
            Print("Game Manager: Force-started!")

    # Reset everything for a fresh game
    ResetGame() : void =
        set CurrentState = game_state.Lobby
        set CurrentRound = 0
        set TeamAssignments = map{}
        RoundTimer.Pause()
        CountdownTimer.Pause()
        EnterLobby()
        Print("Game Manager: Full reset.")

    # Get current game state
    GetCurrentState() : game_state =
        return CurrentState

    # Check if game is actively being played
    IsPlaying() : logic =
        return CurrentState = game_state.Playing

    # Countdown tick handler (if using timer device for countdown)
    OnCountdownTick(MaybeAgent : ?agent) : void =
        # This is called if you wire a repeating 1s timer for countdown
        # The RunCountdown coroutine handles it internally, but this
        # is here if you prefer the timer approach
        pass
