# ============================================================================
# ECONOMY SYSTEM — DEAD PROFIT
# ============================================================================
# Central currency manager. All Ticket earning and spending flows through
# this system. Implements the core risk/reward tension: spend on park
# upgrades (more income but harder nights) OR survival gear (easier nights
# but less income growth).
#
# CURRENCY: Tickets (🎟️)
#   - Earned from: park visitors (passive income during Day), entity kills,
#     night survival bonuses, hidden loot
#   - Spent on: attractions (ParkManager), survival tools (SurvivalTools),
#     repairs (ParkManager), upgrades
#
# INTEGRATION:
#   - ParkManager: calls AddTickets for income, TrySpend for builds/repairs
#   - SurvivalTools: calls TrySpend for tool purchases
#   - Progression: applies income multipliers per night
#   - EntityAI: calls AddTickets for entity elimination bounties
#   - UIManager: reads balances for HUD display
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# PLAYER ECONOMY DATA
# ============================================================================
player_economy := class:
    # Current Ticket balance
    var Tickets : int = 0
    # Total Tickets earned this run (for stats / leaderboard)
    var TotalEarned : int = 0
    # Total Tickets spent this run
    var TotalSpent : int = 0
    # Income multiplier (increases with night progression)
    var IncomeMultiplier : float = 1.0
    # Spending discount (from upgrades or perks, 0.0 = no discount, 0.2 = 20% off)
    var SpendingDiscount : float = 0.0

# ============================================================================
# TRANSACTION LOG ENTRY — For debugging and score screens
# ============================================================================
transaction_type := enum:
    Income          # Passive park income
    EntityBounty    # Reward for eliminating entities
    NightBonus      # Bonus for surviving a night
    LootFound       # Hidden loot pickup
    AttractionBuild # Spending on building/upgrading attractions
    AttractionRepair# Spending on repairs
    ToolPurchase    # Spending on survival tools
    Penalty         # Deductions (entity damage fees, etc.)

