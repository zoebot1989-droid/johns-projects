"use client";
import { motion } from "framer-motion";
import GlitchText from "@/components/GlitchText";
import SectionTitle from "@/components/SectionTitle";

const entities = [
  { name: "Wanderers", icon: "🧟", desc: "Slow, shambling patrol. They destroy your attractions one by one. Ignore them at your own peril.", color: "#b7410e" },
  { name: "Mimics", icon: "🎭", desc: "They look like park objects — benches, trash cans, rides — until you get close. Then they strike.", color: "#ffd700" },
  { name: "The Conductor", icon: "🎩", desc: "Possesses your rides and turns them into deathtraps. That roller coaster? It's his now.", color: "#9b59b6" },
  { name: "Hollow Kids", icon: "👧", desc: "Fast. Travel in groups. Their audio cues will haunt your dreams. Don't let them surround you.", color: "#39ff14" },
  { name: "The Owner", icon: "👁️", desc: "The boss. Teleports. Corrupts entire areas. He built this park, and he'll bury you in it.", color: "#8b0000" },
];

const features = [
  { icon: "🎢", title: "Build & Manage", desc: "Rebuild rides, attractions, and stalls to draw visitors and earn Tickets" },
  { icon: "🌙", title: "Survive the Night", desc: "When the sun sets, entities emerge. Fight or hide — your choice" },
  { icon: "👥", title: "1-4 Player Co-op", desc: "Team up with friends. Divide roles. Survive together or die alone" },
  { icon: "🔄", title: "Roguelite Loop", desc: "5 nights of escalating chaos. The better your park, the worse the horrors" },
  { icon: "🔫", title: "Arm Yourself", desc: "Flashlight, nail gun, fire extinguisher, flare launcher — pick wisely" },
  { icon: "🏆", title: "Score & Compete", desc: "Earn bonus tickets, unlock upgrades, top the leaderboard" },
];

const fadeUp = {
  initial: { opacity: 0, y: 40 },
  whileInView: { opacity: 1, y: 0 },
  viewport: { once: true },
  transition: { duration: 0.6 },
};

