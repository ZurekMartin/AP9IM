#set page(
  paper: "a4",
  margin: (x: 1.8cm, top: 2cm, bottom: 2cm),
  header: align(right)[
    #text(size: 8pt, fill: luma(110))[Zadání 1: Výpočet základních statistických charakteristik náhodných veličin]
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
  #text(size: 15pt, weight: "bold")[Výpočet základních statistických charakteristik náhodných veličin] \
  #v(2pt)
  #line(length: 100%, stroke: 0.5pt + luma(160))
]

#v(2pt)
#align(center)[
    *Jméno a příjmení:* Martin Žůrek \
    *Datum vypracování:* 30. 9. 2026
]
#v(2pt)

== 1. Zadání a postup zpracování dat
Cílem úlohy bylo nasimulovat průchod náhodného signálu zadanou spojitou soustavou 2. řádu, porovnat statistické vlastnosti signálu před a po průchodu soustavou a provést korelační a kovarianční analýzu.

*Postup práce:*
+ V prostředí Simulink bylo sestaveno simulační schéma podle zadání. Koeficienty modelu byly zvoleny podle data narození ($a_1 = 4$, $a_2 = 12$).
+ Soustava byla buzena diskrétním bílým šumem pomocí bloku `Random Number` (funkce `randn`). Perioda vzorkování byla nastavena na $T_0 = 1,0$ s tak, aby na přechodový děj připadalo cca 10 vzorků.
+ Nasimulované hodnoty vstupu $u(k T_0)$ a výstupu $y(k T_0)$ byly exportovány do Workspace, zkopírovány do excelu a následně uloženy jako soubory `u.csv` a `y.csv`.
+ V programovém prostředí Python (Jupyter Notebook) byly načteny vektory dat o délce $N = 251$ vzorků a byl proveden výpočet všech zadaných statistických ukazatelů.

#v(2pt)
#figure(
  image("prubehy.png", width: 92%),
  caption: [Časový průběh generovaného vstupního šumu $u(t)$ a filtrované odezvy soustavy $y(t)$.],
)

== 2. Odhady základních statistických charakteristik a kovarianční matice
Z naměřených dvojic vzorků byly podle definičních vztahů vypočteny odhady středních hodnot $m_u, m_y$, rozptylů $s_u^2, s_y^2$, směrodatných odchylek $s_u, s_y$, vzájemné kovariance $C_(u y)$ a koeficientu korelace $r_(u y)$:

#v(6pt)
#align(center)[
  $m_u = 1/N sum_(k=1)^N u(k), quad s_u^2 = 1/N sum_(k=1)^N [u(k) - m_u]^2, quad C_(u y) = 1/N sum_(k=1)^N [u(k) - m_u][y(k) - m_y], quad r_(u y) = C_(u y) / (s_u s_y)$

]

#v(6pt)
#align(center)[
  #table(
    columns: (auto, auto, auto, auto),
    stroke: (_, y) => if y == 0 { (bottom: 1pt + black) } else if y == 4 { (bottom: 0.5pt + luma(150)) } else { (:) },
    fill: (_, y) => if y == 0 { luma(240) } else { none },
    align: (left, right, left, right),
    [*Charakteristika*], [*Hodnota*], [*Charakteristika*], [*Hodnota*],
    [Střední hodnota $m_u$], [0,00591], [Směrodatná odchylka $s_u$], [1,00383],
    [Střední hodnota $m_y$], [0,00789], [Směrodatná odchylka $s_y$], [0,41424],
    [Rozptyl $s_u^2$], [1,00767], [Kovariance $C_(u y)$], [-0,04175],
    [Rozptyl $s_y^2$], [0,17159], [Koeficient korelace $r_(u y)$], [-0,10041],
  )
]

