require './line_segment'

class Triangle
  def initialize(point1, point2, point3)
    @point1 = point1
    @point2 = point2
    @point3 = point3
  end

  def sides
    [
      LineSegment.new(@point1, @point2),
      LineSegment.new(@point2, @point3),
      LineSegment.new(@point3, @point1)
    ]
  end
end
