import java.util.Scanner;
import java.util.Set;
import java.util.TreeSet;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

class Cube {
    long startX;
    long endX;
    long startY;
    long endY;
    long startZ;
    long endZ;

    public Cube(long startX, long endX, long startY, long endY, long startZ, long endZ) {
        this.startX = startX;
        this.endX = endX;
        this.startY = startY;
        this.endY = endY;
        this.startZ = startZ;
        this.endZ = endZ;
    }

    public Range xRange() {
        return new Range(this.startX, this.endX);
    }

    public Range yRange() {
        return new Range(this.startY, this.endY);
    }

    public Range zRange() {
        return new Range(this.startZ, this.endZ);
    }

    public boolean contains(long x, long y, long z) {
        return (x >= startX && x <= endX && y >= startY && y <= endY && z >= startZ && z <= endZ);
    }

    public boolean contains(Cube other) {
        return (this.contains(other.startX, other.startY, other.startZ) && this.contains(other.endX, other.endY, other.endZ));
    }

    public static Cube fromRanges(Range x, Range y, Range z) {
        return new Cube(x.start, x.end, y.start, y.end, z.start, z.end);
    }

    public long volume() {
        return (this.endX - this.startX) * (this.endY - this.startY) * (this.endZ - this.startZ);
    }
}

class RangeIntersection {
    Range before, overlap, after;

    public RangeIntersection(Range before, Range overlap, Range after) {
        this.before = before;
        this.overlap = overlap;
        this.after = after;
    }
}

class Range {
    long start;
    long end;

    public Range(long start, long end) {
        this.start = start;
        this.end = end;
        if (end < start) {
            throw new RuntimeException("Invalid range: Range(" + start + ", " + end + ")");
        }
    }

    public RangeIntersection intersect(Range other) {

        if (this.start == this.end) {
            return new RangeIntersection(
                other,
                new Range(0, 0),
                new Range(0, 0)
            );
        }

        if (other.start == other.end) {
            return new RangeIntersection(
                this,
                new Range(0, 0),
                new Range(0, 0)
            );
        }

        if (this.start == other.start) {
            return new RangeIntersection(
                new Range(0, 0),
                new Range(this.start, Math.min(this.end, other.end)),
                new Range(Math.min(this.end, other.end), Math.max(this.end, other.end))
            );
        }

        if (this.start == other.end) {
            return new RangeIntersection(
                other,
                new Range(0, 0),
                this
            );
        }

        if (this.end == other.start) {
            return new RangeIntersection(
                this,
                new Range(0, 0),
                other
            );
        }

        if (this.end == other.end) {
            return new RangeIntersection(
                new Range(Math.min(this.start, other.start), Math.max(this.start, other.start)),
                new Range(Math.max(this.start, other.start), this.end),
                new Range(0, 0)
            );
        }

        TreeSet<Long> values = new TreeSet<>();

        values.add(this.start);
        values.add(this.end);
        values.add(other.start);
        values.add(other.end);

        if (values.size() != 4) {
            throw new RuntimeException("TODO: Touching ranges [" + this.start + "," + this.end + "] and [" + other.start + "," + other.end + "]");
        }

        Iterator<Long> it = values.iterator();
        long a = it.next();
        long b = it.next();
        long c = it.next();
        long d = it.next();
        return new RangeIntersection(new Range(a, b), new Range(b, c), new Range(c, d));
    }
}

class Part2 {
    public static void main(String[] args) {
        Scanner s = new Scanner(System.in);
        s.useDelimiter(Pattern.compile("(=|\\.|,|\n)+"));

        Set<Cube> cubes = new HashSet<>();
        int i = 0;

        while (s.hasNext("on x") || s.hasNext("off x")) {
            i++;
            boolean isOn;
            if (s.hasNext("on x")) {
                isOn = true;
            } else {
                isOn = false;
            }
            s.next();

            long startX = s.nextLong();
            long endX = s.nextLong() + 1;
            s.next();
            long startY = s.nextLong();
            long endY = s.nextLong() + 1;
            s.next("z");
            long startZ = s.nextLong();
            long endZ = s.nextLong() + 1;

            Cube cube = new Cube(startX, endX, startY, endY, startZ, endZ);

            //System.out.printf("--- Cube with volume %d ---%n", cube.volume());

            Set<Cube> toRemove = new HashSet<>();
            Set<Cube> toAdd = new HashSet<>();
            if (isOn) {
                toAdd.add(cube);
            }

            for (Cube otherCube : cubes) {
                if (
                    (otherCube.endX <= cube.startX || cube.endX <= otherCube.startX) ||
                    (otherCube.endY <= cube.startY || cube.endY <= otherCube.startY) ||
                    (otherCube.endZ <= cube.startZ || cube.endZ <= otherCube.startZ)
                ) {
                    continue;
                }
                toRemove.add(otherCube);

                // find 27 sub-cubes
                RangeIntersection xIntersection = cube.xRange().intersect(otherCube.xRange());
                RangeIntersection yIntersection = cube.yRange().intersect(otherCube.yRange());
                RangeIntersection zIntersection = cube.zRange().intersect(otherCube.zRange());

                Cube[] newCubes = new Cube[]{
                    Cube.fromRanges(xIntersection.before, yIntersection.before, zIntersection.before),
                    Cube.fromRanges(xIntersection.before, yIntersection.before, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.before, yIntersection.before, zIntersection.after),
                    Cube.fromRanges(xIntersection.before, yIntersection.overlap, zIntersection.before),
                    Cube.fromRanges(xIntersection.before, yIntersection.overlap, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.before, yIntersection.overlap, zIntersection.after),
                    Cube.fromRanges(xIntersection.before, yIntersection.after, zIntersection.before),
                    Cube.fromRanges(xIntersection.before, yIntersection.after, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.before, yIntersection.after, zIntersection.after),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.before, zIntersection.before),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.before, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.before, zIntersection.after),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.overlap, zIntersection.before),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.overlap, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.overlap, zIntersection.after),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.after, zIntersection.before),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.after, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.overlap, yIntersection.after, zIntersection.after),
                    Cube.fromRanges(xIntersection.after, yIntersection.before, zIntersection.before),
                    Cube.fromRanges(xIntersection.after, yIntersection.before, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.after, yIntersection.before, zIntersection.after),
                    Cube.fromRanges(xIntersection.after, yIntersection.overlap, zIntersection.before),
                    Cube.fromRanges(xIntersection.after, yIntersection.overlap, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.after, yIntersection.overlap, zIntersection.after),
                    Cube.fromRanges(xIntersection.after, yIntersection.after, zIntersection.before),
                    Cube.fromRanges(xIntersection.after, yIntersection.after, zIntersection.overlap),
                    Cube.fromRanges(xIntersection.after, yIntersection.after, zIntersection.after),
                };

                // Re-add all cubes part of otherCube not part of cube
                for (Cube subCube : newCubes) {
                    if (subCube.volume() != 0 && otherCube.contains(subCube) && !cube.contains(subCube)) {
                        // System.out.printf("Re-adding cube (%d %d %d) (%d %d %d)%n", subCube.startX, subCube.startY, subCube.startZ, subCube.endX, subCube.endY, subCube.endZ);
                        toAdd.add(subCube);
                    }
                }
            }

            // System.out.printf("Adding %d new cubes%n", toAdd.size());
            // System.out.printf("Removing %d cubes%n", toRemove.size());
            cubes.addAll(toAdd);
            cubes.removeAll(toRemove);
        }

        long ret = 0L;

        for (Cube cube : cubes) {
            ret += cube.volume();
        }

        System.out.println(ret);

        s.close();
    }
}
