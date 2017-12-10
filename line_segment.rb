require './point'

class LineSegment
  attr_reader :start_point, :end_point

  def initialize(point1, point2)
    @start_point = point1
    @end_point = point2
  end

  def length
    start_point.distance_to(end_point)
  end

  def uniq_ids
    [start_point.id, end_point.id].sort
  end
end
