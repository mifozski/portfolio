import React from "react";

import ProjectItem from "./ProjectItem";
import PrKillerImg from "../../public/assets/projects/prKiller.png";

export function Projects() {
  return (
    <div id="projects" className="w-full">
      <div className="max-w-[1240px] mx-auto px-2 py-16">
        <p className="text-xl tracking-widest uppercase text-[#5651e5]">
          Projects
        </p>
        <h2>What I&apos;ve Built</h2>
        <div className="grid md:grid-cols-2 gap-8">
          <ProjectItem
            title="PR Killer"
            background={PrKillerImg}
            url="/projects/pr-killer"
          />
          <ProjectItem
            title="PR Killer"
            background={PrKillerImg}
            url="/projects/pr-killer"
          />
          <ProjectItem
            title="PR Killer"
            background={PrKillerImg}
            url="/projects/pr-killer"
          />
          <ProjectItem
            title="PR Killer"
            background={PrKillerImg}
            url="/projects/pr-killer"
          />
        </div>
      </div>
    </div>
  );
}
