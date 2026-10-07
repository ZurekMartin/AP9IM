#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 2cm),
  header: align(right)[
    #text(size: 8pt, fill: luma(110))[Zadání 2: Zjištění stacionárnosti a ergodičnosti náhodného procesu]
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
  #text(size: 15pt, weight: "bold")[Zjištění stacionárnosti a ergodičnosti náhodného procesu] \
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + luma(160))
]

#v(2pt)
#align(center)[
    *Jméno a příjmení:* Martin Žůrek \
    *Datum vypracování:* 7. 10. 2026
]
#v(2pt)

== 1. Zadání a postup zpracování dat
Cílem úlohy bylo zpracovat náhodný proces tvořený souborem 1000 realizací, vyšetřit jeho stacionaritu a ergodicitu a určit kovarianční matici a autokovarianční funkce.

*Postup práce:*
+ Byl spuštěn skript generování, ve kterém byl nastaven počet realizací na 1000 o délce 1100 vzorků a parametr `Seed` se měnil od 0 po 999.
+ Nasimulované hodnoty byly zkopírovány do excelu a uloženy jako soubor `a.csv`.
+ V programovém prostředí Python (Jupyter Notebook) bylo prvních 100 vzorků každé realizace vynecháno, takže další zpracování probíhalo s $N = 1000$ vzorky. Řezy byly voleny po 100 hodnotách ($k = 100, 200, dots, 1000$), čímž vzniklo 10 náhodných veličin $X_1, dots, X_(10)$.

#v(2pt)
#figure(
  image("realizace.png", width: 80%),
  caption: [Ukázka 3 náhodně vybraných realizací, svislé čáry vyznačují řezy pro soubor 10 náhodných veličin.],
)

== 2. Vyšetření stacionarity
V 10 řezech $k$ byly pro $M_s$ náhodně vybraných realizací (5, 30 a 1000) určeny odhady střední hodnoty a rozptylu, tabulka uvádí průměr a směrodatnou odchylku těchto 10 hodnot:

#v(6pt)
#align(center)[
  $hat(m)_X (k) = 1/M_s sum_(j=1)^(M_s) x_j (k), quad hat(s)_X^2 (k) = 1/M_s sum_(j=1)^(M_s) [x_j (k) - hat(m)_X (k)]^2$
]

#v(2pt)
#figure(
  image("stacionarita.png", width: 80%),
  caption: [Časové průběhy středních hodnot a rozptylů pro 5, 30 a 1000 realizací.],
)

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else if y == 3 { (bottom: 0.5pt + luma(150)) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (left, right, right, right, right),
    [*Počet realizací*], [*Průměr $hat(m)_X$*], [*Sm. odch. $hat(m)_X$ v čase*], [*Průměr $hat(s)_X^2$*], [*Sm. odch. $hat(s)_X^2$ v čase*],
    [5], [0,05230], [0,35739], [0,34892], [0,24565],
    [30], [-0,03567], [0,18901], [0,46944], [0,10364],
    [1000], [0,00422], [0,03432], [0,51012], [0,02559],
  )
]

== 3. Střední hodnota a rozptyl z jedné realizace a ze souboru realizací
Pro jednu náhodně vybranou realizaci (č. 485) byly určeny časové průměry a porovnány s hodnotami ze souboru realizací:

#v(6pt)
#align(center)[
  $m_j = 1/N sum_(k=1)^N x_j (k), quad s_j^2 = 1/N sum_(k=1)^N [x_j (k) - m_j]^2$
]

#v(2pt)
#align(center)[
  #table(
    columns: (auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else if y == 4 { (bottom: 0.5pt + luma(150)) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (left, right, right),
    [*Veličina*], [*Střední hodnota*], [*Rozptyl*],
    [Jedna realizace (č. 485): časový průměr], [0,04198], [0,45234],
    [Soubor realizací: průměr přes 10 řezů], [0,00422], [0,51012],
    [Všechny realizace: průměr časových průměrů], [0,00282], [0,52142],
    [Všechny realizace: sm. odch. časových průměrů], [0,07485], [0,05773],
  )
]

== 4. Kovarianční matice náhodných veličin
Kovarianční matice souboru 10 náhodných veličin byla vypočtena dle definičního vztahu a porovnána s funkcí `np.cov(Xp, rowvar=False, bias=True)`. Obě matice vykázaly shodu s přesností $Delta = 5,55 dot 10^(-17)$:

#v(6pt)
#align(center)[
  $C_X (p, q) = 1/M sum_(j=1)^M [x_j (k_p) - hat(m)_X (k_p)][x_j (k_q) - hat(m)_X (k_q)], quad p, q = 1, dots, 10$
]

