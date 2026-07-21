import React from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { FadeIn } from "../components/FadeIn";
import { colors, font } from "../styles";

const messages = [
  ["Jane", "I will send my contribution tomorrow"],
  ["Chairperson", "What did we agree for Saturday?"],
  ["Treasurer", "Let me check the spreadsheet"],
  ["Mary", "I can clear the balance next week"],
];

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();

  return (
    <AbsoluteFill style={{ background: colors.canvas, fontFamily: font, padding: 110 }}>
      <FadeIn>
        <div style={{ color: colors.red, fontSize: 22, fontWeight: 800, letterSpacing: 3, textTransform: "uppercase" }}>
          The work is scattered
        </div>
        <h1 style={{ color: colors.ink, fontSize: 72, lineHeight: 1.08, maxWidth: 980, margin: "18px 0 0" }}>
          Money in M-PESA. Records in spreadsheets. Decisions buried in chat.
        </h1>
      </FadeIn>

      <div style={{ position: "absolute", right: 100, bottom: 80, width: 710, height: 580 }}>
        {messages.map(([name, message], index) => {
          const start = 25 + index * 24;
          const opacity = interpolate(frame, [start, start + 15], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div key={name} style={{ opacity, background: index % 2 ? colors.card : colors.greenSoft, border: `1px solid ${colors.border}`, borderRadius: 18, padding: 22, marginBottom: 18, marginLeft: index % 2 ? 70 : 0 }}>
              <div style={{ color: colors.green, fontWeight: 800, fontSize: 18 }}>{name}</div>
              <div style={{ color: colors.ink, fontSize: 26, marginTop: 5 }}>{message}</div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};
