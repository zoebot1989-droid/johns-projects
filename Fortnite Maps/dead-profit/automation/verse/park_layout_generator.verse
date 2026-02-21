using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeProp }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Zone definition — each zone has a center position, radius, and associated props
zone_data := struct:
    Name : string
    Center : vector3
    Radius : float
    # Rotation of the zone (yaw in degrees)
    Yaw : float = 0.0

# The main park layout generator device
# Place this device in your level, then wire up prop asset references in the Details panel.
park_layout_generator_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # PROP ASSET REFERENCES — Wire these in the UEFN Details panel
    # Place one of each prop in your level, then drag it onto these fields
    # ═══════════════════════════════════════════════════
    @editable FencePost : creative_prop_asset = external {}
    @editable FencePanel : creative_prop_asset = external {}
    @editable EntranceArch : creative_prop_asset = external {}
    @editable PathLight : creative_prop_asset = external {}
    @editable ZoneSign : creative_prop_asset = external {}
    @editable Bench : creative_prop_asset = external {}
    @editable TrashCan : creative_prop_asset = external {}
    @editable Tree : creative_prop_asset = external {}
    @editable Bush : creative_prop_asset = external {}
    @editable Lamppost : creative_prop_asset = external {}

    # ═══════════════════════════════════════════════════
    # ZONE DEFINITIONS — Edit these to match your terrain layout
    # Coordinates: X=forward, Y=right, Z=up (in centimeters)
    # ═══════════════════════════════════════════════════

    Zones : []zone_data = array:
        # Entrance — south side of map
        zone_data:
            Name := "Entrance"
            Center := vector3{X := 0.0, Y := 0.0, Z := 0.0}
            Radius := 2000.0
            Yaw := 0.0
        # Central Plaza — the hub
        zone_data:
            Name := "Central Plaza"
            Center := vector3{X := 4000.0, Y := 0.0, Z := 0.0}
            Radius := 3000.0
        # Kiddie Zone — northeast
        zone_data:
            Name := "Kiddie Zone"
            Center := vector3{X := 7000.0, Y := 4000.0, Z := 0.0}
            Radius := 2500.0
        # Food Court — east
        zone_data:
            Name := "Food Court"
            Center := vector3{X := 8000.0, Y := 0.0, Z := 0.0}
            Radius := 2000.0
        # Rides Area — northwest
        zone_data:
            Name := "Rides Area"
            Center := vector3{X := 7000.0, Y := -4000.0, Z := 0.0}
            Radius := 3500.0
        # Haunted House — far north
        zone_data:
            Name := "Haunted House"
            Center := vector3{X := 11000.0, Y := 0.0, Z := 0.0}
            Radius := 2000.0
        # Water Rides — west
        zone_data:
            Name := "Water Rides"
            Center := vector3{X := 4000.0, Y := -5000.0, Z := 0.0}
            Radius := 2500.0
        # Main Stage / Boss Arena — center-north
        zone_data:
            Name := "Boss Arena"
            Center := vector3{X := 9000.0, Y := 0.0, Z := 0.0}
            Radius := 2000.0
        # Underground Tunnels entrance
        zone_data:
            Name := "Tunnels Entrance"
            Center := vector3{X := 5000.0, Y := 2000.0, Z := -500.0}
            Radius := 1000.0

    # ═══════════════════════════════════════════════════
    # STARTUP — Spawns the full park layout
    # ═══════════════════════════════════════════════════
    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Generating park layout...")

        # Spawn perimeter fence around the entire park
        SpawnPerimeterFence()

        # Spawn entrance archway
        SpawnEntrance()

        # For each zone, spawn boundary markers and path lights
        for (Zone : Zones):
            SpawnZoneBoundary(Zone)
            SpawnPathLights(Zone)
            SpawnZoneDecor(Zone)

        Print("Dead Profit: Park layout generation complete!")

    # ═══════════════════════════════════════════════════
    # PERIMETER FENCE — Ring of fence posts around the whole park
    # ═══════════════════════════════════════════════════
    SpawnPerimeterFence() : void =
        # Fence in a large rectangle around the park
        # Corners: (-2000, -7000) to (13000, 6000)
        FenceSpacing := 500.0
        MinX := -2000.0
        MaxX := 13000.0
        MinY := -7000.0
        MaxY := 6000.0

        # South edge
        var CurrentX : float = MinX
        loop:
            if (CurrentX > MaxX):
                break
            SpawnPropAt(FencePost, vector3{X := CurrentX, Y := MinY, Z := 0.0}, 0.0)
            set CurrentX += FenceSpacing

        # North edge
        set CurrentX = MinX
        loop:
            if (CurrentX > MaxX):
                break
            SpawnPropAt(FencePost, vector3{X := CurrentX, Y := MaxY, Z := 0.0}, 0.0)
            set CurrentX += FenceSpacing

        # East edge
        var CurrentY : float = MinY
        loop:
            if (CurrentY > MaxY):
                break
            SpawnPropAt(FencePost, vector3{X := MaxX, Y := CurrentY, Z := 0.0}, 90.0)
            set CurrentY += FenceSpacing

        # West edge
        set CurrentY = MinY
        loop:
            if (CurrentY > MaxY):
                break
            SpawnPropAt(FencePost, vector3{X := MinX, Y := CurrentY, Z := 0.0}, 90.0)
            set CurrentY += FenceSpacing

    # ═══════════════════════════════════════════════════
    # ENTRANCE
    # ═══════════════════════════════════════════════════
    SpawnEntrance() : void =
        # Main entrance arch
        SpawnPropAt(EntranceArch, vector3{X := 0.0, Y := 0.0, Z := 0.0}, 0.0)
        # Flanking lampposts
        SpawnPropAt(Lamppost, vector3{X := 0.0, Y := -300.0, Z := 0.0}, 0.0)
        SpawnPropAt(Lamppost, vector3{X := 0.0, Y := 300.0, Z := 0.0}, 0.0)
        # Benches at entrance
        SpawnPropAt(Bench, vector3{X := 200.0, Y := -500.0, Z := 0.0}, 90.0)
        SpawnPropAt(Bench, vector3{X := 200.0, Y := 500.0, Z := 0.0}, -90.0)

    # ═══════════════════════════════════════════════════
    # ZONE BOUNDARY — Lamp posts around each zone perimeter
    # ═══════════════════════════════════════════════════
    SpawnZoneBoundary(Zone : zone_data) : void =
        # Place 8 lampposts in a circle around the zone
        NumPosts := 8
        var I : int = 0
        loop:
            if (I >= NumPosts):
                break
            Angle := (I * 1.0 / (NumPosts * 1.0)) * 6.28318
            PosX := Zone.Center.X + Zone.Radius * Cos(Angle)
            PosY := Zone.Center.Y + Zone.Radius * Sin(Angle)
            SpawnPropAt(Lamppost, vector3{X := PosX, Y := PosY, Z := Zone.Center.Z}, 0.0)
            set I += 1

    # ═══════════════════════════════════════════════════
    # PATH LIGHTS — Along paths leading to each zone from center
    # ═══════════════════════════════════════════════════
    SpawnPathLights(Zone : zone_data) : void =
        # Line of path lights from plaza center to zone center
        PlazaCenter := vector3{X := 4000.0, Y := 0.0, Z := 0.0}
        DirX := Zone.Center.X - PlazaCenter.X
        DirY := Zone.Center.Y - PlazaCenter.Y
        Dist := Sqrt(DirX * DirX + DirY * DirY)
        if (Dist < 100.0):
            return  # Skip if zone IS the plaza
        NormX := DirX / Dist
        NormY := DirY / Dist
        LightSpacing := 800.0
        var D : float = 0.0
        loop:
            if (D > Dist):
                break
            PosX := PlazaCenter.X + NormX * D
            PosY := PlazaCenter.Y + NormY * D
            SpawnPropAt(PathLight, vector3{X := PosX, Y := PosY, Z := 0.0}, 0.0)
            set D += LightSpacing

    # ═══════════════════════════════════════════════════
    # ZONE DECOR — Benches, trash cans, trees around each zone
    # ═══════════════════════════════════════════════════
    SpawnZoneDecor(Zone : zone_data) : void =
        # 4 benches around each zone
        SpawnPropAt(Bench, vector3{X := Zone.Center.X + 500.0, Y := Zone.Center.Y, Z := Zone.Center.Z}, 0.0)
        SpawnPropAt(Bench, vector3{X := Zone.Center.X - 500.0, Y := Zone.Center.Y, Z := Zone.Center.Z}, 180.0)
        SpawnPropAt(Bench, vector3{X := Zone.Center.X, Y := Zone.Center.Y + 500.0, Z := Zone.Center.Z}, 90.0)
        SpawnPropAt(Bench, vector3{X := Zone.Center.X, Y := Zone.Center.Y - 500.0, Z := Zone.Center.Z}, -90.0)

        # Trash cans near benches
        SpawnPropAt(TrashCan, vector3{X := Zone.Center.X + 600.0, Y := Zone.Center.Y + 100.0, Z := Zone.Center.Z}, 0.0)
        SpawnPropAt(TrashCan, vector3{X := Zone.Center.X - 600.0, Y := Zone.Center.Y - 100.0, Z := Zone.Center.Z}, 0.0)

        # Trees scattered
        SpawnPropAt(Tree, vector3{X := Zone.Center.X + Zone.Radius * 0.7, Y := Zone.Center.Y + Zone.Radius * 0.3, Z := Zone.Center.Z}, 0.0)
        SpawnPropAt(Tree, vector3{X := Zone.Center.X - Zone.Radius * 0.5, Y := Zone.Center.Y - Zone.Radius * 0.6, Z := Zone.Center.Z}, 45.0)
        SpawnPropAt(Bush, vector3{X := Zone.Center.X + Zone.Radius * 0.4, Y := Zone.Center.Y - Zone.Radius * 0.5, Z := Zone.Center.Z}, 0.0)

        # Zone sign
        SpawnPropAt(ZoneSign, vector3{X := Zone.Center.X, Y := Zone.Center.Y - Zone.Radius + 200.0, Z := Zone.Center.Z + 200.0}, 0.0)

    # ═══════════════════════════════════════════════════
    # UTILITY — Spawn a prop at a position with yaw rotation
    # ═══════════════════════════════════════════════════
    SpawnPropAt(Asset : creative_prop_asset, Position : vector3, YawDeg : float) : void =
        Rot := MakeRotationFromYawPitchRollDegrees(YawDeg, 0.0, 0.0)
        Transform := transform{Translation := Position, Rotation := Rot}
        SpawnProp(Asset, Transform)

    # Math helpers
    Cos(Radians : float) : float = external {}
    Sin(Radians : float) : float = external {}
    Sqrt(Value : float) : float = external {}