#v(2pt)
#figure(
  image("kovariancni_matice.png", width: 64%),
  caption: [Kovarianční matice náhodných veličin $X_1, dots, X_(10)$.],
)

== 5. Autokovarianční funkce
Autokovarianční funkce byla určena z jedné realizace a ze souboru realizací pro maximální posunutí $m = 300$. U souboru byly porovnány dvě varianty: varianta 1 s pevným počátečním okamžikem $k_0$ (první vzorek) a varianta 2 s průměrováním přes všechny počáteční okamžiky:

#v(6pt)
#align(center)[
  $C_(x x)(i) = 1/(N - i) sum_(k=1)^(N - i) [x(k) - m_j][x(k + i) - m_j]$

  #v(4pt)
  $C_(x x)^((1))(i) = 1/M sum_(j=1)^M [x_j (k_0) - hat(m)_X (k_0)][x_j (k_0 + i) - hat(m)_X (k_0 + i)]$

  #v(4pt)
  $C_(x x)^((2))(i) = 1/(N - i) sum_(k=1)^(N - i) 1/M sum_(j=1)^M [x_j (k) - hat(m)_X (k)][x_j (k + i) - hat(m)_X (k + i)]$
]

#v(2pt)
#figure(
  image("autokovariance_jedna.png", width: 64%),
  caption: [Autokovarianční funkce z jedné realizace (č. 485).],
)

#v(2pt)
#figure(
  image("autokovariance_soubor.png", width: 80%),
  caption: [Autokovarianční funkce ze souboru realizací (varianta 1 a 2), porovnání s jednou realizací a rozdíl variant.],
)

== 6. Závěr
V rámci měření byly vyčísleny a zhodnoceny veškeré požadované charakteristiky náhodného procesu:
- *Stacionarita a vliv počtu realizací:* Na všech 1000 realizacích se střední hodnota i rozptyl v čase prakticky nemění (průměr středních hodnot $0,00422$, průměr rozptylů $0,51012$ se směrodatnou odchylkou v čase $0,02559$, tj. přibližně 5 % průměru), proces je tedy stacionární. Se zvyšujícím se počtem realizací kolísání výrazně klesá: směrodatná odchylka průběhu střední hodnoty klesla z $0,35739$ (5 realizací) přes $0,18901$ (30 realizací) na $0,03432$ (1000 realizací), u rozptylu z $0,24565$ přes $0,10364$ na $0,02559$. U 5 realizací je navíc průměr rozptylů výrazně nižší ($0,34892$ oproti $0,51012$), takže by malý soubor mohl vést k chybnému závěru o nestacionaritě.
- *Ergodicita:* Jedna náhodně vybraná realizace (č. 485) dává $m = 0,04198$ a $s^2 = 0,45234$, soubor realizací $0,00422$ a $0,51012$. Odchylky ($0,03776$ a $0,05778$) jsou srovnatelné se směrodatnými odchylkami časových průměrů mezi jednotlivými realizacemi ($0,07485$ a $0,05773$), jde tedy o běžné výběrové kolísání. Průměry časových průměrů přes všech 1000 realizací ($0,00282$ a $0,52142$) odpovídají hodnotám ze souboru, proto je proces ergodický ve střední hodnotě i rozptylu.
- *Kovarianční matice:* Matice vypočtená dle vzorce se shoduje s funkcí `np.cov` (rozdíl $5,55 dot 10^(-17)$). Diagonální prvky (rozptyly v řezech) leží v rozmezí $0,472$ až $0,554$ a mimodiagonální prvky nepřesahují v absolutní hodnotě $0,037$, protože autokovarianční funkce klesá k nule během přibližně 20 posunutí, tedy mnohem dříve než je vzdálenost řezů (100 vzorků).
- *Autokovarianční funkce:* Autokovarianční funkce má maximum v počátku, rovné rozptylu ($C_(x x)(0) = 0,45234$ z jedné realizace, $0,52456$ varianta 1, $0,52629$ varianta 2), a klesá k nule přibližně během 20 posunutí. Odhad z jedné realizace se pro velká posunutí odchyluje od varianty 2 až o $0,08669$, protože se průměruje z menšího počtu součinů $N - i$.
- *Varianty autokovariance ze souboru:* Varianta 1 využívá pouze 1000 součinů pro každé posunutí, proto kolísá kolem nuly (až $0,06240$ od varianty 2). Varianta 2 průměruje přes všechny počáteční okamžiky a je výrazně hladší, proto je pro stacionární proces vhodnější.
