import React from "react";
import { AbsoluteFill } from "remotion";
import { FadeIn } from "../components/FadeIn";
import { colors, font } from "../styles";

export const ClosingScene: React.FC = () => (
  <AbsoluteFill style={{ background: colors.green, color: "white", alignItems: "center", justifyContent: "center", fontFamily: font }}>
    <FadeIn>
      <div style={{ textAlign: "center" }}>
        <div style={{ fontSize: 92, fontWeight: 850, letterSpacing: -4 }}>Chama Agent</div>
        <div style={{ fontSize: 34, marginTop: 24, opacity: 0.82 }}>From conversation to accountable action.</div>
        <div style={{ fontSize: 21, marginTop: 42, color: colors.greenSoft, letterSpacing: 2 }}>OPENAI BUILD WEEK 2026 · WORK & PRODUCTIVITY</div>
      </div>
    </FadeIn>
  </AbsoluteFill>
);
