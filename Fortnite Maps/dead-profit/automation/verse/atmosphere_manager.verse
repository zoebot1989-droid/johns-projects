using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Per-zone atmosphere configuration
zone_atmosphere := struct:
    Name : string
    Center : vector3
    Radius : float
    # Day settings
    DayFogEnabled : logic = false
    DayParticlesEnabled : logic = false
    DaySoundEnabled : logic = true
    # Night settings
    NightFogEnabled : logic = true
    NightParticlesEnabled : logic = true
    NightSoundEnabled : logic = true

# Manages fog, particles, and ambient sounds per zone based on time of day
atmosphere_manager_device := class(creative_device):

    # ═══════════════════════════════════════════════════
    # VFX DEVICE REFERENCES — Place vfx_spawner_device in each zone
    # ═══════════════════════════════════════════════════

    # Fog machines per zone
    @editable EntranceFog : []vfx_spawner_device = array{}
    @editable PlazaFog : []vfx_spawner_device = array{}
    @editable KiddieFog : []vfx_spawner_device = array{}
    @editable FoodCourtFog : []vfx_spawner_device = array{}
    @editable RidesFog : []vfx_spawner_device = array{}
    @editable HauntedFog : []vfx_spawner_device = array{}
    @editable WaterFog : []vfx_spawner_device = array{}
    @editable BossArenaFog : []vfx_spawner_device = array{}
    @editable TunnelFog : []vfx_spawner_device = array{}

    # Particle effects per zone (sparks, dust, drips, etc.)
    @editable EntranceParticles : []vfx_spawner_device = array{}
    @editable PlazaParticles : []vfx_spawner_device = array{}
    @editable HauntedParticles : []vfx_spawner_device = array{}
    @editable TunnelParticles : []vfx_spawner_device = array{}
    @editable WaterParticles : []vfx_spawner_device = array{}
    @editable RidesParticles : []vfx_spawner_device = array{}

    # Ambient sound players per zone
    @editable EntranceSounds : []audio_player_device = array{}
    @editable PlazaSounds : []audio_player_device = array{}
    @editable KiddieSounds : []audio_player_device = array{}
    @editable FoodCourtSounds : []audio_player_device = array{}
    @editable RidesSounds : []audio_player_device = array{}
    @editable HauntedSounds : []audio_player_device = array{}
    @editable WaterSounds : []audio_player_device = array{}
    @editable BossArenaSounds : []audio_player_device = array{}
    @editable TunnelSounds : []audio_player_device = array{}

    # Night-only horror sounds (screams, whispers, creaks)
    @editable NightHorrorSounds : []audio_player_device = array{}

    # Global wind/ambient
    @editable GlobalAmbientSound : []audio_player_device = array{}

    # Reference to lighting controller for day/night state
    @editable LightingController : lighting_controller_device = lighting_controller_device{}

    # Timing
    @editable AtmosphereCheckInterval : float = 5.0

    var CurrentlyNight : logic = false

    OnBegin<override>()<suspends> : void =
        Print("Dead Profit: Atmosphere manager active")

        # Start global ambient (always on)
        for (S : GlobalAmbientSound):
            S.Play()

        # Set initial daytime atmosphere
        SetDaytimeAtmosphere()

        # Monitor day/night changes
        loop:
            Sleep(AtmosphereCheckInterval)

            if (LightingController.IsNight?):
                if (not CurrentlyNight?):
                    Print("Dead Profit: Switching to night atmosphere")
                    set CurrentlyNight = true
                    SetNighttimeAtmosphere()
            else:
                if (CurrentlyNight?):
                    Print("Dead Profit: Switching to day atmosphere")
                    set CurrentlyNight = false
                    SetDaytimeAtmosphere()

    # ═══════════════════════════════════════════════════
    # DAYTIME ATMOSPHERE
    # Light fog in haunted/tunnel only, ambient park sounds
    # ═══════════════════════════════════════════════════
    SetDaytimeAtmosphere() : void =
        # Most fog OFF during day
        DisableVFXGroup(EntranceFog)
        DisableVFXGroup(PlazaFog)
        DisableVFXGroup(KiddieFog)
        DisableVFXGroup(FoodCourtFog)
        DisableVFXGroup(RidesFog)
        DisableVFXGroup(WaterFog)
        DisableVFXGroup(BossArenaFog)

        # Haunted house and tunnels always have fog
        EnableVFXGroup(HauntedFog)
        EnableVFXGroup(TunnelFog)

        # Particles: water mist, some dust
        DisableVFXGroup(EntranceParticles)
        DisableVFXGroup(PlazaParticles)
        DisableVFXGroup(HauntedParticles)
        EnableVFXGroup(WaterParticles)   # Water mist always
        DisableVFXGroup(RidesParticles)
        EnableVFXGroup(TunnelParticles)  # Dripping water always

        # Sounds: cheerful park ambience
        EnableSoundGroup(EntranceSounds)
        EnableSoundGroup(PlazaSounds)
        EnableSoundGroup(KiddieSounds)
        EnableSoundGroup(FoodCourtSounds)
        EnableSoundGroup(RidesSounds)
        EnableSoundGroup(HauntedSounds)
        EnableSoundGroup(WaterSounds)
        EnableSoundGroup(TunnelSounds)

        # No horror sounds during day
        DisableSoundGroup(NightHorrorSounds)
        DisableSoundGroup(BossArenaSounds)

    # ═══════════════════════════════════════════════════
    # NIGHTTIME ATMOSPHERE
    # Heavy fog everywhere, horror particles, creepy sounds
    # ═══════════════════════════════════════════════════
    SetNighttimeAtmosphere() : void =
        # Fog EVERYWHERE at night
        EnableVFXGroup(EntranceFog)
        EnableVFXGroup(PlazaFog)
        EnableVFXGroup(KiddieFog)
        EnableVFXGroup(FoodCourtFog)
        EnableVFXGroup(RidesFog)
        EnableVFXGroup(HauntedFog)
        EnableVFXGroup(WaterFog)
        EnableVFXGroup(BossArenaFog)
        EnableVFXGroup(TunnelFog)

        # All particles active
        EnableVFXGroup(EntranceParticles)
        EnableVFXGroup(PlazaParticles)
        EnableVFXGroup(HauntedParticles)
        EnableVFXGroup(WaterParticles)
        EnableVFXGroup(RidesParticles)
        EnableVFXGroup(TunnelParticles)

        # Night sounds replace day sounds
        EnableSoundGroup(EntranceSounds)
        EnableSoundGroup(PlazaSounds)
        EnableSoundGroup(HauntedSounds)
        EnableSoundGroup(WaterSounds)
        EnableSoundGroup(TunnelSounds)

        # Horror sounds ON
        EnableSoundGroup(NightHorrorSounds)

    # ═══════════════════════════════════════════════════
    # BOSS ATMOSPHERE — Activate for boss fights
    # ═══════════════════════════════════════════════════
    ActivateBossAtmosphere() : void =
        EnableVFXGroup(BossArenaFog)
        EnableSoundGroup(BossArenaSounds)
        # Intensify all fog
        EnableVFXGroup(PlazaFog)

    DeactivateBossAtmosphere() : void =
        DisableVFXGroup(BossArenaFog)
        DisableSoundGroup(BossArenaSounds)

    # ═══════════════════════════════════════════════════
    # UTILITY
    # ═══════════════════════════════════════════════════
    EnableVFXGroup(Devices : []vfx_spawner_device) : void =
        for (D : Devices):
            D.Enable()

    DisableVFXGroup(Devices : []vfx_spawner_device) : void =
        for (D : Devices):
            D.Disable()

    EnableSoundGroup(Devices : []audio_player_device) : void =
        for (D : Devices):
            D.Play()

    DisableSoundGroup(Devices : []audio_player_device) : void =
        for (D : Devices):
            D.Stop()
