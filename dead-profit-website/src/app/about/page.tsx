"use client";
import { motion } from "framer-motion";
import SectionTitle from "@/components/SectionTitle";

const cycles = [
  { phase: "DAY", duration: "3 min", icon: "☀️", color: "#ffd700", desc: "Visitors flood the park. Build rides, repair attractions, set up stalls, and earn Tickets. The more you build, the more you earn — but the entities are watching." },
  { phase: "DUSK", duration: "30 sec", icon: "🌅", color: "#b7410e", desc: "Warning sirens blare. Visitors flee in panic. You have 30 seconds to board up, arm up, and set your defenses. The clock is ticking." },
  { phase: "NIGHT", duration: "2 min", icon: "🌙", color: "#1a0a2e", desc: "Darkness falls. Entities crawl from every shadow. Fight with flashlights, nail guns, and flare launchers. Protect your rides — or lose everything you built." },
  { phase: "DAWN", duration: "15 sec", icon: "🌄", color: "#39ff14", desc: "You survived. Score screen tallies your earnings, bonus tickets flow in, and the loop resets. But tomorrow night will be worse." },
];

const features = [
  { icon: "👥", title: "1-4 Player Co-op", desc: "Every player matters. Split roles — one builds while others defend. Communication is survival." },
  { icon: "🎢", title: "Tycoon Building", desc: "12+ rides and attractions to build. Each generates different Ticket rates and attracts different visitor types." },
  { icon: "👻", title: "Horror Survival", desc: "5 unique entity types with distinct AI behaviors. Learn their patterns or become another ghost story." },
  { icon: "🔄", title: "Roguelite Progression", desc: "5 nights per game with escalating difficulty. Unlock permanent upgrades between runs." },
  { icon: "💰", title: "Risk vs Reward", desc: "The more profitable your park, the stronger the entities get. Greed kills — literally." },
  { icon: "🎯", title: "Boss Night", desc: "Night 5: The Owner himself appears. A final stand against the entity that started it all." },
];

export default function AboutPage() {
  return (
    <div className="pt-20">
      {/* Hero */}
      <section className="relative py-20 px-4 overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-[#1a0a2e]/50 to-[#0a0a0f]" />
        <div className="relative z-10 max-w-4xl mx-auto text-center">
          <motion.h1
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            className="font-horror text-5xl md:text-7xl neon-green mb-6"
          >
            MALMOUTH FUNLAND
          </motion.h1>
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-gray-400 text-lg md:text-xl leading-relaxed max-w-3xl mx-auto"
          >
            Once the happiest place in the county. Now a rotting monument to greed and something much worse.
          </motion.p>
        </div>
      </section>

      {/* Lore */}
      <section className="py-16 px-4">
        <div className="max-w-3xl mx-auto">
          <SectionTitle title="THE STORY" />
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="prose prose-invert max-w-none space-y-6 text-gray-300 leading-relaxed"
          >
            <p>
              Malmouth Funland opened in 1987 under the vision of <strong className="text-[#b7410e]">Harold Morrow</strong> — 
              a man who believed happiness could be manufactured, bottled, and sold at markup. For a decade, the park thrived. 
              Families came from across the state. The Ferris wheel lit up the night sky. The laughter never stopped.
            </p>
            <p>
              Then came the accident. Night shift, summer of &apos;97. A roller coaster derailed during a private event. 
              Seven dead. The park closed overnight. Harold vanished. The insurance money disappeared.
            </p>
            <p>
              But the park didn&apos;t stay empty. Something moved in. Something that feeds on the energy of crowds, 
              the thrill of rides, the <em className="text-[#ffd700]">profit of entertainment</em>. The Entity.
            </p>
            <p>
              Now a mysterious investor has reopened Malmouth Funland, hiring crews (that&apos;s you) to rebuild and 
              reopen the park. The money is good. The contract is... unusual. And every night, when the last visitor 
              leaves, the entities come out to play.
            </p>
            <p className="text-[#39ff14] font-semibold text-lg">
              Your job: make the park profitable. Your challenge: survive until dawn.
            </p>
          </motion.div>
        </div>
      </section>

      {/* Day/Night Cycle */}
      <section className="py-20 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="THE CYCLE" subtitle="Every game runs 5 rounds. Each round follows the same deadly rhythm." />
          <div className="space-y-6">
            {cycles.map((c, i) => (
              <motion.div
                key={c.phase}
                initial={{ opacity: 0, x: i % 2 === 0 ? -30 : 30 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
                className="flex flex-col md:flex-row items-start gap-6 bg-[#0a0a0f] border border-gray-800 p-6 hover:border-opacity-50 transition-all"
                style={{ borderLeftColor: c.color, borderLeftWidth: "4px" }}
              >
                <div className="text-5xl">{c.icon}</div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="font-horror text-2xl" style={{ color: c.color }}>{c.phase}</h3>
                    <span className="text-gray-600 text-sm uppercase tracking-widest">({c.duration})</span>
                  </div>
                  <p className="text-gray-400 leading-relaxed">{c.desc}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <SectionTitle title="FEATURES" />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((f, i) => (
              <motion.div
                key={f.title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className="bg-[#12121a] border border-gray-800 p-6 hover:border-[#39ff14]/30 transition-all"
              >
                <div className="text-4xl mb-3">{f.icon}</div>
                <h3 className="font-horror text-xl text-[#39ff14] mb-2">{f.title}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">{f.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
