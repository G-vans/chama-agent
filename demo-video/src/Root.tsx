import React from "react";
import { Composition } from "remotion";
import { ChamaAgentDemo, TOTAL_FRAMES } from "./ChamaAgentDemo";
import { FPS, HEIGHT, WIDTH } from "./styles";

export const RemotionRoot: React.FC = () => (
  <Composition
    id="ChamaAgentDemo"
    component={ChamaAgentDemo}
    durationInFrames={TOTAL_FRAMES}
    fps={FPS}
    width={WIDTH}
    height={HEIGHT}
  />
);
