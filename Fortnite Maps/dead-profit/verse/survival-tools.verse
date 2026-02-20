# ============================================================================
# SURVIVAL TOOLS — DEAD PROFIT
# ============================================================================
# Player tools for the Night phase. These are the player's defense against
# entities. Each tool has limited uses/charge, creating resource tension.
#
# TOOLS:
#   1. Flashlight     — Stuns entities in a cone, drains battery
#   2. Barricade      — Placeable wall that blocks entity paths
#   3. Noise Maker    — Throwable distraction, lures entities away
#   4. Hiding Spot    — Activatable hiding points (lockers, dumpsters)
#   5. Emergency Flare — Area stun + light, rare and powerful
#
# INTEGRATION:
#   - EntityAI: Flashlight stuns, flare stuns, noise maker distracts
#   - Economy: Tools purchased with Tickets during Day phase
#   - DayNightCycle: Tools only usable during Night/Dusk
#   - UIManager: Shows tool inventory and charges on HUD
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# TOOL TYPE ENUM
# ============================================================================
tool_type := enum:
    Flashlight
    Barricade
    NoiseMaker
    HidingSpot
    EmergencyFlare

# ============================================================================
# PLAYER TOOL INVENTORY — Tracks what each player has
# ============================================================================
player_tool_inventory := class:
    # Flashlight battery (0-100)
    var FlashlightBattery : float = 100.0
    var FlashlightOn : logic = false

    # Barricade charges (how many can be placed)
    var BarricadeCharges : int = 0

    # Noise maker charges
    var NoiseMakerCharges : int = 0

    # Emergency flare charges (rare, powerful)
    var FlareCharges : int = 0

    # Is the player currently hiding?
    var IsHiding : logic = false

