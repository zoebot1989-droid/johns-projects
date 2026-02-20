# ============================================================================
# PARK MANAGER — DEAD PROFIT
# ============================================================================
# Amusement park tycoon system. Players build and upgrade attractions to
# generate income (Tickets) from visitors during the Day phase.
#
# ATTRACTIONS:
#   Each attraction has a name, base income, build cost, upgrade tiers,
#   and a physical location in the park. Attractions can be damaged by
#   entities at Night and must be repaired during Day.
#
# VISITOR SYSTEM:
#   Visitor count is score-based (not actual NPCs for performance).
#   More/better attractions = higher visitor score = more income per tick.
#
# INTEGRATION:
#   - DayNightCycle: Income only generates during Day phase
#   - Economy: All currency flows through economy.verse
#   - EntityAI: Entities can call DamageAttraction() at night
#   - Progression: Unlocks higher-tier attractions on later nights
#   - UIManager: Displays attraction status, visitor count, income rate
#
# DEVICE WIRING:
#   - Each attraction needs: button_device (build/upgrade), prop_mover_device
#     (show/hide the built attraction), billboard_device (status display)
#   - Wire IncomeTimer to a repeating timer (every 10 seconds recommended)
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# ATTRACTION TIER — Defines one upgrade level of an attraction
# ============================================================================
attraction_tier := struct:
    TierName : string           # e.g., "Basic Ferris Wheel", "Deluxe Ferris Wheel"
    UpgradeCost : int           # Tickets needed to reach this tier
    IncomePerTick : int         # Tickets earned per income tick at this tier
    VisitorBonus : int          # Additional visitors attracted at this tier
    RepairCost : int            # Cost to repair from damaged state at this tier

# ============================================================================
# ATTRACTION STATE — Runtime state for one attraction
# ============================================================================
attraction_state := class:
    # Which attraction template this is (index into Attractions array)
    AttractionIndex : int = 0
    # Current upgrade tier (0 = not built, 1 = tier 1, etc.)
    var CurrentTier : int = 0
    # Is this attraction currently damaged by entities?
    var IsDamaged : logic = false
    # Health points (entities reduce this; 0 = damaged)
    var Health : int = 100
    var MaxHealth : int = 100

# ============================================================================
# ATTRACTION TEMPLATE — Defines a buildable attraction in the editor
# ============================================================================
# Each attraction in the park is represented by one of these.
# Wire up the physical devices in UEFN's details panel.
# ============================================================================
attraction_template := struct:
    # Display name
    Name : string
    # Zone this attraction belongs to (for organization)
    Zone : string
    # Tiers available (index 0 = tier 1, etc.)
    Tiers : []attraction_tier
    # Maximum health points
    MaxHealth : int