# ============================================================================
# ECONOMY DEVICE
# ============================================================================
economy_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: HUD & FEEDBACK
    # ------------------------------------------

    # Main currency display HUD (shows per-player)
    @editable
    CurrencyHUD : hud_message_device = hud_message_device{}

    # Audio: money earned (cha-ching)
    @editable
    EarnSound : audio_player_device = audio_player_device{}

    # Audio: money spent (cash register)
    @editable
    SpendSound : audio_player_device = audio_player_device{}

    # Audio: insufficient funds
    @editable
    InsufficientFundsSound : audio_player_device = audio_player_device{}

    # Billboard for showing economy stats (total earned, spent, etc.)
    @editable
    EconomyStatsDisplay : billboard_device = billboard_device{}

    # ------------------------------------------
    # CONFIGURATION
    # ------------------------------------------

    # Starting Tickets for each player
    @editable
    StartingTickets : int = 100

    # Night survival bonus (base amount, multiplied by night number)
    @editable
    NightSurvivalBonusBase : int = 50

    # Bonus Tickets per entity eliminated
    @editable
    EntityBountyBase : int = 10

    # Income multipliers by night number
    # Night 1: 1.0x, Night 2: 1.5x, Night 3: 2.0x, Night 4: 3.0x, Night 5: 5.0x
    NightMultipliers : []float = array{1.0, 1.5, 2.0, 3.0, 5.0}

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var PlayerEconomies : [player]player_economy = map{}

    # Shared team pool (optional — for co-op shared economy)
    var SharedPool : int = 0
    var UseSharedPool : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Economy: Initializing DEAD PROFIT economy...")

        # Register current players
        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        Print("Economy: Ready. Starting balance: {StartingTickets} Tickets per player.")

    InitializePlayer(Player : player) : void =
        if (not PlayerEconomies[Player]):
            NewEconomy := player_economy{}
            set NewEconomy.Tickets = StartingTickets
            set NewEconomy.TotalEarned = StartingTickets
            if (set PlayerEconomies[Player] = NewEconomy) {}
            UpdateCurrencyHUD(Player)
            Print("Economy: Player initialized with {StartingTickets} Tickets")

    OnPlayerAdded(Player : player) : void =
        InitializePlayer(Player)

    # ========================================================================
    # EARNING — Add Tickets
    # ========================================================================

    # Add Tickets to a specific player
    AddTickets(Player : player, BaseAmount : int, Type : transaction_type) : void =
        if (Econ := PlayerEconomies[Player]):
            # Apply income multiplier
            MultipliedAmount := Floor[BaseAmount * Econ.IncomeMultiplier]
            set Econ.Tickets += MultipliedAmount
            set Econ.TotalEarned += MultipliedAmount

            EarnSound.Play()
            UpdateCurrencyHUD(Player)
            Print("Economy: +{MultipliedAmount} Tickets ({Type}) [Multiplier: {Econ.IncomeMultiplier}x]")

    # Add Tickets to ALL players (used for park income ticks)
    AddTicketsToAll(BaseAmount : int) : void =
        for (Player -> Econ : PlayerEconomies):
            MultipliedAmount := Floor[BaseAmount * Econ.IncomeMultiplier]
            set Econ.Tickets += MultipliedAmount
            set Econ.TotalEarned += MultipliedAmount
            UpdateCurrencyHUD(Player)
        EarnSound.Play()
        Print("Economy: +{BaseAmount} Tickets to all players (park income)")

    # Grant night survival bonus to all players
    GrantNightBonus(NightNumber : int, EntitiesEliminated : int) : void =
        # Base bonus + night multiplier + bounties
        SurvivalBonus := NightSurvivalBonusBase * NightNumber
        EntityBonus := EntitiesEliminated * EntityBountyBase

        TotalBonus := SurvivalBonus + EntityBonus

        for (Player -> Econ : PlayerEconomies):
            MultipliedBonus := Floor[TotalBonus * Econ.IncomeMultiplier]
            set Econ.Tickets += MultipliedBonus
            set Econ.TotalEarned += MultipliedBonus
            UpdateCurrencyHUD(Player)

        Print("Economy: Night {NightNumber} bonus — Survival: {SurvivalBonus}, Bounties: {EntityBonus}, Total: {TotalBonus}")

    # ========================================================================
    # SPENDING — Remove Tickets
    # ========================================================================

    # Try to spend Tickets. Returns true if successful, false if insufficient funds.
    TrySpend(Player : player, BaseAmount : int, Type : transaction_type) : logic =
        if (Econ := PlayerEconomies[Player]):
            # Apply spending discount
            DiscountedAmount := Floor[BaseAmount * (1.0 - Econ.SpendingDiscount)]
            if (DiscountedAmount < 1): set DiscountedAmount = 1  # Minimum 1

            if (Econ.Tickets >= DiscountedAmount):
                set Econ.Tickets -= DiscountedAmount
                set Econ.TotalSpent += DiscountedAmount
                SpendSound.Play()
                UpdateCurrencyHUD(Player)
                Print("Economy: -{DiscountedAmount} Tickets ({Type}) [Discount: {Econ.SpendingDiscount}]")
                return true
            else:
                InsufficientFundsSound.Play()
                Print("Economy: INSUFFICIENT FUNDS. Need {DiscountedAmount}, have {Econ.Tickets}")
                return false
        return false

    # Force-deduct Tickets (for penalties — doesn't check balance, can go negative)
    Penalize(Player : player, Amount : int) : void =
        if (Econ := PlayerEconomies[Player]):
            set Econ.Tickets -= Amount
            if (Econ.Tickets < 0):
                set Econ.Tickets = 0
            set Econ.TotalSpent += Amount
            UpdateCurrencyHUD(Player)
            Print("Economy: ⚠️ Penalty: -{Amount} Tickets")

    # ========================================================================
    # MULTIPLIER MANAGEMENT — Called by Progression
    # ========================================================================

    # Set income multiplier based on night number
    SetNightMultiplier(NightNumber : int) : void =
        if (Multiplier := NightMultipliers[NightNumber - 1]):
            for (Player -> Econ : PlayerEconomies):
                set Econ.IncomeMultiplier = Multiplier
            Print("Economy: Income multiplier set to {Multiplier}x for Night {NightNumber}")

    # Set a specific player's multiplier (for individual bonuses)
    SetPlayerMultiplier(Player : player, Multiplier : float) : void =
        if (Econ := PlayerEconomies[Player]):
            set Econ.IncomeMultiplier = Multiplier

    # Set spending discount for a player
    SetSpendingDiscount(Player : player, Discount : float) : void =
        if (Econ := PlayerEconomies[Player]):
            set Econ.SpendingDiscount = Discount
            Print("Economy: Spending discount set to {Discount} for player")

    # ========================================================================
    # QUERIES — Used by other systems
    # ========================================================================

    GetTickets(Player : player) : int =
        if (Econ := PlayerEconomies[Player]):
            return Econ.Tickets
        return 0

    GetTotalEarned(Player : player) : int =
        if (Econ := PlayerEconomies[Player]):
            return Econ.TotalEarned
        return 0

    GetTotalSpent(Player : player) : int =
        if (Econ := PlayerEconomies[Player]):
            return Econ.TotalSpent
        return 0

    CanAfford(Player : player, Amount : int) : logic =
        if (Econ := PlayerEconomies[Player]):
            DiscountedAmount := Floor[Amount * (1.0 - Econ.SpendingDiscount)]
            return Econ.Tickets >= DiscountedAmount
        return false

    # Get the richest player (for stats display)
    GetRichestPlayer() : ?player =
        var BestPlayer : ?player = false
        var BestAmount : int = -1
        for (Player -> Econ : PlayerEconomies):
            if (Econ.Tickets > BestAmount):
                set BestAmount = Econ.Tickets
                set BestPlayer = option{Player}
        return BestPlayer

    # Get total Tickets across all players
    GetTeamTotalTickets() : int =
        var Total : int = 0
        for (_ -> Econ : PlayerEconomies):
            set Total += Econ.Tickets
        return Total

    # ========================================================================
    # HUD UPDATE
    # ========================================================================

    UpdateCurrencyHUD(Player : player) : void =
        if (Econ := PlayerEconomies[Player]):
            MultiplierText := if (Econ.IncomeMultiplier > 1.0) then " ({Econ.IncomeMultiplier}x)" else ""
            CurrencyHUD.SetText(StringToMessage(
                "🎟️ {Econ.Tickets} Tickets{MultiplierText}"
            ))
            CurrencyHUD.Show(Player)

    # Update the stats billboard (shown at Central Plaza)
    UpdateStatsDisplay() : void =
        var TotalAllEarned : int = 0
        var TotalAllSpent : int = 0
        var PlayerCount : int = 0
        for (_ -> Econ : PlayerEconomies):
            set TotalAllEarned += Econ.TotalEarned
            set TotalAllSpent += Econ.TotalSpent
            set PlayerCount += 1
        EconomyStatsDisplay.SetText(StringToMessage(
            "📊 Team Economy\nPlayers: {PlayerCount}\nTotal Earned: {TotalAllEarned}\nTotal Spent: {TotalAllSpent}"
        ))

    # ========================================================================
    # RESET — For new game
    # ========================================================================

    ResetEconomy() : void =
        for (Player -> Econ : PlayerEconomies):
            set Econ.Tickets = StartingTickets
            set Econ.TotalEarned = StartingTickets
            set Econ.TotalSpent = 0
            set Econ.IncomeMultiplier = 1.0
            set Econ.SpendingDiscount = 0.0
            UpdateCurrencyHUD(Player)
        set SharedPool = 0
        Print("Economy: Full reset. All players back to {StartingTickets} Tickets.")
