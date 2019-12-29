require_relative './line_segment'

class Square
  def initialize(point0, point1, point2, point3)
    @vertices = [point0, point1, point2, point3]
  end

  def sides
    [
      LineSegment.new(@vertices[0], @vertices[1]),
      LineSegment.new(@vertices[1], @vertices[2]),
      LineSegment.new(@vertices[2], @vertices[3]),
      LineSegment.new(@vertices[3], @vertices[0])
    ]
  end

  def diagonals
    [
      LineSegment.new(@vertices[0], @vertices[2]),
      LineSegment.new(@vertices[1], @vertices[3])
    ]
  end
end
