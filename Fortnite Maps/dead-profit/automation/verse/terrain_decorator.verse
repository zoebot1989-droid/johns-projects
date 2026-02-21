using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeProp }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Scatters environmental detail props across zones for an abandoned feel
# These are small details that make the park feel lived-in and neglected
terrain_decorator_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # DETAIL PROP REFERENCES
    # ═══════════════════════════════════════════════════
    @editable Debris : creative_prop_asset = external {}
    @editable LeafPile : creative_prop_asset = external {}
    @editable Puddle : creative_prop_asset = external {}
    @editable Crack : creative_prop_asset = external {}
    @editable RustPatch : creative_prop_asset = external {}
    @editable Newspaper : creative_prop_asset = external {}
    @editable BrokenBottle : creative_prop_asset = external {}
    @editable OldTicket : creative_prop_asset = external {}
    @editable Cobweb : creative_prop_asset = external {}
    @editable Moss : creative_prop_asset = external {}
    @editable BrokenSign : creative_prop_asset = external {}
    @editable FallenPole : creative_prop_asset = external {}
    @editable Graffiti : creative_prop_asset = external {}
    @editable WeedClump : creative_prop_asset = external {}
    @editable Vine : creative_prop_asset = external {}

    # Scatter density — how many detail props per zone
    @editable ScatterDensity : int = 15

    # Random seed for reproducible layouts
    var Seed : int = 42

    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Decorating terrain...")

        # Scatter debris along all pathways
        ScatterAlongPath(vector3{X := 0.0, Y := 0.0, Z := 0.0}, vector3{X := 4000.0, Y := 0.0, Z := 0.0})
        ScatterAlongPath(vector3{X := 4000.0, Y := 0.0, Z := 0.0}, vector3{X := 7000.0, Y := 4000.0, Z := 0.0})
        ScatterAlongPath(vector3{X := 4000.0, Y := 0.0, Z := 0.0}, vector3{X := 8000.0, Y := 0.0, Z := 0.0})
        ScatterAlongPath(vector3{X := 4000.0, Y := 0.0, Z := 0.0}, vector3{X := 7000.0, Y := -4000.0, Z := 0.0})
        ScatterAlongPath(vector3{X := 4000.0, Y := 0.0, Z := 0.0}, vector3{X := 11000.0, Y := 0.0, Z := 0.0})
        ScatterAlongPath(vector3{X := 4000.0, Y := 0.0, Z := 0.0}, vector3{X := 4000.0, Y := -5000.0, Z := 0.0})

        # Heavy decoration in specific zones
        DecorateZone("Entrance", vector3{X := 0.0, Y := 0.0, Z := 0.0}, 2000.0)
        DecorateZone("Plaza", vector3{X := 4000.0, Y := 0.0, Z := 0.0}, 3000.0)
        DecorateZone("Kiddie", vector3{X := 7000.0, Y := 4000.0, Z := 0.0}, 2500.0)
        DecorateZone("FoodCourt", vector3{X := 8000.0, Y := 0.0, Z := 0.0}, 2000.0)
        DecorateZone("Rides", vector3{X := 7000.0, Y := -4000.0, Z := 0.0}, 3500.0)
        DecorateZone("Haunted", vector3{X := 11000.0, Y := 0.0, Z := 0.0}, 2000.0)
        DecorateZone("Water", vector3{X := 4000.0, Y := -5000.0, Z := 0.0}, 2500.0)
        DecorateZone("BossArena", vector3{X := 9000.0, Y := 0.0, Z := 0.0}, 2000.0)

        Print("Dead Profit: Terrain decoration complete!")

    # ═══════════════════════════════════════════════════
    # ZONE DECORATION — Scatter detail props in a zone
    # ═══════════════════════════════════════════════════
    DecorateZone(ZoneName : string, Center : vector3, Radius : float) : void =
        var I : int = 0
        loop:
            if (I >= ScatterDensity):
                break

            # Pseudo-random position within zone radius
            Angle := PseudoRandom() * 6.28318
            Dist := PseudoRandom() * Radius * 0.9
            PosX := Center.X + Dist * Cos(Angle)
            PosY := Center.Y + Dist * Sin(Angle)
            YawDeg := PseudoRandom() * 360.0
            Pos := vector3{X := PosX, Y := PosY, Z := Center.Z}

            # Pick prop based on zone and randomness
            PropChoice := Floor(PseudoRandom() * 8.0)
            case (PropChoice):
                0 => SpawnAt(Debris, Pos, YawDeg)
                1 => SpawnAt(LeafPile, Pos, YawDeg)
                2 => SpawnAt(WeedClump, Pos, YawDeg)
                3 => SpawnAt(Crack, Pos, 0.0)
                4 => SpawnAt(Newspaper, Pos, YawDeg)
                5 => SpawnAt(Puddle, Pos, 0.0)
                6 => SpawnAt(OldTicket, Pos, YawDeg)
                7 => SpawnAt(BrokenBottle, Pos, YawDeg)
                _ => SpawnAt(Debris, Pos, YawDeg)

            set I += 1

        # Zone-specific extras
        if (ZoneName = "Haunted"):
            # Extra cobwebs and vines
            var J : int = 0
            loop:
                if (J >= 8):
                    break
                A := PseudoRandom() * 6.28318
                D := PseudoRandom() * Radius * 0.7
                P := vector3{X := Center.X + D * Cos(A), Y := Center.Y + D * Sin(A), Z := Center.Z + 200.0}
                if (J < 4):
                    SpawnAt(Cobweb, P, PseudoRandom() * 360.0)
                else:
                    SpawnAt(Vine, P, PseudoRandom() * 360.0)
                set J += 1

        if (ZoneName = "Rides"):
            # Rust patches and broken signs
            var J : int = 0
            loop:
                if (J >= 5):
                    break
                A := PseudoRandom() * 6.28318
                D := PseudoRandom() * Radius * 0.6
                P := vector3{X := Center.X + D * Cos(A), Y := Center.Y + D * Sin(A), Z := Center.Z}
                if (J < 3):
                    SpawnAt(RustPatch, P, 0.0)
                else:
                    SpawnAt(BrokenSign, P, PseudoRandom() * 360.0)
                set J += 1

        if (ZoneName = "Plaza"):
            # Fallen poles and graffiti
            SpawnAt(FallenPole, vector3{X := Center.X + 800.0, Y := Center.Y + 400.0, Z := 0.0}, 75.0)
            SpawnAt(Graffiti, vector3{X := Center.X - 500.0, Y := Center.Y + 1000.0, Z := 150.0}, 0.0)
            SpawnAt(Graffiti, vector3{X := Center.X + 1200.0, Y := Center.Y - 800.0, Z := 150.0}, 90.0)

    # ═══════════════════════════════════════════════════
    # PATH DECORATION — Scatter litter along walkways
    # ═══════════════════════════════════════════════════
    ScatterAlongPath(Start : vector3, End : vector3) : void =
        DirX := End.X - Start.X
        DirY := End.Y - Start.Y
        Length := Sqrt(DirX * DirX + DirY * DirY)
        if (Length < 100.0):
            return
        NX := DirX / Length
        NY := DirY / Length
        # Perpendicular for offset
        PX := -NY
        PY := NX

        NumScatter := Floor(Length / 500.0)
        var I : int = 0
        loop:
            if (I >= NumScatter):
                break
            T := PseudoRandom() * Length
            Offset := (PseudoRandom() - 0.5) * 400.0  # Scatter width
            PosX := Start.X + NX * T + PX * Offset
            PosY := Start.Y + NY * T + PY * Offset
            Pos := vector3{X := PosX, Y := PosY, Z := 0.0}
            YawDeg := PseudoRandom() * 360.0

            Choice := Floor(PseudoRandom() * 5.0)
            case (Choice):
                0 => SpawnAt(LeafPile, Pos, YawDeg)
                1 => SpawnAt(Newspaper, Pos, YawDeg)
                2 => SpawnAt(OldTicket, Pos, YawDeg)
                3 => SpawnAt(WeedClump, Pos, YawDeg)
                4 => SpawnAt(Debris, Pos, YawDeg)
                _ => SpawnAt(Debris, Pos, YawDeg)
            set I += 1

    # ═══════════════════════════════════════════════════
    # UTILITY
    # ═══════════════════════════════════════════════════
    SpawnAt(Asset : creative_prop_asset, Position : vector3, YawDeg : float) : void =
        Rot := MakeRotationFromYawPitchRollDegrees(YawDeg, 0.0, 0.0)
        SpawnProp(Asset, transform{Translation := Position, Rotation := Rot})

    # Simple pseudo-random using linear congruential generator
    PseudoRandom() : float =
        set Seed = (Seed * 1103515245 + 12345) % 2147483647
        return (Seed * 1.0) / 2147483647.0

    Cos(R : float) : float = external {}
    Sin(R : float) : float = external {}
    Sqrt(V : float) : float = external {}
    Floor(V : float) : int = external {}
