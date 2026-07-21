import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { FadeIn } from "../components/FadeIn";
import { colors, font } from "../styles";

export const TitleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const width = interpolate(frame, [18, 55], [0, 480], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ background: colors.ink, color: "white", alignItems: "center", justifyContent: "center", fontFamily: font }}>
      <FadeIn delay={5}>
        <div style={{ fontSize: 104, fontWeight: 800, letterSpacing: -5 }}>Chama Agent</div>
      </FadeIn>
      <div style={{ width, height: 4, background: colors.gold, margin: "28px 0" }} />
      <FadeIn delay={35}>
        <div style={{ fontSize: 34, color: "rgba(255,255,255,0.72)" }}>From group conversation to accountable action.</div>
      </FadeIn>
      <FadeIn delay={65}>
        <div style={{ fontSize: 22, color: colors.greenSoft, marginTop: 34, letterSpacing: 2 }}>POWERED BY GPT-5.6 · BUILT WITH CODEX</div>
      </FadeIn>
    </AbsoluteFill>
  );
};
