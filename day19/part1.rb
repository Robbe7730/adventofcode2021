$beacon_coords = []
$scanner_coords = {
  0 => [0, 0, 0]
}
$corrected_scanner_coords = {}

def main
  line = gets.chomp
  scanners = {}
  while line != nil
    scanner_id = line.sub(/--- scanner (.+) ---/, "\\1").to_i
    scanners[scanner_id] = []
    line = gets

    while line != nil and line.chomp != ""
      coord = line.scan(/(-?\d+)/).map { |x| x[0].to_i }
      scanners[scanner_id].push(coord)
      line = gets
    end

    line = gets
  end

  $corrected_scanner_coords[0] = scanners[0]

  found = [0]
  queue = Queue.new
  queue << 0
  while !queue.empty?
    i = queue.pop
    for j in 0..(scanners.length-1) do
      if j != i
        n = find_overlap_rotated(scanners, i, j)
        if n != nil && (!found.include? n)
          # puts found.length.to_s + "/" + (scanners.length - 1).to_s
          queue << n
          found.append(n)
        end
      end
    end
  end
  puts $beacon_coords.length
end

def rotate(coord)
  x = coord[0]
  y = coord[1]
  z = coord[2]

  return [
    [ x,  y,  z],
    [ x,  z, -y],
    [ x, -y, -z],
    [ x, -z,  y],

    [ y, -x,  z],
    [ y,  z,  x],
    [ y , x, -z],
    [ y, -z, -x],

    [-x, -y,  z],
    [-x, -z, -y],
    [-x,  y, -z],
    [-x,  z,  y],

    [-y,  x,  z],
    [-y, -z,  x],
    [-y, -x, -z],
    [-y,  z, -x],

    [ z,  y, -x],
    [ z,  x,  y],
    [ z, -y,  x],
    [ z, -x, -y],

    [-z, -y, -x],
    [-z, -x,  y],
    [-z,  y,  x],
    [-z,  x, -y],
  ]
end

def rotations(coords)
  t = coords.map{ |x| rotate(x)}

  ret = []
  for i in 0..23 do
    ret.push(t.map{ |x| x[i] }.to_a)
  end
  return ret
end

def find_overlap_rotated(coords, i, j)
  coords_i = $corrected_scanner_coords[i]
  coords_j = coords[j]
  for new_coords_j in rotations(coords_j)
    r = find_overlap(coords_i, new_coords_j, i, j)
    if r != nil
      return r
    end
  end
  return nil
end

def find_overlap(coords_i, coords_j, i, j)
  # Assume coord_i is at (0,0,0)
  for coord_i in coords_i
    for coord_j in coords_j
      # Assuming coord_i and coord_j point to the same beacon, how many overlap?
      base_j_local = coord_j.zip(coord_i).map{|x, y| y - x}
      coords_j_transposed_local = coords_j.map{ |coord_k|
        coord_k.zip(base_j_local).map{ |x, y| x + y }
      }

      overlap = coords_i & coords_j_transposed_local

      if (overlap.length >= 12)
        overlap_global = overlap.map{ |coord|
          coord.zip($scanner_coords[i]).map{ |x, y| x + y }
        }
        coords_j_transposed_global = coords_j_transposed_local.map{ |coord|
          coord.zip($scanner_coords[i]).map{ |x, y| x + y }
        }
        base_j_global = base_j_local.zip($scanner_coords[i]).map{ |x, y| x + y }
        $beacon_coords |= coords_j_transposed_global
        $scanner_coords[j] = base_j_global
        $corrected_scanner_coords[j] = coords_j
        # puts overlap_global.to_s
        # puts base_j_local.to_s
        return j
      end
    end
  end
  return nil
end

main
