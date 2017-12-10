require './line_segment'

class Square
  def initialize(point1, point2, point3, point4)
    @point1 = point1
    @point2 = point2
    @point3 = point3
    @point4 = point4
  end

  def sides
    [
      LineSegment.new(@point1, @point2),
      LineSegment.new(@point2, @point3),
      LineSegment.new(@point3, @point4),
      LineSegment.new(@point4, @point1)
    ]
  end

  def diagonals
    [
      LineSegment.new(@point1, @point3),
      LineSegment.new(@point2, @point4)
    ]
  end
end
