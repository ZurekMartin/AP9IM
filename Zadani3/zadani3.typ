#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 2cm),
  header: align(right)[
    #text(size: 8pt, fill: luma(110))[Zadání 3: Buzení modelu dynamické soustavy generátorem PNBS]
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
  #text(size: 15pt, weight: "bold")[Buzení modelu dynamické soustavy generátorem PNBS] \
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + luma(160))
]

#v(2pt)
#align(center)[
    *Jméno a příjmení:* Martin Žůrek \
    *Datum vypracování:* 14. 10. 2026
]
#v(2pt)

== 1. Zadání a postup zpracování úlohy
Cílem úlohy bylo stanovit frekvenční spektrum zadané spojité dynamické soustavy, navrhnout parametry pseudonáhodného binárního signálu (PNBS) s periodou $T_G = N Delta t$ jako optimálního budicího signálu pro identifikaci, ověřit jejich volbu pomocí maximální časové konstanty $T_max$ a porovnat výkonovou spektrální hustotu aproximovaného telegrafního signálu $S_G (f)$ se spektrem soustavy $S_S (f)$ v normovaném zobrazení. Dále bylo úkolem provést diskretizaci soustavy, odvodit diferenční rovnici a simulovat buzení v délce 5 opakovacích period generátoru.

*Postup práce:*
+ Zadání přenos soustavy neuvádí, proto byla zvolena spojitá dynamická soustava 3. řádu s přenosem $G_S (s) = 2 / ((2s + 1)(0,5s + 1)(0,25s + 1))$ (časové konstanty 2; 0,5 a 0,25 s, zesílení 2).
+ Bylo určeno frekvenční spektrum $S_S (omega) = |G_S (j omega)|^2 = G_S (j omega) G_S (-j omega)$ a dosazením $omega = 2 pi f$ spektrum $S_S (f)$, které bylo uloženo do tabulky.
+ Na základě frekvenčního spektra byl zvolen krok hodinových impulsů $Delta t$, amplituda $a$ a počet stupňů registru $n$. Parametry byly ověřeny pomocí $T_max$.
+ Byla vypočtena výkonová spektrální hustota $S_G (f)$ včetně limity pro $f = 0$, uložena do tabulky a vykreslena samostatně i společně se spektrem soustavy (normovaně).
+ S krokem vzorkování $T_0 = Delta t$ byl metodou ZOH určen diskrétní přenos $G_S (z)$ a sestavena diferenční rovnice.
+ V programovém prostředí Python (Jupyter Notebook) byl vytvořen generátor PNBS s hodnotami $0$ a $a$, realizována simulace odezvy pro 5 period $T_G$ a data byla uložena do souboru `data_pnbs.csv` ve formátu $[k, u(k), y(k)]$.

== 2. Frekvenční spektrum soustavy
Frekvenční spektrum soustavy je dáno vztahem:

#v(4pt)
#align(center)[
  $S_S (omega) = |G_S (j omega)|^2 = G_S (j omega) G_S (-j omega) = 4 / ((1 + 4 omega^2)(1 + 0,25 omega^2)(1 + 0,0625 omega^2)), quad S_S (f) = S_S (2 pi f)$
]
#v(2pt)

Maximum spektra je $S_S (0) = 4$. Mezní frekvence, při které spektrum klesne na 5 % maxima ($S_S (f_max) / S_S (f)_max = 0,05$), byla stanovena na $f_max = 0,2488$ Hz ($omega_max = 1,5630$ rad/s). Hodnoty jsou uloženy také v souboru `tabulka_spektrum_soustavy.csv`.

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else if y == 12 { (bottom: 0.5pt + luma(150)) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (right, right, right, right),
    [*$f$ [Hz]*], [*$S_S (f)$*], [*$S_S (f) / S_S (f)_max$*], [*$S_S (f) / S_S (f)_max$ [%]*],
    [0,0000], [4,00000], [1,00000], [100,00 %],
    [0,0500], [2,78161], [0,69540], [69,54 %],
    [0,1000], [1,37760], [0,34440], [34,44 %],
    [0,1500], [0,68108], [0,17027], [17,03 %],
    [0,2000], [0,35675], [0,08919], [8,92 %],
    [*0,2488*], [*0,20000*], [*0,05000*], [*5,00 %*],
    [0,3000], [0,11395], [0,02849], [2,85 %],
    [0,4000], [0,04233], [0,01058], [1,06 %],
    [0,5000], [0,01763], [0,00441], [0,44 %],
    [0,6000], [0,00804], [0,00201], [0,20 %],
    [0,8000], [0,00208], [0,00052], [0,05 %],
    [1,0000], [0,00067], [0,00017], [0,02 %],
  )
]

