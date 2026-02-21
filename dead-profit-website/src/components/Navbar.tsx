"use client";
import Link from "next/link";
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const links = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
  { href: "/entities", label: "Entities" },
  { href: "/guide", label: "How to Play" },
  { href: "/community", label: "Community" },
];

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="fixed top-0 w-full z-50 bg-[#0a0a0f]/90 backdrop-blur-md border-b border-[#39ff14]/10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <Link href="/" className="font-horror text-2xl tracking-wider neon-green flicker">
            DEAD PROFIT
          </Link>

          {/* Desktop */}
          <div className="hidden md:flex items-center gap-8">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-gray-300 hover:text-[#39ff14] transition-colors duration-200 text-sm uppercase tracking-widest"
              >
                {link.label}
              </Link>
            ))}
            <Link
              href="/#play"
              className="bg-[#39ff14]/10 border border-[#39ff14]/50 text-[#39ff14] px-4 py-2 text-sm uppercase tracking-widest hover:bg-[#39ff14]/20 transition-all pulse-glow"
            >
              Play Now
            </Link>
          </div>

          {/* Mobile toggle */}
          <button
            className="md:hidden text-[#39ff14] text-2xl"
            onClick={() => setIsOpen(!isOpen)}
          >
            {isOpen ? "✕" : "☰"}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden bg-[#0a0a0f]/95 border-b border-[#39ff14]/10"
          >
            <div className="px-4 py-4 flex flex-col gap-4">
              {links.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setIsOpen(false)}
                  className="text-gray-300 hover:text-[#39ff14] transition-colors text-sm uppercase tracking-widest"
                >
                  {link.label}
                </Link>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
}
