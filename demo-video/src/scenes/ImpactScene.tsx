import React from "react";
import { AbsoluteFill } from "remotion";
import { FadeIn } from "../components/FadeIn";
import { colors, font } from "../styles";

const groups = ["Savings chamas", "Funeral committees", "Wedding groups", "Welfare groups"];

export const ImpactScene: React.FC = () => (
  <AbsoluteFill style={{ background: colors.canvas, fontFamily: font, padding: 105 }}>
    <FadeIn>
      <div style={{ color: colors.green, fontSize: 22, fontWeight: 800, textTransform: "uppercase", letterSpacing: 3 }}>One operating model</div>
      <h2 style={{ color: colors.ink, fontSize: 68, maxWidth: 1200, lineHeight: 1.12, margin: "18px 0 50px" }}>
        Every community group deserves an agent that turns discussion into accountable work.
      </h2>
    </FadeIn>
    <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24 }}>
      {groups.map((group, index) => (
        <FadeIn key={group} delay={20 + index * 12}>
          <div style={{ background: colors.card, border: `1px solid ${colors.border}`, borderRadius: 20, padding: 32, color: colors.ink, fontSize: 30, fontWeight: 700 }}>
            <span style={{ color: colors.green, marginRight: 16 }}>●</span>{group}
          </div>
        </FadeIn>
      ))}
    </div>
  </AbsoluteFill>
);
