"use client";
import { motion } from "framer-motion";
import SectionTitle from "@/components/SectionTitle";

const entities = [
  {
    name: "Wanderers",
    icon: "🧟",
    type: "Common",
    danger: 2,
    color: "#b7410e",
    behavior: "Slow-moving patrol entities that shamble through the park in predictable routes. They don't chase players — they destroy attractions. Left unchecked, they'll dismantle your entire park by morning. They're drawn to the most profitable rides first.",
    tips: [
      "Prioritize elimination early — they compound damage over time",
      "Nail gun is most efficient; 3 shots to take down",
      "They ignore players unless directly attacked",
      "Listen for their dragging footsteps to track location",
    ],
  },
  {
    name: "Mimics",
    icon: "🎭",
    type: "Ambush",
    danger: 3,
    color: "#ffd700",
    behavior: "The shapeshifters of Malmouth Funland. Mimics disguise themselves as park objects — benches, trash cans, ticket booths, even ride parts. They remain perfectly still until a player gets within 3 meters, then explode into a frenzy of teeth and claws. Extremely hard to spot in the chaos of a functioning park.",
    tips: [
      "Flashlight reveals a faint shimmer on disguised Mimics",
      "Objects that weren't there during the day phase are suspects",
      "Fire extinguisher stuns them for 5 seconds",
      "Travel in pairs — one watches while the other interacts",
      "They can't mimic objects that are currently being used by visitors",
    ],
  },
  {
    name: "The Conductor",
    icon: "🎩",
    type: "Elite",
    danger: 4,
    color: "#9b59b6",
    behavior: "A spectral figure in a tattered ringmaster's outfit. The Conductor doesn't attack directly — instead, it possesses your rides and turns them into deathtraps. A possessed ride damages players who get close and stops generating Tickets. The Conductor teleports between rides, making it incredibly hard to pin down.",
    tips: [
      "Flare launcher forces it out of a possessed ride",
      "Look for rides that spark with purple electricity — that's possession",
      "It can only possess one ride at a time",
      "Destroying the ride it's in deals massive damage to it",
      "It prioritizes your highest-earning attractions",
    ],
  },
  {
    name: "Hollow Kids",
    icon: "👧",
    type: "Swarm",
    danger: 4,
    color: "#39ff14",
    behavior: "The most terrifying entities in the park. Small, fast, and they travel in groups of 3-5. Their audio design is nightmare fuel — distorted laughter, crying, carnival music played backwards. They rush players in coordinated attacks and can climb structures. One alone is manageable. A pack is a death sentence.",
    tips: [
      "Fire extinguisher is your best friend — AoE crowd control",
      "They're weak individually but deadly in numbers",
      "Bright areas slow them down — keep the lights on",
      "Their laughter audio cue gives you ~4 seconds warning",
      "They can't open doors — use buildings as choke points",
      "Never run in a straight line; they're faster than you",
    ],
  },
  {
    name: "The Owner",
    icon: "👁️",
    type: "Boss",
    danger: 5,
    color: "#8b0000",
    behavior: "Harold Morrow. The man who built Malmouth Funland and never truly left. The Owner appears only on Night 5 as the final boss. He teleports across the map, corrupts entire zones (turning them dark and damaging), and summons lesser entities. He's fast, intelligent, and personal — he knows your name and he'll use it.",
    tips: [
      "All 4 players should focus fire — he has massive health",
      "Corrupted zones deal damage over time; keep moving",
      "Flare launcher reveals his true position during teleports",
      "He has 3 phases with increasing aggression",
      "Destroying the central Ferris wheel deals bonus damage to him",
      "When he speaks, his next attack targets that player",
    ],
  },
];

function DangerBar({ level }: { level: number }) {
  return (
    <div className="flex items-center gap-2">
      <span className="text-xs text-gray-500 uppercase tracking-widest">Danger</span>
      <div className="flex gap-1">
        {[1, 2, 3, 4, 5].map((n) => (
          <div
            key={n}
            className={`w-3 h-3 ${n <= level ? "bg-red-600" : "bg-gray-800"} transition-colors`}
          />
        ))}
      </div>
    </div>
  );
}

export default function EntitiesPage() {
  return (
    <div className="pt-20">
      <section className="relative py-20 px-4 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-[#1a0a2e]/50 to-[#0a0a0f]" />
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="font-horror text-5xl md:text-7xl neon-green mb-6"
          >
            THE BESTIARY
          </motion.h1>
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-gray-400 text-lg"
          >
            Every entity that calls Malmouth Funland home. Know them. Fear them. Survive them.
          </motion.p>
        </div>
      </section>

      <section className="py-16 px-4">
        <div className="max-w-5xl mx-auto space-y-8">
          {entities.map((e, i) => (
            <motion.div
              key={e.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.1 }}
              className="entity-card bg-[#12121a] p-8 relative overflow-hidden"
            >
              {/* Top accent bar */}
              <div className="absolute top-0 left-0 w-full h-1" style={{ backgroundColor: e.color }} />

              <div className="flex flex-col md:flex-row gap-6">
                {/* Icon & Meta */}
                <div className="flex flex-col items-center md:items-start md:w-48 shrink-0">
                  <div className="text-7xl mb-4">{e.icon}</div>
                  <h2 className="font-horror text-3xl mb-1" style={{ color: e.color }}>{e.name}</h2>
                  <span className="text-xs text-gray-500 uppercase tracking-[0.2em] mb-3">{e.type}</span>
                  <DangerBar level={e.danger} />
                </div>

                {/* Details */}
                <div className="flex-1">
                  <h3 className="text-sm text-gray-500 uppercase tracking-widest mb-2">Behavior</h3>
                  <p className="text-gray-300 leading-relaxed mb-6">{e.behavior}</p>

                  <h3 className="text-sm text-gray-500 uppercase tracking-widest mb-2">Survival Tips</h3>
                  <ul className="space-y-2">
                    {e.tips.map((tip, j) => (
                      <li key={j} className="flex items-start gap-2 text-gray-400 text-sm">
                        <span className="text-[#39ff14] mt-0.5">▸</span>
                        <span>{tip}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </section>
    </div>
  );
}
