# ============================================================================
# PICKUP & INVENTORY SYSTEM — Verse Template for UEFN
# ============================================================================
# Item collection, inventory tracking, and basic item management.
# Supports collectible items, consumables, and key items for puzzles.
#
# HOW TO USE:
#   1. Add pickup_manager_device to your project
#   2. Create pickup_item_device instances for each collectible in your map
#   3. Wire trigger_devices and VFX to the pickup items
#   4. Use the inventory API to check what players have collected
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

# Types of items that can be collected
item_type := enum:
    Collectible    # Standard pickup (coins, gems, stars)
    Consumable     # Used once then gone (health pack, ammo)
    KeyItem        # Quest/puzzle item (keys, artifacts)
    Currency       # Adds to a currency balance

# Definition of a pickup item
item_definition := struct:
    # Unique identifier for this item type (e.g., "red_key", "gold_coin")
    ItemId : string
    # Display name
    DisplayName : string
    # What kind of item this is
    Type : item_type
    # Value (currency amount, score points, etc.)
    Value : int

# Player's inventory — tracks what they've collected
player_inventory := class:
    # Map of item_id → quantity owned
    var Items : [string]int = map{}
    # Total items collected (lifetime stat)
    var TotalCollected : int = 0

# ============================================================================
# INDIVIDUAL PICKUP ITEM
# ============================================================================
# Place one of these for each collectible in your map.
# Each one represents a single pickup point.
# ============================================================================

pickup_item_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # Trigger zone — player walks in to collect
    @editable
    CollectionTrigger : trigger_device = trigger_device{}

    # VFX when item is collected (sparkle, poof, etc.)
    @editable
    CollectVFX : vfx_spawner_device = vfx_spawner_device{}

    # Sound when collected
    @editable
    CollectSound : audio_player_device = audio_player_device{}

    # The prop/visual representing this item (hidden after collection)
    @editable
    ItemProp : prop_manipulator_device = prop_manipulator_device{}

    # Timer for respawn (optional — set to 0 for no respawn)
    @editable
    RespawnTimer : timer_device = timer_device{}

    # ------------------------------------------
    # ITEM CONFIGURATION
    # ------------------------------------------

    # What item this pickup gives
    @editable
    ItemId : string = "default_item"

    @editable
    ItemDisplayName : string = "Item"

    @editable
    ItemValue : int = 1

    # Should this item respawn after being collected?
    @editable
    CanRespawn : logic = true

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var IsCollected : logic = false

    # Reference to the main pickup manager (set during registration)
    var Manager : ?pickup_manager_device = false

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        CollectionTrigger.TriggeredEvent.Subscribe(OnPlayerEnter)
        RespawnTimer.SuccessEvent.Subscribe(OnRespawn)
        Print("Pickup: '{ItemDisplayName}' ready for collection.")

    # ========================================================================
    # COLLECTION
    # ========================================================================
    OnPlayerEnter(Agent : ?agent) : void =
        if (IsCollected?):
            return  # Already collected, waiting for respawn

        if (Player := player[Agent?]):
            # Mark as collected
            set IsCollected = true

            # Visual feedback
            CollectSound.Play()
            CollectVFX.Enable()

            # Hide the item prop
            # ItemProp.Hide()  # or disable the visual

            # Notify the manager
            if (ManagerRef := Manager?):
                ManagerRef.OnItemCollected(Player, ItemId, ItemValue)

            Print("Pickup: '{ItemDisplayName}' collected!")

            # Start respawn timer if applicable
            if (CanRespawn?):
                RespawnTimer.Start()

    # ========================================================================
    # RESPAWN
    # ========================================================================
    OnRespawn(MaybeAgent : ?agent) : void =
        set IsCollected = false
        CollectVFX.Disable()
        # ItemProp.Show()  # Make the item visible again
        Print("Pickup: '{ItemDisplayName}' respawned!")

    # Force-reset this pickup
    Reset() : void =
        set IsCollected = false
        RespawnTimer.Pause()
        CollectVFX.Disable()

# ============================================================================
# PICKUP MANAGER
# ============================================================================
# Central manager that tracks all pickups and player inventories.
# Place ONE of these in your map.
# ============================================================================

