import Visualizer from "./visualizer";
import { EDGES, POINTS } from "./data";

const visualizer = new Visualizer();
visualizer.initialize(EDGES, POINTS);

const render = (): void => {
  requestAnimationFrame(render);
  visualizer.render();
};

render();
