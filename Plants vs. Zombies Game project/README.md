# Játék projekt leírása

A projekt során egy leegyszerűsített verzióját fogjuk a Plants vs Zombies játéknak implementálni. A játékban egy 5 soros pályán zombik masíroznak jobbról balra, míg a játékos növények lerakávásval próbálja megvédeni magát. A zombik nyernek, ha egy zombi elér a pálya bal oldalára. A játékos nyer, ha az összes zombi meghal. A játék során Napokat kell gyűjteni, amellyvel új növényeket lehet venni. Az eredeti videójátékkal kapcsolatban egyéb információ a Wikipédián olvasható.

Mivel az implementációban nem lehet grafikai felületünk, ezért csak egy szimulációt fogunk elvégezni, vagyis önmagától fognak zajlani a körök. A játék menetét diszkrét időintervallumokra bontjuk (úgy nevezett körökre), amelyek eltelése után minden játékban szereplő zombi és növény elvégezhet egy automatikus műveletet. Például: A zombi megy előre, míg a növény lő.

# Játékmodell

A játékmodell fogja tartalmazni a növényeket, zombikat és a játékos Napjainak számát.

# Növények

Növényekből szükségünk lesz az alap növényekre: Peashooter, Sunflower, Walnut és CherryBomb. Definiáljunk egy Plant adattípust az előbb említett konstruktorokkal. Minden konstruktornak legyen egy Int típusú paramétere, amely a maradék életpontjukat reprezentálja a példányoknak. A növények funkcionalitását később implementáljuk.

# Zombik
Definiáljuk a Zombie adattípust az alábbi konstruktorokkal: Basic, Conehead, Buckethead és Vaulting. Minden konstruktornak legyen két Int típusú paramétere, amelyből az első a maradék életponját, míg a második a mozgási sebességét reprezentálja.

# Modell
Definiáljuk a GameModel adattípust, amelynek egy GameModel nevű konstruktora van. A konstruktor tárolja, hogy mennyi Napja van a játékosnak egy Sun típusú paraméterben, illetve a növények és a zombik helyét és pozícióit egy [(Coordinate, Plant)] és [(Coordinate, Zombie)] típusú paraméterekben.

# Vásárlás

A játékban minden növénynek van egy előre megadott ára:

Peashooter-nek 100 Nap,
Sunflower-nek és Walnut-nak 50 Nap
CherryBomb-nak 150 Nap.

# Zombik lerakása

A zombik az eredeti játékban mindig valamelyik sor végén jelennek meg - néhány irreleváns kivétellel. Ezt a sémát próbáljuk meg a szimulációban is követni. Definiáljuk a placeZombieInLane nevű függvényt, amely egy zombit lehelyez valamelyik sáv végére. Ha az adott sáv végén már van zombi vagy a sáv száma nem megfelelő, akkor adjunk vissza Nothingot. A játéktérben 5 sáv van és azok 12 hosszúak. Az indexelést 0-tól kezdjük.

# Zombik mozgása és támadása

A zombik minden kör alatt a sebességüknek megfelelő mezőt mennek előre, amennyiben tudnak. Ha egy zombi nem tud előre menni, mert a mezőn, amin áll, van egy növény, akkor a zombi beleharap a növénybe és csökkenti az életponját 1-gyel és továbbra is azon a mezőn marad. Ez alól csak a Vaulting zombi a kivétel: ha még a sebessége 2, akkor az első növényt átugorja és halad tovább, viszont a sebessége 1-re csökken.

# Pályatisztítás

Amikor egy növény lelő egy zombit vagy egy zombi megeszik egy növényt, és az életpontja 0-ra vagy az alá esik, akkor ezeket a halott lényeket el kell tüntetni a pályáról. Definiáljuk a cleanBoard függvényt, amely letöröl mindent a pályáról, aminek legfeljebb 0 életpontja van.

# Növények műveletei

A növények minden körben valami műveletet végeznek el:

- a Peashooter meglövi a sorban lévő első előtte lévő zombit,
- a Sunflower produkál 25 Napot,
- a CherryBomb felrobban, megölvén saját magát és az összes zombit egy 3 * 3-as területen, ahol a növény a középpontja (itt a megölés az életpontok 0-ra való állítását jelenti).