pickup_manager_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED PROPERTIES
    # ------------------------------------------

    # HUD for showing inventory/collection status
    @editable
    InventoryHUD : hud_message_device = hud_message_device{}

    # Audio for "collection complete" (all items found)
    @editable
    AllCollectedSound : audio_player_device = audio_player_device{}

    # Total number of collectible items in the map (for completion tracking)
    @editable
    TotalCollectibles : int = 10

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    var PlayerInventories : [player]player_inventory = map{}

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("Pickup Manager: Initializing...")

        # Register current players
        for (Player : GetPlayspace().GetPlayers()):
            RegisterPlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        Print("Pickup Manager: Ready. Tracking {TotalCollectibles} collectibles.")

    # ========================================================================
    # PLAYER REGISTRATION
    # ========================================================================

    RegisterPlayer(Player : player) : void =
        if (not PlayerInventories[Player]):
            NewInventory := player_inventory{}
            if (set PlayerInventories[Player] = NewInventory) {}

    OnPlayerAdded(Player : player) : void =
        RegisterPlayer(Player)

    # ========================================================================
    # COLLECTION HANDLING
    # Called by individual pickup_item_device instances.
    # ========================================================================

    OnItemCollected(Player : player, ItemId : string, Value : int) : void =
        if (Inventory := PlayerInventories[Player]):
            # Add to inventory
            CurrentCount := if (Count := Inventory.Items[ItemId]) then Count else 0
            if (set Inventory.Items[ItemId] = CurrentCount + 1) {}
            set Inventory.TotalCollected += 1

            Print("Pickup Manager: Player collected '{ItemId}'. Total: {Inventory.TotalCollected}/{TotalCollectibles}")

            # Update HUD
            UpdateInventoryHUD(Player)

            # Check for completion
            if (Inventory.TotalCollected >= TotalCollectibles):
                OnAllItemsCollected(Player)

    # ========================================================================
    # INVENTORY QUERIES
    # ========================================================================

    # Check if a player has a specific item
    HasItem(Player : player, ItemId : string) : logic =
        if (Inventory := PlayerInventories[Player]):
            if (Count := Inventory.Items[ItemId]):
                if (Count > 0):
                    return true
        return false

    # Get quantity of a specific item
    GetItemCount(Player : player, ItemId : string) : int =
        if (Inventory := PlayerInventories[Player]):
            if (Count := Inventory.Items[ItemId]):
                return Count
        return 0

    # Get total items collected
    GetTotalCollected(Player : player) : int =
        if (Inventory := PlayerInventories[Player]):
            return Inventory.TotalCollected
        return 0

    # Remove an item from inventory (for consumables or key usage)
    UseItem(Player : player, ItemId : string) : logic =
        if (Inventory := PlayerInventories[Player]):
            if (Count := Inventory.Items[ItemId]):
                if (Count > 0):
                    if (set Inventory.Items[ItemId] = Count - 1) {}
                    Print("Pickup Manager: Used item '{ItemId}'. Remaining: {Count - 1}")
                    UpdateInventoryHUD(Player)
                    return true
        return false

    # ========================================================================
    # COMPLETION
    # ========================================================================

    OnAllItemsCollected(Player : player) : void =
        Print("Pickup Manager: 🎉 ALL ITEMS COLLECTED!")
        AllCollectedSound.Play()

        InventoryHUD.SetText(StringToMessage("✅ All {TotalCollectibles} items collected!"))
        InventoryHUD.Show(Player)

        # ----------------------------------------------------------
        # ADD YOUR COMPLETION LOGIC HERE
        # Examples:
        #   - Open a secret door
        #   - Grant a reward
        #   - Trigger an ending cinematic
        #   - Add bonus score
        # ----------------------------------------------------------

    # ========================================================================
    # UI
    # ========================================================================

    UpdateInventoryHUD(Player : player) : void =
        if (Inventory := PlayerInventories[Player]):
            InventoryHUD.SetText(
                StringToMessage("📦 Collected: {Inventory.TotalCollected}/{TotalCollectibles}")
            )
            InventoryHUD.Show(Player)

    # ========================================================================
    # RESET
    # ========================================================================

    ResetAllInventories() : void =
        for (Player -> Inventory : PlayerInventories):
            set Inventory.Items = map{}
            set Inventory.TotalCollected = 0
        Print("Pickup Manager: All inventories reset.")
