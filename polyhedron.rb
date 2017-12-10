require './square'
require './triangle'
require './point'

class Polyhedron
  attr_reader :points, :h, :k

  def initialize(h, k)
    @h, @k = h, k
    @points = []
    create_points
  end

  def n
    6 * (h**2 + k**2)
  end

  def d
    h + k - 1
  end

  def squares
    squares = []
    if k.zero?
      # 面の部分
      d.times do |x|
        d.times do |y|
          6.times do |f|
            squares << face_initialize(id(x, y, f), id(x + 1, y, f), id(x + 1, y + 1, f), id(x, y + 1, f))
          end
        end
      end

      # 辺の部分
      d.times do |i|
        squares << face_initialize(id(i, 0, 1), id(i + 1, 0, 1), id(0, i + 1, 0), id(0, i, 0))
        squares << face_initialize(id(i, 0, 0), id(i + 1, 0, 0), id(0, i + 1, 2), id(0, i, 2))
        squares << face_initialize(id(i, 0, 2), id(i + 1, 0, 2), id(0, i + 1, 1), id(0, i, 1))

        squares << face_initialize(id(i, d, 0), id(i + 1, d, 0), id(d - (i + 1), d, 3), id(d - i, d, 3))
        squares << face_initialize(id(i, d, 1), id(i + 1, d, 1), id(d - (i + 1), d, 4), id(d - i, d, 4))
        squares << face_initialize(id(i, d, 2), id(i + 1, d, 2), id(d - (i + 1), d, 5), id(d - i, d, 5))

        squares << face_initialize(id(d, i, 0), id(d, i + 1, 0), id(d, d - (i + 1), 5), id(d, d - i, 5))
        squares << face_initialize(id(d, i, 1), id(d, i + 1, 1), id(d, d - (i + 1), 3), id(d, d - i, 3))
        squares << face_initialize(id(d, i, 2), id(d, i + 1, 2), id(d, d - (i + 1), 4), id(d, d - i, 4))

        squares << face_initialize(id(d - i, 0, 3), id(d - (i + 1), 0, 3), id(0, d - (i + 1), 4), id(0, d - i, 4))
        squares << face_initialize(id(d - i, 0, 4), id(d - (i + 1), 0, 4), id(0, d - (i + 1), 5), id(0, d - i, 5))
        squares << face_initialize(id(d - i, 0, 5), id(d - (i + 1), 0, 5), id(0, d - (i + 1), 3), id(0, d - i, 3))
      end
    else
      # 正方形d*d枚の部分
      d.times do |x|
        d.times do |y|
          6.times do |f|
            squares << face_initialize(id(x, y, f), id(x + 1, y, f), id(x + 1, y + 1, f), id(x, y + 1, f))
          end
        end
      end
    end
    squares
  end

  def triangles
    if k.zero?
      # 全体を立方体のように扱ったときの頂点にあたる
      [
        face_initialize(id(0, 0, 0), id(0, 0, 1), id(0, 0, 2)), #A
        face_initialize(id(0, 0, 3), id(0, 0, 4), id(0, 0, 5)), #G

        face_initialize(id(0, d, 0), id(d, 0, 1), id(d, d, 3)), #B
        face_initialize(id(0, d, 1), id(d, 0, 2), id(d, d, 4)), #E
        face_initialize(id(0, d, 2), id(d, 0, 0), id(d, d, 5)), #D

        face_initialize(id(d, d, 0), id(d, 0, 5), id(0, d, 3)), #C
        face_initialize(id(d, d, 1), id(d, 0, 3), id(0, d, 4)), #F
        face_initialize(id(d, d, 2), id(d, 0, 4), id(0, d, 5)) #H
      ]
    else
      [
        face_initialize(id(h - 1, 0, 0), id(h, 0, 0), id(d, h, 5)),
        face_initialize(id(d, h - 1, 0), id(d, h, 0), id(h - 1, 0, 5)),
        face_initialize(id(k - 1, d, 0), id(k, d, 0), id(h, 0, 1)),
        face_initialize(id(0, k - 1, 0), id(0, k, 0), id(0, k, 1)),

        face_initialize(id(h - 1, 0, 4), id(h, 0, 4), id(d, h, 2)),
        face_initialize(id(d, h - 1, 4), id(d, h, 4), id(h - 1, 0, 2)),
        face_initialize(id(k - 1, d, 4), id(k, d, 4), id(h, 0, 3)),
        face_initialize(id(0, k - 1, 4), id(0, k, 4), id(0, k, 3))
      ]
    end
  end

  def diagonals
    @diagonals ||= squares.map(&:diagonals).flatten.uniq(&:uniq_ids)
  end

  def edges
    return @edges unless @edges.nil?
    faces = squares.empty? ? triangles : squares
    @edges = faces.map(&:sides).flatten.uniq(&:uniq_ids)
  end

  def average_length
    edges.map(&:length).sum / n / 2
  end

  def rss
    average = average_length
    edges.sum { |edge| (edge.length - average)**2 } + diagonals.sum { |diagonal| (diagonal.length - average * Math.sqrt(2))**2 }
  end

  def rss_if_point_moved(moved_point, delta_theta, delta_phi)
    moved_point.theta += delta_theta
    moved_point.phi += delta_phi
    rss_stash = rss
    moved_point.theta -= delta_theta
    moved_point.phi -= delta_phi
    rss_stash
  end


  private

  def face_initialize(*ids)
    points = ids.map { |id| @points[id] }
    case ids.size
    when 3
      ::Triangle.new(*points)
    when 4
      ::Square.new(*points)
    else
      raise
    end
  end

  def index(x, y, f)
    x + y * (d + 1) + f * (d + 1)**2
  end

  def id(x, y, f)
    id_conversion[index(x, y, f)]
  end

  def former_dominant?(xy1, xy2)
    xy1[0] + xy1[1] < xy2[0] + xy2[1] || (xy1[0] + xy1[1] == xy2[0] + xy2[1] && xy1[1] < xy2[1])
  end

  def face_rotation(x, y)
    xy_set = [
      [x, y],
      [d - y, x],
      [d - x, d - y],
      [y, d - x]
    ]
    min = 0
    (1..3).each do |i|
      min = i if former_dominant?(xy_set[i], xy_set[min])
    end
    [id(xy_set[min][0], xy_set[min][1], 0), (4 - min) % 4]
  end

  def create_points
    rotate_x = Matrix[[1, 0, 0],
      [0, 0, -1],
      [0, 1, 0]]
    rotate_y = Matrix[[0, 0, 1],
      [0, 1, 0],
      [-1, 0, 0]]
    rotate_z = Matrix[[0, -1, 0],
      [1, 0, 0],
      [0, 0, 1]]

    # 平面0におけるC4対称性の利用
    (d + 1).times do |x|
      (d + 1).times do |y|
        id = id(x, y, 0)
        @points[id] = Point.new(x, y, 0, id, d)
        reference_point_id, rotation_num = face_rotation(x, y)
        if rotation_num.positive?
          @points[id].relative = points[reference_point_id]
          @points[id].conversion = rotate_z**rotation_num
        end
      end
    end

    # 1-5面はそれぞれ適切に回転させると0面に重なる
    (1..5).each do |f|
      (d + 1).times do |x|
        (d + 1).times do |y|
          id = id(x, y, f)
          next unless @points[id].nil?
          @points[id] = Point.new(x, y, f, id, d)
          @points[id].relative, @points[id].conversion =
            case f
            when 1
              [@points[id(d - y, x, 0)], rotate_y]
            when 2
              [@points[id(y, d - x, 0)], rotate_x**3]
            when 3
              [@points[id(d - x, d - y, 0)], rotate_x]
            when 4
              [@points[id(y, d - x, 0)], rotate_y**2]
            when 5
              [@points[id(d - x, d - y, 0)], rotate_y**3]
            end
        end
      end
    end

    loop do
      flag = true
      points.each do |point|
        next if point.absolute? || point.relative.absolute?
        point.conversion = point.conversion * point.relative.conversion
        point.relative = point.relative.relative
        flag = false
      end
      break if flag
    end
  end

  def id_conversion
    return @id_conversion unless @id_conversion.nil?
    equivalent_points = []
    if k.positive?
      h.times do |dh|
        k.times do |dk|
          equivalent_points[index(0 + dh, 0 + dk, 1)] = index(k - 1 - dk, k + dh, 0)
          equivalent_points[index(0 + dh, 0 + dk, 2)] = index(k - 1 - dk, k + dh, 1)
          # equivalent_points[index(0+dh, 0+dk, 0)] = index(k-1-dk, k+dh, 2)
          equivalent_points[index(k - 1 - dk, k + dh, 2)] = index(0 + dh, 0 + dk, 0)

          equivalent_points[index(d - dh, d - dk, 3)] = index(k + dh, h + dk, 0)
          equivalent_points[index(d - dh, d - dk, 4)] = index(k + dh, h + dk, 1)
          equivalent_points[index(d - dh, d - dk, 5)] = index(k + dh, h + dk, 2)

          equivalent_points[index(d - dk, 0 + dh, 5)] = index(h + dk, h - 1 - dh, 0)
          equivalent_points[index(d - dk, 0 + dh, 3)] = index(h + dk, h - 1 - dh, 1)
          equivalent_points[index(d - dk, 0 + dh, 4)] = index(h + dk, h - 1 - dh, 2)

          equivalent_points[index(k - 1 - dk, k + dh, 4)] = index(0 + dh, 0 + dk, 3)
          equivalent_points[index(k - 1 - dk, k + dh, 5)] = index(0 + dh, 0 + dk, 4)
          # equivalent_points[index(k-1-dk, k+dh, 3)] = index(0+dh, 0+dk, 5)
          equivalent_points[index(0 + dh, 0 + dk, 5)] = index(k - 1 - dk, k + dh, 3)
        end
      end
    end

    @id_conversion = []
    count = 0
    (6 * (d + 1) * (d + 1)).times do |i|
      if equivalent_points[i].nil?
        @id_conversion << count
        count += 1
      else
        @id_conversion << id_conversion[equivalent_points[i]]
      end
    end
    @id_conversion
  end
end
