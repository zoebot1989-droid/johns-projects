# ============================================================================
# ENTITY AI — DEAD PROFIT
# ============================================================================
# Horror entities that spawn during the Night phase. Each entity type has
# unique behavior: patrol patterns, chase mechanics, vision detection,
# and special abilities.
#
# ENTITY TYPES (from game design doc):
#   1. Wanderer    — Slow patrol, destroys attractions on contact
#   2. Mimic       — Disguises as park objects, ambushes nearby players
#   3. Conductor   — Possesses rides, turning them into death traps
#   4. Hollow Kid  — Fast, appears in groups, terrifying audio
#   5. The Owner   — Night 5 boss, teleports, corrupts areas
#
# IMPLEMENTATION:
#   Uses guard_spawner_device + creature_spawner_device for entity spawning.
#   AI behavior is driven by timer ticks and distance checks.
#   Vision cone detection uses dot-product angle checks.
#
# INTEGRATION:
#   - DayNightCycle: Entities only active during Night phase
#   - ParkManager: Entities can damage/destroy attractions
#   - Progression: Entity count/types scale with night number
#   - SurvivalTools: Flashlight stuns, flares distract, barricades block
# ============================================================================

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# ============================================================================
# ENTITY TYPE ENUM
# ============================================================================
entity_type := enum:
    Wanderer        # Slow, patrols, damages attractions
    Mimic           # Disguised, ambushes players
    Conductor       # Possesses rides
    HollowKid       # Fast, group spawns
    TheOwner        # Night 5 boss

# ============================================================================
# ENTITY BEHAVIOR STATE
# ============================================================================
entity_behavior := enum:
    Idle            # Waiting / just spawned
    Patrolling      # Walking a patrol route
    Chasing         # Detected player, pursuing
    Attacking       # In attack range, dealing damage
    Hiding          # Mimic: disguised as an object
    Possessing      # Conductor: controlling a ride
    Teleporting     # The Owner: mid-teleport
    Stunned         # Hit by flashlight or flare
    Despawning      # Being removed (dawn)

# ============================================================================
# ENTITY CONFIG — Per-type configuration
# ============================================================================
entity_config := struct:
    Type : entity_type
    # Movement speed (units per second)
    MoveSpeed : float
    # Detection radius (how far it can "see")
    DetectionRadius : float
    # Vision cone half-angle in degrees (180 = sees everything)
    VisionAngleDegrees : float
    # Damage dealt to players on hit
    PlayerDamage : int
    # Damage dealt to attractions on contact
    AttractionDamage : int
    # How long the entity stays stunned by flashlight (seconds)
    StunDuration : float
    # Health points (0 = unkillable, must be driven away)
    Health : int
    # Points awarded for eliminating/driving away
    ScoreValue : int

