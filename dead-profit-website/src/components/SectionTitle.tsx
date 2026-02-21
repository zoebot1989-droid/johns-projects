"use client";
import { motion } from "framer-motion";

export default function SectionTitle({ title, subtitle }: { title: string; subtitle?: string }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.6 }}
      className="text-center mb-16"
    >
      <h2 className="font-horror text-4xl md:text-5xl lg:text-6xl neon-green mb-4">{title}</h2>
      {subtitle && <p className="text-gray-400 text-lg max-w-2xl mx-auto">{subtitle}</p>}
      <div className="w-24 h-0.5 bg-[#39ff14]/50 mx-auto mt-6" />
    </motion.div>
  );
}