#v(2pt)
#figure(
  image("spektrum_soustavy.png", width: 62%),
  caption: [Graf závislosti $S_S (f) / S_S (f)_max$ na frekvenci $f$ (modrý bod značí pokles na 5 %).],
)

== 3. Volba parametrů PNBS a kontrola pomocí $T_max$
Spektrum PNBS má na mezní frekvenci $f_max$ klesnout nejvýše o 5 %, tedy $S_G (f_max) / S_G (f)_max >= 0,95$:

#v(4pt)
#align(center)[
  $(sin(pi f Delta t) / (pi f Delta t))^2 >= 0,95 ==> pi f_max Delta t <= 0,3913 ==> Delta t <= 0,3913 / (pi f_max) approx 0,5007 " s"$
]
#v(2pt)

Byl zvolen $Delta t = 0,5$ s, pro které je $S_G (f_max) / S_G (f)_max = 0,9501$ (pokles o 4,99 %). Amplituda $a = 1$ ovlivňuje pouze úroveň spektra, nikoli jeho tvar.

Maximální časová konstanta soustavy aproximované soustavou 1. řádu je $T_max = 2$ s. Pásmo frekvencí rozhodující pro dynamiku soustavy je omezeno frekvencemi $f_"dolní" = 0,5 / (2 pi T_max) = 0,0398$ Hz a $f_"horní" = 10 / (2 pi T_max) = 0,7958$ Hz. Spektrum PNBS je rovnoměrné od nejnižší frekvence $f_d = 1 / (N Delta t)$ po nejvyšší frekvenci $f_h = 0,5 / Delta t$, aby pásmo soustavy pokrylo, musí platit $f_d < f_"dolní"$ a $f_h > f_"horní"$, což vede na zadané podmínky:

#v(4pt)
#align(center)[
  $Delta t < 0,314 T_max = 0,628 " s", quad N Delta t > 12,56 T_max = 25,12 " s"$
]
#v(2pt)

Zvolený krok $Delta t = 0,5$ s první podmínku splňuje ($f_h = 1$ Hz $> f_"horní"$). Druhá podmínka pro opakovací periodu $T_G = N Delta t = (2^n - 1) Delta t$ vede na:
- Pro $n = 5$ je $N = 31$, $T_G = 15,5 " s" < 25,12 " s"$, $f_d = 0,0645$ Hz $> f_"dolní"$ (nevyhovuje).
- Pro $n = 6$ je $N = 63$, $T_G = 31,5 " s" > 25,12 " s"$, $f_d = 0,0317$ Hz $< f_"dolní"$ (vyhovuje).

Byl proto zvolen počet stupňů posuvného registru $n = 6$, délka periody $N = 63$ a amplituda $a = 1$. Buzení nabývá hodnot $0$ a $a = 1$.

== 4. Výkonová spektrální hustota generátoru PNBS
Výkonová spektrální hustota generátoru PNBS je dána vztahem, pro $f = 0$ je limita (podle $1 - cos x = 2 sin^2 (x / 2)$ a $lim_(x -> 0) sin(x) / x = 1$) rovna $a^2 Delta t$:

#v(4pt)
#align(center)[
  $S_G (f) = a^2 / (2 pi^2 f^2 Delta t) (1 - cos 2 pi f Delta t) = a^2 Delta t (sin(pi f Delta t) / (pi f Delta t))^2, quad S_G (0) = a^2 Delta t = 0,5$
]
#v(2pt)

