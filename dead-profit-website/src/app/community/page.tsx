"use client";
import { motion } from "framer-motion";
import SectionTitle from "@/components/SectionTitle";
import { useState } from "react";

const socials = [
  { name: "Discord", icon: "💬", color: "#5865F2", desc: "Join the official server. LFG, strategies, bug reports, and community events.", link: "#", members: "Coming Soon" },
  { name: "YouTube", icon: "📺", color: "#FF0000", desc: "Trailers, devlogs, gameplay clips, and community highlights.", link: "#", members: "Subscribe" },
  { name: "TikTok", icon: "🎵", color: "#ff0050", desc: "Short clips, entity encounters, and the best (worst) deaths in Malmouth Funland.", link: "#", members: "Follow" },
  { name: "Reddit", icon: "🤖", color: "#FF4500", desc: "r/DeadProfit — theories, fan art, strategies, and memes.", link: "#", members: "Join" },
];

export default function CommunityPage() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

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
            JOIN THE CREW
          </motion.h1>
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-gray-400 text-lg"
          >
            Survive alone or thrive together. The Malmouth Funland community is waiting.
          </motion.p>
        </div>
      </section>

      {/* Discord CTA */}
      <section className="py-16 px-4">
        <div className="max-w-3xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="bg-[#5865F2]/10 border border-[#5865F2]/30 p-8 md:p-12 text-center"
          >
            <div className="text-6xl mb-4">💬</div>
            <h2 className="font-horror text-3xl md:text-4xl text-white mb-4">Official Discord Server</h2>
            <p className="text-gray-400 mb-6 max-w-lg mx-auto">
              Find co-op partners, share strategies, report entity sightings, and get early access to updates.
            </p>
            <a
              href="#"
              className="bg-[#5865F2] text-white font-bold px-8 py-4 text-lg uppercase tracking-widest hover:bg-[#4752C4] transition-all inline-block"
            >
              Join Discord Server
            </a>
          </motion.div>
        </div>
      </section>

      {/* Social Links */}
      <section className="py-16 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="FIND US EVERYWHERE" />
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
            {socials.map((s, i) => (
              <motion.a
                key={s.name}
                href={s.link}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                className="bg-[#0a0a0f] border border-gray-800 p-6 hover:border-opacity-50 transition-all group block"
                style={{ borderLeftColor: s.color, borderLeftWidth: "4px" }}
              >
                <div className="flex items-center gap-3 mb-3">
                  <span className="text-4xl">{s.icon}</span>
                  <div>
                    <h3 className="font-horror text-xl text-white group-hover:text-[#39ff14] transition-colors">{s.name}</h3>
                    <span className="text-xs uppercase tracking-widest" style={{ color: s.color }}>{s.members}</span>
                  </div>
                </div>
                <p className="text-gray-400 text-sm">{s.desc}</p>
              </motion.a>
            ))}
          </div>
        </div>
      </section>

      {/* Fan Art */}
      <section className="py-16 px-4">
        <div className="max-w-5xl mx-auto">
          <SectionTitle title="FAN ART GALLERY" subtitle="Submit your Malmouth Funland creations. Best ones get featured!" />
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {[1, 2, 3, 4, 5, 6].map((n) => (
              <motion.div
                key={n}
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: n * 0.1 }}
                className="aspect-square bg-[#12121a] border border-gray-800 flex items-center justify-center hover:border-[#39ff14]/20 transition-all"
              >
                <span className="text-gray-700 text-xs uppercase tracking-widest">Coming Soon</span>
              </motion.div>
            ))}
          </div>
          <p className="text-center text-gray-600 text-sm mt-6">
            Submit fan art via our Discord server to be featured here!
          </p>
        </div>
      </section>

      {/* Leaderboard */}
      <section className="py-16 px-4 bg-gradient-to-b from-[#0a0a0f] to-[#12121a]">
        <div className="max-w-3xl mx-auto">
          <SectionTitle title="LEADERBOARD" subtitle="Top survivors of Malmouth Funland" />
          <div className="bg-[#0a0a0f] border border-gray-800 overflow-hidden">
            <div className="grid grid-cols-4 gap-4 p-4 border-b border-gray-800 text-xs text-gray-500 uppercase tracking-widest">
              <span>Rank</span>
              <span>Player</span>
              <span>Score</span>
              <span>Nights</span>
            </div>
            {[1, 2, 3, 4, 5].map((n) => (
              <div key={n} className="grid grid-cols-4 gap-4 p-4 border-b border-gray-800/50 text-gray-600 text-sm">
                <span>#{n}</span>
                <span>—</span>
                <span>—</span>
                <span>—</span>
              </div>
            ))}
            <div className="p-6 text-center text-gray-700 text-sm">
              Leaderboard activates at launch
            </div>
          </div>
        </div>
      </section>

      {/* Newsletter */}
      <section className="py-16 px-4">
        <div className="max-w-xl mx-auto text-center">
          <SectionTitle title="STAY ALIVE" subtitle="Get updates on launches, patches, and new entities." />
          {submitted ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-[#39ff14]/10 border border-[#39ff14]/30 p-6 text-[#39ff14]"
            >
              <p className="font-horror text-2xl mb-2">YOU&apos;RE IN</p>
              <p className="text-sm text-gray-400">We&apos;ll be in touch. If we survive the night.</p>
            </motion.div>
          ) : (
            <motion.form
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              onSubmit={(e) => { e.preventDefault(); setSubmitted(true); }}
              className="flex flex-col sm:flex-row gap-3"
            >
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                className="flex-1 bg-[#12121a] border border-gray-700 px-4 py-3 text-white placeholder-gray-600 focus:border-[#39ff14] focus:outline-none transition-colors"
              />
              <button
                type="submit"
                className="bg-[#39ff14]/10 border border-[#39ff14]/50 text-[#39ff14] px-6 py-3 uppercase tracking-widest text-sm font-bold hover:bg-[#39ff14]/20 transition-all"
              >
                Subscribe
              </button>
            </motion.form>
          )}
        </div>
      </section>
    </div>
  );
}
