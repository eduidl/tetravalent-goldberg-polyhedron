require 'csv'

require './polyhedron'
require './script'

module Main
  module_function

  MAXIMUM_DELTA = 0.1.freeze
  MINIMUM_DELTA = 0.001.freeze
  DIRECTIONS = [[1, 0], [-1, 0], [0, 1], [0, -1]].freeze

  def fix_vertices_position(polyhedron)
    delta = MAXIMUM_DELTA.dup
    # rss_min = polyhedron.rss
    rss_min = polyhedron.rss
    loop do
      did_movement_flag = false
      polyhedron.points.select(&:absolute?).each do |moved_point|
        rss_and_indexes = DIRECTIONS.map.with_index do |(theta, phi), i|
          [polyhedron.rss_if_point_moved(moved_point, delta * theta, delta * phi), i]
        end
        rss, i = rss_and_indexes.min { |(rss1, _), (rss2, _)| rss1 <=> rss2 }
        next if rss >= rss_min
        moved_point.theta += delta * DIRECTIONS[i][0]
        moved_point.phi += delta * DIRECTIONS[i][1]
        did_movement_flag = true
        rss_min = rss
        puts "現在の平均二乗誤差: #{rss_min}"
      end
      next if did_movement_flag
      break if delta < MINIMUM_DELTA
      delta /= 2
    end
  end

  def result(polyhedron)
    puts '計算終了'
    point_arr = polyhedron.points.map(&:coordinate)
    edge_arr = polyhedron.edges.map(&:uniq_ids)
    File.open('./js/script.js', 'w+') do |file|
      file.puts ::Script.text(point_arr, edge_arr)
    end

    CSV.open("csv/#{Time.now.strftime('%Y%m%d%H%M%S')}M#{polyhedron.n}L#{2 * polyhedron.n}.csv", 'w+') do |file|
      file << ['h', polyhedron.h]
      file << ['k', polyhedron.k]
      file << ['average length of edges', polyhedron.average_length]
      polyhedron.points.each do |point|
        file << point.coordinate
      end
    end
  end
end

puts 'hとkをスペース区切りで入力してください'
begin
  h, k = gets.chomp.split(' ').map(&:to_i)
  raise '値を二つ入力してください' if k.nil?
  raise '非負の値を入力してください' if h.negative? || k.negative?
  raise 'h = k = 0は不適な組です' if h.zero? && k.zero?
  # h < kのときはhとkを入れ替えて扱う
  h, k = k, h if h < k
rescue => e
  puts e.message
  retry
end

polyhedron = Polyhedron.new(h, k)
Main.fix_vertices_position(polyhedron)
Main.result(polyhedron)
