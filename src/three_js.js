const THREE = require('three');
const TrackballControls = require('three-trackballcontrols');

export default class ThreeJS {
  constructor() {
    const width = window.innerWidth;
    const height = window.innerHeight;

    this.scene = new THREE.Scene();

    // light
    const light = new THREE.DirectionalLight(0xffffff, 1);
    light.position.set(0, 100, 30);
    this.scene.add(light);

    const ambient = new THREE.AmbientLight(0x404040);
    this.scene.add(ambient);

    // camera
    this.camera = new THREE.PerspectiveCamera(45, width / height, 1, 1000);
    this.camera.position.set(20, 10, 30);
    this.camera.lookAt(this.scene.position);

    // controls
    this.controls = new TrackballControls(this.camera);
    this.controls.rotateSpeed = 5.0;

    // renderer
    this.renderer = new THREE.WebGLRenderer({ antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setClearColor(0xffffff);
    this.renderer.setPixelRatio(window.devicePixelRatio);
    document.getElementById('stage').appendChild(this.renderer.domElement);
  }

  initialize(edges, points) {
    edges.forEach((edge) => {
      const geom = new THREE.Geometry();
      geom.vertices.push(
        new THREE.Vector3(points[edge[0]][0],
                          points[edge[0]][1],
                          points[edge[0]][2]));
      geom.vertices.push(
        new THREE.Vector3(points[edge[1]][0],
                          points[edge[1]][1],
                          points[edge[1]][2]));
      const line = new THREE.Line(
        geom, 
        new THREE.LineBasicMaterial({ color: 'green' })
      );
      this.scene.add(line);
    });

    const sphere = new THREE.Mesh(
      new THREE.SphereGeometry(9, 30, 30),
      new THREE.MeshBasicMaterial({
        transparent: true,
        opacity: 0.7,
        color: 0xffffff
      })
    );
    this.scene.add(sphere);
  }

  render() {
    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  }
}
