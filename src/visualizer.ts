import * as THREE from "three";
import { ConvexGeometry } from "three/examples/jsm/geometries/ConvexGeometry";
import { TrackballControls } from "three/examples/jsm/controls/TrackballControls";

import { Point, Edge } from "./types";

export default class Visualizer {
  scene: THREE.Scene;
  camera: THREE.PerspectiveCamera;
  controls: TrackballControls;
  renderer: THREE.WebGLRenderer;

  constructor() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    this.scene = new THREE.Scene();

    // camera
    this.camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
    this.camera.position.set(25, 25, 25);

    // renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setClearColor(0x010101);
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

  initialize(points: Point[], edges: Edge[]): void {
    const vertices = points.map(point => {
      return new THREE.Vector3(point[0], point[1], point[2]);
    });
    const convex = new THREE.Mesh(
      new ConvexGeometry(vertices),
      new THREE.MeshNormalMaterial({
        transparent: true,
        opacity: 0.8
      })
    );
    this.scene.add(convex);
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
        new THREE.LineBasicMaterial({ color: "black" })
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
