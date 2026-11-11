#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 2cm),
  header: align(right)[
    #text(size: 8pt, fill: luma(110))[Zadání 4: Výpočet impulsní funkce pomocí korelační analýzy]
    #v(6pt)
  ],
  footer: context align(center)[
    #text(size: 8.5pt, fill: luma(110))[
      Strana #counter(page).display("1 z 1", both: true)
    ]
  ]
)

#set text(
  font: "Times New Roman",
  lang: "cs",
  size: 9.5pt
)
#set par(justify: true, leading: 0.6em)

#align(center)[
  #v(-12pt)
  #text(size: 15pt, weight: "bold")[Výpočet impulsní funkce pomocí korelační analýzy] \
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + luma(160))
]

#v(2pt)
#align(center)[
    *Jméno a příjmení:* Martin Žůrek \
    *Datum vypracování:* 21. 10. 2026
]
#v(2pt)

== 1. Zadání a postup zpracování úlohy
Cílem úlohy bylo určit impulsní a přechodovou funkci lineární soustavy pomocí korelační analýzy ze dvou souborů vstupně-výstupních dat a porovnat je s identifikací a s analytickými průběhy.

*Postup práce:*
+ Jako první soubor dat byl použit náhodný signál z úlohy 1 (soubory `u.csv` a `y.csv`), jako druhý data získaná buzením soustavy generátorem PNBS z úlohy 3 (soubor `data_pnbs.csv`).
+ Pro oba soubory byly vypočteny autokorelační funkce $R_(u u)(i)$, $R_(y y)(i)$ a vzájemná korelační funkce $R_(u y)(i)$ pro $i = 0, dots, m$, kde $m = "int"(0,1 dot N)$ ($m = 25$ pro náhodný signál, $m = 31$ pro PNBS).
+ Z korelačních funkcí byla pomocí Wienerovy–Hopfovy rovnice určena impulsní funkce a z ní přechodová funkce.
+ Výsledky byly porovnány s odhady modelů ARX a FIR (náhrada System Identification Toolboxu) a s analytickými průběhy (náhrada Control System Toolboxu).
+ Všechny výpočty byly provedeny v programovém prostředí Python (Jupyter Notebook).

== 2. Zdrojová data
První soubor tvoří náhodný signál z úlohy 1 ($N = 251$ vzorků, $T_0 = 1$ s) a odezva soustavy 2. řádu $G_S (s) = 1 / (0,16 s^2 + 2,4 s + 1)$. Doba přechodového děje je $9,2$ s, tedy přibližně 10 vzorků. Druhý soubor tvoří data z úlohy 3: signál PNBS ($N = 63$, $5$ period, celkem $315$ vzorků, $T_0 = 0,5$ s) a odezva soustavy 3. řádu $G_S (s) = 2 / ((2 s + 1)(0,5 s + 1)(0,25 s + 1))$.

#v(2pt)
#figure(
  image("data_nahodny.png", width: 70%),
  caption: [Vstupní náhodný signál $u(t)$ a výstupní signál $y(t)$ z úlohy 1.],
)
Vstup je bílý šum se směrodatnou odchylkou přibližně 1. Soustava jej filtruje jako dolní propust, proto je výstup vyhlazený a výrazně menší (směrodatná odchylka přibližně 0,4). Jde o jedinou realizaci šumu s $251$ vzorky.


#figure(
  image("data_pnbs.png", width: 70%),
  caption: [Vstupní signál PNBS $u(t)$ a výstupní signál $y(t)$ z úlohy 3.],
)
PNBS nabývá pouze hodnot $0$ a $1$ a opakuje se po $63$ vzorcích. Výstup začíná v nule a během první periody se ustaluje, od druhé periody se již opakuje stejný průběh (střední hodnota $1,016$, tedy zesílení $2$ krát střední hodnota vstupu $0,5$). První perioda tak obsahuje přechodný děj, ostatní jsou ustálené.


== 3. Autokorelační a vzájemné korelační funkce
Korelační funkce byly vypočteny pro posunutí $i = 0, dots, m$. U PNBS, který je periodický, byla použita poslední (ustálená) perioda s periodickým prodloužením signálu. Autokorelační funkce vstupu má pík v počátku ($R_(u u)(0) = 1,00771$ u náhodného signálu, $0,50794$ u PNBS) a jinak kolísá kolem nuly s amplitudou $1 / sqrt(N) approx 0,06$ (konečná délka záznamu). U PNBS je konstantní ($0,254$), což odpovídá druhé mocnině střední hodnoty signálu ($0,5^2$), protože nabývá hodnot $0$ a $1$ a při $T_0 = Delta t$ je jeho autokorelace mimo počátek (po odečtení střední hodnoty) nulová. Vstup se tedy chová jako bílý šum. Funkce $R_(y y)(i)$ klesá, jak odpovídá setrvačnosti soustavy. Vzájemná korelační funkce $R_(u y)(i)$ má maximum pro $i = 1$ (náhodný signál), resp. $i = 3$ (PNBS) a poté klesá k nule.

