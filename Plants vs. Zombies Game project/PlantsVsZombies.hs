module MyGameModule where

import Data.List

type Coordinate = (Int, Int)
type Sun = Int

data Plant = Peashooter Int | Sunflower Int | Walnut Int | CherryBomb Int deriving (Show,Eq)

data Zombie = Basic Int Int | Conehead Int Int | Buckethead Int Int | Vaulting Int Int deriving (Show,Eq)
-- 1. maradék életpont, 2. movementSpeed

data GameModel = GameModel Sun [(Coordinate, Plant)] [(Coordinate, Zombie)] deriving (Show,Eq)

defaultPeashooter :: Plant
defaultPeashooter = Peashooter 3

defaultSunflower :: Plant
defaultSunflower = Sunflower 2

defaultWalnut :: Plant
defaultWalnut = Walnut 15

defaultCherryBomb :: Plant
defaultCherryBomb = CherryBomb 2

basic :: Zombie
basic = Basic 5 1

coneHead :: Zombie
coneHead = Conehead 10 1

bucketHead :: Zombie
bucketHead = Buckethead 20 1

vaulting :: Zombie
vaulting = Vaulting 7 2

---------------------------------------------------------------------------------------------------------

-- SEGÉDFÜGGVÉNYEK

--fromJust :: Maybe a -> a
--fromJust (Just a) = a
--fromJust Nothing = undefined

cordCheckO :: Coordinate -> Bool
cordCheckO (x,y)
    | x >= 0 && x < 5 && y >=0 && y < 12 = True
    | otherwise = False

cordCheckS :: Int -> Bool
cordCheckS x
    | x > 4 || x < 0 = False
    | otherwise = True

-----------------------------------------------------------------------------

validRange :: Coordinate -> Bool
validRange (x,y)
    | x < 5 && x >= 0 && y < 12 && y >= 0 = True
    | otherwise = False

enoughSun :: Int -> Plant -> Bool
enoughSun sun typeOfPlant
    | typeOfPlant == defaultPeashooter && sun >= 100 = True
    | typeOfPlant == defaultSunflower && sun >= 50 = True
    | typeOfPlant == defaultWalnut && sun >= 50 = True
    | typeOfPlant == defaultCherryBomb && sun >= 150 = True
    | otherwise = False

priceOfPlant :: Plant -> Int
priceOfPlant plantType
    | plantType == defaultPeashooter = 100
    | plantType == defaultSunflower || plantType == defaultWalnut = 50
    | plantType == defaultCherryBomb = 150

tryPurchase :: GameModel -> Coordinate -> Plant -> Maybe GameModel
tryPurchase (GameModel sun plants zombies) (x,y) plantType
    | lookup (x,y) plants /= Nothing || not (validRange (x,y)) || not (enoughSun sun plantType) = Nothing
    | lookup (x,y) plants == Nothing && validRange (x,y) && (enoughSun sun plantType) = Just (GameModel (sun - (priceOfPlant plantType)) ([((x,y), plantType)] ++ plants) zombies)

    
------------------------------------------------------------------------------------------

placeZombieInLane :: GameModel -> Zombie -> Int -> Maybe GameModel
placeZombieInLane  (GameModel sun cordOfPlants cordOfZombies) zombieType oszlop
    | (not (cordCheckS oszlop)) = Nothing
    | lookup (oszlop, 11) cordOfZombies /= Nothing = Nothing -- már létező helyre próbálok lerakni zombit
    | otherwise = Just (GameModel sun cordOfPlants ([((oszlop,11), zombieType)] ++ cordOfZombies))

------------------------------------------------------------------------------------------



rightZombie :: Zombie -> Bool
rightZombie (Vaulting _ 2) = False
rightZombie (Vaulting _ 1) = True
rightZombie _ = True

lookUp :: Coordinate -> [(Coordinate, Plant)] -> Bool
lookUp (x,y) ls
    | lookup (x,y) ls /= Nothing = True
    | otherwise = False


