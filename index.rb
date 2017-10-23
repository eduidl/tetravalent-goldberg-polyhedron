require 'matrix'
require 'csv'

class Point
    attr_accessor :theta, :phi, :relative, :conversion

    def initialize(x, y, f, id)
        xd = 1 - (x + 0.5) * 2 / ($d + 1)
        yd = 1 - (y + 0.5) * 2 / ($d + 1)
        case f
        when 0
            xx, yy, zz = xd, yd, 1
        when 1
            xx, yy, zz = 1, xd, yd
        when 2
            xx, yy, zz = yd, 1, xd
        when 3
            xx, yy, zz = -xd, -1, -yd
        when 4
            xx, yy, zz = -yd, -xd, -1
        when 5
            xx, yy, zz = -1, -yd, -xd
        end
        r = xx ** 2 + yy ** 2 + zz ** 2
        @theta = Math.acos(zz/r)
        @phi   = Math.atan2(yy, xx)
        @id = id
        @relative = id
        @conversion = Matrix[[1, 0, 0],
                             [0, 1, 0],
                             [0, 0, 1]]
    end

    def absolute?()
        @id == @relative
    end

    def x()
        if self.absolute?
            10 * Math.sin(@theta) * Math.cos(@phi)
        else
            (@conversion * $polyhedron.points[@relative].vector)[0]
        end
    end

    def y()
        if self.absolute?
            10 * Math.sin(@theta) * Math.sin(@phi)
        else
            (@conversion * $polyhedron.points[@relative].vector)[1]
        end
    end

    def z()
        if self.absolute?
            10 * Math.cos(@theta)
        else
            (@conversion * $polyhedron.points[@relative].vector)[2]
        end
    end

    def vector()
        Vector[self.x, self.y, self.z]
    end

	# Pointクラスのインスタンスを引数にとり、その点との距離を返す
    def distanceTo(other)
        Math.sqrt((self.x - other.x) ** 2 + (self.y - other.y) ** 2 + (self.z - other.z) ** 2)
    end
end