#v(2pt)
#figure(
  image("korelace.png", width: 72%),
  caption: [Autokorelační funkce $R_(u u)(i)$, $R_(y y)(i)$ a vzájemná korelační funkce $R_(u y)(i)$ náhodného signálu (nahoře) a PNBS (dole).],
)

Z grafu je vidět hlavní rozdíl obou signálů. U náhodného signálu je $R_(u u)(i)$ pík v nule se šumem kolem nuly, takže i $R_(u y)(i)$ je zatížena náhodnou chybou (kolísání pro $i > 5$). U PNBS jsou všechny tři funkce hladké, protože je signál periodický a korelační funkce lze určit přesně. Tvar $R_(u y)(i)$ odpovídá tvaru impulsní funkce soustavy.

== 4. Impulsní funkce určená korelační analýzou
Impulsní funkce byla určena z Wienerovy–Hopfovy rovnice, která po diskretizaci s periodou $T_0$ vede na soustavu lineárních rovnic:

#v(4pt)
#align(center)[
  $R_(u y)(tau) = integral_0^infinity g(lambda) R_(u u)(tau - lambda) d lambda, quad bold(r) = bold(R) bold(g), quad bold(g) = bold(R)^(-1) bold(r)$
]
#v(2pt)

kde $bold(R)$ je matice z hodnot $R_(u u)(i)$, $bold(g)$ vektor hodnot impulsní funkce a $bold(r)$ vektor hodnot $R_(u y)(i) / T_0$. Vzájemnou korelační funkci je nutné dělit periodou vzorkování, jinak hodnoty impulsní funkce nevychází. Analytické hodnoty byly získány ze skokové odezvy soustavy, protože $g(t) = d h(t) / d t$. Odhad odpovídá střední hodnotě spojité impulsní funkce přes interval $T_0$ (hodnotám ZOH modelu), proto neleží přesně na křivce $g(t)$.

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (right, right, right, right, right),
    [*$i$*], [*$g(i)$ analyticky (náh.)*], [*$hat(g)(i)$ náhodný*], [*$g(i)$ analyticky (PNBS)*], [*$hat(g)(i)$ PNBS*],
    [0], [0,00000], [0,00143], [0,00000], [0,00008],
    [1], [0,32904], [0,33176], [0,15670], [0,15678],
    [2], [0,23403], [0,23646], [0,49678], [0,49686],
    [3], [0,15240], [0,15398], [0,59868], [0,59876],
    [4], [0,09924], [0,10023], [0,55417], [0,55425],
    [5], [0,06463], [0,06450], [0,46529], [0,46537],
    [6], [0,04209], [0,04383], [0,37495], [0,37503],
    [8], [0,01785], [0,01754], [0,23276], [0,23284],
    [10], [0,00757], [0,00735], [0,14190], [0,14198],
    [15], [0,00089], [0,00111], [0,04071], [0,04079],
    [20], [0,00010], [0,00102], [0,01166], [0,01174],
    [25], [0,00001], [-0,00023], [0,00334], [0,00342],
  )
]

Z tabulky je vidět, že odhad z PNBS se shoduje s analytickými hodnotami na 4 desetinná místa (odchylka nejvýše $0,00008$). U náhodného signálu je shoda horší (odchylka do $0,00280$) a pro velká $i$ odhad kolísá kolem nuly (např. $hat(g)(25) = -0,00023$ místo $0,00001$), což je vliv šumu. Hodnota $hat(g)(0)$ vychází u obou signálů téměř nulová, jak odpovídá soustavě bez přímého průchodu.

#v(2pt)
#figure(
  image("impulsni_funkce.png", width: 64%),
  caption: [Impulsní funkce určená korelační analýzou z náhodného signálu a PNBS, porovnání s analytickými hodnotami.],
)

Odhady (barevné body) leží na analytických hodnotách (černé body). Od spojité křivky $g(t)$ se liší, protože odpovídají průměru přes interval $T_0$; u náhodného signálu je tento rozdíl výraznější, protože $T_0 = 1$ s je velké vzhledem k časovým konstantám soustavy. Průběh z PNBS je hladký, u náhodného signálu je vidět drobný šum v ocasu křivky.

== 5. Přechodová funkce
Přechodová funkce byla vypočtena jako součet hodnot impulsní funkce:

#v(4pt)
#align(center)[
  $h(k) = T_0 sum_(i=0)^(k) g(i), quad k = 0, 1, dots, m$
]
#v(2pt)

Přechodová funkce se ustálí na hodnotě $1,02329$ (náhodný signál, teoreticky $1$) a $1,99996$ (PNBS, teoreticky $2$).

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (right, right, right, right, right),
    [*$i$*], [*$s(i)$ analyticky (náh.)*], [*$hat(s)(i)$ náhodný*], [*$s(i)$ analyticky (PNBS)*], [*$hat(s)(i)$ PNBS*],
    [0], [0,00000], [0,00143], [0,00000], [0,00004],
    [1], [0,32904], [0,33319], [0,07835], [0,07843],
    [2], [0,56307], [0,56965], [0,32674], [0,32686],
    [3], [0,71547], [0,72362], [0,62608], [0,62624],
    [4], [0,81471], [0,82385], [0,90317], [0,90337],
    [5], [0,87934], [0,88835], [1,13581], [1,13605],
    [6], [0,92143], [0,93218], [1,32329], [1,32357],
    [8], [0,96668], [0,97790], [1,58800], [1,58836],
    [10], [0,98587], [0,99685], [1,74990], [1,75033],
    [15], [0,99835], [1,00960], [1,92833], [1,92896],
    [20], [0,99981], [1,01805], [1,97947], [1,98030],
    [25], [0,99998], [1,02329], [1,99412], [1,99515],
  )
]

