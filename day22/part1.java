import java.util.Scanner;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.HashSet;

class Part1 {
    public static void main(String[] args) {
        Scanner s = new Scanner(System.in);
        s.useDelimiter(Pattern.compile("(=|\\.|,|\n)+"));

        Set<Integer> on = new HashSet<>();

        while (s.hasNext("on x") || s.hasNext("off x")) {
            boolean isOn;
            if (s.hasNext("on x")) {
                isOn = true;
            } else {
                isOn = false;
            }
            s.next();

            int startX = s.nextInt();
            int endX = s.nextInt();
            s.next();
            int startY = s.nextInt();
            int endY = s.nextInt();
            s.next("z");
            int startZ = s.nextInt();
            int endZ = s.nextInt();

            if (startX <= 50 && endX >= -50 && startY <= 50 && endY >=-50 && startZ <= 50 && endZ >= -50){
                for (int x = startX; x <= endX; x++) {
                    for (int y = startY; y <= endY; y++) {
                        for (int z = startZ; z <= endZ; z++) {
                            int index = (x+50) * 1000000 + (y+50) * 100 * 50 + (z+50);

                            if (isOn) {
                                on.add(index);
                            } else {
                                on.remove(index);
                            }
                        }
                    }
                }
            }
        }

        System.out.println(on.size());

        s.close();
    }
}
