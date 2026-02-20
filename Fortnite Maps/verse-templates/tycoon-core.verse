# ============================================================================
# TYCOON CORE SYSTEM — Verse Template for UEFN
# ============================================================================
# A complete tycoon progression framework with currency, upgrades, tiered
# unlocks, and persistent player progress via the Fortnite persistence system.
#
# HOW TO USE:
#   1. Add this device to your UEFN project
#   2. Wire up the button_device references in the editor
#   3. Customize the upgrade tiers and costs below
#   4. Connect UI elements for currency display
#
# DEPENDENCIES: Fortnite.com, Verse.org modules (auto-imported in UEFN)
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# DATA STRUCTURES
# ============================================================================

# Represents a single upgrade tier that players can purchase.
# Add more fields as needed (e.g., description, icon reference).
upgrade_tier := struct:
    # Display name shown in UI
    Name : string
    # Cost in tycoon currency to purchase this tier
    Cost : int
    # The tier level (1, 2, 3...) — used for ordering and unlock checks
    Level : int

# Tracks an individual player's tycoon progress.
# One instance per player in the game.
player_progress := class:
    # Current currency balance
    var Currency : int = 0
    # Highest upgrade tier unlocked (0 = none)
    var CurrentTier : int = 0
    # Total currency earned all-time (useful for stats/leaderboards)
    var TotalEarned : int = 0

# ============================================================================
# MAIN TYCOON DEVICE
# ============================================================================

