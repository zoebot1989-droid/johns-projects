# ============================================================================
# LEADERBOARD SYSTEM — Verse Template for UEFN
# ============================================================================
# Score tracking, display, and time-based leaderboard functionality.
# Tracks player scores during a session and displays rankings.
#
# HOW TO USE:
#   1. Add this device to your UEFN project
#   2. Wire up billboard/HUD devices for display
#   3. Call AddScore() from your game logic when players earn points
#   4. Leaderboard updates automatically
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# DATA STRUCTURES
# ============================================================================

# Individual player's score entry
player_score := class:
    var Score : int = 0
    var BestTime : float = 0.0        # Best completion time (seconds), 0 = not set
    var Kills : int = 0                # Optional: track eliminations
    var Deaths : int = 0               # Optional: track deaths
    var StartTime : float = 0.0        # When the player started (for time tracking)

# A snapshot of leaderboard rankings for display
leaderboard_entry := struct:
    Player : player
    Score : int
    Rank : int

# ============================================================================
# MAIN LEADERBOARD DEVICE
# ============================================================================

leaderboard_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Billboard devices for displaying top scores (wire up 1-5 billboards)
    # Each billboard shows one rank: #1, #2, #3, etc.
    @editable
    RankDisplays : []billboard_device = array{}

    # HUD message for showing the current player their own score
    @editable
    PersonalScoreHUD : hud_message_device = hud_message_device{}

    # Timer for periodic leaderboard refresh
    @editable
    RefreshTimer : timer_device = timer_device{}

    # How often to refresh the display (wire timer to this interval)
    @editable
    RefreshIntervalSeconds : float = 5.0

    # Billboard for showing time-based leaderboard
    @editable
    TimeLeaderboardDisplay : billboard_device = billboard_device{}

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var PlayerScores : [player]player_score = map{}
    var GameStartTime : float = 0.0

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Leaderboard: Initializing...")

        # Register current players
        for (Player : GetPlayspace().GetPlayers()):
            RegisterPlayer(Player)

        # Listen for player join/leave
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        # Periodic refresh of the display
        RefreshTimer.SuccessEvent.Subscribe(OnRefreshTick)
        RefreshTimer.Start()

        Print("Leaderboard: Ready. Tracking {PlayerScores.Length} players.")

    # ========================================================================
    # PLAYER REGISTRATION
    # ========================================================================

    RegisterPlayer(Player : player) : void =
        if (not PlayerScores[Player]):
            NewScore := player_score{}
            if (set PlayerScores[Player] = NewScore) {}
            Print("Leaderboard: Player registered.")

    OnPlayerAdded(Player : player) : void =
        RegisterPlayer(Player)

    OnPlayerRemoved(Player : player) : void =
        Print("Leaderboard: Player removed from tracking.")

    # ========================================================================
    # SCORE MANAGEMENT
    # ========================================================================

    # Add points to a player's score.
    # Call this from your game logic (e.g., on kill, objective complete, pickup).
    AddScore(Player : player, Points : int) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.Score += Points
            Print("Leaderboard: +{Points} points. Total: {Entry.Score}")
            UpdatePersonalHUD(Player)

    # Set a player's score to an exact value
    SetScore(Player : player, Points : int) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.Score = Points
            UpdatePersonalHUD(Player)

    # Get a player's current score
    GetScore(Player : player) : int =
        if (Entry := PlayerScores[Player]):
            return Entry.Score
        return 0

    # Increment kill count
    AddKill(Player : player) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.Kills += 1

    # Increment death count
    AddDeath(Player : player) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.Deaths += 1

    # ========================================================================
    # TIME TRACKING
    # ========================================================================

    # Start the timer for a player (e.g., when a race/challenge begins)
    StartTimer(Player : player) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.StartTime = GetSimulationElapsedTime()
            Print("Leaderboard: Timer started for player.")

    # Stop the timer and record the completion time
    # Returns the elapsed time in seconds
    StopTimer(Player : player) : float =
        if (Entry := PlayerScores[Player]):
            if (Entry.StartTime > 0.0):
                ElapsedTime := GetSimulationElapsedTime() - Entry.StartTime
                # Update best time if this is faster (or first completion)
                if (Entry.BestTime <= 0.0 or ElapsedTime < Entry.BestTime):
                    set Entry.BestTime = ElapsedTime
                    Print("Leaderboard: New best time: {ElapsedTime}s!")
                return ElapsedTime
        return 0.0

    # ========================================================================
    # RANKING & SORTING
    # ========================================================================

    # Get sorted rankings (highest score first).
    # Returns an array of leaderboard_entry structs.
    GetRankings() : []leaderboard_entry =
        # Collect all entries
        var Entries : []leaderboard_entry = array{}

        for (Player -> Score : PlayerScores):
            NewEntry := leaderboard_entry:
                Player := Player
                Score := Score.Score
                Rank := 0  # Will be set after sorting
            set Entries += array{NewEntry}

        # Simple bubble sort by score (descending)
        # For small player counts this is fine
        var Sorted : []leaderboard_entry = Entries
        for (I := 0..Sorted.Length - 1):
            for (J := 0..Sorted.Length - I - 2):
                if (EntryA := Sorted[J], EntryB := Sorted[J + 1]):
                    if (EntryA.Score < EntryB.Score):
                        # Swap
                        set Sorted[J] = EntryB
                        set Sorted[J + 1] = EntryA

        # Assign ranks
        var Ranked : []leaderboard_entry = array{}
        for (Idx -> Entry : Sorted):
            RankedEntry := leaderboard_entry:
                Player := Entry.Player
                Score := Entry.Score
                Rank := Idx + 1
            set Ranked += array{RankedEntry}

        return Ranked

    # Get rankings sorted by best time (fastest first)
    GetTimeRankings() : []leaderboard_entry =
        var Entries : []leaderboard_entry = array{}

        for (Player -> Score : PlayerScores):
            if (Score.BestTime > 0.0):  # Only include players who have a time
                NewEntry := leaderboard_entry:
                    Player := Player
                    Score := Floor[Score.BestTime]  # Time in seconds as int
                    Rank := 0
                set Entries += array{NewEntry}

        # Sort ascending (fastest time = best)
        var Sorted : []leaderboard_entry = Entries
        for (I := 0..Sorted.Length - 1):
            for (J := 0..Sorted.Length - I - 2):
                if (EntryA := Sorted[J], EntryB := Sorted[J + 1]):
                    if (EntryA.Score > EntryB.Score):
                        set Sorted[J] = EntryB
                        set Sorted[J + 1] = EntryA

        var Ranked : []leaderboard_entry = array{}
        for (Idx -> Entry : Sorted):
            RankedEntry := leaderboard_entry:
                Player := Entry.Player
                Score := Entry.Score
                Rank := Idx + 1
            set Ranked += array{RankedEntry}

        return Ranked

    # ========================================================================
    # DISPLAY
    # ========================================================================

    # Refresh the leaderboard billboards
    OnRefreshTick(MaybeAgent : ?agent) : void =
        UpdateLeaderboardDisplay()

    # Update billboard displays with current rankings
    UpdateLeaderboardDisplay() : void =
        Rankings := GetRankings()

        # Update each rank billboard
        for (Idx -> Display : RankDisplays):
            if (Entry := Rankings[Idx]):
                Display.SetText(
                    StringToMessage("#{Entry.Rank} — Score: {Entry.Score}")
                )
            else:
                Display.SetText(StringToMessage("#{Idx + 1} — ---"))

        Print("Leaderboard: Display updated. {Rankings.Length} ranked players.")

    # Show a player their personal score on HUD
    UpdatePersonalHUD(Player : player) : void =
        if (Entry := PlayerScores[Player]):
            PersonalScoreHUD.SetText(
                StringToMessage("⭐ Score: {Entry.Score} | Kills: {Entry.Kills} | Deaths: {Entry.Deaths}")
            )
            PersonalScoreHUD.Show(Player)

    # ========================================================================
    # RESET
    # ========================================================================

    # Reset all scores (call between rounds)
    ResetAllScores() : void =
        for (Player -> Score : PlayerScores):
            set Score.Score = 0
            set Score.Kills = 0
            set Score.Deaths = 0
            set Score.BestTime = 0.0
        UpdateLeaderboardDisplay()
        Print("Leaderboard: All scores reset.")

    # Reset a single player's score
    ResetPlayerScore(Player : player) : void =
        if (Entry := PlayerScores[Player]):
            set Entry.Score = 0
            set Entry.Kills = 0
            set Entry.Deaths = 0
            UpdatePersonalHUD(Player)