reduceSpeed :: Zombie -> Zombie
reduceSpeed (Basic x y) = Basic x y
reduceSpeed (Conehead x y) = Conehead x y
reduceSpeed (Buckethead x y) = Buckethead x y
reduceSpeed (Vaulting x y)
    | y == 2 = (Vaulting x (y-1))
    | otherwise = (Vaulting x y)

lowerHP :: Plant -> Plant
lowerHP (Peashooter currentHP) = (Peashooter (currentHP - 1))
lowerHP (Sunflower currentHP) = (Sunflower (currentHP - 1))
lowerHP (Walnut currentHP) = (Walnut (currentHP - 1))
lowerHP (CherryBomb currentHP) = (CherryBomb (currentHP - 1))


reduceHP :: Coordinate -> [(Coordinate, Plant)] -> [(Coordinate, Plant)]
reduceHP (x,y) [] = []
reduceHP (x,y) (((a,b), plantName):xs)
    | x == a && y == b = [((a,b), lowerHP plantName)] ++ reduceHP (x,y) xs
    | otherwise = ((a,b), plantName) : reduceHP (x,y) xs



moveForward :: (Coordinate, Zombie) -> [(Coordinate, Zombie)] ->[(Coordinate, Zombie)]
moveForward _ [] = []
moveForward ((x,y), zombieType) (((a,b), zombieName):xs)
    | x == a && y == b && zombieType == zombieName = [((x,y-1), zombieType)] ++ xs
    | otherwise = ((a,b), zombieName) : moveForward ((x,y), zombieType) xs




vault :: (Coordinate, Zombie) -> [(Coordinate, Zombie)] ->[(Coordinate, Zombie)]
vault _ [] = []
vault ((x,y), zombieType) (((a,b), zombieName):xs)
    | x == a && y == b && zombieType == zombieName = [((a,b-1), (reduceSpeed zombieName))] ++ xs
    | otherwise = ((a,b), zombieName) : vault ((x,y), zombieType) xs


vault2 :: [(Coordinate, Plant)] -> (Coordinate, Zombie) -> [(Coordinate, Zombie)] ->[(Coordinate, Zombie)]
vault2 _ _ [] = []
vault2 plants ((x,y), zombieType) (((a,b), zombieName):xs)
    | lookUp (x,y-1) plants && x == a && y == b && zombieType == zombieName = [((x,y-2), reduceSpeed zombieType)] ++ xs
    | x == a && y == b && zombieType == zombieName && y - 2 >= 0 = [((x,y-2), zombieType)] ++ xs
    | x == a && y == b && zombieType == zombieName && y - 2 < 0 = [((x,y-1), zombieType)] ++ xs
    | otherwise = [((a,b), zombieName)] ++ vault2 plants ((x,y), zombieType) xs




constructGameModel :: GameModel -> GameModel -> Maybe GameModel -- elsőn iterálok
constructGameModel (GameModel sun plants []) constructedGameModel = Just constructedGameModel -- zombi lista üres -> iteráció vége (-> constructed Gamemodel)
constructGameModel (GameModel sun plants (((x,y), zombieName):bs)) (GameModel sun2 plants2 zombies2)
    | y <= 0 = Nothing -- Iteráció során vizsgált zombi koordinátája 0 -> Beért, vége a játéknak

    -- Zombi + Növény Contact ÉS *megfelelő*(segédfüggvény) a zombi (nem Vaulting, ha igen, akkor pedig nincs már ugrása) - ÜTÉS
    -- ez csak akkor futhat le, ha a zombi nem Vaulting, ha pedig igen, akkor csak 1-es Speeddel rendelkező
    | lookUp (x,y) plants && (rightZombie zombieName) = constructGameModel (GameModel sun plants bs) (GameModel sun2 (reduceHP (x,y) plants2) zombies2)

    -- Zombi + Növény Contact ÉS nem megfelelő a zombi (Vaulting, 2 SPEED) -> NINCS ÜTÉS, csak MOVE
    | lookUp (x,y) plants && (not (rightZombie zombieName)) = constructGameModel (GameModel sun plants bs) (GameModel sun2 plants2 (vault ((x,y), zombieName) zombies2))
    -- nincs Conctact, viszont Vaulting zombi 2 Speed
    -- ((0,5), Vaulting 7 2)
    | not (lookUp (x,y) plants) && (not (rightZombie zombieName)) = constructGameModel (GameModel sun plants bs) (GameModel sun2 plants2 (vault2 plants2 ((x,y), zombieName) zombies2))
    -- NINCS CONTANCT, CSAK MOVE
    | otherwise = constructGameModel (GameModel sun plants bs) (GameModel sun2 plants2 (moveForward ((x,y), zombieName) zombies2))