Hodnoty jsou uloženy také v souboru `tabulka_spektrum_pnbs.csv`.

#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else if y == 12 { (bottom: 0.5pt + luma(150)) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (right, right, right, right),
    [*$f$ [Hz]*], [*$S_G (f)$*], [*$S_G (f) / S_G (f)_max$*], [*$S_G (f) / S_G (f)_max$ [%]*],
    [0,0000], [0,50000], [1,00000], [100,00 %],
    [0,0500], [0,49897], [0,99795], [99,79 %],
    [0,1000], [0,49590], [0,99180], [99,18 %],
    [0,1500], [0,49082], [0,98163], [98,16 %],
    [0,2000], [0,48377], [0,96753], [96,75 %],
    [*0,2488*], [*0,47506*], [*0,95013*], [*95,01 %*],
    [0,3000], [0,46407], [0,92814], [92,81 %],
    [0,4000], [0,43757], [0,87514], [87,51 %],
    [0,5000], [0,40528], [0,81057], [81,06 %],
    [0,6000], [0,36842], [0,73684], [73,68 %],
    [0,8000], [0,28639], [0,57279], [57,28 %],
    [1,0000], [0,20264], [0,40528], [40,53 %],
  )
]

#v(2pt)
#figure(
  image("spektrum_pnbs.png", width: 70%),
  caption: [Graf závislosti $S_G (f) / S_G (f)_max$ na frekvenci $f$.],
)

#figure(
  image("spektrum_porovnani.png", width: 70%),
  caption: [Porovnání průběhů $S_S (f) / S_S (f)_max$ a $S_G (f) / S_G (f)_max$ v závislosti na frekvenci $f$.],
)

Modrý bod označuje 5% hodnotu frekvenčního spektra soustavy na frekvenci $f_max$. Vedeme-li jím kolmici, protne průběh výkonové spektrální hustoty PNBS (červený bod) v hodnotě $0,9501$, takže pokles od maxima činí $Delta S_G = 4,99 %$, tedy méně než přípustných 5 %.

== 5. Diskrétní přenos a diferenční rovnice soustavy
Perioda vzorkování byla zvolena shodná s hodinovým taktem $T_0 = Delta t = 0,5$ s. Spojitý přenos $G_S (s) = 2 / (0,25s^3 + 1,625s^2 + 2,75s + 1)$ byl diskretizován metodou ZOH:

#v(4pt)
#align(center)[
  $G_S (z) = cal(Z) {(1 - e^(-T_0 s)) / s G_S (s)} = (0,07835 z^(-1) + 0,14794 z^(-2) + 0,01551 z^(-3)) / (1 - 1,28202 z^(-1) + 0,44169 z^(-2) - 0,03877 z^(-3))$
]
#v(2pt)

Odpovídající diferenční rovnice soustavy pro výpočet odezvy má tvar:

#v(4pt)
#align(center)[
  $y(k) = 1,28202 y(k - 1) - 0,44169 y(k - 2) + 0,03877 y(k - 3) + 0,07835 u(k - 1) + 0,14794 u(k - 2) + 0,01551 u(k - 3)$
]
#v(2pt)

Správnost diskretizace byla ověřena: póly $G_S (z)$ odpovídají $e^(-T_0 / T_i)$ ($0,1353$; $0,3679$; $0,7788$), statické zesílení je $G_S (z = 1) = 2$ a skoková odezva diskrétního modelu se shoduje se spojitým modelem ve vzorkovacích okamžicích s přesností $4 dot 10^(-15)$.

== 6. Simulace buzení soustavy generátorem PNBS
Generátor PNBS byl realizován 6stupňovým posuvným registrem se zpětnou vazbou danou primitivním polynomem $x^6 + x^5 + 1$ (XOR 6. a 5. buňky), s počátečním stavem samých jedniček. Výstup nabývá hodnot $0$ a $a = 1$. Vygenerovaná posloupnost má maximální délku $N = 63$ (32 hodnot $a$, 31 hodnot $0$, 63 různých šestic). Simulace buzení byla provedena pro pětinásobek opakovací periody generátoru ($5 T_G = 157,5$ s, tj. $5N = 315$ vzorků) a data byla uložena do souboru `data_pnbs.csv` ve formátu $[k, u(k), y(k)]$. Perioda vzorkování $T_0 = Delta t$ zajišťuje alespoň dva vzorky na periodu frekvence $f_h$ a doba měření překračuje doporučené minimum dvou period. Odezva byla počítána z diferenční rovnice (shoda s `lfilter` $8,9 dot 10^(-16)$).