Kovarianční matice vypočtená dle definičního vztahu $bold(C)_X = mat(s_u^2, C_(u y); C_(u y), s_y^2)$ a matice určená funkcí `np.cov(u, y, bias=True)` vykázaly absolutní shodu s přesností $Delta = 2,08 dot 10^(-17)$:
#v(4pt)
$ bold(C)_X = mat(   1.00767043, -0.04175372;   #v(5pt)   -0.04175372,  0.17159415 ) $
#v(4pt)

== 3. Histogramy četností a diskrétní distribuční funkce
Rozložení hodnot obou veličin bylo znázorněno pomocí histogramů četností rozdělených do 10 intervalů a diskrétních distribučních funkcí $F(u)$ a $F(y)$ rozdělených do 20 intervalů.

#v(2pt)
#figure(
  image("histogramy.png", width: 86%),
  caption: [Histogramy četností (10 intervalů) a průběhy diskrétních distribučních funkcí (20 intervalů).],
)

== 4. Korelační a kovarianční analýza
Podle zadání byly pro maximální posunutí $m = "int"(0,1 dot N) = 25$ vypočteny odhady autokorelačních funkcí $R_(u u)(i), R_(y y)(i)$, vzájemné korelační funkce $R_(u y)(i)$, autokovariančních funkcí $C_(u u)(i), C_(y y)(i)$ a vzájemné kovarianční funkce $C_(u y)(i)$:

#v(6pt)
#align(center)[
  $R_(u u)(i) = 1/(N - i) sum_(k=1)^(N - i) u(k) u(k + i), quad C_(u y)(i) = 1/(N - i) sum_(k=1)^(N - i) [u(k) - m_u][y(k + i) - m_y]$
]

#v(2pt)
#figure(
  image("korelace_kovariance.png", width: 86%),
  caption: [Průběhy autokorelačních, vzájemných korelačních a kovariančních funkcí pro posunutí $i = 0 dots 25$.],
)

== 5. Závěr
V rámci měření byly vyčísleny a zhodnoceny veškeré požadované statistické charakteristiky:
- *Chování střední hodnoty:* Vstupní generovaný šum vykazuje střední hodnotu $m_u approx 0,00591$ (teoreticky 0). Na výstupu soustavy je $m_y approx 0,00789$. Jelikož zkoumaná soustava má jednotkové statické zesílení, stejnosměrná úroveň signálu se prakticky nezměnila a zůstala v těsné blízkosti nuly.
- *Změna rozptylu signálu:* Vstupní bílý šum má rozptyl $s_u^2 approx 1,00767$ (odpovídá normovanému buzení $sigma^2 = 1$). Průchodem soustavou došlo k výraznému poklesu rozptylu na $s_y^2 approx 0,17159$ (směrodatná odchylka klesla z $1,00383$ na $0,41424$). Tento pokles je způsoben filtrační dynamikou soustavy 2. řádu, jež působí jako dolní propust.
- *Rozložení pravděpodobnosti:* Histogramy ověřily normální rozdělení obou veličin. Histogram výstupu je vlivem zmenšeného rozptylu podstatně užší a strmější. Distribuční funkce vykazují plynulý esovitý průběh.
- *Korelace a kovariance:* Vzájemná kovariance $C_(u y) approx -0,04175$ i koeficient korelace $r_(u y) approx -0,10041$ potvrzují velmi nízkou okamžitou lineární vazbu mezi neposunutým vstupem a výstupem.
- *Průběh korelačních a kovariančních funkcí:* Autokorelační funkce vstupu $R_(u u)(i)$ má ostrý pík pro $i = 0$ a pro jakékoliv posunutí $i >= 1$ klesá k nule, což potvrzuje nulovou paměť a nekorelovanost bílého šumu. Naopak $R_(y y)(i)$ klesá pozvolna vlivem setrvačnosti a akumulační schopnosti soustavy. Vzájemná funkce $R_(u y)(i)$ zachycuje odezvu systému na vstupní buzení s postupným odezníváním.