performZombieActions :: GameModel -> Maybe GameModel
performZombieActions (GameModel sun plants zombies) = constructGameModel (GameModel sun plants zombies) (GameModel sun plants zombies)





cleanBoard :: GameModel -> GameModel
cleanBoard (GameModel sun plants zombies) = (GameModel sun (cleanP plants) (cleanZ zombies))
    where
        cleanP :: [(Coordinate, Plant)] -> [(Coordinate, Plant)]
        cleanP [] = []
        cleanP (((x,y), plantName):xs)
            | isZeroHealthP plantName = cleanP xs
            | otherwise = ((x,y), plantName) : cleanP xs
                where
                    isZeroHealthP :: Plant -> Bool
                    isZeroHealthP (Peashooter hp)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthP (Sunflower hp)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthP (Walnut hp)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthP (CherryBomb hp)
                        | hp <= 0 = True
                        | otherwise = False
        cleanZ :: [(Coordinate, Zombie)] -> [(Coordinate, Zombie)]
        cleanZ [] = []
        cleanZ (((x,y), zombieName):xs)
            | isZeroHealthZ zombieName = cleanZ xs
            | otherwise = ((x,y), zombieName) : cleanZ xs
                where
                    isZeroHealthZ :: Zombie -> Bool
                    isZeroHealthZ (Basic hp speed)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthZ (Conehead hp speed)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthZ (Buckethead hp speed)
                        | hp <= 0 = True
                        | otherwise = False
                    isZeroHealthZ (Vaulting hp speed)
                        | hp <= 0 = True
                        | otherwise = False





explode :: (Coordinate, Plant) -> [(Coordinate, Plant)] -> [(Coordinate, Plant)]
explode _ [] = []
explode ((x,y), plantName) (((a,b), plantType):xs)
    | x == a && y == b && plantName == plantType = ((a,b), (setToZero plantType)) : explode ((x,y), plantName) xs
    | otherwise = ((a,b), plantType) : explode ((x,y), plantName) xs
        where
            setToZero :: Plant -> Plant
            setToZero (CherryBomb hp) = CherryBomb 0


setToZeroZ :: Zombie -> Zombie
setToZeroZ (Vaulting hp speed) = (Vaulting 0 speed)
setToZeroZ (Basic hp speed) = (Basic 0 speed)
setToZeroZ (Conehead hp speed) = (Conehead 0 speed)
setToZeroZ (Buckethead hp speed) = (Buckethead 0 speed)

killZombie :: Coordinate -> [(Coordinate, Zombie)] -> [(Coordinate, Zombie)]
killZombie _ [] = []
killZombie (x,y) (((a,b), zombieType):xs)
    | a == x && b == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x + 1 && b + 1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x && b-1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x - 1 && b - 1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x + 1 && b - 1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x - 1 && b == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x + 1 && b == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x && b + 1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | a == x - 1 && b + 1 == y = ((a,b), setToZeroZ zombieType) : killZombie (x,y) xs
    | otherwise = ((a,b), zombieType) : killZombie (x,y) xs


