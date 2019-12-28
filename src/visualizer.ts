import * as THREE from "three";
import { TrackballControls } from "three/examples/jsm/controls/TrackballControls";

import { Edge, Point } from "./types";

export default class Visualizer {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  controls: TrackballControls;
  renderer: THREE.WebGLRenderer;

  constructor() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.scene = new THREE.Scene();

    // light
    const light = new THREE.DirectionalLight(0xffffff, 1);
    light.position.set(0, 100, 30);
    this.scene.add(light);
    this.scene.add(new THREE.AmbientLight(0x404040));

    // camera
    this.camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
    this.camera.position.set(20, 10, 30);

    // renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setClearColor(0xeeeeee);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    const stage = document.getElementById("stage");
    if (stage === null) {
      throw TypeError;
    }
    stage.appendChild(this.renderer.domElement);

    // controls
    this.controls = new TrackballControls(
      this.camera,
      this.renderer.domElement
    );
    this.controls.rotateSpeed = 5.0;
  }

  initialize(edges: Edge[], points: Point[]): void {
    for (const edge of edges) {
      const geom = new THREE.Geometry();
      geom.vertices.push(
        new THREE.Vector3(
          points[edge[0]][0],
          points[edge[0]][1],
          points[edge[0]][2]
        )
      );
      geom.vertices.push(
        new THREE.Vector3(
          points[edge[1]][0],
          points[edge[1]][1],
          points[edge[1]][2]
        )
      );
      const line = new THREE.Line(
        geom,
        new THREE.LineBasicMaterial({ color: "green" })
      );
      this.scene.add(line);
    }
  }

  render(): void {
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }

  resize(width: number, height: number): void {
    this.renderer.setSize(width, height);
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
  }
}
