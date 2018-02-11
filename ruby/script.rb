module Script
  module_function

  def text(point_arr, edge_arr)
    <<-SCRIPT
export const POINTS = #{point_arr};

export const EDGES = #{edge_arr};
    SCRIPT
  end
end