class Polyhedron
    attr_reader :points

    def initialize(h, k)
        $h, $k = h, k
        $n = 6 * (h ** 2 + k ** 2)
        $d = $h + $k - 1
        @points, @edges, @diagonals, @squares, @triangles = [], [], [], [], []

        getIdConversion()
        if ($k == 0)
            getFaces1()
        else
            getFaces2()
        end

        getEdgesDiagonals()
        checkRelativity()
    end

    # k = 0のとき
    def getFaces1
        # 全体を立方体のように扱う
        @triangles = [[id(0, 0, 0), id(0, 0, 1), id(0, 0, 2)], #A
                      [id(0, 0, 3), id(0, 0, 4), id(0, 0, 5)], #G

                      [id(0, $d, 0), id($d, 0, 1), id($d, $d, 3)], #B
                      [id(0, $d, 1), id($d, 0, 2), id($d, $d, 4)], #E
                      [id(0, $d, 2), id($d, 0, 0), id($d, $d, 5)], #D

                      [id($d, $d, 0), id($d, 0, 5), id(0, $d, 3)], #C
                      [id($d, $d, 1), id($d, 0, 3), id(0, $d, 4)], #C
                      [id($d, $d, 2), id($d, 0, 4), id(0, $d, 5)]] #H

        # 面の部分
        $d.times do |x|
            $d.times do |y|
                6.times do |f|
                    @squares << [id(x, y, f), id(x+1, y, f), id(x+1, y+1, f), id(x, y+1, f)]
                end
            end
        end

        # 辺の部分
        $d.times do |i|
            @squares << [id(i, 0, 1), id(i+1, 0, 1), id(0, i+1, 0), id(0, i, 0)]
            @squares << [id(i, 0, 0), id(i+1, 0, 0), id(0, i+1, 2), id(0, i, 2)]
            @squares << [id(i, 0, 2), id(i+1, 0, 2), id(0, i+1, 1), id(0, i, 1)]

            @squares << [id(i, $d, 0), id(i+1, $d, 0), id($d-(i+1), $d, 3), id($d-i, $d, 3)]
            @squares << [id(i, $d, 1), id(i+1, $d, 1), id($d-(i+1), $d, 4), id($d-i, $d, 4)]
            @squares << [id(i, $d, 2), id(i+1, $d, 2), id($d-(i+1), $d, 5), id($d-i, $d, 5)]

            @squares << [id($d, i, 0), id($d, i+1, 0), id($d, $d-(i+1), 5), id($d, $d-i, 5)]
            @squares << [id($d, i, 1), id($d, i+1, 1), id($d, $d-(i+1), 3), id($d, $d-i, 3)]
            @squares << [id($d, i, 2), id($d, i+1, 2), id($d, $d-(i+1), 4), id($d, $d-i, 4)]

            @squares << [id($d-i, 0, 3), id($d-(i+1), 0, 3), id(0, $d-(i+1), 4), id(0, $d-i, 4)]
            @squares << [id($d-i, 0, 4), id($d-(i+1), 0, 4), id(0, $d-(i+1), 5), id(0, $d-i, 5)]
            @squares << [id($d-i, 0, 5), id($d-(i+1), 0, 5), id(0, $d-(i+1), 3), id(0, $d-i, 3)]
        end
    end

    # k ≠ 0のとき
    def getFaces2()
        @triangles = [[id($h-1, 0, 0), id($h, 0, 0), id($d, $h, 5)],
                      [id($d, $h-1, 0), id($d, $h, 0), id($h-1, 0, 5)],
                      [id($k-1, $d, 0), id($k, $d, 0), id($h, 0, 1)],
                      [id(0, $k-1, 0), id(0, $k, 0), id(0, $k, 1)],
                      [id($h-1, 0, 4), id($h, 0, 4), id($d, $h, 2)],
                      [id($d, $h-1, 4), id($d, $h, 4), id($h-1, 0, 2)],
                      [id($k-1, $d, 4), id($k, $d, 4), id($h, 0, 3)],
                      [id(0, $k-1, 4), id(0, $k, 4), id(0, $k, 3)]]

        # 正方形d*d枚の部分
        $d.times do |x|
            $d.times do |y|
                6.times do |f|
                    @squares << [id(x, y, f), id(x+1, y, f), id(x+1, y+1, f), id(x, y+1, f)]
                end
            end
        end
    end

    def getEdgesDiagonals()
        if !@squares.empty?
            @squares.each do |square|
                addEdge(square[0], square[1])
                addEdge(square[1], square[2])
                addEdge(square[2], square[3])
                addEdge(square[3], square[0])

                addDiagonal(square[0], square[2])
                addDiagonal(square[1], square[3])
            end
        else
            @triangles.each do |triangle|
                addEdge(triangle[0], triangle[1])
                addEdge(triangle[1], triangle[2])
                addEdge(triangle[2], triangle[0])
            end
        end
        @edges.uniq!
        @diagonals.uniq!
    end

    def addEdge(i, j)
        if i > j
            @edges << [j, i]
        else
            @edges << [i, j]
        end
    end

    def addDiagonal(i, j)
        if i > j
            @diagonals << [j, i]
        else
            @diagonals << [i, j]
        end
    end

    def index(x, y, f)
        x + y * ($d + 1) + f * ($d + 1) ** 2
    end

    def id(x, y, f)
        @id_conversion[x + y * ($d + 1) + f * ($d + 1) ** 2]
    end

    def formerDominant?(xy1, xy2)
        return xy1[0] + xy1[1] < xy2[0] + xy2[1] || (xy1[0] + xy1[1] == xy2[0] + xy2[1] && xy1[1] < xy2[1])
    end

    def faceRotation(xy)
        x, y = xy
        xy_set = [[x, y],
                  [$d - y, x],
                  [$d - x, $d - y],
                  [y, $d - x]]
        min = 0
        (1..3).each do |i|
            min = i if formerDominant?(xy_set[i], xy_set[min])
        end
        return { :xy => xy_set[min], :id => id(xy_set[min][0], xy_set[min][1], 0), :rotation_from_xy => min, :rotation_to_xy => (4 - min) % 4 }
    end

    def checkRelativity()
        rotateX = Matrix[[ 1, 0, 0],
                         [ 0, 0,-1],
                         [ 0, 1, 0]]
        rotateY = Matrix[[ 0, 0, 1],
                         [ 0, 1, 0],
                         [-1, 0, 0]]
        rotateZ = Matrix[[ 0,-1, 0],
                         [ 1, 0, 0],
                         [ 0, 0, 1]]

        # 平面0におけるC4対称性の利用
        ($d + 1).times do |x|
            ($d + 1).times do |y|
                id = id(x, y, 0)
                @points[id] = Point.new(x, y, 0, id)
                reference_point = faceRotation([x, y])
                rotation_num = reference_point[:rotation_to_xy]
                if rotation_num > 0
                    @points[id].relative = reference_point[:id]
                    @points[id].conversion = rotateZ ** rotation_num
                end
            end
        end

        # 1-5面はそれぞれ適切に回転させると0面に重なる
        (1..5).each do |f|
            ($d + 1).times do |x|
                ($d + 1).times do |y|
                    id = id(x, y, f)
                    if @points[id].nil?
                        @points[id] = Point.new(x, y, f, id)
                        case f
                        when 1
                            @points[id].relative = id($d-y, x, 0)
                            @points[id].conversion = rotateY
                        when 2
                            @points[id].relative = id(y, $d-x, 0)
                            @points[id].conversion = rotateX ** 3
                        when 3
                            @points[id].relative = id($d-x, $d-y, 0)
                            @points[id].conversion = rotateX
                        when 4
                            @points[id].relative = id(y, $d-x, 0)
                            @points[id].conversion = rotateY ** 2
                        when 5
                            @points[id].relative = id($d-x, $d-y, 0)
                            @points[id].conversion = rotateY ** 3
                        end
                    end
                end
            end
        end

        loop do
            flag = true
            @points.each do |point|
                if !point.absolute? && !@points[point.relative].absolute?
                    point.conversion = point.conversion * @points[point.relative].conversion
                    point.relative = @points[point.relative].relative
                    flag = false
                end
            end
            break if flag
        end

        @absolute_points = @points.select {|point| point.absolute?}
    end

    def getIdConversion()
        equivalent_points = []
        if $k != 0
            $h.times do |dh|
                $k.times do |dk|
                    equivalent_points[index(0+dh, 0+dk, 1)] = index($k-1-dk, $k+dh, 0)
                    equivalent_points[index(0+dh, 0+dk, 2)] = index($k-1-dk, $k+dh, 1)
                    # equivalent_points[index(0+dh, 0+dk, 0)] = index($k-1-dk, $k+dh, 2)
                    equivalent_points[index($k-1-dk, $k+dh, 2)] = index(0+dh, 0+dk, 0)

                    equivalent_points[index($d-dh, $d-dk, 3)] = index($k+dh, $h+dk, 0)
                    equivalent_points[index($d-dh, $d-dk, 4)] = index($k+dh, $h+dk, 1)
                    equivalent_points[index($d-dh, $d-dk, 5)] = index($k+dh, $h+dk, 2)

                    equivalent_points[index($d-dk, 0+dh, 5)] = index($h+dk ,$h-1-dh, 0)
                    equivalent_points[index($d-dk, 0+dh, 3)] = index($h+dk ,$h-1-dh, 1)
                    equivalent_points[index($d-dk, 0+dh, 4)] = index($h+dk ,$h-1-dh, 2)

                    equivalent_points[index($k-1-dk, $k+dh, 4)] = index(0+dh, 0+dk, 3)
                    equivalent_points[index($k-1-dk, $k+dh, 5)] = index(0+dh, 0+dk, 4)
                    # equivalent_points[index($k-1-dk, $k+dh, 3)] = index(0+dh, 0+dk, 5)
                    equivalent_points[index(0+dh, 0+dk, 5)] = index($k-1-dk, $k+dh, 3)
                end
            end
        end

        @id_conversion = []
        count = 0
        (6 * ($d + 1) * ($d + 1)).times do |i|
            if equivalent_points[i].nil?
                @id_conversion[i] = count
                count += 1
            else
                @id_conversion[i] = @id_conversion[equivalent_points[i]]
            end
        end
    end

    def calculateVericesPosition()
        @maximum_delta = 0.1
        @minimum_delta = 0.001
        @delta = @maximum_delta
        @did_movement_flag = false
        @rss_min = Float::INFINITY
        loop do
            @did_movement_flag = false
            @absolute_points.each do |moved_point|
                movePoint(moved_point)
            end
            if !@did_movement_flag && @delta > @minimum_delta
                @delta /= 2
            elsif !@did_movement_flag && @delta <= @minimum_delta
                break
            end
        end

        show()
    end

    def movePoint(moved_point)
        proper_direction = [0, 0]
        directions = [[-1, -1], [ 0, -1], [  1, -1],
                      [-1,  0],           [  1,  0],
                      [-1,  1], [ 0,  1], [  1,  1]]
        directions.each do |theta, phi|
            moved_point.theta += @delta * theta
            moved_point.phi   += @delta * phi
            rss = calculateRSS()
            if rss < @rss_min
                proper_direction = [theta, phi]
                @rss_min = rss
                p rss
            end
            moved_point.theta -= @delta * theta
            moved_point.phi   -= @delta * phi
        end
        if proper_direction != [0, 0]
            moved_point.theta += @delta * proper_direction[0]
            moved_point.phi   += @delta * proper_direction[1]
            @did_movement_flag = true
        end
    end

    def calculateRSS()
        sum = 0
        @edges.each do |i, j|
            sum += @points[i].distanceTo(@points[j])
        end
        @average = sum / $n / 2
        rss = 0
        @edges.each do |i, j|
            rss += (@points[i].distanceTo(@points[j]) - @average) ** 2
        end

        @diagonals.each do |i, j|
            rss += (@points[i].distanceTo(@points[j]) - @average * Math.sqrt(2)) ** 2
        end
        return rss
    end

    def show()
        @points.each do |point|
            puts "[#{point.x}, #{point.y}, #{point.z}],"
        end

        @edges.each do |edge|
            print "[#{edge[0]}, #{edge[1]}], "
        end

        puts ""

        CSV.open('goldberg.csv', 'w') do |file|
            file << ["h", $h, "k", $k, "average length of edges", @average]
            @points.each do |point|
                file << [point.x, point.y, point.z]
            end
        end
    end
end

h, k = 0, 0

loop do
    puts 'hとkをスペース区切りで入力してください'

    input = gets.chomp
    h, k = input.split(' ').map(&:to_i)

    if k.nil? || h < 0 || k < 0
        puts '非負の値を入力してください'
    elsif h == 0 && k == 0
        puts 'h = k = 0は不適な組です'
    elsif h < k
        h, k = k, h
        break
    else
        break
    end
end

$polyhedron = Polyhedron.new(h, k)
$polyhedron.calculateVericesPosition()