# ============================================================================
# PARK MANAGER DEVICE
# ============================================================================
park_manager_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: INTERACTION DEVICES
    # One button per attraction for build/upgrade interaction.
    # ------------------------------------------

    # Build/upgrade buttons — one per attraction slot
    # Player interacts to build (if not built) or upgrade (if built)
    @editable
    AttractionButtons : []button_device = array{}

    # Prop movers that reveal/hide the built attractions
    # Index matches AttractionButtons
    @editable
    AttractionPropMovers : []prop_mover_device = array{}

    # Billboards showing each attraction's status (name, tier, income, health)
    @editable
    AttractionDisplays : []billboard_device = array{}

    # ------------------------------------------
    # EDITOR-EXPOSED: INCOME SYSTEM
    # ------------------------------------------

    # Repeating timer for income generation (every 10 seconds recommended)
    @editable
    IncomeTimer : timer_device = timer_device{}

    # HUD showing total park income rate and visitor count
    @editable
    ParkStatsHUD : hud_message_device = hud_message_device{}

    # Audio: cash register / cha-ching when income is earned
    @editable
    IncomeSound : audio_player_device = audio_player_device{}

    # Audio: construction sound when building/upgrading
    @editable
    BuildSound : audio_player_device = audio_player_device{}

    # Audio: damage sound when attraction is hit
    @editable
    DamageSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: REPAIR SYSTEM
    # ------------------------------------------

    # Buttons for repairing damaged attractions (can reuse build buttons)
    @editable
    RepairButtons : []button_device = array{}

    # ------------------------------------------
    # CONFIGURATION: ATTRACTION DEFINITIONS
    # ------------------------------------------
    # These define all available attractions in the park.
    # Customize names, costs, income values, and tiers here.

    AttractionTemplates : []attraction_template = array:
        # ---- TIER 1: KIDDIE ZONE / GAME STALLS ----
        attraction_template:
            Name := "Balloon Dart Booth"
            Zone := "Game Stalls"
            MaxHealth := 80
            Tiers := array:
                attraction_tier:
                    TierName := "Basic Booth"
                    UpgradeCost := 50
                    IncomePerTick := 5
                    VisitorBonus := 10
                    RepairCost := 25
                attraction_tier:
                    TierName := "Neon Booth"
                    UpgradeCost := 150
                    IncomePerTick := 12
                    VisitorBonus := 20
                    RepairCost := 50

        attraction_template:
            Name := "Kiddie Train"
            Zone := "Kiddie Zone"
            MaxHealth := 80
            Tiers := array:
                attraction_tier:
                    TierName := "Rusty Train"
                    UpgradeCost := 75
                    IncomePerTick := 7
                    VisitorBonus := 15
                    RepairCost := 30
                attraction_tier:
                    TierName := "Express Train"
                    UpgradeCost := 200
                    IncomePerTick := 15
                    VisitorBonus := 30
                    RepairCost := 60

        attraction_template:
            Name := "Cotton Candy Stand"
            Zone := "Food Court"
            MaxHealth := 60
            Tiers := array:
                attraction_tier:
                    TierName := "Basic Stand"
                    UpgradeCost := 40
                    IncomePerTick := 4
                    VisitorBonus := 8
                    RepairCost := 20
                attraction_tier:
                    TierName := "Deluxe Stand"
                    UpgradeCost := 120
                    IncomePerTick := 10
                    VisitorBonus := 18
                    RepairCost := 40

        # ---- TIER 2: MAIN RIDES ----
        attraction_template:
            Name := "Ferris Wheel"
            Zone := "Rides Area"
            MaxHealth := 120
            Tiers := array:
                attraction_tier:
                    TierName := "Rickety Wheel"
                    UpgradeCost := 200
                    IncomePerTick := 15
                    VisitorBonus := 25
                    RepairCost := 75
                attraction_tier:
                    TierName := "Grand Wheel"
                    UpgradeCost := 500
                    IncomePerTick := 30
                    VisitorBonus := 50
                    RepairCost := 150
                attraction_tier:
                    TierName := "Neon Sky Wheel"
                    UpgradeCost := 1200
                    IncomePerTick := 55
                    VisitorBonus := 90
                    RepairCost := 300

        attraction_template:
            Name := "Roller Coaster"
            Zone := "Rides Area"
            MaxHealth := 150
            Tiers := array:
                attraction_tier:
                    TierName := "Wooden Coaster"
                    UpgradeCost := 300
                    IncomePerTick := 20
                    VisitorBonus := 35
                    RepairCost := 100
                attraction_tier:
                    TierName := "Steel Coaster"
                    UpgradeCost := 800
                    IncomePerTick := 45
                    VisitorBonus := 70
                    RepairCost := 250
                attraction_tier:
                    TierName := "Hyper Coaster"
                    UpgradeCost := 2000
                    IncomePerTick := 80
                    VisitorBonus := 120
                    RepairCost := 500

        attraction_template:
            Name := "Bumper Cars"
            Zone := "Rides Area"
            MaxHealth := 100
            Tiers := array:
                attraction_tier:
                    TierName := "Rusty Bumpers"
                    UpgradeCost := 150
                    IncomePerTick := 10
                    VisitorBonus := 20
                    RepairCost := 50
                attraction_tier:
                    TierName := "Electric Bumpers"
                    UpgradeCost := 400
                    IncomePerTick := 25
                    VisitorBonus := 40
                    RepairCost := 120

        # ---- TIER 3: PREMIUM ATTRACTIONS ----
        attraction_template:
            Name := "Haunted House Ride"
            Zone := "Haunted House"
            MaxHealth := 200
            Tiers := array:
                attraction_tier:
                    TierName := "Spooky Shack"
                    UpgradeCost := 500
                    IncomePerTick := 30
                    VisitorBonus := 50
                    RepairCost := 150
                attraction_tier:
                    TierName := "Terror Manor"
                    UpgradeCost := 1500
                    IncomePerTick := 65
                    VisitorBonus := 100
                    RepairCost := 400
                attraction_tier:
                    TierName := "Nightmare Palace"
                    UpgradeCost := 4000
                    IncomePerTick := 120
                    VisitorBonus := 180
                    RepairCost := 800

        attraction_template:
            Name := "Log Flume"
            Zone := "Water Rides"
            MaxHealth := 130
            Tiers := array:
                attraction_tier:
                    TierName := "Leaky Logs"
                    UpgradeCost := 350
                    IncomePerTick := 18
                    VisitorBonus := 30
                    RepairCost := 100
                attraction_tier:
                    TierName := "Raging Rapids"
                    UpgradeCost := 900
                    IncomePerTick := 40
                    VisitorBonus := 65
                    RepairCost := 250

        attraction_template:
            Name := "Main Stage"
            Zone := "Central Plaza"
            MaxHealth := 180
            Tiers := array:
                attraction_tier:
                    TierName := "Open Mic"
                    UpgradeCost := 250
                    IncomePerTick := 12
                    VisitorBonus := 40
                    RepairCost := 80
                attraction_tier:
                    TierName := "Concert Stage"
                    UpgradeCost := 700
                    IncomePerTick := 35
                    VisitorBonus := 75
                    RepairCost := 200
                attraction_tier:
                    TierName := "Mega Arena"
                    UpgradeCost := 2500
                    IncomePerTick := 70
                    VisitorBonus := 130
                    RepairCost := 600

        attraction_template:
            Name := "Food Court"
            Zone := "Food Court"
            MaxHealth := 90
            Tiers := array:
                attraction_tier:
                    TierName := "Hot Dog Cart"
                    UpgradeCost := 60
                    IncomePerTick := 6
                    VisitorBonus := 12
                    RepairCost := 25
                attraction_tier:
                    TierName := "Food Hall"
                    UpgradeCost := 250
                    IncomePerTick := 18
                    VisitorBonus := 35
                    RepairCost := 80
                attraction_tier:
                    TierName := "Gourmet Plaza"
                    UpgradeCost := 800
                    IncomePerTick := 38
                    VisitorBonus := 60
                    RepairCost := 200

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    # Runtime state for each attraction (index matches AttractionTemplates)
    var Attractions : []attraction_state = array{}

    # Total visitor count (sum of all attraction visitor bonuses)
    var TotalVisitors : int = 0

    # Total income per tick (sum of all active attraction incomes)
    var IncomePerTick : int = 0

    # Is the park currently generating income? (only during Day)
    var IsGeneratingIncome : logic = false

    # Park star rating (1-5, based on total visitors)
    var ParkRating : int = 0

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("ParkManager: Initializing DEAD PROFIT park system...")

        # Initialize attraction states
        for (Index -> Template : AttractionTemplates):
            NewState := attraction_state:
                AttractionIndex := Index
            set Attractions += array{NewState}

        # Wire up build buttons
        for (Index -> Button : AttractionButtons):
            Button.InteractedWithEvent.Subscribe(MakeBuildHandler(Index))

        # Wire up repair buttons
        for (Index -> Button : RepairButtons):
            Button.InteractedWithEvent.Subscribe(MakeRepairHandler(Index))

        # Wire up income timer
        IncomeTimer.SuccessEvent.Subscribe(OnIncomeTick)

        # Update all displays
        UpdateAllDisplays()
        RecalculateStats()

        Print("ParkManager: Ready. {AttractionTemplates.Length} attraction slots available.")

    # ========================================================================
    # BUILD / UPGRADE SYSTEM
    # ========================================================================

    # Creates a handler closure for a specific attraction index
    MakeBuildHandler(AttractionIndex : int) : tuple(agent) -> void =
        return (Agent : agent) =>
            if (Player := player[Agent]):
                TryBuildOrUpgrade(Player, AttractionIndex)

    # Creates a handler closure for repair
    MakeRepairHandler(AttractionIndex : int) : tuple(agent) -> void =
        return (Agent : agent) =>
            if (Player := player[Agent]):
                TryRepair(Player, AttractionIndex)

    # Attempt to build a new attraction or upgrade an existing one
    TryBuildOrUpgrade(Player : player, Index : int) : void =
        if (State := Attractions[Index], Template := AttractionTemplates[Index]):
            NextTier := State.CurrentTier + 1

            # Check if there's a next tier available
            if (TierData := Template.Tiers[NextTier - 1]):
                Cost := TierData.UpgradeCost

                # Check if player can afford it (calls into Economy system)
                # For now, using a direct currency check pattern
                Print("ParkManager: Player wants to build/upgrade {Template.Name} to {TierData.TierName} (Cost: {Cost})")

                # TODO: Call Economy.TrySpend(Player, Cost)
                # If successful:
                set State.CurrentTier = NextTier
                set State.Health = Template.MaxHealth
                set State.MaxHealth = Template.MaxHealth
                set State.IsDamaged = false

                # Play build sound
                BuildSound.Play()

                # Show the attraction prop (reveal via prop mover)
                if (Mover := AttractionPropMovers[Index]):
                    Mover.Begin()

                RecalculateStats()
                UpdateAttractionDisplay(Index)
                Print("ParkManager: ✅ {Template.Name} built/upgraded to {TierData.TierName}!")
            else:
                Print("ParkManager: {Template.Name} is at max tier!")

    # Attempt to repair a damaged attraction
    TryRepair(Player : player, Index : int) : void =
        if (State := Attractions[Index], Template := AttractionTemplates[Index]):
            if (State.IsDamaged?):
                if (TierData := Template.Tiers[State.CurrentTier - 1]):
                    Cost := TierData.RepairCost
                    Print("ParkManager: Repairing {Template.Name} (Cost: {Cost})")

                    # TODO: Call Economy.TrySpend(Player, Cost)
                    set State.IsDamaged = false
                    set State.Health = State.MaxHealth
                    BuildSound.Play()
                    RecalculateStats()
                    UpdateAttractionDisplay(Index)
                    Print("ParkManager: 🔧 {Template.Name} repaired!")
            else:
                Print("ParkManager: {Template.Name} is not damaged.")

    # ========================================================================
    # INCOME GENERATION
    # ========================================================================

    # Called by DayNightCycle when Day starts
    StartIncomeGeneration() : void =
        set IsGeneratingIncome = true
        IncomeTimer.Start()
        Print("ParkManager: 💰 Income generation STARTED")

    # Called by DayNightCycle when Day ends (Dusk)
    StopIncomeGeneration() : void =
        set IsGeneratingIncome = false
        IncomeTimer.Pause()
        Print("ParkManager: Income generation STOPPED")

    # Timer tick — generate income for all players
    OnIncomeTick(MaybeAgent : ?agent) : void =
        if (IsGeneratingIncome?):
            if (IncomePerTick > 0):
                # TODO: Call Economy.AddTicketsToAll(IncomePerTick)
                IncomeSound.Play()
                Print("ParkManager: 💰 +{IncomePerTick} Tickets (Visitors: {TotalVisitors})")

    # ========================================================================
    # DAMAGE SYSTEM — Called by EntityAI when entities attack
    # ========================================================================

    # Entity damages a specific attraction
    DamageAttraction(Index : int, Damage : int) : void =
        if (State := Attractions[Index], Template := AttractionTemplates[Index]):
            if (State.CurrentTier > 0 and not State.IsDamaged?):
                set State.Health -= Damage

                if (State.Health <= 0):
                    set State.Health = 0
                    set State.IsDamaged = true
                    DamageSound.Play()
                    RecalculateStats()
                    UpdateAttractionDisplay(Index)
                    Print("ParkManager: 💥 {Template.Name} DESTROYED by entities!")
                else:
                    Print("ParkManager: ⚠️ {Template.Name} took {Damage} damage (HP: {State.Health}/{State.MaxHealth})")

    # Damage a random built attraction (used by EntityAI for area attacks)
    DamageRandomAttraction(Damage : int) : void =
        # Collect indices of built, undamaged attractions
        var ValidTargets : []int = array{}
        for (Index -> State : Attractions):
            if (State.CurrentTier > 0 and not State.IsDamaged?):
                set ValidTargets += array{Index}

        if (ValidTargets.Length > 0):
            # Pick random target
            RandomIndex := GetRandomInt(0, ValidTargets.Length - 1)
            if (TargetIndex := ValidTargets[RandomIndex]):
                DamageAttraction(TargetIndex, Damage)

    # ========================================================================
    # STATS RECALCULATION
    # ========================================================================

    # Recalculate total visitors and income based on active attractions
    RecalculateStats() : void =
        var NewVisitors : int = 0
        var NewIncome : int = 0

        for (Index -> State : Attractions):
            if (State.CurrentTier > 0 and not State.IsDamaged?):
                if (Template := AttractionTemplates[Index]):
                    if (TierData := Template.Tiers[State.CurrentTier - 1]):
                        set NewVisitors += TierData.VisitorBonus
                        set NewIncome += TierData.IncomePerTick

        set TotalVisitors = NewVisitors
        set IncomePerTick = NewIncome

        # Calculate park rating (star system)
        if (TotalVisitors >= 500):
            set ParkRating = 5
        else if (TotalVisitors >= 300):
            set ParkRating = 4
        else if (TotalVisitors >= 150):
            set ParkRating = 3
        else if (TotalVisitors >= 50):
            set ParkRating = 2
        else if (TotalVisitors > 0):
            set ParkRating = 1
        else:
            set ParkRating = 0

        # Update park stats HUD
        StarDisplay := MakeStarString(ParkRating)
        ParkStatsHUD.SetText(
            StringToMessage("{StarDisplay} | Visitors: {TotalVisitors} | Income: +{IncomePerTick}/tick")
        )
        ParkStatsHUD.Show()

        Print("ParkManager: Stats updated — Rating: {ParkRating}★, Visitors: {TotalVisitors}, Income: {IncomePerTick}/tick")

    # Helper: Create star rating string
    MakeStarString(Stars : int) : string =
        if (Stars >= 5): return "★★★★★"
        if (Stars >= 4): return "★★★★☆"
        if (Stars >= 3): return "★★★☆☆"
        if (Stars >= 2): return "★★☆☆☆"
        if (Stars >= 1): return "★☆☆☆☆"
        return "☆☆☆☆☆"

    # ========================================================================
    # DISPLAY UPDATES
    # ========================================================================

    UpdateAttractionDisplay(Index : int) : void =
        if (State := Attractions[Index], Template := AttractionTemplates[Index]):
            if (Display := AttractionDisplays[Index]):
                if (State.CurrentTier = 0):
                    # Not built yet — show build cost
                    if (FirstTier := Template.Tiers[0]):
                        Display.SetText(StringToMessage(
                            "🔨 {Template.Name}\n[NOT BUILT]\nCost: {FirstTier.UpgradeCost} Tickets"
                        ))
                else if (State.IsDamaged?):
                    # Damaged — show repair cost
                    if (TierData := Template.Tiers[State.CurrentTier - 1]):
                        Display.SetText(StringToMessage(
                            "💥 {Template.Name}\n[DAMAGED]\nRepair: {TierData.RepairCost} Tickets"
                        ))
                else:
                    # Active — show status
                    if (TierData := Template.Tiers[State.CurrentTier - 1]):
                        Display.SetText(StringToMessage(
                            "✅ {Template.Name}\n{TierData.TierName}\nIncome: +{TierData.IncomePerTick} | HP: {State.Health}/{State.MaxHealth}"
                        ))

    UpdateAllDisplays() : void =
        for (Index -> _ : Attractions):
            UpdateAttractionDisplay(Index)

    # ========================================================================
    # PUBLIC GETTERS
    # ========================================================================

    GetTotalVisitors() : int = TotalVisitors
    GetIncomePerTick() : int = IncomePerTick
    GetParkRating() : int = ParkRating

    GetAttractionCount() : int =
        var Count : int = 0
        for (State : Attractions):
            if (State.CurrentTier > 0):
                set Count += 1
        return Count

    GetDamagedCount() : int =
        var Count : int = 0
        for (State : Attractions):
            if (State.IsDamaged?):
                set Count += 1
        return Count

    # ========================================================================
    # RESET — For new game
    # ========================================================================
    ResetPark() : void =
        for (State : Attractions):
            set State.CurrentTier = 0
            set State.IsDamaged = false
            set State.Health = 100
        RecalculateStats()
        UpdateAllDisplays()
        Print("ParkManager: Park fully reset.")