export default function Home() {
  return (
    <>
      {/* HERO */}
      <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
        {/* Background gradient */}
        <div className="absolute inset-0 bg-gradient-to-b from-[#1a0a2e] via-[#0a0a0f] to-[#0a0a0f]" />
        {/* Fog */}
        <div className="fog-layer opacity-30" />
        <div className="fog-layer opacity-20" style={{ animationDelay: "-10s", animationDuration: "30s" }} />

        {/* Radial glow */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-[#39ff14]/5 rounded-full blur-[120px]" />
        <div className="absolute top-1/3 left-1/3 w-[300px] h-[300px] bg-[#8b0000]/10 rounded-full blur-[100px]" />

        <div className="relative z-10 text-center px-4 max-w-5xl">
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8 }}
          >
            <GlitchText
              text="DEAD PROFIT"
              className="text-6xl sm:text-7xl md:text-8xl lg:text-9xl tracking-wider text-white"
            />
          </motion.div>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5, duration: 0.8 }}
            className="text-xl md:text-2xl text-gray-300 mt-6 italic"
          >
            &ldquo;The park wants your money. The Entity wants your soul.&rdquo;
          </motion.p>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.8, duration: 0.8 }}
            className="text-sm md:text-base text-gray-500 mt-3 uppercase tracking-[0.3em]"
          >
            Co-op Horror Tycoon • Fortnite Creative
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2, duration: 0.6 }}
            className="mt-10 flex flex-col sm:flex-row gap-4 justify-center items-center"
            id="play"
          >
            <a
              href="#"
              className="bg-[#39ff14] text-black font-bold px-8 py-4 text-lg uppercase tracking-widest hover:bg-[#4aff3b] transition-all pulse-glow inline-block"
            >
              ▶ Play Now — XXXX-XXXX-XXXX
            </a>
            <a
              href="#trailer"
              className="border border-gray-600 text-gray-300 px-8 py-4 text-lg uppercase tracking-widest hover:border-[#39ff14] hover:text-[#39ff14] transition-all inline-block"
            >
              Watch Trailer
            </a>
          </motion.div>
        </div>

        {/* Scroll indicator */}
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ repeat: Infinity, duration: 2 }}
          className="absolute bottom-8 left-1/2 -translate-x-1/2 text-gray-600 text-2xl"
        >
          ↓
        </motion.div>
      </section>

      {/* TRAILER */}
      <section id="trailer" className="py-20 px-4">
        <div className="max-w-4xl mx-auto">
          <SectionTitle title="WATCH THE TRAILER" />
          <motion.div {...fadeUp} className="aspect-video bg-[#12121a] border border-[#39ff14]/10 flex items-center justify-center">
            <div className="text-center text-gray-600">
              <div className="text-6xl mb-4">▶</div>
              <p className="uppercase tracking-widest text-sm">Trailer Coming Soon</p>
              <p className="text-xs mt-2 text-gray-700">YouTube embed placeholder</p>
            </div>
          </motion.div>
        </div>
      </section>

      {/* GAMEPLAY OVERVIEW */}
      <section className="py-20 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-7xl mx-auto">
          <SectionTitle title="HOW IT WORKS" subtitle="Day builds. Night kills. Repeat until dawn... or death." />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {features.map((f, i) => (
              <motion.div
                key={f.title}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className="bg-[#0a0a0f] border border-gray-800 p-6 hover:border-[#39ff14]/30 transition-all group"
              >
                <div className="text-4xl mb-4">{f.icon}</div>
                <h3 className="font-horror text-xl text-[#39ff14] mb-2">{f.title}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">{f.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* ENTITIES SHOWCASE */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <SectionTitle title="KNOW YOUR ENEMY" subtitle="They lurk in the dark. Learn them — or become one of them." />
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {entities.map((e, i) => (
              <motion.div
                key={e.name}
                initial={{ opacity: 0, scale: 0.95 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: i * 0.1 }}
                className="entity-card bg-[#12121a] p-6 relative overflow-hidden group cursor-pointer"
              >
                {/* Glow accent */}
                <div
                  className="absolute top-0 left-0 w-full h-1 opacity-50 group-hover:opacity-100 transition-opacity"
                  style={{ backgroundColor: e.color }}
                />
                <div className="text-5xl mb-4">{e.icon}</div>
                <h3 className="font-horror text-2xl mb-2" style={{ color: e.color }}>{e.name}</h3>
                <p className="text-gray-400 text-sm leading-relaxed">{e.desc}</p>
              </motion.div>
            ))}
          </div>
          <motion.div {...fadeUp} className="text-center mt-10">
            <a href="/entities" className="text-[#39ff14] uppercase tracking-widest text-sm hover:underline">
              View Full Bestiary →
            </a>
          </motion.div>
        </div>
      </section>

      {/* SCREENSHOTS */}
      <section className="py-20 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#1a0a2e]/30">
        <div className="max-w-7xl mx-auto">
          <SectionTitle title="SCREENSHOTS" subtitle="Malmouth Funland awaits..." />
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {[1, 2, 3, 4, 5, 6].map((n) => (
              <motion.div
                key={n}
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: n * 0.1 }}
                className="aspect-video bg-[#12121a] border border-gray-800 flex items-center justify-center hover:border-[#39ff14]/30 transition-all"
              >
                <span className="text-gray-700 text-sm uppercase tracking-widest">Screenshot {n}</span>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* COMMUNITY CTA */}
      <section className="py-20 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <SectionTitle title="JOIN THE COMMUNITY" subtitle="Team up. Share stories. Report bugs (and entities)." />
          <motion.div {...fadeUp} className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="#"
              className="bg-[#5865F2] text-white font-bold px-8 py-4 text-lg uppercase tracking-widest hover:bg-[#4752C4] transition-all inline-block"
            >
              🎮 Join Discord
            </a>
            <a
              href="/community"
              className="border border-gray-600 text-gray-300 px-8 py-4 text-lg uppercase tracking-widest hover:border-[#39ff14] hover:text-[#39ff14] transition-all inline-block"
            >
              All Socials
            </a>
          </motion.div>
        </div>
      </section>
    </>
  );
}