# ============================================================================
# SURVIVAL TOOLS DEVICE
# ============================================================================
survival_tools_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: FLASHLIGHT
    # ------------------------------------------

    # Light device attached to the player's view (or world-space)
    @editable
    FlashlightLight : light_device = light_device{}

    # Button to toggle flashlight
    @editable
    FlashlightToggleButton : button_device = button_device{}

    # Timer for battery drain (repeating, 1 second)
    @editable
    BatteryDrainTimer : timer_device = timer_device{}

    # Audio: flashlight click
    @editable
    FlashlightClickSound : audio_player_device = audio_player_device{}

    # Audio: low battery warning
    @editable
    LowBatteryWarning : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: BARRICADES
    # ------------------------------------------

    # Button to place a barricade
    @editable
    BarricadePlaceButton : button_device = button_device{}

    # Barrier devices that get enabled when barricades are placed
    # Place these at strategic chokepoints around the map
    @editable
    BarricadeSlots : []barrier_device = array{}

    # Audio: barricade placement (wood/metal slamming)
    @editable
    BarricadePlaceSound : audio_player_device = audio_player_device{}

    # Audio: barricade breaking
    @editable
    BarricadeBreakSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: NOISE MAKER
    # ------------------------------------------

    # Button to throw noise maker
    @editable
    NoiseMakerButton : button_device = button_device{}

    # Audio player at the noise maker landing point
    @editable
    NoiseMakerSound : audio_player_device = audio_player_device{}

    # VFX for noise maker (sparks, blinking light)
    @editable
    NoiseMakerVFX : vfx_spawner_device = vfx_spawner_device{}

    # Timer for noise maker duration (how long it distracts)
    @editable
    NoiseMakerDurationTimer : timer_device = timer_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: HIDING SPOTS
    # ------------------------------------------

    # Trigger zones at hiding locations (lockers, dumpsters, under desks)
    @editable
    HidingSpotTriggers : []trigger_device = array{}

    # Buttons inside hiding spots (to enter/exit)
    @editable
    HidingSpotButtons : []button_device = array{}

    # Audio: hiding (door creak, breathing)
    @editable
    HidingEnterSound : audio_player_device = audio_player_device{}

    @editable
    HidingExitSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: EMERGENCY FLARE
    # ------------------------------------------

    # Button to deploy flare
    @editable
    FlareButton : button_device = button_device{}

    # Light device for the flare (bright red)
    @editable
    FlareLight : light_device = light_device{}

    # Audio: flare ignition + burn
    @editable
    FlareSound : audio_player_device = audio_player_device{}

    # VFX: flare particles (red smoke, sparks)
    @editable
    FlareVFX : vfx_spawner_device = vfx_spawner_device{}

    # Timer for flare duration
    @editable
    FlareDurationTimer : timer_device = timer_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: HUD
    # ------------------------------------------

    @editable
    ToolHUD : hud_message_device = hud_message_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: SHOP (Buy tools during Day)
    # ------------------------------------------

    # Buttons at the shop for purchasing tools
    @editable
    BuyBarricadeButton : button_device = button_device{}

    @editable
    BuyNoiseMakerButton : button_device = button_device{}

    @editable
    BuyFlareButton : button_device = button_device{}

    @editable
    BuyBatteryButton : button_device = button_device{}

    # Purchase sounds
    @editable
    PurchaseSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # CONFIGURATION: COSTS & STATS
    # ------------------------------------------

    @editable
    BarricadeCost : int = 30
    @editable
    NoiseMakerCost : int = 20
    @editable
    FlareCost : int = 75
    @editable
    BatteryRefillCost : int = 15

    @editable
    FlashlightDrainPerTick : float = 2.0
    @editable
    LowBatteryThreshold : float = 20.0
    @editable
    FlareStunDuration : float = 5.0
    @editable
    NoiseMakerDuration : float = 8.0

    # Maximum charges per tool
    @editable
    MaxBarricades : int = 3
    @editable
    MaxNoiseMakers : int = 5
    @editable
    MaxFlares : int = 2

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var PlayerTools : [player]player_tool_inventory = map{}
    var NextBarricadeSlot : int = 0  # Which barricade slot to use next
    var LowBatteryWarned : logic = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("SurvivalTools: Initializing...")

        # Flashlight controls
        FlashlightToggleButton.InteractedWithEvent.Subscribe(OnFlashlightToggle)
        BatteryDrainTimer.SuccessEvent.Subscribe(OnBatteryDrain)

        # Barricade controls
        BarricadePlaceButton.InteractedWithEvent.Subscribe(OnBarricadePlace)

        # Noise maker controls
        NoiseMakerButton.InteractedWithEvent.Subscribe(OnNoiseMakerDeploy)
        NoiseMakerDurationTimer.SuccessEvent.Subscribe(OnNoiseMakerExpired)

        # Hiding spot controls
        for (Button : HidingSpotButtons):
            Button.InteractedWithEvent.Subscribe(OnHidingSpotToggle)

        # Flare controls
        FlareButton.InteractedWithEvent.Subscribe(OnFlareDeploy)
        FlareDurationTimer.SuccessEvent.Subscribe(OnFlareExpired)

        # Shop buttons
        BuyBarricadeButton.InteractedWithEvent.Subscribe(OnBuyBarricade)
        BuyNoiseMakerButton.InteractedWithEvent.Subscribe(OnBuyNoiseMaker)
        BuyFlareButton.InteractedWithEvent.Subscribe(OnBuyFlare)
        BuyBatteryButton.InteractedWithEvent.Subscribe(OnBuyBattery)

        # Initialize player inventories
        for (Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        # Start with flashlight off
        FlashlightLight.TurnOff()
        FlareLight.TurnOff()

        # Disable all barricades initially
        for (Barrier : BarricadeSlots):
            Barrier.Disable()

        Print("SurvivalTools: Ready. {BarricadeSlots.Length} barricade slots, {HidingSpotTriggers.Length} hiding spots.")

    InitializePlayer(Player : player) : void =
        if (not PlayerTools[Player]):
            NewInventory := player_tool_inventory{}
            if (set PlayerTools[Player] = NewInventory) {}
            UpdateToolHUD(Player)

    OnPlayerAdded(Player : player) : void =
        InitializePlayer(Player)

    # ========================================================================
    # FLASHLIGHT
    # ========================================================================

    OnFlashlightToggle(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.FlashlightOn?):
                    # Turn OFF
                    set Tools.FlashlightOn = false
                    FlashlightLight.TurnOff()
                    BatteryDrainTimer.Pause()
                    FlashlightClickSound.Play()
                else:
                    # Turn ON (if battery > 0)
                    if (Tools.FlashlightBattery > 0.0):
                        set Tools.FlashlightOn = true
                        FlashlightLight.TurnOn()
                        BatteryDrainTimer.Start()
                        FlashlightClickSound.Play()
                        # Stun nearby entities in flashlight cone
                        # TODO: Call EntityAI.StunEntity() for entities in beam
                    else:
                        FlashlightClickSound.Play()  # Dead click
                UpdateToolHUD(Player)

    OnBatteryDrain(MaybeAgent : ?agent) : void =
        for (Player -> Tools : PlayerTools):
            if (Tools.FlashlightOn?):
                set Tools.FlashlightBattery -= FlashlightDrainPerTick
                if (Tools.FlashlightBattery <= 0.0):
                    set Tools.FlashlightBattery = 0.0
                    set Tools.FlashlightOn = false
                    FlashlightLight.TurnOff()
                    BatteryDrainTimer.Pause()
                    Print("SurvivalTools: Flashlight battery DEAD!")
                else if (Tools.FlashlightBattery <= LowBatteryThreshold):
                    if (not LowBatteryWarned?):
                        set LowBatteryWarned = true
                        LowBatteryWarning.Play()
                UpdateToolHUD(Player)

    # ========================================================================
    # BARRICADES
    # ========================================================================

    OnBarricadePlace(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.BarricadeCharges > 0):
                    if (NextBarricadeSlot < BarricadeSlots.Length):
                        if (Barrier := BarricadeSlots[NextBarricadeSlot]):
                            Barrier.Enable()
                            set NextBarricadeSlot += 1
                            set Tools.BarricadeCharges -= 1
                            BarricadePlaceSound.Play()
                            Print("SurvivalTools: Barricade placed! ({Tools.BarricadeCharges} remaining)")
                            UpdateToolHUD(Player)
                    else:
                        Print("SurvivalTools: No barricade slots available!")
                else:
                    Print("SurvivalTools: No barricade charges!")

    # Called by EntityAI when an entity breaks through a barricade
    BreakBarricade(SlotIndex : int) : void =
        if (Barrier := BarricadeSlots[SlotIndex]):
            Barrier.Disable()
            BarricadeBreakSound.Play()
            Print("SurvivalTools: 💥 Barricade at slot {SlotIndex} DESTROYED!")

    # ========================================================================
    # NOISE MAKER
    # ========================================================================

    OnNoiseMakerDeploy(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.NoiseMakerCharges > 0):
                    set Tools.NoiseMakerCharges -= 1
                    NoiseMakerSound.Play()
                    NoiseMakerVFX.Enable()
                    NoiseMakerDurationTimer.Start()
                    # TODO: Call EntityAI.DistractEntities(position, radius)
                    Print("SurvivalTools: Noise maker deployed! Entities distracted for {NoiseMakerDuration}s")
                    UpdateToolHUD(Player)
                else:
                    Print("SurvivalTools: No noise makers!")

    OnNoiseMakerExpired(MaybeAgent : ?agent) : void =
        NoiseMakerSound.Stop()
        NoiseMakerVFX.Disable()
        Print("SurvivalTools: Noise maker expired.")

    # ========================================================================
    # HIDING SPOTS
    # ========================================================================

    OnHidingSpotToggle(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.IsHiding?):
                    # Exit hiding
                    set Tools.IsHiding = false
                    HidingExitSound.Play()
                    # TODO: Make player visible to entities again
                    # TODO: Re-enable player movement
                    Print("SurvivalTools: Player exited hiding spot")
                else:
                    # Enter hiding
                    set Tools.IsHiding = true
                    HidingEnterSound.Play()
                    # TODO: Make player invisible to entities
                    # TODO: Restrict player movement (lock in place)
                    # NOTE: Player can still be found if entity is very close
                    Print("SurvivalTools: Player is HIDING")
                UpdateToolHUD(Player)

    # Check if a player is currently hiding (used by EntityAI)
    IsPlayerHiding(Player : player) : logic =
        if (Tools := PlayerTools[Player]):
            return Tools.IsHiding
        return false

    # ========================================================================
    # EMERGENCY FLARE
    # ========================================================================

    OnFlareDeploy(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.FlareCharges > 0):
                    set Tools.FlareCharges -= 1
                    FlareSound.Play()
                    FlareLight.TurnOn()
                    FlareVFX.Enable()
                    FlareDurationTimer.Start()

                    # Stun ALL nearby entities
                    # TODO: Call EntityAI.StunEntity() for each entity in radius
                    Print("SurvivalTools: 🔥 EMERGENCY FLARE DEPLOYED! All nearby entities stunned!")
                    UpdateToolHUD(Player)
                else:
                    Print("SurvivalTools: No flares!")

    OnFlareExpired(MaybeAgent : ?agent) : void =
        FlareLight.TurnOff()
        FlareVFX.Disable()
        Print("SurvivalTools: Flare burned out.")

    # ========================================================================
    # SHOP — Buy tools during Day phase
    # ========================================================================

    OnBuyBarricade(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.BarricadeCharges < MaxBarricades):
                    # TODO: Call Economy.TrySpend(Player, BarricadeCost)
                    set Tools.BarricadeCharges += 1
                    PurchaseSound.Play()
                    Print("SurvivalTools: Purchased barricade ({Tools.BarricadeCharges}/{MaxBarricades})")
                    UpdateToolHUD(Player)
                else:
                    Print("SurvivalTools: Max barricades reached!")

    OnBuyNoiseMaker(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.NoiseMakerCharges < MaxNoiseMakers):
                    # TODO: Call Economy.TrySpend(Player, NoiseMakerCost)
                    set Tools.NoiseMakerCharges += 1
                    PurchaseSound.Play()
                    Print("SurvivalTools: Purchased noise maker ({Tools.NoiseMakerCharges}/{MaxNoiseMakers})")
                    UpdateToolHUD(Player)

    OnBuyFlare(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                if (Tools.FlareCharges < MaxFlares):
                    # TODO: Call Economy.TrySpend(Player, FlareCost)
                    set Tools.FlareCharges += 1
                    PurchaseSound.Play()
                    Print("SurvivalTools: Purchased emergency flare ({Tools.FlareCharges}/{MaxFlares})")
                    UpdateToolHUD(Player)

    OnBuyBattery(Agent : agent) : void =
        if (Player := player[Agent]):
            if (Tools := PlayerTools[Player]):
                # Refill battery to 100%
                # TODO: Call Economy.TrySpend(Player, BatteryRefillCost)
                set Tools.FlashlightBattery = 100.0
                set LowBatteryWarned = false
                PurchaseSound.Play()
                Print("SurvivalTools: Battery refilled!")
                UpdateToolHUD(Player)

    # ========================================================================
    # HUD UPDATE
    # ========================================================================

    UpdateToolHUD(Player : player) : void =
        if (Tools := PlayerTools[Player]):
            BatteryPct := Floor[Tools.FlashlightBattery]
            FlashlightStatus := if (Tools.FlashlightOn?) then "ON" else "OFF"
            HidingStatus := if (Tools.IsHiding?) then " [HIDING]" else ""

            ToolHUD.SetText(StringToMessage(
                "🔦 {FlashlightStatus} {BatteryPct}% | 🧱 x{Tools.BarricadeCharges} | 📢 x{Tools.NoiseMakerCharges} | 🔥 x{Tools.FlareCharges}{HidingStatus}"
            ))
            ToolHUD.Show(Player)

    # ========================================================================
    # RESET — For new game / new night
    # ========================================================================

    ResetBarricades() : void =
        set NextBarricadeSlot = 0
        for (Barrier : BarricadeSlots):
            Barrier.Disable()
        Print("SurvivalTools: All barricades reset.")

    ResetAllTools() : void =
        for (Player -> Tools : PlayerTools):
            set Tools.FlashlightBattery = 100.0
            set Tools.FlashlightOn = false
            set Tools.BarricadeCharges = 0
            set Tools.NoiseMakerCharges = 0
            set Tools.FlareCharges = 0
            set Tools.IsHiding = false
            UpdateToolHUD(Player)
        ResetBarricades()
        FlashlightLight.TurnOff()
        FlareLight.TurnOff()
        Print("SurvivalTools: All tools reset.")
