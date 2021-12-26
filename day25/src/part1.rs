use std::{collections::HashMap, io::stdin};
use std::io::BufRead;

#[derive(Eq, PartialEq)]
enum Direction {
    East,
    South
}

#[derive(Eq, PartialEq)]
struct SeaFloor {
    pub grid: HashMap<(usize, usize), Direction>,
    pub width: usize,
    pub height: usize,
}

impl SeaFloor {
    pub fn new() -> SeaFloor {
        return SeaFloor {
            grid: HashMap::new(),
            width: 0,
            height: 0,
        }
    }

    pub fn print_board(&self) {
        for i in 0..self.height {
            for j in 0..self.width {
                match self.grid.get(&(i, j)) {
                    Some(Direction::East) => print!(">"),
                    Some(Direction::South) => print!("v"),
                    None => print!("."),
                }
            }
            println!()
        }
    }

    pub fn next_board(&self) -> SeaFloor {
        let mut ret = SeaFloor::new();

        ret.width = self.width;
        ret.height = self.height;

        // East
        self.grid.iter()
                 .for_each(|((i, j), v)| {
                     if v == &Direction::East {
                        if self.grid.contains_key(&(*i, (j + 1) % self.width)) {
                            ret.grid.insert((*i, *j), Direction::East);
                        } else {
                            ret.grid.insert((*i, (j + 1) % self.width), Direction::East);
                        }
                     }
                 });

        // South
        self.grid.iter()
                 .for_each(|((i, j), v)| {
                     if v == &Direction::South {
                        if ret.grid.get(&((i+1) % self.height, *j)) != None ||
                             self.grid.get(&((i+1) % self.height, *j)) == Some(&Direction::South) {
                            ret.grid.insert((*i, *j), Direction::South);
                        } else {
                            ret.grid.insert(((i + 1) % self.height, *j), Direction::South);
                        }
                     }
                 });

        ret
    }
}

fn main() {
    let stdin = stdin();
    let stdin_lock = stdin.lock();
    let mut sea_floor = SeaFloor::new();
    stdin_lock.lines()
              .enumerate()
              .for_each(|(i, line_)| {
                  let line = line_.unwrap();
                  if sea_floor.width == 0 {
                      sea_floor.width = line.len();
                  }
                  sea_floor.height += 1;
                  line.chars()
                      .enumerate()
                      .for_each(|(j, c)|
                          if c == '>' {
                              sea_floor.grid.insert((i, j), Direction::East);
                          } else if c == 'v' {
                              sea_floor.grid.insert((i, j), Direction::South);
                          }
                      )
                  }
              );

    let mut ret = 1;
    // println!("----- Board 0 -----");
    // sea_floor.print_board();
    let mut new_sea_floor = sea_floor.next_board();
    // println!("----- Board 1 -----");
    // new_sea_floor.print_board();
    while new_sea_floor != sea_floor {
        sea_floor = new_sea_floor;
        new_sea_floor = sea_floor.next_board();
        ret += 1;
        // println!("----- Board {} -----", ret);
        // new_sea_floor.print_board();
    }

    println!("{}", ret);
}
