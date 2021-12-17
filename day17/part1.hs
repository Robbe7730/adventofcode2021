-- > 1128
-- > 5050 -> someone elses answer

main :: IO()
main = do
    print $ bestY ((81, 129), (-150, -108))
    -- print $ bestY ((20, 30), (-10, -5))

bestY :: ((Int, Int), (Int, Int)) -> Int
bestY target = foldl (score target) 0 ([(x, y) | x <- [0..300], y <- [0..300]])

score :: ((Int, Int), (Int, Int)) -> Int -> (Int, Int) -> Int
score target best direction = let
  steps = map snd $ (\x -> if' ((length x) == 2000) [] x) $ take 2000 $ takeWhile (\x -> not (hitTarget target x)) $ map snd $ iterate step (direction, (0, 0))
  in max best $ maximum (steps ++ [0])

step :: ((Int, Int), (Int, Int)) -> ((Int, Int), (Int, Int))
step ((dx, dy), (x, y)) = ((decreaseDX dx, dy-1), (x+dx, y+dy))

decreaseDX :: Int -> Int
decreaseDX 0 = 0
decreaseDX a = a + (if' (a > 0) (-1) 1)

hitTarget :: ((Int, Int), (Int, Int)) -> (Int, Int) -> Bool
hitTarget (xrange, yrange) (x, y) = (inRange xrange x) && (inRange yrange y)

inRange :: (Int, Int) -> Int -> Bool
inRange (minX, maxX) x = (x >= minX) && (x <= maxX)

if' :: Bool -> a -> a -> a
if' True  x _ = x
if' False _ y = y
