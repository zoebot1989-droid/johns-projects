using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeProp }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# A single prop placement instruction
prop_placement := struct:
    Position : vector3
    YawDegrees : float = 0.0
    Scale : float = 1.0

# Generic prop placer — give it arrays of positions and it spawns props
# Use this for bulk decoration: rows of fences, grids of market stalls, etc.
prop_placer_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # PROP REFERENCES — Wire in UEFN Details panel
    # ═══════════════════════════════════════════════════
    @editable MetalFence : creative_prop_asset = external {}
    @editable WoodFence : creative_prop_asset = external {}
    @editable Barrel : creative_prop_asset = external {}
    @editable Crate : creative_prop_asset = external {}
    @editable FoodStall : creative_prop_asset = external {}
    @editable TicketBooth : creative_prop_asset = external {}
    @editable Dumpster : creative_prop_asset = external {}
    @editable Planter : creative_prop_asset = external {}
    @editable ParkBanner : creative_prop_asset = external {}
    @editable NeonSign : creative_prop_asset = external {}
    @editable Cone : creative_prop_asset = external {}
    @editable Barrier : creative_prop_asset = external {}
    @editable Table : creative_prop_asset = external {}
    @editable Chair : creative_prop_asset = external {}
    @editable Umbrella : creative_prop_asset = external {}
    @editable Fountain : creative_prop_asset = external {}

    # ═══════════════════════════════════════════════════
    # PLACEMENT DATA — Edit these arrays to change what spawns where
    # Each array corresponds to one prop type
    # ═══════════════════════════════════════════════════

    # Entrance ticket booths
    TicketBoothPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := -200.0, Y := -400.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := -200.0, Y := 0.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := -200.0, Y := 400.0, Z := 0.0}, YawDegrees := 0.0}

    # Central Plaza fountain
    FountainPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 4000.0, Y := 0.0, Z := 0.0}}

    # Food Court — stalls and tables
    FoodStallPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 7500.0, Y := -500.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 7500.0, Y := 0.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 7500.0, Y := 500.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 8500.0, Y := -500.0, Z := 0.0}, YawDegrees := 180.0}
        prop_placement{Position := vector3{X := 8500.0, Y := 0.0, Z := 0.0}, YawDegrees := 180.0}
        prop_placement{Position := vector3{X := 8500.0, Y := 500.0, Z := 0.0}, YawDegrees := 180.0}

    TablePlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 8000.0, Y := -600.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 8000.0, Y := -200.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 8000.0, Y := 200.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 8000.0, Y := 600.0, Z := 0.0}}

    # Scattered barrels and crates (abandoned feel)
    BarrelPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 3000.0, Y := 1500.0, Z := 0.0}, YawDegrees := 15.0}
        prop_placement{Position := vector3{X := 3100.0, Y := 1600.0, Z := 0.0}, YawDegrees := -30.0}
        prop_placement{Position := vector3{X := 6000.0, Y := -2000.0, Z := 0.0}, YawDegrees := 45.0}
        prop_placement{Position := vector3{X := 5500.0, Y := 3000.0, Z := 0.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 9500.0, Y := 1000.0, Z := 0.0}, YawDegrees := -20.0}
        prop_placement{Position := vector3{X := 10000.0, Y := -1500.0, Z := 0.0}, YawDegrees := 60.0}

    CratePlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 3200.0, Y := 1500.0, Z := 0.0}, YawDegrees := 10.0}
        prop_placement{Position := vector3{X := 6100.0, Y := -1900.0, Z := 0.0}, YawDegrees := -15.0}
        prop_placement{Position := vector3{X := 10100.0, Y := -1400.0, Z := 0.0}, YawDegrees := 30.0}

    # Dumpsters near food court and rides
    DumpsterPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 8800.0, Y := 800.0, Z := 0.0}, YawDegrees := 90.0}
        prop_placement{Position := vector3{X := 7200.0, Y := -4500.0, Z := 0.0}, YawDegrees := 0.0}

    # Neon signs (entrance, food court, rides)
    NeonSignPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 0.0, Y := 0.0, Z := 400.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 7500.0, Y := 0.0, Z := 350.0}, YawDegrees := 0.0}
        prop_placement{Position := vector3{X := 7000.0, Y := -4000.0, Z := 350.0}, YawDegrees := -45.0}

    # Barriers / cones for construction/abandoned areas
    ConePlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 5000.0, Y := -3000.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 5100.0, Y := -3000.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 5200.0, Y := -3000.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 10500.0, Y := 500.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 10600.0, Y := 500.0, Z := 0.0}}

    BarrierPlacements : []prop_placement = array:
        prop_placement{Position := vector3{X := 5000.0, Y := -3100.0, Z := 0.0}}
        prop_placement{Position := vector3{X := 10500.0, Y := 600.0, Z := 0.0}}

    # ═══════════════════════════════════════════════════
    # STARTUP
    # ═══════════════════════════════════════════════════
    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Placing props...")

        SpawnAll(TicketBooth, TicketBoothPlacements)
        SpawnAll(Fountain, FountainPlacements)
        SpawnAll(FoodStall, FoodStallPlacements)
        SpawnAll(Table, TablePlacements)
        SpawnAll(Barrel, BarrelPlacements)
        SpawnAll(Crate, CratePlacements)
        SpawnAll(Dumpster, DumpsterPlacements)
        SpawnAll(NeonSign, NeonSignPlacements)
        SpawnAll(Cone, ConePlacements)
        SpawnAll(Barrier, BarrierPlacements)

        Print("Dead Profit: Props placed!")

    # ═══════════════════════════════════════════════════
    # SPAWN HELPER
    # ═══════════════════════════════════════════════════
    SpawnAll(Asset : creative_prop_asset, Placements : []prop_placement) : void =
        for (P : Placements):
            Rot := MakeRotationFromYawPitchRollDegrees(P.YawDegrees, 0.0, 0.0)
            T := transform{Translation := P.Position, Rotation := Rot, Scale := vector3{X := P.Scale, Y := P.Scale, Z := P.Scale}}
            SpawnProp(Asset, T)
