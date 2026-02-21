"use client";
import { motion } from "framer-motion";

interface GlitchTextProps {
  text: string;
  className?: string;
  as?: "h1" | "h2" | "h3" | "span";
}

export default function GlitchText({ text, className = "", as: Tag = "h1" }: GlitchTextProps) {
  return (
    <motion.div
      className="relative inline-block"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5 }}
    >
      <Tag className={`font-horror ${className}`}>
        {text}
      </Tag>
      {/* Glitch layers */}
      <Tag
        className={`font-horror ${className} absolute top-0 left-0 opacity-70`}
        style={{
          color: "#39ff14",
          animation: "glitchText 2.5s infinite linear alternate-reverse",
          mixBlendMode: "screen",
        }}
        aria-hidden
      >
        {text}
      </Tag>
      <Tag
        className={`font-horror ${className} absolute top-0 left-0 opacity-70`}
        style={{
          color: "#8b0000",
          animation: "glitchText 3s infinite linear alternate",
          mixBlendMode: "screen",
        }}
        aria-hidden
      >
        {text}
      </Tag>
    </motion.div>
  );
}