zombieInLane :: Coordinate -> [(Coordinate, Zombie)] -> Bool
zombieInLane _ [] = False
zombieInLane (x,y) (((xZ,yZ), zombieName):xs)
    | x == xZ = True
    | otherwise = zombieInLane (x,y) xs


notDead :: Plant -> Bool
notDead (Peashooter hp)
    | hp > 0 = True
    | otherwise = False
notDead (Sunflower hp)
    | hp > 0 = True
    | otherwise = False
notDead (Walnut hp)
    | hp > 0 = True
    | otherwise = False
notDead (CherryBomb hp)
    | hp > 0 = True
    |  otherwise = False


lowerZHP :: Zombie -> Zombie
lowerZHP (Basic cHP movementSpeed) = (Basic (cHP - 1) movementSpeed)
lowerZHP (Buckethead cHP movementSpeed) = (Buckethead (cHP - 1) movementSpeed)
lowerZHP (Conehead cHP movementSpeed) = (Conehead (cHP - 1) movementSpeed)
lowerZHP (Vaulting cHP movementSpeed) = (Vaulting (cHP - 1) movementSpeed)


getFirstZombieCord :: Coordinate -> [(Coordinate, Zombie)] -> Coordinate
getFirstZombieCord (xP,yP) (((xZ,yZ), zombieName):xs)
    | xP == xZ = (xZ,yZ)
    | otherwise = getFirstZombieCord (xP,yP) xs

reduceZHP :: Coordinate -> [(Coordinate, Zombie)] -> [(Coordinate, Zombie)]
reduceZHP _ [] = []
reduceZHP (x,y) (((a,b), zombieName):xs) -- (x,y) elso zombi koordinataja
    | x == a && y == b = ((a,b), (lowerZHP zombieName)) : reduceZHP (x,y) xs
    | otherwise = ((a,b), zombieName) : reduceZHP (x,y) xs




zombieInRange :: Coordinate -> [(Coordinate, Zombie)] -> Bool
zombieInRange (x,y) zombies
    | lookup (x,y) zombies /= Nothing = True
    | lookup (x,y+1) zombies /= Nothing = True
    | lookup (x+1,y+1) zombies /= Nothing = True
    | lookup (x-1,y+1) zombies /= Nothing = True
    | lookup (x+1,y) zombies /= Nothing = True
    | lookup (x-1,y) zombies /= Nothing = True
    | lookup (x,y-1) zombies /= Nothing = True
    | lookup (x-1,y-1) zombies /= Nothing = True
    | lookup (x+1,y-1) zombies /= Nothing = True
    | otherwise = False



constructGameModelP :: GameModel -> GameModel -> GameModel
constructGameModelP (GameModel sun [] zombies) constructedGameModel = constructedGameModel
constructGameModelP (GameModel sun (((x,y), plantName):bs) zombies) (GameModel sun2 plants2 zombies2)
    | plantName == defaultSunflower && (notDead plantName) = constructGameModelP (GameModel sun bs zombies) (GameModel (sun2 + 25) plants2 zombies2)

    | plantName == defaultPeashooter && notDead (plantName) && (zombieInLane (x,y) zombies) = constructGameModelP (GameModel sun bs zombies) (GameModel sun2 plants2 (reduceZHP (getFirstZombieCord (x,y) zombies) zombies2))
    
    | plantName == defaultCherryBomb && notDead (plantName)= constructGameModelP (GameModel sun bs zombies) (GameModel sun2 (explode ((x,y), plantName) plants2) (killZombie (x,y) zombies2))
    | otherwise = constructGameModelP (GameModel sun bs zombies) (GameModel sun2 plants2 zombies2)
--  && (zombieInRange (x,y) zombies) Cherrybombol kiszedtem, hogy mindig robbanjon

performPlantActions :: GameModel -> GameModel
performPlantActions (GameModel sun plants zombies) = constructGameModelP (GameModel sun plants zombies) (GameModel sun plants zombies)


--------------------------------------------------------