Chyba impulsní funkce se součtem hromadí, proto je odchylka přechodové funkce u náhodného signálu větší (kolem $0,02$ pro velká $i$), zatímco u PNBS zůstává pod $0,002$. Přechodová funkce z PNBS se tedy velmi dobře ustálí na teoretické hodnotě $2$.

#v(2pt)
#figure(
  image("prechodova_funkce.png", width: 64%),
  caption: [Přechodová funkce vypočtená z impulsní funkce, porovnání s analytickými hodnotami.],
)

Obě přechodové funkce mají správný exponenciální tvar. Křivka z náhodného signálu se postupně odchyluje nad analytickou hodnotu $1$ (nahromaděná chyba), křivka z PNBS s analytickou prakticky splývá.

== 6. Porovnání s identifikací a s analytickými průběhy
Jako náhrada System Identification Toolboxu byl metodou nejmenších čtverců z dat odhadnut model ARX (řád 2 pro náhodný signál, řád 3 pro PNBS) a váhová posloupnost FIR, jako náhrada Control System Toolboxu byly použity funkce `scipy.signal`. Odchylky od analytických hodnot shrnuje tabulka:

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (left, left, right, right),
    [*Metoda*], [*Data*], [*max $|Delta g|$*], [*max $|Delta s|$*],
    [korelační analýza], [náhodný signál], [0,00280], [0,02356],
    [ARX], [náhodný signál], [0,00000], [0,00000],
    [FIR], [náhodný signál], [0,00000], [0,00002],
    [korelační analýza], [PNBS], [0,00008], [0,00127],
    [ARX], [PNBS], [0,00000], [0,00000],
    [FIR], [PNBS], [0,00011], [0,00125],
  )
]

Tabulka potvrzuje, že pro korelační analýzu jsou přesnější data z PNBS ($0,00127$ proti $0,02356$ u přechodové funkce, tedy asi 18krát). Modely ARX a FIR jsou přesné u obou signálů, protože data neobsahují měřicí šum a soustava je řádu, který model odpovídá. Korelační analýza je nejméně přesná, ale na rozdíl od ARX nevyžaduje volbu řádu modelu.

#v(2pt)
#figure(
  image("porovnani_toolbox.png", width: 68%),
  caption: [Impulsní a přechodová funkce získané korelační analýzou, modelem ARX a odhadem FIR, porovnání s analytickými hodnotami.],
)

V grafu splývají ARX, FIR i analytické hodnoty; od nich se odděluje pouze korelační analýza u náhodného signálu (nahoře), u PNBS (dole) je rozdíl neznatelný.

*Srovnání náhodného signálu a PNBS:* Náhodný signál je jen jedna realizace šumu s konečnou délkou, proto jsou jeho korelační funkce zatíženy náhodnou chybou a z nich určená impulsní i přechodová funkce se odchylují od analytických. PNBS je periodický signál s téměř rovnoměrným spektrem, jeho korelační funkce lze určit přesně a výsledek je podstatně přesnější. Výsledky tak odpovídají očekávání, že přesnější odhad dává buzení PNBS.

== 7. Závěr
V rámci měření byly vyčísleny a zhodnoceny veškeré požadované charakteristiky:
- *Korelační funkce:* Autokorelační funkce vstupu má pík v počátku, vstup se chová jako bílý šum. Vzájemná korelační funkce $R_(u y)(i)$ má maximum pro $i = 1$ (náhodný signál), resp. $i = 3$ (PNBS).
- *Impulsní funkce:* Hodnoty určené korelační analýzou se shodují s analytickými s maximální odchylkou $0,00280$ (náhodný signál) a $0,00008$ (PNBS).
- *Přechodová funkce:* Ze součtu impulsní funkce se ustálí na hodnotě $1,02329$ a $1,99996$ (teoreticky $1$ a $2$), maximální odchylka činí $0,02356$ a $0,00127$.
- *Přesnost:* Přesnější jsou data získaná buzením PNBS (odchylka impulsní funkce $0,00008$ proti $0,00280$, přechodové funkce $0,00127$ proti $0,02356$). Náhodný signál je jen jedna realizace šumu, PNBS je periodický a má téměř rovnoměrné spektrum, což odpovídá teorii.
- *Srovnání s identifikací:* Modely ARX a FIR se shodují s analytickými průběhy téměř přesně (odchylka přechodové funkce nejvýše $0,00125$), korelační analýza je méně přesná ($0,02356$ a $0,00127$), ale jednodušší a nevyžaduje volbu struktury modelu.
