import React from "react";
import { Audio, Series, staticFile } from "remotion";
import { assets } from "./config";
import { ProductClip } from "./components/ProductClip";
import { ClosingScene } from "./scenes/ClosingScene";
import { ImpactScene } from "./scenes/ImpactScene";
import { ProblemScene } from "./scenes/ProblemScene";
import { TitleScene } from "./scenes/TitleScene";

const seconds = (value: number) => value * 30;
export const TOTAL_FRAMES = seconds(179);

export const ChamaAgentDemo: React.FC = () => (
  <>
    {assets.voiceover ? <Audio src={staticFile(assets.voiceover)} /> : null}
    <Series>
      <Series.Sequence durationInFrames={seconds(12)}><ProblemScene /></Series.Sequence>
      <Series.Sequence durationInFrames={seconds(13)}><TitleScene /></Series.Sequence>
      <Series.Sequence durationInFrames={seconds(13)}>
        <ProductClip asset={assets.dashboard} eyebrow="Live records" title="See who needs attention" detail="Real contribution totals, arrears, and member statements." />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(20)}>
        <ProductClip asset={assets.healthReport} eyebrow="GPT-5.6 health report" title="From records to decisions" detail="Health score, named risks, collection actions, and meeting agenda." />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(49)}>
        <ProductClip asset={assets.chatIntelligence} eyebrow="Group Chat Intelligence" title="The conversation becomes accountable work" detail="Topics, decisions, owners, promises, unresolved issues, and reminders." accent="#68d391" />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(21)}>
        <ProductClip asset={assets.payment} eyebrow="M-PESA + Turbo Streams" title="Request, confirm, update—live" detail="Daraja callback to Contribution record to the member row." accent="#f6c85f" />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(10)}>
        <ProductClip asset={assets.statement} eyebrow="Member accountability" title="A clear PDF statement" detail="Every member can verify their own contribution history." />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(18)}>
        <ProductClip asset={assets.codex} eyebrow="Built with Codex" title="An engineering collaborator, not a footnote" detail="Implementation, debugging, API migration, testing, and sequential commits." accent="#9ae6b4" />
      </Series.Sequence>
      <Series.Sequence durationInFrames={seconds(19)}><ImpactScene /></Series.Sequence>
      <Series.Sequence durationInFrames={seconds(4)}><ClosingScene /></Series.Sequence>
    </Series>
  </>
);
