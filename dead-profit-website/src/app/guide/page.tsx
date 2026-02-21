"use client";
import { motion } from "framer-motion";
import SectionTitle from "@/components/SectionTitle";

const steps = [
  { step: 1, title: "Enter the Map Code", desc: "Launch Fortnite, go to Creative, and enter the map code: XXXX-XXXX-XXXX. You can play solo or invite up to 3 friends.", icon: "🎮" },
  { step: 2, title: "Choose Your Role", desc: "Builder, Defender, Scout, or Mechanic. Each role gets unique starting tools and passive bonuses. In solo, you're all of them.", icon: "🎭" },
  { step: 3, title: "Survive Day One", desc: "Your first day is a tutorial. Build your first ride, earn your first Tickets, and get familiar with the park layout before nightfall.", icon: "☀️" },
  { step: 4, title: "Prepare for Night", desc: "When the siren sounds, you have 30 seconds. Buy weapons, board up entrances, and position your team. Night is coming.", icon: "🔔" },
  { step: 5, title: "Fight the Entities", desc: "Use flashlights to spot, nail guns to damage, fire extinguishers to crowd control, and flares to reveal. Protect your rides.", icon: "⚔️" },
  { step: 6, title: "Survive All 5 Nights", desc: "Each night gets harder. By Night 5, The Owner himself arrives. Beat him to win. Your score depends on park value and survival.", icon: "🏆" },
];

const weapons = [
  { name: "Flashlight", icon: "🔦", desc: "Reveals Mimics, slows Hollow Kids, stuns Wanderers briefly. No damage but essential for survival.", tier: "Starting" },
  { name: "Nail Gun", icon: "🔫", desc: "Your bread and butter. Medium damage, fast fire rate, limited ammo. Best against Wanderers.", tier: "Starting" },
  { name: "Fire Extinguisher", icon: "🧯", desc: "AoE crowd control. Slows and damages groups. The Hollow Kids' worst nightmare.", tier: "Tier 2" },
  { name: "Flare Launcher", icon: "🎆", desc: "High damage, reveals hidden entities, forces The Conductor out of rides. Rare ammo.", tier: "Tier 3" },
];

const roles = [
  { name: "Builder", icon: "🔨", color: "#ffd700", desc: "Builds rides 25% faster. Gets a free repair kit each day. The money-maker.", focus: "Prioritize ride construction and repair during the day." },
  { name: "Defender", icon: "🛡️", color: "#8b0000", desc: "Starts with extra ammo. Deals 15% more weapon damage. Barricades are 50% stronger.", focus: "Guard the most valuable rides at night. You're the front line." },
  { name: "Scout", icon: "👁️", color: "#39ff14", desc: "Moves 10% faster. Flashlight has extended range. Can mark entities for teammates.", focus: "Patrol the perimeter. Early detection saves lives." },
  { name: "Mechanic", icon: "⚙️", color: "#9b59b6", desc: "Repairs damaged rides 40% faster. Can sabotage possessed rides to hurt The Conductor.", focus: "Follow up after attacks. Your repairs keep the money flowing." },
];

const tips = [
  "Don't over-build early — you need Tickets for weapons too",
  "Always carry a Flashlight. Always.",
  "The Conductor targets your highest-earning ride first",
  "Hollow Kids can't open doors — use buildings as chokepoints",
  "Repair rides between nights or your income crashes",
  "Flares are rare — save them for The Conductor and Night 5",
  "Split up during the day, stick together at night",
  "Listen. Audio cues give you 3-5 seconds of warning",
  "The park layout has natural chokepoints — learn them",
  "Greed kills. A modest park with good defenses beats a rich park with none",
];

export default function GuidePage() {
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
            SURVIVAL GUIDE
          </motion.h1>
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-gray-400 text-lg"
          >
            Everything you need to know to survive your first shift at Malmouth Funland.
          </motion.p>
        </div>
      </section>

      {/* Getting Started */}
      <section className="py-16 px-4">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="GETTING STARTED" />
          <div className="space-y-4">
            {steps.map((s, i) => (
              <motion.div
                key={s.step}
                initial={{ opacity: 0, x: -20 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                className="flex items-start gap-6 bg-[#12121a] border border-gray-800 p-6 hover:border-[#39ff14]/20 transition-all"
              >
                <div className="flex flex-col items-center shrink-0">
                  <div className="text-4xl mb-2">{s.icon}</div>
                  <div className="w-8 h-8 rounded-full bg-[#39ff14]/10 border border-[#39ff14]/30 flex items-center justify-center text-[#39ff14] font-bold text-sm">
                    {s.step}
                  </div>
                </div>
                <div>
                  <h3 className="font-horror text-xl text-[#39ff14] mb-1">{s.title}</h3>
                  <p className="text-gray-400 text-sm leading-relaxed">{s.desc}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Weapons */}
      <section className="py-16 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="YOUR ARSENAL" subtitle="Every tool has its moment. Know when to use what." />
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {weapons.map((w, i) => (
              <motion.div
                key={w.name}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                className="bg-[#0a0a0f] border border-gray-800 p-6 hover:border-[#39ff14]/20 transition-all"
              >
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-4xl">{w.icon}</span>
                  <div>
                    <h3 className="font-horror text-xl text-white">{w.name}</h3>
                    <span className="text-xs text-[#39ff14] uppercase tracking-widest">{w.tier}</span>
                  </div>
                </div>
                <p className="text-gray-400 text-sm leading-relaxed">{w.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Co-op Roles */}
      <section className="py-16 px-4">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="CO-OP ROLES" subtitle="Each player picks a role. Here's what they do." />
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {roles.map((r, i) => (
              <motion.div
                key={r.name}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                className="bg-[#12121a] border border-gray-800 p-6 hover:border-opacity-50 transition-all"
                style={{ borderLeftColor: r.color, borderLeftWidth: "4px" }}
              >
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-4xl">{r.icon}</span>
                  <h3 className="font-horror text-2xl" style={{ color: r.color }}>{r.name}</h3>
                </div>
                <p className="text-gray-300 text-sm mb-3">{r.desc}</p>
                <p className="text-gray-500 text-xs italic">{r.focus}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Tips */}
      <section className="py-16 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-3xl mx-auto">
          <SectionTitle title="PRO TIPS" subtitle="Wisdom from those who survived... barely." />
          <div className="space-y-3">
            {tips.map((tip, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: -10 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.3, delay: i * 0.05 }}
                className="flex items-start gap-3 bg-[#0a0a0f] border border-gray-800 p-4"
              >
                <span className="text-[#39ff14] shrink-0">💀</span>
                <p className="text-gray-300 text-sm">{tip}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
