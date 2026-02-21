import Link from "next/link";

export default function Footer() {
  return (
    <footer className="bg-[#0a0a0f] border-t border-[#39ff14]/10 py-12">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="font-horror text-2xl neon-green mb-4">DEAD PROFIT</h3>
            <p className="text-gray-500 text-sm leading-relaxed">
              The park wants your money.<br />The Entity wants your soul.
            </p>
          </div>
          <div>
            <h4 className="text-white font-semibold mb-4 uppercase tracking-wider text-sm">Navigate</h4>
            <div className="flex flex-col gap-2">
              {[
                { href: "/about", label: "About" },
                { href: "/entities", label: "Entities" },
                { href: "/guide", label: "How to Play" },
                { href: "/community", label: "Community" },
              ].map((link) => (
                <Link key={link.href} href={link.href} className="text-gray-500 hover:text-[#39ff14] transition-colors text-sm">
                  {link.label}
                </Link>
              ))}
            </div>
          </div>
          <div>
            <h4 className="text-white font-semibold mb-4 uppercase tracking-wider text-sm">Connect</h4>
            <div className="flex flex-col gap-2">
              <a href="#" className="text-gray-500 hover:text-[#39ff14] transition-colors text-sm">Discord</a>
              <a href="#" className="text-gray-500 hover:text-[#39ff14] transition-colors text-sm">YouTube</a>
              <a href="#" className="text-gray-500 hover:text-[#39ff14] transition-colors text-sm">TikTok</a>
              <a href="#" className="text-gray-500 hover:text-[#39ff14] transition-colors text-sm">Reddit</a>
            </div>
          </div>
        </div>
        <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-600 text-xs">
          <p>© 2026 DEAD PROFIT. Not affiliated with Epic Games. Made in Fortnite Creative / UEFN.</p>
        </div>
      </div>
    </footer>
  );
}
