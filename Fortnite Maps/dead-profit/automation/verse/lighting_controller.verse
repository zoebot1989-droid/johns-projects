using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Light group — a set of lights that behave together
light_group_type := enum:
    Pathway       # Warm white along paths
    Zone          # Zone-specific ambient
    Horror        # Red/flickering for night scares
    Neon          # Colorful neon signs
    Emergency     # Flashing red/blue (broken areas)
    Spotlight     # Boss arena / stage

# Controls all lights in the park with day/night cycling and horror effects
lighting_controller_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # LIGHT DEVICE REFERENCES
    # Place customizable_light_device actors in UEFN, wire them here
    # Group them by purpose for easy management
    # ═══════════════════════════════════════════════════

    # Pathway lights — warm white, line the walkways
    @editable PathwayLights : []customizable_light_device = array{}

    # Zone ambient lights — one color per zone
    @editable EntranceLights : []customizable_light_device = array{}
    @editable PlazaLights : []customizable_light_device = array{}
    @editable KiddieLights : []customizable_light_device = array{}
    @editable FoodCourtLights : []customizable_light_device = array{}
    @editable RidesLights : []customizable_light_device = array{}
    @editable HauntedLights : []customizable_light_device = array{}
    @editable WaterLights : []customizable_light_device = array{}
    @editable BossArenaLights : []customizable_light_device = array{}
    @editable TunnelLights : []customizable_light_device = array{}

    # Horror/flicker lights — only active at night
    @editable HorrorFlickerLights : []customizable_light_device = array{}

    # Neon signs — bright colored, flicker occasionally
    @editable NeonLights : []customizable_light_device = array{}

    # Emergency/broken lights — flash red
    @editable EmergencyLights : []customizable_light_device = array{}

    # Boss arena spotlights
    @editable Spotlights : []customizable_light_device = array{}

    # ═══════════════════════════════════════════════════
    # TIMING CONFIG
    # ═══════════════════════════════════════════════════
    # Day/night cycle duration in seconds
    @editable DayCycleDuration : float = 600.0  # 10 minutes
    # Fraction of cycle that is "night" (0.0-1.0)
    @editable NightFraction : float = 0.4
    # How often to update lights (seconds)
    @editable UpdateInterval : float = 1.0
    # Flicker speed for horror lights (seconds between flickers)
    @editable FlickerInterval : float = 0.3

    # Track current time state
    var IsNight : logic = false
    var CycleTimer : float = 0.0
    var BossActive : logic = false

    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Lighting controller active")

        # Start with daytime
        SetDaytimeLighting()

        # Run day/night cycle and flicker effects concurrently
        sync:
            DayNightCycleLoop()
            NeonFlickerLoop()
            HorrorFlickerLoop()

    # ═══════════════════════════════════════════════════
    # DAY/NIGHT CYCLE
    # ═══════════════════════════════════════════════════
    DayNightCycleLoop()<suspends> : void =
        DayDuration := DayCycleDuration * (1.0 - NightFraction)
        NightDuration := DayCycleDuration * NightFraction

        loop:
            # === DAYTIME ===
            Print("Dead Profit: Day begins")
            set IsNight = false
            SetDaytimeLighting()
            Sleep(DayDuration)

            # === SUNSET TRANSITION ===
            Print("Dead Profit: Sunset transition...")
            SetSunsetLighting()
            Sleep(10.0)

            # === NIGHTTIME ===
            Print("Dead Profit: Night falls...")
            set IsNight = true
            SetNighttimeLighting()
            Sleep(NightDuration - 20.0)

            # === SUNRISE TRANSITION ===
            Print("Dead Profit: Dawn approaches...")
            SetDawnLighting()
            Sleep(10.0)

    # ═══════════════════════════════════════════════════
    # LIGHTING STATES
    # ═══════════════════════════════════════════════════
    SetDaytimeLighting() : void =
        # Pathway lights: dim warm white
        for (L : PathwayLights):
            L.TurnOff()

        # Zone lights: soft, welcoming colors
        SetGroupColor(EntranceLights, true)    # Warm yellow
        SetGroupColor(PlazaLights, true)       # Soft white
        SetGroupColor(KiddieLights, true)      # Pastel
        SetGroupColor(FoodCourtLights, true)   # Warm
        SetGroupColor(RidesLights, true)       # Bright
        SetGroupColor(WaterLights, true)       # Cool blue

        # Horror elements OFF during day
        for (L : HorrorFlickerLights):
            L.TurnOff()
        for (L : EmergencyLights):
            L.TurnOff()

        # Haunted house always slightly eerie
        SetGroupColor(HauntedLights, true)
        SetGroupColor(TunnelLights, true)

        # Neon signs on (they're always on in amusement parks)
        for (L : NeonLights):
            L.TurnOn()

    SetNighttimeLighting() : void =
        # Pathway lights ON — critical for navigation
        for (L : PathwayLights):
            L.TurnOn()

        # Zone lights: darker, more sinister
        SetGroupColor(EntranceLights, true)
        SetGroupColor(PlazaLights, true)
        SetGroupColor(KiddieLights, true)
        SetGroupColor(FoodCourtLights, true)
        SetGroupColor(RidesLights, true)
        SetGroupColor(WaterLights, true)

        # Horror elements ON
        for (L : HorrorFlickerLights):
            L.TurnOn()
        for (L : EmergencyLights):
            L.TurnOn()

        # Neon brighter at night
        for (L : NeonLights):
            L.TurnOn()

    SetSunsetLighting() : void =
        # Transition — pathway lights start coming on
        for (L : PathwayLights):
            L.TurnOn()
        # Warm orange tones everywhere
        SetGroupColor(PlazaLights, true)

    SetDawnLighting() : void =
        # Horror elements start turning off
        for (L : HorrorFlickerLights):
            L.TurnOff()
        for (L : EmergencyLights):
            L.TurnOff()

    # ═══════════════════════════════════════════════════
    # FLICKER EFFECTS
    # ═══════════════════════════════════════════════════
    NeonFlickerLoop()<suspends> : void =
        # Neon signs occasionally flicker (abandoned feel)
        loop:
            Sleep(3.0 + GetRandomFloat() * 5.0)
            if (NeonLights.Length > 0):
                # Pick a random neon light to flicker
                Index := GetRandomInt(0, NeonLights.Length - 1)
                if (Light := NeonLights[Index]):
                    Light.TurnOff()
                    Sleep(0.1)
                    Light.TurnOn()
                    Sleep(0.05)
                    Light.TurnOff()
                    Sleep(0.15)
                    Light.TurnOn()

    HorrorFlickerLoop()<suspends> : void =
        # Horror lights flicker rapidly during night
        loop:
            Sleep(FlickerInterval)
            if (IsNight?):
                for (L : HorrorFlickerLights):
                    # Random chance to flicker each light
                    if (GetRandomFloat() < 0.3):
                        L.TurnOff()
                        Sleep(0.05)
                        L.TurnOn()

    # ═══════════════════════════════════════════════════
    # BOSS MODE — Activate dramatic lighting
    # ═══════════════════════════════════════════════════
    ActivateBossLighting() : void =
        set BossActive = true
        # All normal lights dim/off
        for (L : PathwayLights):
            L.TurnOff()
        # Spotlights on boss arena
        for (L : Spotlights):
            L.TurnOn()
        # Emergency red everywhere else
        for (L : EmergencyLights):
            L.TurnOn()

    DeactivateBossLighting() : void =
        set BossActive = false
        for (L : Spotlights):
            L.TurnOff()
        if (IsNight?):
            SetNighttimeLighting()
        else:
            SetDaytimeLighting()

    # ═══════════════════════════════════════════════════
    # UTILITY
    # ═══════════════════════════════════════════════════
    SetGroupColor(Lights : []customizable_light_device, TurnOn : logic) : void =
        for (L : Lights):
            if (TurnOn?):
                L.TurnOn()
            else:
                L.TurnOff()

    GetRandomFloat() : float = external {}
    GetRandomInt(Min : int, Max : int) : int = external {}