tycoon_core_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # Wire these up in UEFN's details panel.
    # ------------------------------------------

    # Button players interact with to earn currency (e.g., a collector/generator)
    @editable
    EarnButton : button_device = button_device{}

    # Button to purchase the next upgrade tier
    @editable
    UpgradeButton : button_device = button_device{}

    # How much currency the player earns per button press
    @editable
    EarnAmount : int = 10

    # Billboard or HUD message device to display currency (optional)
    @editable
    CurrencyDisplay : hud_message_device = hud_message_device{}

    # Timer device for passive income (optional — wire up a repeating timer)
    @editable
    PassiveIncomeTimer : timer_device = timer_device{}

    # Passive income amount per timer tick
    @editable
    PassiveIncomeAmount : int = 1

    # ------------------------------------------
    # UPGRADE TIERS CONFIGURATION
    # Customize these for your tycoon's progression.
    # ------------------------------------------

    # Define your upgrade tiers here. Players unlock them in order.
    UpgradeTiers : []upgrade_tier = array:
        upgrade_tier:
            Name := "Tier 1 — Starter"
            Cost := 100
            Level := 1
        upgrade_tier:
            Name := "Tier 2 — Bronze"
            Cost := 500
            Level := 2
        upgrade_tier:
            Name := "Tier 3 — Silver"
            Cost := 2000
            Level := 3
        upgrade_tier:
            Name := "Tier 4 — Gold"
            Cost := 10000
            Level := 4
        upgrade_tier:
            Name := "Tier 5 — Diamond"
            Cost := 50000
            Level := 5

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    # Map of player → their progress. Populated when players join.
    var PlayerDataMap : [player]player_progress = map{}

    # ========================================================================
    # INITIALIZATION — Called when the device starts in-game
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Tycoon Core: Initializing...")

        # Listen for button interactions
        EarnButton.InteractedWithEvent.Subscribe(OnEarnButtonPressed)
        UpgradeButton.InteractedWithEvent.Subscribe(OnUpgradeButtonPressed)

        # Listen for passive income timer
        PassiveIncomeTimer.SuccessEvent.Subscribe(OnPassiveIncomeTick)

        # Register all current players
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            InitializePlayer(Player)

        # Listen for new players joining
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        Print("Tycoon Core: Ready! {UpgradeTiers.Length} upgrade tiers configured.")

    # ========================================================================
    # PLAYER MANAGEMENT
    # ========================================================================

    # Sets up tracking for a new player
    InitializePlayer(Player : player) : void =
        if (not PlayerDataMap[Player]):
            NewProgress := player_progress{}
            if (set PlayerDataMap[Player] = NewProgress) {}
            Print("Tycoon Core: Player initialized with 0 currency.")
            UpdateCurrencyDisplay(Player)

    # Called when a new player joins mid-game
    OnPlayerAdded(Player : player) : void =
        InitializePlayer(Player)

    # Cleanup when a player leaves
    OnPlayerRemoved(Player : player) : void =
        # In a real implementation, save progress here before removing
        if (var UpdatedMap := PlayerDataMap):
            # Log their final stats before removal
            if (Progress := PlayerDataMap[Player]):
                Print("Tycoon Core: Player left with {Progress.Currency} currency at tier {Progress.CurrentTier}.")

    # ========================================================================
    # CURRENCY SYSTEM
    # ========================================================================

    # Called when a player presses the earn button
    OnEarnButtonPressed(Agent : agent) : void =
        if (Player := player[Agent]):
            AddCurrency(Player, EarnAmount)

    # Called each time the passive income timer fires
    OnPassiveIncomeTick(MaybeAgent : ?agent) : void =
        # Give passive income to ALL players
        for (Player -> Progress : PlayerDataMap):
            AddCurrency(Player, PassiveIncomeAmount)

    # Add currency to a player's balance
    # This is the central method — call this from any earning source.
    AddCurrency(Player : player, Amount : int) : void =
        if (Progress := PlayerDataMap[Player]):
            set Progress.Currency += Amount
            set Progress.TotalEarned += Amount
            UpdateCurrencyDisplay(Player)
            Print("Tycoon Core: +{Amount} currency. Balance: {Progress.Currency}")

    # Remove currency from a player (for purchases)
    # Returns true if the player had enough, false otherwise.
    SpendCurrency(Player : player, Amount : int) : logic =
        if (Progress := PlayerDataMap[Player]):
            if (Progress.Currency >= Amount):
                set Progress.Currency -= Amount
                UpdateCurrencyDisplay(Player)
                return true
        return false

    # Get a player's current balance
    GetCurrency(Player : player) : int =
        if (Progress := PlayerDataMap[Player]):
            return Progress.Currency
        return 0

    # ========================================================================
    # UPGRADE SYSTEM
    # ========================================================================

    # Called when a player presses the upgrade button
    OnUpgradeButtonPressed(Agent : agent) : void =
        if (Player := player[Agent]):
            TryPurchaseNextTier(Player)

    # Attempts to purchase the next upgrade tier for the player
    TryPurchaseNextTier(Player : player) : void =
        if (Progress := PlayerDataMap[Player]):
            NextTierLevel := Progress.CurrentTier + 1

            # Find the next tier in our configuration
            for (Tier : UpgradeTiers):
                if (Tier.Level = NextTierLevel):
                    # Check if player can afford it
                    if (SpendCurrency(Player, Tier.Cost)?):
                        set Progress.CurrentTier = NextTierLevel
                        OnTierUnlocked(Player, Tier)
                        Print("Tycoon Core: Unlocked {Tier.Name}!")
                        return
                    else:
                        Print("Tycoon Core: Not enough currency. Need {Tier.Cost}, have {Progress.Currency}.")
                        return

            Print("Tycoon Core: Already at max tier!")

    # Called when a player unlocks a new tier.
    # CUSTOMIZE THIS to trigger props, barriers, spawners, etc.
    OnTierUnlocked(Player : player, Tier : upgrade_tier) : void =
        # -------------------------------------------------------
        # ADD YOUR TIER UNLOCK LOGIC HERE
        # Examples:
        #   - Enable a prop_mover_device to reveal a new area
        #   - Disable a barrier_device to open a path
        #   - Grant an item via item_granter_device
        #   - Spawn NPCs via guard_spawner_device
        # -------------------------------------------------------
        Print("Tycoon Core: Player unlocked tier {Tier.Level}: {Tier.Name}")

        # Example: You could switch on tier level
        # case (Tier.Level):
        #     1 => Tier1Barrier.Disable()
        #     2 => Tier2PropMover.Begin()
        #     3 => Tier3ItemGranter.GrantItem(Player)

    # ========================================================================
    # UI / DISPLAY
    # ========================================================================

    # Updates the HUD display showing the player's currency
    UpdateCurrencyDisplay(Player : player) : void =
        if (Progress := PlayerDataMap[Player]):
            # Show currency on HUD message device
            # Format: "💰 1,234 coins | Tier 3"
            CurrencyDisplay.SetText(
                StringToMessage("Currency: {Progress.Currency} | Tier: {Progress.CurrentTier}")
            )
            CurrencyDisplay.Show(Player)

    # ========================================================================
    # SAVE / LOAD (Persistence)
    # ========================================================================
    # NOTE: UEFN persistence uses the persistable attribute and
    # persist_player_data. This is a simplified reference.
    # For full implementation, see Epic's persistence documentation.
    #
    # To make this work:
    #   1. Mark your data class with <persistable>
    #   2. Use the persistence module to save/load
    #   3. Call SavePlayerProgress on timer or on significant events
    #   4. Call LoadPlayerProgress when player joins
    # ========================================================================

    # Placeholder — replace with actual persistence calls
    SavePlayerProgress(Player : player) : void =
        if (Progress := PlayerDataMap[Player]):
            Print("Tycoon Core: [SAVE] Currency={Progress.Currency}, Tier={Progress.CurrentTier}, TotalEarned={Progress.TotalEarned}")
            # TODO: Implement with UEFN persistence API
            # Example:
            #   PlayerData := GetOrCreatePersistedData(Player)
            #   set PlayerData.Currency = Progress.Currency
            #   set PlayerData.CurrentTier = Progress.CurrentTier

    # Placeholder — replace with actual persistence calls
    LoadPlayerProgress(Player : player) : void =
        Print("Tycoon Core: [LOAD] Loading progress for player...")
        # TODO: Implement with UEFN persistence API
        # Example:
        #   if (PlayerData := GetPersistedData(Player)):
        #       if (Progress := PlayerDataMap[Player]):
        #           set Progress.Currency = PlayerData.Currency
        #           set Progress.CurrentTier = PlayerData.CurrentTier
