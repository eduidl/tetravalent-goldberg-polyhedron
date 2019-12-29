import Visualizer from "./visualizer";
import { POINTS, EDGES } from "./data";

const visualizer = new Visualizer();
visualizer.initialize(POINTS, EDGES);

const render = (): void => {
  requestAnimationFrame(render);
  visualizer.render();
};

render();
