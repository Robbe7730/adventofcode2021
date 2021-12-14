import scala.io.StdIn.readLine

object Day14Part1 extends App {
  var polymer_template = readLine()

  readLine()
  var line = readLine()
  var mapping:Map[String, String] = Map()

  while (line != null) {
    var line_split = line.split(" -> ");
    mapping += (line_split(0) -> line_split(1))
    line = readLine()
  }

  for (step <- 1 to 10) {
    polymer_template = polymer_template.zipWithIndex.filter { case (x, i) =>
      i + 1 < polymer_template.length()
    }.map{ case (x, i) =>
      val new_value = mapping(s"$x${polymer_template(i+1)}")
      s"$x${new_value}"
    }.mkString + polymer_template(polymer_template.length()-1)
  }

  var min_value = -1
  var max_value = -1
  var counts:Map[Char,Int] = Map()
  for (c <- polymer_template) {
    if (!counts.contains(c)) {
      counts += (c -> 0)
    }
    counts += (c -> (counts(c) + 1))
  }

  println(counts.values.max - counts.values.min)
}
