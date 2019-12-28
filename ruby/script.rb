module Script
  module_function

  def text(point_arr, edge_arr)
    <<-SCRIPT
import { Edge, Point } from "./types";

export const POINTS: Point[] = #{point_arr};

export const EDGES: Edge[] = #{edge_arr};
    SCRIPT
  end
end
