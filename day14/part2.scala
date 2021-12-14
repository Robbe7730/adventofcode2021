import scala.io.StdIn.readLine

object Day14Part2 extends App {
  var polymer_template = readLine()

  readLine()
  var line = readLine()
  var mapping:Map[String, String] = Map()

  while (line != null) {
    var line_split = line.split(" -> ");
    mapping += (line_split(0) -> line_split(1))
    line = readLine()
  }

  var pairs:Map[String, Long] = Map()

  for ((x, i) <- polymer_template.zipWithIndex) {
    if (i + 1 < polymer_template.length()) {
      val pair = s"$x${polymer_template(i+1)}"
      if (!pairs.contains(pair)) {
        pairs += (pair -> 1L)
      } else {
        pairs += (pair -> (pairs(pair) + 1L))
      }
    }
  }

  for (step <- 1 to 40) {
    var new_pairs:Map[String, Long] = Map()

    for (pair <- pairs.keys) {
      val new_value = mapping(pair)

      val first_pair = pair(0) + new_value
      if (!new_pairs.contains(first_pair)) {
        new_pairs += (first_pair -> pairs(pair))
      } else {
        new_pairs += (first_pair -> (new_pairs(first_pair) + pairs(pair)))
      }
      
      val second_pair = new_value + pair(1)
      if (!new_pairs.contains(second_pair)) {
        new_pairs += (second_pair -> pairs(pair))
      } else {
        new_pairs += (second_pair -> (new_pairs(second_pair) + pairs(pair)))
      }
    }
    
    pairs = new_pairs
  }

  var min_value = -1
  var max_value = -1
  var counts:Map[Char,Long] = Map()
  for (pair <- pairs.keys) {
    if (!counts.contains(pair(0))) {
      counts += (pair(0) -> 0)
    }
    counts += (pair(0) -> (counts(pair(0)) + pairs(pair)))

    if (!counts.contains(pair(1))) {
      counts += (pair(1) -> 0)
    }
    counts += (pair(1) -> (counts(pair(1)) + pairs(pair)))
  }

  val last_char = polymer_template(polymer_template.length()-1);
  counts += (last_char -> (counts(last_char)+1))

  println((counts.values.max - counts.values.min) / 2)
}