# ============================================================================
# ENTITY AI MANAGER DEVICE
# ============================================================================
entity_ai_device := class(creative_device):

    # ------------------------------------------
    # EDITOR-EXPOSED: SPAWNERS
    # Place these at entity spawn points around the map.
    # ------------------------------------------

    # Wanderer spawn points (Haunted House area, perimeter)
    @editable
    WandererSpawners : []guard_spawner_device = array{}

    # Mimic spawn points (scattered throughout park)
    @editable
    MimicSpawners : []guard_spawner_device = array{}

    # Conductor spawn point (near ride areas)
    @editable
    ConductorSpawners : []guard_spawner_device = array{}

    # Hollow Kid spawn points (perimeter fence breach points)
    @editable
    HollowKidSpawners : []guard_spawner_device = array{}

    # The Owner spawn point (Central Plaza / Main Stage)
    @editable
    OwnerSpawner : guard_spawner_device = guard_spawner_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: PATROL WAYPOINTS
    # Prop manipulators placed at patrol route positions.
    # Entities move between these points when patrolling.
    # ------------------------------------------

    # Waypoints for Wanderer patrol routes
    @editable
    WandererWaypoints : []prop_manipulator_device = array{}

    # Waypoints for Hollow Kid rush routes
    @editable
    HollowKidWaypoints : []prop_manipulator_device = array{}

    # Teleport destinations for The Owner
    @editable
    OwnerTeleportPoints : []teleporter_device = array{}

    # ------------------------------------------
    # EDITOR-EXPOSED: DETECTION & COMBAT
    # ------------------------------------------

    # Timer for AI behavior ticks (every 0.5 - 1.0 seconds)
    @editable
    AITickTimer : timer_device = timer_device{}

    # Trigger zones around entity spawn areas (detect player proximity)
    @editable
    DetectionTriggers : []trigger_device = array{}

    # Damage dealing devices (placed on entities or at attack range)
    @editable
    DamageDevices : []damage_volume_device = array{}

    # ------------------------------------------
    # EDITOR-EXPOSED: AUDIO
    # ------------------------------------------

    # Wanderer: slow footsteps, groaning
    @editable
    WandererAudio : audio_player_device = audio_player_device{}

    # Mimic: sudden scare sting when it reveals
    @editable
    MimicRevealAudio : audio_player_device = audio_player_device{}

    # Conductor: machinery grinding, electrical sparks
    @editable
    ConductorAudio : audio_player_device = audio_player_device{}

    # Hollow Kids: children's laughter, running footsteps
    @editable
    HollowKidAudio : audio_player_device = audio_player_device{}

    # The Owner: deep rumble, distorted carnival music
    @editable
    OwnerAudio : audio_player_device = audio_player_device{}

    # Generic entity proximity warning (heartbeat gets faster)
    @editable
    ProximityHeartbeat : audio_player_device = audio_player_device{}

    # Stun sound effect
    @editable
    StunSound : audio_player_device = audio_player_device{}

    # ------------------------------------------
    # EDITOR-EXPOSED: VFX
    # ------------------------------------------

    # VFX for entity stun (bright flash)
    @editable
    StunVFX : vfx_spawner_device = vfx_spawner_device{}

    # VFX for The Owner's corruption effect
    @editable
    CorruptionVFX : vfx_spawner_device = vfx_spawner_device{}

    # VFX for Mimic reveal (smoke/particle burst)
    @editable
    MimicRevealVFX : vfx_spawner_device = vfx_spawner_device{}

    # ------------------------------------------
    # CONFIGURATION — Entity type stats
    # ------------------------------------------

    EntityConfigs : []entity_config = array:
        # Wanderer: slow, steady, destroys attractions
        entity_config:
            Type := entity_type.Wanderer
            MoveSpeed := 150.0
            DetectionRadius := 800.0
            VisionAngleDegrees := 120.0
            PlayerDamage := 20
            AttractionDamage := 25
            StunDuration := 3.0
            Health := 100
            ScoreValue := 10

        # Mimic: stationary until triggered, then fast burst
        entity_config:
            Type := entity_type.Mimic
            MoveSpeed := 400.0
            DetectionRadius := 400.0
            VisionAngleDegrees := 360.0     # Detects in all directions (proximity-based)
            PlayerDamage := 35
            AttractionDamage := 0           # Mimics target players, not attractions
            StunDuration := 2.0
            Health := 60
            ScoreValue := 15

        # Conductor: medium speed, possesses rides
        entity_config:
            Type := entity_type.Conductor
            MoveSpeed := 200.0
            DetectionRadius := 600.0
            VisionAngleDegrees := 90.0
            PlayerDamage := 15
            AttractionDamage := 40          # Heavy attraction damage (possessing rides)
            StunDuration := 4.0
            Health := 120
            ScoreValue := 20

        # Hollow Kid: very fast, low health, group spawns
        entity_config:
            Type := entity_type.HollowKid
            MoveSpeed := 500.0
            DetectionRadius := 1000.0
            VisionAngleDegrees := 180.0
            PlayerDamage := 15
            AttractionDamage := 10
            StunDuration := 1.5
            Health := 40
            ScoreValue := 5

        # The Owner (Boss): teleports, corrupts, unkillable (driven back)
        entity_config:
            Type := entity_type.TheOwner
            MoveSpeed := 250.0
            DetectionRadius := 1500.0
            VisionAngleDegrees := 360.0     # Always knows where you are
            PlayerDamage := 50
            AttractionDamage := 60
            StunDuration := 5.0
            Health := 0                     # Cannot be killed, only driven back
            ScoreValue := 100

    # ------------------------------------------
    # INTERNAL STATE
    # ------------------------------------------

    # Are entities currently active? (Only true during Night phase)
    var EntitiesActive : logic = false

    # Current night number (affects spawn counts)
    var CurrentNight : int = 1

    # How many entities of each type are currently spawned
    var ActiveWanderers : int = 0
    var ActiveMimics : int = 0
    var ActiveConductors : int = 0
    var ActiveHollowKids : int = 0
    var OwnerActive : logic = false

    # Total entities eliminated this night (for score)
    var EntitiesEliminated : int = 0

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    OnBegin<override>()<suspends> : void =
        Print("EntityAI: Initializing DEAD PROFIT entity system...")

        # Subscribe to AI tick timer
        AITickTimer.SuccessEvent.Subscribe(OnAITick)

        # Subscribe to detection triggers
        for (Trigger : DetectionTriggers):
            Trigger.TriggeredEvent.Subscribe(OnPlayerDetected)

        # Disable all spawners initially
        DisableAllSpawners()

        Print("EntityAI: Ready. Entities dormant until Night phase.")

    # ========================================================================
    # ACTIVATION — Called by DayNightCycle
    # ========================================================================

    # Activate entities for the night. Called when Night phase starts.
    ActivateEntities(NightNumber : int) : void =
        set CurrentNight = NightNumber
        set EntitiesActive = true
        set EntitiesEliminated = 0
        Print("EntityAI: 👹 Entities ACTIVATING for Night {NightNumber}!")

        # Determine what spawns based on night number
        SpawnEntitiesForNight(NightNumber)

        # Start AI processing
        AITickTimer.Start()

    # Deactivate all entities. Called when Dawn phase starts.
    DeactivateEntities() : void =
        set EntitiesActive = false
        Print("EntityAI: Entities DEACTIVATING (Dawn)")

        # Disable all spawners
        DisableAllSpawners()

        # Stop AI processing
        AITickTimer.Pause()

        # Reset counts
        set ActiveWanderers = 0
        set ActiveMimics = 0
        set ActiveConductors = 0
        set ActiveHollowKids = 0
        set OwnerActive = false

        Print("EntityAI: All entities despawned. Eliminated this night: {EntitiesEliminated}")

    # ========================================================================
    # SPAWN LOGIC — Scales with night number
    # ========================================================================

    SpawnEntitiesForNight(Night : int) : void =
        Print("EntityAI: Spawning entities for Night {Night}...")

        # Night 1: Wanderers only (tutorial)
        if (Night >= 1):
            SpawnWanderers(2 + Night)    # Night 1: 3, Night 2: 4, etc.

        # Night 2: + Mimics
        if (Night >= 2):
            SpawnMimics(Night)           # Night 2: 2, Night 3: 3, etc.

        # Night 3: + Conductor
        if (Night >= 3):
            SpawnConductors(1)           # 1 Conductor from Night 3+

        # Night 4: + Hollow Kids
        if (Night >= 4):
            SpawnHollowKids(Night * 2)   # Night 4: 8, Night 5: 10

        # Night 5: THE OWNER (boss)
        if (Night >= 5):
            SpawnTheOwner()

    # --- Spawn helpers ---

    SpawnWanderers(Count : int) : void =
        var Spawned : int = 0
        for (Spawner : WandererSpawners):
            if (Spawned >= Count):
                break
            Spawner.Enable()
            set Spawned += 1
        set ActiveWanderers = Spawned
        WandererAudio.Play()
        Print("EntityAI: Spawned {Spawned} Wanderers")

    SpawnMimics(Count : int) : void =
        var Spawned : int = 0
        for (Spawner : MimicSpawners):
            if (Spawned >= Count):
                break
            Spawner.Enable()
            set Spawned += 1
        set ActiveMimics = Spawned
        Print("EntityAI: Spawned {Spawned} Mimics (disguised)")

    SpawnConductors(Count : int) : void =
        var Spawned : int = 0
        for (Spawner : ConductorSpawners):
            if (Spawned >= Count):
                break
            Spawner.Enable()
            set Spawned += 1
        set ActiveConductors = Spawned
        ConductorAudio.Play()
        Print("EntityAI: Spawned {Spawned} Conductors")

    SpawnHollowKids(Count : int) : void =
        var Spawned : int = 0
        for (Spawner : HollowKidSpawners):
            if (Spawned >= Count):
                break
            Spawner.Enable()
            set Spawned += 1
        set ActiveHollowKids = Spawned
        HollowKidAudio.Play()
        Print("EntityAI: Spawned {Spawned} Hollow Kids")

    SpawnTheOwner() : void =
        set OwnerActive = true
        OwnerSpawner.Enable()
        OwnerAudio.Play()
        CorruptionVFX.Enable()
        Print("EntityAI: 💀 THE OWNER HAS ARRIVED")

    DisableAllSpawners() : void =
        for (S : WandererSpawners): S.Disable()
        for (S : MimicSpawners): S.Disable()
        for (S : ConductorSpawners): S.Disable()
        for (S : HollowKidSpawners): S.Disable()
        OwnerSpawner.Disable()
        CorruptionVFX.Disable()

    # ========================================================================
    # AI BEHAVIOR TICK
    # Called every ~0.5-1.0 seconds by AITickTimer.
    # This drives entity behavior: patrol movement, player detection,
    # chase logic, and attack triggers.
    # ========================================================================

    OnAITick(MaybeAgent : ?agent) : void =
        if (not EntitiesActive?):
            return

        # Process each entity type's behavior
        ProcessWandererBehavior()
        ProcessMimicBehavior()
        ProcessConductorBehavior()
        ProcessHollowKidBehavior()
        if (OwnerActive?):
            ProcessOwnerBehavior()

    # --- WANDERER BEHAVIOR ---
    # Slow patrol between waypoints. If player is nearby, move toward them.
    # On contact with attraction, deal damage.
    ProcessWandererBehavior() : void =
        # Wanderer AI is primarily handled by the guard_spawner_device's
        # built-in patrol behavior in UEFN. We supplement with:
        # - Periodic attraction damage checks
        # - Player proximity alerts
        if (ActiveWanderers > 0):
            # The guard AI handles movement. We handle game-specific logic
            # like attraction damage through trigger volumes placed near rides.
            pass

    # --- MIMIC BEHAVIOR ---
    # Stay hidden (disguised as park prop). When player enters detection range,
    # reveal and rush toward them.
    ProcessMimicBehavior() : void =
        if (ActiveMimics > 0):
            # Mimic reveal is handled by DetectionTriggers
            # When a player triggers proximity, the mimic "reveals"
            pass

    # --- CONDUCTOR BEHAVIOR ---
    # Move toward the nearest active ride. "Possess" it, making it
    # a death trap that damages nearby players.
    ProcessConductorBehavior() : void =
        if (ActiveConductors > 0):
            # Conductor AI: The guard moves toward ride areas.
            # When it reaches a ride, we trigger the "possessed" state
            # which activates damage volumes around that ride.
            pass

    # --- HOLLOW KID BEHAVIOR ---
    # Fast movement in groups. Rush toward players along set paths.
    ProcessHollowKidBehavior() : void =
        if (ActiveHollowKids > 0):
            # Hollow Kids use aggressive chase AI from guard_spawner.
            # Their speed and group behavior make them scary.
            pass

    # --- THE OWNER BEHAVIOR ---
    # Teleports between points. Corrupts areas (damages all attractions nearby).
    # Cannot be killed, only stunned temporarily.
    ProcessOwnerBehavior() : void =
        # The Owner periodically teleports to a random point
        # and corrupts the surrounding area
        spawn { OwnerTeleportSequence() }

    OwnerTeleportSequence()<suspends> : void =
        if (OwnerActive? and OwnerTeleportPoints.Length > 0):
            # Pick a random teleport destination
            RandomIndex := GetRandomInt(0, OwnerTeleportPoints.Length - 1)
            if (TeleportPoint := OwnerTeleportPoints[RandomIndex]):
                CorruptionVFX.Enable()
                OwnerAudio.Play()
                # The Owner appears at the teleport point
                # Damage all attractions in the area
                # TODO: Call ParkManager.DamageRandomAttraction(60)
                Print("EntityAI: The Owner teleported and corrupted an area!")

            # Wait before next teleport (8-15 seconds)
            Sleep(10.0)

    # ========================================================================
    # PLAYER DETECTION
    # ========================================================================

    OnPlayerDetected(Agent : ?agent) : void =
        if (EntitiesActive?):
            # A player entered an entity's detection zone
            # Trigger proximity warning
            ProximityHeartbeat.Play()
            Print("EntityAI: Player detected in entity zone!")

    # Vision cone check: Is a target within the entity's field of view?
    # Uses dot product of forward vector and direction to target.
    IsInVisionCone(EntityForward : vector3, EntityPosition : vector3,
                   TargetPosition : vector3, ConeAngleDegrees : float) : logic =
        # Direction from entity to target
        DirectionToTarget := TargetPosition - EntityPosition

        # Normalize (simplified — in real Verse, use vector math library)
        # Dot product gives cosine of angle between vectors
        # If cos(angle) > cos(coneHalfAngle), target is in cone

        # For UEFN, distance-based detection via trigger_devices is more
        # practical than manual vector math. This is the conceptual algorithm.
        return false  # Placeholder — actual detection uses trigger_devices

    # ========================================================================
    # STUN / INTERACTION — Called by SurvivalTools
    # ========================================================================

    # Stun an entity (called when hit by flashlight beam or flare)
    StunEntity(EntityTypeToStun : entity_type) : void =
        StunSound.Play()
        StunVFX.Enable()
        Print("EntityAI: Entity stunned!")

        # Find the config for stun duration
        for (Config : EntityConfigs):
            if (Config.Type = EntityTypeToStun):
                spawn { StunDuration(Config.StunDuration) }
                break

    StunDuration(Duration : float)<suspends> : void =
        Sleep(Duration)
        StunVFX.Disable()
        Print("EntityAI: Entity recovered from stun.")

    # Distract entities toward a position (noise maker / flare)
    DistractEntities(Position : vector3, Radius : float) : void =
        # All entities within radius are attracted to the noise source
        # instead of chasing players. Implemented through guard_spawner
        # patrol point reassignment.
        Print("EntityAI: Distraction deployed! Entities redirected.")

    # ========================================================================
    # ENTITY ELIMINATION
    # ========================================================================

    OnEntityEliminated(Type : entity_type) : void =
        set EntitiesEliminated += 1

        # Update active counts
        if (Type = entity_type.Wanderer):
            set ActiveWanderers -= 1
        else if (Type = entity_type.Mimic):
            set ActiveMimics -= 1
        else if (Type = entity_type.HollowKid):
            set ActiveHollowKids -= 1

        # Find score value
        for (Config : EntityConfigs):
            if (Config.Type = Type):
                # TODO: Call Economy.AddTickets(Player, Config.ScoreValue)
                Print("EntityAI: Entity eliminated! +{Config.ScoreValue} points")
                break

    # ========================================================================
    # PUBLIC GETTERS
    # ========================================================================

    GetTotalActiveEntities() : int =
        var Total : int = ActiveWanderers + ActiveMimics + ActiveConductors + ActiveHollowKids
        if (OwnerActive?):
            set Total += 1
        return Total

    GetEntitiesEliminated() : int = EntitiesEliminated
    IsOwnerActive() : logic = OwnerActive

    # ========================================================================
    # MIMIC REVEAL — Special behavior
    # When a player gets too close to a disguised Mimic, it reveals and attacks
    # ========================================================================

    RevealMimic(MimicIndex : int) : void =
        MimicRevealAudio.Play()
        MimicRevealVFX.Enable()
        Print("EntityAI: 😱 MIMIC REVEALED! It was disguised as a park object!")
        # The mimic's guard_spawner switches to aggressive chase mode
        spawn { HideMimicVFX() }

    HideMimicVFX()<suspends> : void =
        Sleep(1.0)
        MimicRevealVFX.Disable()
