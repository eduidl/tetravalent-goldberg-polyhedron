require "csv"
require "pathname"

require_relative "./ruby/polyhedron"
require_relative "./ruby/script"

module Main
  module_function

  MAXIMUM_DELTA = 0.1
  MINIMUM_DELTA = 0.01
  DIRECTIONS = [
    [-1, -1], [0, -1], [1, -1],
    [-1, 0], [1, 0],
    [-1, 1], [0, 1], [1, 1],
  ].freeze

  def fix_vertices_position(polyhedron)
    delta = MAXIMUM_DELTA
    rss_min = polyhedron.rss
    loop do
      moved_flag = false
      polyhedron.points.select(&:absolute?).each do |moved_point|
        rss_and_indexes = DIRECTIONS.map.with_index do |(theta, phi), i|
          [polyhedron.rss_if_point_moved(moved_point, delta * theta, delta * phi), i]
        end
        rss, i = rss_and_indexes.min_by { |rss, _i| rss }
        next if rss >= rss_min
        moved_point.theta += delta * DIRECTIONS[i][0]
        moved_point.phi += delta * DIRECTIONS[i][1]
        moved_flag = true
        rss_min = rss
        puts "現在の平均二乗誤差: #{rss_min}"
      end
      next if moved_flag
      break if delta < MINIMUM_DELTA
      delta /= 3
    end
  end

  def result(polyhedron)
    puts "計算終了"
    Pathname.new("./src/data.ts").open("w") do |f|
      f.puts ::Script.text(polyhedron)
    end

    csv_dir = Pathname.new("./csv")
    csv_dir.mkdir() unless csv_dir.exist?
    path = csv_dir.join("#{Time.now.strftime("%Y%m%d%H%M%S")}M#{polyhedron.n}L#{2 * polyhedron.n}.csv")
    CSV.open(path, "w") do |f|
      f << ["h", polyhedron.h]
      f << ["k", polyhedron.k]
      f << ["average length of edges", polyhedron.average_length]
      polyhedron.points.each do |point|
        f << point.coordinate
      end
    end
  end
end

puts "hとkをスペース区切りで入力してください"
begin
  h, k = gets.chomp.split.map(&:to_i)
  raise "値を二つ入力してください" if k.nil?
  raise "非負の値を入力してください" if h.negative? || k.negative?
  raise "h = k = 0は不適な組です" if h.zero? && k.zero?
  # h < kのときはhとkを入れ替えて扱う
  h, k = k, h if h < k
rescue => e
  puts e.message
  retry
end

polyhedron = Polyhedron.new(h, k)
Main.fix_vertices_position(polyhedron)
Main.result(polyhedron)
