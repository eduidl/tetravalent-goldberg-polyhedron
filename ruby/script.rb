module Script
  module_function

  def text(polyhedron)
    <<-SCRIPT
import { Point, Edge } from "./types";

export const POINTS: Point[] = #{polyhedron.points.map(&:coordinate)};

export const EDGES: Edge[] = #{polyhedron.edges.map(&:uniq_ids)};
    SCRIPT
  end
end