#figure(
  image("pnbs_odezva.png", width: 80%),
  caption: [Průběh budicího signálu PNBS $u(t)$ a simulované odezvy soustavy $y(t)$ pro 5 opakovacích period (svislé čáry oddělují jednotlivé periody $T_G = 31,5$ s).],
)

== 7. Ověření frekvenčních vlastností generovaných dat
Z ustáleného stavu (2. až 5. perioda, rozdíl odezev $2,1 dot 10^(-7)$) byla určena frekvenční charakteristika $hat(G)(f_k) = Y(k) / U(k)$ na harmonických $f_k = k / T_G$ (krok $0,0317$ Hz, v pásmu $f <= f_max$ leží 7 harmonických). Odhad se shoduje s $G_S (z)$ s přesností $2 dot 10^(-7)$ a $|hat(G)(f)|^2$ se v pásmu $f <= f_max$ liší od $S_S (f)$ nejvýše o $4,31$ %, což odpovídá poklesu $S_G$ vlivem držení impulsu (4,99 % na $f_max$). Autokorelační funkce signálu má píky pro násobky $N$ a hodnotu $-1 / (N - 1)$ mimo ně.

#figure(
  image("pnbs_overeni.png", width: 85%),
  caption: [Porovnání frekvenčního spektra soustavy a výkonového spektra PNBS získaných z uložených dat s teoretickými průběhy.],
)

== 8. Závěr
V rámci měření byly vyčísleny a zhodnoceny veškeré požadované charakteristiky:
- *Spektrum soustavy:* Soustava má dolnopropustný charakter s maximem $S_S (0) = 4$. Spektrum klesne na 5 % maxima na frekvenci $f_max approx 0,2488$ Hz ($omega_max approx 1,5630$ rad/s).
- *Parametry PNBS:* Z podmínky poklesu $S_G$ o nejvýše 5 % na $f_max$ vyšlo $Delta t <= 0,5007$ s, byl zvolen $Delta t = 0,5$ s. Na $f_max$ pak spektrum PNBS klesne o 4,99 % ($0,9501$ maxima), takže je v pásmu soustavy prakticky rovnoměrné. Amplituda $a = 1$ ovlivňuje pouze úroveň spektra $S_G (0) = a^2 Delta t = 0,5$.
- *Kontrola pomocí $T_max$:* Pro $T_max = 2$ s leží pásmo rozhodující pro dynamiku soustavy mezi $f_"dolní" = 0,0398$ Hz a $f_"horní" = 0,7958$ Hz. Podmínka $Delta t < 0,314 T_max = 0,628$ s je splněna ($f_h = 1$ Hz $> f_"horní"$). Podmínku $N Delta t > 12,56 T_max = 25,12$ s ($f_d < f_"dolní"$) splňuje až $n = 6$ ($T_G = 31,5$ s, $f_d = 0,0317$ Hz), pro $n = 5$ je $T_G = 15,5$ s a podmínka splněna není.
- *Diskrétní model a simulace:* Diskrétní přenos $G_S (z)$ a diferenční rovnice 3. řádu mají póly $e^(-T_0 / T_i)$ a statické zesílení $2$. Generátor s polynomem $x^6 + x^5 + 1$ vytváří posloupnost maximální délky $N = 63$, bylo uloženo $5N = 315$ vzorků.
- *Frekvenční vlastnosti dat:* Spektrum určené z dat se shoduje s $G_S (z)$ s přesností $2 dot 10^(-7)$ a v pásmu $f <= f_max$ se od $S_S (f)$ liší nejvýše o $4,31$ %, uložená data proto odpovídají frekvenčním vlastnostem soustavy.
