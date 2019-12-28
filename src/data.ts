import { Edge, Point } from "./types";

export const POINTS: Point[] = [
  [0.0, 0.0, 10.0],
  [10.0, 0.0, 0.0],
  [0.0, 10.0, 0.0],
  [0.0, -10.0, 0.0],
  [0.0, 0.0, -10.0],
  [-10.0, 0.0, 0.0]
];

export const EDGES: Edge[] = [
  [0, 1],
  [1, 2],
  [0, 2],
  [3, 4],
  [4, 5],
  [3, 5],
  [1, 3],
  [0, 3],
  [2, 4],
  [1, 4],
  [0, 5],
  [2, 5]
];
