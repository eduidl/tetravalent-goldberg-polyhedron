import ThreeJS from './three_js.js'
import { POINTS, EDGES } from './data.js';

function render() {
  requestAnimationFrame(render);
  three_js.render();
}

const three_js = new ThreeJS();
three_js.initialize(EDGES, POINTS);
render();
