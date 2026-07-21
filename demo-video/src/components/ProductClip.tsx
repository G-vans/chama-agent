import React from "react";
import { AbsoluteFill, OffthreadVideo, staticFile } from "remotion";
import { colors, font } from "../styles";

export const ProductClip: React.FC<{
  asset: string | null;
  eyebrow: string;
  title: string;
  detail: string;
  accent?: string;
}> = ({ asset, eyebrow, title, detail, accent = colors.green }) => (
  <AbsoluteFill style={{ backgroundColor: colors.canvas, fontFamily: font }}>
    {asset ? (
      <OffthreadVideo
        src={staticFile(asset)}
        style={{ width: "100%", height: "100%", objectFit: "cover" }}
      />
    ) : (
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
        <div
          style={{
            width: 1540,
            height: 780,
            background: colors.card,
            border: `2px dashed ${colors.border}`,
            borderRadius: 28,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: colors.muted,
            fontSize: 32,
          }}
        >
          Add this screen recording in public/
        </div>
      </AbsoluteFill>
    )}

    <div
      style={{
        position: "absolute",
        left: 70,
        bottom: 62,
        maxWidth: 950,
        padding: "24px 32px",
        borderRadius: 18,
        color: "white",
        background: "rgba(16, 25, 19, 0.92)",
        boxShadow: "0 16px 50px rgba(0,0,0,0.22)",
      }}
    >
      <div style={{ color: accent, fontWeight: 800, fontSize: 20, textTransform: "uppercase", letterSpacing: 2 }}>
        {eyebrow}
      </div>
      <div style={{ fontSize: 44, fontWeight: 750, marginTop: 8 }}>{title}</div>
      <div style={{ fontSize: 23, opacity: 0.76, marginTop: 8 }}>{detail}</div>
    </div>
  </AbsoluteFill>
);
