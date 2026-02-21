using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeProp }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Ride types
ride_type := enum:
    FerrisWheel
    Carousel
    RollerCoaster
    BumperCars
    HauntedRide
    WaterSlide
    DropTower

ride_config := struct:
    Type : ride_type
    Center : vector3
    YawDegrees : float = 0.0
    # Whether the ride is "broken" (abandoned aesthetic)
    IsBroken : logic = true

# Builds ride structures from props and adds interactive elements
ride_builder_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # PROP REFERENCES
    # ═══════════════════════════════════════════════════
    @editable MetalBeam : creative_prop_asset = external {}
    @editable MetalPlate : creative_prop_asset = external {}
    @editable RideSeat : creative_prop_asset = external {}
    @editable RideCart : creative_prop_asset = external {}
    @editable RideTrack : creative_prop_asset = external {}
    @editable WoodPlank : creative_prop_asset = external {}
    @editable RoofPanel : creative_prop_asset = external {}
    @editable RideFence : creative_prop_asset = external {}
    @editable CautionSign : creative_prop_asset = external {}
    @editable BrokenPiece : creative_prop_asset = external {}

    # DEVICE REFERENCES — for interactive rides
    @editable RideTriggers : []trigger_device = array{}
    @editable RideTeleporters : []teleporter_device = array{}

    # ═══════════════════════════════════════════════════
    # RIDE DEFINITIONS
    # ═══════════════════════════════════════════════════
    Rides : []ride_config = array:
        # Ferris Wheel in Rides Area
        ride_config:
            Type := ride_type.FerrisWheel
            Center := vector3{X := 6000.0, Y := -4000.0, Z := 0.0}
        # Carousel in Kiddie Zone
        ride_config:
            Type := ride_type.Carousel
            Center := vector3{X := 7000.0, Y := 4500.0, Z := 0.0}
        # Roller Coaster in Rides Area
        ride_config:
            Type := ride_type.RollerCoaster
            Center := vector3{X := 8000.0, Y := -4500.0, Z := 0.0}
            YawDegrees := 45.0
        # Bumper Cars in Kiddie Zone
        ride_config:
            Type := ride_type.BumperCars
            Center := vector3{X := 7500.0, Y := 3500.0, Z := 0.0}
        # Haunted Ride at Haunted House
        ride_config:
            Type := ride_type.HauntedRide
            Center := vector3{X := 11000.0, Y := 0.0, Z := 0.0}
        # Water Slide in Water Rides
        ride_config:
            Type := ride_type.WaterSlide
            Center := vector3{X := 4000.0, Y := -5000.0, Z := 0.0}
        # Drop Tower in Rides Area
        ride_config:
            Type := ride_type.DropTower
            Center := vector3{X := 7000.0, Y := -5500.0, Z := 0.0}

    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Building rides...")
        for (Ride : Rides):
            BuildRide(Ride)
        Print("Dead Profit: Rides built!")

    BuildRide(Ride : ride_config) : void =
        case (Ride.Type):
            ride_type.FerrisWheel => BuildFerrisWheel(Ride)
            ride_type.Carousel => BuildCarousel(Ride)
            ride_type.RollerCoaster => BuildCoasterStation(Ride)
            ride_type.BumperCars => BuildBumperCarsArena(Ride)
            ride_type.HauntedRide => BuildHauntedRide(Ride)
            ride_type.WaterSlide => BuildWaterSlide(Ride)
            ride_type.DropTower => BuildDropTower(Ride)

    # ═══════════════════════════════════════════════════
    # FERRIS WHEEL — Central tower + surrounding seats
    # ═══════════════════════════════════════════════════
    BuildFerrisWheel(Ride : ride_config) : void =
        C := Ride.Center
        # Central support column
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 500.0}, 0.0)
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 1000.0}, 0.0)
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 1500.0}, 0.0)
        # Seats in a circle at mid-height
        NumSeats := 8
        Radius := 800.0
        var I : int = 0
        loop:
            if (I >= NumSeats):
                break
            Angle := (I * 1.0 / (NumSeats * 1.0)) * 6.28318
            SX := C.X + Radius * Cos(Angle)
            SY := C.Y + Radius * Sin(Angle)
            SpawnAt(RideSeat, vector3{X := SX, Y := SY, Z := 800.0}, Angle * 57.2958)
            set I += 1
        # Fencing around base
        SpawnRideFencing(C, 1200.0)
        # Broken pieces if abandoned
        if (Ride.IsBroken?):
            SpawnAt(BrokenPiece, vector3{X := C.X + 300.0, Y := C.Y + 200.0, Z := 0.0}, 25.0)
            SpawnAt(CautionSign, vector3{X := C.X, Y := C.Y - 1200.0, Z := 0.0}, 0.0)

    # ═══════════════════════════════════════════════════
    # CAROUSEL — Circular platform with seats
    # ═══════════════════════════════════════════════════
    BuildCarousel(Ride : ride_config) : void =
        C := Ride.Center
        # Platform
        SpawnAt(MetalPlate, vector3{X := C.X, Y := C.Y, Z := 50.0}, 0.0)
        # Center pole
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(RoofPanel, vector3{X := C.X, Y := C.Y, Z := 500.0}, 0.0)
        # Seats
        NumSeats := 6
        Radius := 400.0
        var I : int = 0
        loop:
            if (I >= NumSeats):
                break
            Angle := (I * 1.0 / (NumSeats * 1.0)) * 6.28318
            SX := C.X + Radius * Cos(Angle)
            SY := C.Y + Radius * Sin(Angle)
            SpawnAt(RideSeat, vector3{X := SX, Y := SY, Z := 80.0}, Angle * 57.2958)
            set I += 1
        SpawnRideFencing(C, 600.0)
        if (Ride.IsBroken?):
            SpawnAt(BrokenPiece, vector3{X := C.X - 200.0, Y := C.Y + 100.0, Z := 0.0}, -15.0)

    # ═══════════════════════════════════════════════════
    # ROLLER COASTER STATION
    # ═══════════════════════════════════════════════════
    BuildCoasterStation(Ride : ride_config) : void =
        C := Ride.Center
        # Station platform
        SpawnAt(MetalPlate, vector3{X := C.X, Y := C.Y, Z := 100.0}, Ride.YawDegrees)
        SpawnAt(RoofPanel, vector3{X := C.X, Y := C.Y, Z := 400.0}, Ride.YawDegrees)
        # Track pieces leading out
        var T : float = 0.0
        loop:
            if (T > 2000.0):
                break
            SpawnAt(RideTrack, vector3{X := C.X + T, Y := C.Y, Z := 100.0}, Ride.YawDegrees)
            set T += 300.0
        # Cart at station
        SpawnAt(RideCart, vector3{X := C.X, Y := C.Y, Z := 120.0}, Ride.YawDegrees)
        SpawnRideFencing(C, 800.0)
        if (Ride.IsBroken?):
            SpawnAt(CautionSign, vector3{X := C.X - 200.0, Y := C.Y - 800.0, Z := 0.0}, 0.0)
            SpawnAt(BrokenPiece, vector3{X := C.X + 1500.0, Y := C.Y + 100.0, Z := 50.0}, 40.0)

    # ═══════════════════════════════════════════════════
    # BUMPER CARS ARENA
    # ═══════════════════════════════════════════════════
    BuildBumperCarsArena(Ride : ride_config) : void =
        C := Ride.Center
        # Floor
        SpawnAt(MetalPlate, vector3{X := C.X, Y := C.Y, Z := 10.0}, 0.0)
        # Scattered carts
        SpawnAt(RideCart, vector3{X := C.X + 200.0, Y := C.Y + 100.0, Z := 20.0}, 30.0)
        SpawnAt(RideCart, vector3{X := C.X - 150.0, Y := C.Y - 200.0, Z := 20.0}, -60.0)
        SpawnAt(RideCart, vector3{X := C.X + 50.0, Y := C.Y - 300.0, Z := 20.0}, 120.0)
        SpawnAt(RideCart, vector3{X := C.X - 300.0, Y := C.Y + 150.0, Z := 20.0}, -10.0)
        SpawnRideFencing(C, 600.0)

    # ═══════════════════════════════════════════════════
    # HAUNTED RIDE — Track through the haunted house
    # ═══════════════════════════════════════════════════
    BuildHauntedRide(Ride : ride_config) : void =
        C := Ride.Center
        # Entrance structure
        SpawnAt(WoodPlank, vector3{X := C.X - 500.0, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(WoodPlank, vector3{X := C.X - 500.0, Y := C.Y, Z := 300.0}, 0.0)
        SpawnAt(RoofPanel, vector3{X := C.X - 500.0, Y := C.Y, Z := 500.0}, 0.0)
        # Track winding through
        SpawnAt(RideTrack, vector3{X := C.X - 400.0, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(RideTrack, vector3{X := C.X - 100.0, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(RideTrack, vector3{X := C.X + 200.0, Y := C.Y + 100.0, Z := 0.0}, 30.0)
        SpawnAt(RideTrack, vector3{X := C.X + 400.0, Y := C.Y + 300.0, Z := 0.0}, 45.0)
        SpawnAt(RideTrack, vector3{X := C.X + 400.0, Y := C.Y + 600.0, Z := 0.0}, 90.0)
        # Cart
        SpawnAt(RideCart, vector3{X := C.X - 400.0, Y := C.Y, Z := 20.0}, 0.0)
        SpawnRideFencing(C, 1000.0)

    # ═══════════════════════════════════════════════════
    # WATER SLIDE
    # ═══════════════════════════════════════════════════
    BuildWaterSlide(Ride : ride_config) : void =
        C := Ride.Center
        # Tower
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 0.0}, 0.0)
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 500.0}, 0.0)
        SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := 1000.0}, 0.0)
        SpawnAt(MetalPlate, vector3{X := C.X, Y := C.Y, Z := 1100.0}, 0.0)
        # Slide pieces going down
        var H : float = 1000.0
        var D : float = 0.0
        loop:
            if (H < 0.0):
                break
            SpawnAt(MetalPlate, vector3{X := C.X + D, Y := C.Y, Z := H}, 0.0)
            set H -= 150.0
            set D += 200.0
        # Pool at bottom
        SpawnAt(MetalPlate, vector3{X := C.X + D, Y := C.Y, Z := 0.0}, 0.0)
        SpawnRideFencing(C, 1500.0)

    # ═══════════════════════════════════════════════════
    # DROP TOWER
    # ═══════════════════════════════════════════════════
    BuildDropTower(Ride : ride_config) : void =
        C := Ride.Center
        # Tower structure
        var H : float = 0.0
        loop:
            if (H > 2000.0):
                break
            SpawnAt(MetalBeam, vector3{X := C.X, Y := C.Y, Z := H}, 0.0)
            set H += 400.0
        # Seat ring at top
        SpawnAt(RideSeat, vector3{X := C.X, Y := C.Y, Z := 1800.0}, 0.0)
        SpawnRideFencing(C, 800.0)
        if (Ride.IsBroken?):
            SpawnAt(CautionSign, vector3{X := C.X, Y := C.Y - 800.0, Z := 0.0}, 0.0)

    # ═══════════════════════════════════════════════════
    # UTILITY
    # ═══════════════════════════════════════════════════
    SpawnRideFencing(Center : vector3, Radius : float) : void =
        NumPosts := 12
        var I : int = 0
        loop:
            if (I >= NumPosts):
                break
            Angle := (I * 1.0 / (NumPosts * 1.0)) * 6.28318
            FX := Center.X + Radius * Cos(Angle)
            FY := Center.Y + Radius * Sin(Angle)
            SpawnAt(RideFence, vector3{X := FX, Y := FY, Z := Center.Z}, Angle * 57.2958)
            set I += 1

    SpawnAt(Asset : creative_prop_asset, Position : vector3, YawDeg : float) : void =
        Rot := MakeRotationFromYawPitchRollDegrees(YawDeg, 0.0, 0.0)
        SpawnProp(Asset, transform{Translation := Position, Rotation := Rot})

    Cos(Radians : float) : float = external {}
    Sin(Radians : float) : float = external {}
