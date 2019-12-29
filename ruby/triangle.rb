require_relative './line_segment'

class Triangle
  def initialize(point0, point1, point2)
    @vertices = [point0, point1, point2]
  end

  def sides
    [
      LineSegment.new(@vertices[0], @vertices[1]),
      LineSegment.new(@vertices[1], @vertices[2]),
      LineSegment.new(@vertices[2], @vertices[0])
    ]
  end
end
