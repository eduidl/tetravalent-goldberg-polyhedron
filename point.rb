require 'matrix'

class Point
  attr_accessor :theta, :phi, :relative, :conversion
  attr_reader :id

  def initialize(x, y, f, id, d)
    xd = 1 - (x + 1) * 2.0 / (d + 2)
    yd = 1 - (y + 1) * 2.0 / (d + 2)
    xx, yy, zz = case f
                 when 0
                   [xd, yd, 1]
                 when 1
                   [1, xd, yd]
                 when 2
                   [yd, 1, xd]
                 when 3
                   [-xd, -1, -yd]
                 when 4
                   [-yd, -xd, -1]
                 when 5
                   [-1, -yd, -xd]
                 end
    r = Math.sqrt(xx**2 + yy**2 + zz**2)
    @theta = Math.acos(zz/r)
    @phi = Math.atan2(yy, xx)
    @id = id
    @relative = nil
    @conversion = Matrix[[1, 0, 0],
                         [0, 1, 0],
                         [0, 0, 1]]
  end

  def absolute?
    relative.nil?
  end

  def x
    if absolute?
      10 * Math.sin(theta) * Math.cos(phi)
    else
      (conversion * relative.vector)[0]
    end
  end

  def y
    if absolute?
      10 * Math.sin(theta) * Math.sin(phi)
    else
      (conversion * relative.vector)[1]
    end
  end

  def z
    if absolute?
      10 * Math.cos(theta)
    else
      (conversion * relative.vector)[2]
    end
  end

  def vector
    Vector[x, y, z]
  end

  def distance_to(other)
    Math.sqrt((x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2)
  end

  def coordinate
    [x, y, z]
  end
end
