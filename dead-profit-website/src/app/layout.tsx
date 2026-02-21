import type { Metadata } from "next";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "DEAD PROFIT — The Park Wants Your Money. The Entity Wants Your Soul.",
  description: "A 1-4 player co-op horror tycoon in Fortnite Creative. Rebuild an abandoned amusement park by day. Survive entity attacks by night.",
  keywords: "Dead Profit, Fortnite Creative, UEFN, horror tycoon, co-op, Malmouth Funland",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        <div className="static-overlay" />
        <Navbar />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
