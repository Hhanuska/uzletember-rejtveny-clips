(deffacts init
  (napok hetfo kedd szerda csutortok pentek)
  (program gyaravato konferencia sajto tv uzlet)
  (marka breitling omega patek rolex tag)
  (ertek 1100 1400 1800 2100 2400)
  (napszamok 1 2 3 4 5)
)

(defrule gen-start
  (declare (salience 10))
  (ertek $? ?e $?)
  (napszamok $? ?n $?)
  =>
  (assert (nap ?n ?e))
)

(defrule megold
  ; A keddi napra dragabb orat valasztott, mint a konferenciara
  (ertek $? ?KonfErtek $?)                                                                          ; program ertek KonfErtek
  (ertek $? ?KEDDErtek&~?KonfErtek $?)                                                              ; nap ertek KEDDErtek
  (test (> ?KEDDErtek ?KonfErtek))
  (nap ?KONFERENCIA&~2 ?KonfErtek)                                                                  ; program KONFERENCIA
  (nap 2 ?KEDDErtek)                                                                                ; nap 2

  ; Az 1.1 millios Tag Heuer-t a het korabbi napjan viselte
  ; mint amikor tv interjut adott
  (ertek ?TagERTEK 1400 $?)                                                                         ; ora ertek TagERTEK
  (nap ?TAG ?TagERTEK)                                                                              ; ora TAG
  (ertek $? ?TvErtek&~?KonfErtek $?)                                                                ; program ertek  TvErtek
  (nap ?TV&~?KONFERENCIA ?TvErtek)                                                                  ; program TV
  (test (> ?TV ?TAG))

  ; Csutortok 300 ezerrel dragabb, mint rolex
  (ertek $? ?RolexERTEK&~?TagERTEK $?)                                                              ; ora ertek RolexERTEK
  (nap ?ROLEX&~4&~?TAG ?RolexERTEK)                                                                 ; ora ROLEX
  (ertek $? ?CSUTErtek&~?KEDDErtek $?)                                                              ; nap ertek CSUTErtek
  (nap 4 ?CSUTErtek)                                                                                ; nap 4
  (test (= ?CSUTErtek (+ ?RolexERTEK 300)))

  ; Sajtotajekoztaton viselt Omega, szerdan Patek
  ; kozottuk a kulonbseg nem 400 ezer
  (ertek $? ?OmegaERTEK&~?RolexERTEK&~?TagERTEK $?)                                                 ; ora ertek OmegaERTEK
  (ertek $? ?SajtoErtek&?OmegaERTEK&~?KonfErtek&~?TvErtek $?)                                       ; program ertek SajtoErtek
  (nap ?OMEGA&~?TAG&~?ROLEX ?OmegaERTEK)                                                            ; ora OMEGA
  (nap ?SAJTO&?OMEGA&~?TV&~?KONFERENCIA ?SajtoErtek)                                                ; program SAJTO

  (ertek $? ?SZERDAErtek&~?KEDDErtek&~?CSUTErtek $?)                                                ; nap ertek SZERDAErtek
  (ertek $? ?PatekERTEK&?SZERDAErtek&~?OmegaERTEK&~?RolexERTEK&~?TagERTEK $?)                       ; ora ertek PatekERTEK
  (nap 3 ?SZERDAErtek)                                                                              ; nap 3
  (nap ?PATEK&3&~?TAG&~?ROLEX&~?OMEGA ?PatekERTEK)                                                  ; ora PATEK

  (not (or
    (test (= (- ?SajtoErtek ?PatekERTEK) 400))
    (test (= (- ?SajtoErtek ?PatekERTEK) -400))
  ))

  ; Penteken egy gyaravato unnepseg, ekkor nem Breitlinget viselt
  (ertek $? ?GyarErtek&~?KonfErtek&~?TvErtek&~?SajtoErtek $?)                                       ; program ertek GyarErtek
  (ertek $? ?PENTEKErtek&?GyarErtek&~?KEDDErtek&~?CSUTErtek&~?SZERDAErtek $?)                       ; nap ertek PENTEKErtek
  (nap ?GYAR&5&~?KONFERENCIA&~?TV&~?SAJTO ?GyarErtek)                                               ; program GYAR
  (nap 5 ?PENTEKErtek)                                                                              ; nap 5

  (ertek $? ?BreitlingERTEK&~?TagERTEK&~?RolexERTEK&~?OmegaERTEK&~?PatekERTEK $?)                   ; ora ertek BreitlingERTEK
  (nap ?BREITLING&~5&~?TAG&~?ROLEX&~?OMEGA&~?PATEK ?BreitlingERTEK)                                 ; ora BREITLING

  ; Az uzleti targyalason 1 millioval dragabb orat viselt, mint a sajtotajekoztaton
  (ertek $? ?UzletErtek&~?KonfErtek&~?TvErtek&~?SajtoErtek&~?GyarErtek $?)                          ; program ertek UzletErtek
  (test (= (+ ?SajtoErtek 1000) ?UzletErtek))
  (nap ?UZLET&~?KONFERENCIA&~?TV&~?SAJTO&~?GYAR ?UzletErtek)                                        ; program uzlet

  (ertek $? ?HETFOErtek&~?KEDDErtek&~?SZERDAErtek&~?CSUTErtek&~?PENTEKErtek $?)                     ; nap ertek HETFOErtek
  (nap 1 ?HETFOErtek)                                                                               ; nap 1
  =>
  (assert (megoldas-temp
    programok konferencia ?KONFERENCIA tv ?TV sajto ?SAJTO gyar ?GYAR uzlet ?UZLET
    programErtekek konferencia ?KonfErtek tv ?TvErtek sajto ?SajtoErtek gyar ?GyarErtek uzlet ?UzletErtek

    orak tag ?TAG rolex ?ROLEX omega ?OMEGA patek ?PATEK breitling ?BREITLING
    oraErtekek tag ?TagERTEK rolex ?RolexERTEK omega ?OmegaERTEK patek ?PatekERTEK breitling ?BreitlingERTEK

    napErtekek 1 ?HETFOErtek 2 ?KEDDErtek 3 ?SZERDAErtek 4 ?CSUTErtek 5 ?PENTEKErtek
  ))
)

(defrule invalid
  (napszamok $? ?n $?)
  ?f <- (megoldas-temp
    programok $? ?program ?n $?
    programErtekek $? ?program ?programertek $?
    orak $? ?ora ?n $?
    oraErtekek $? ?ora ?oraertek $?
    napErtekek $? ?n ?napertek $?
  )

  (or 
    (test (neq ?oraertek ?programertek))
    (test (neq ?napertek ?programertek))
  )
  =>
  (retract ?f)
)

(defrule cleanup-1
  (declare (salience -20))
  ?tempmegoldas <- (megoldas-temp $?)
  =>
  (retract ?tempmegoldas)
)

(defrule cleanup-2
  (declare (salience -20))
  ?nap <- (nap ? ?)
  =>
  (retract ?nap)  
)

(defglobal
  ?*megoldasCounter* = 1
)

(defrule prepare
  (declare (salience -5))
  ?f <- (megoldas-temp programok $?tail)
  =>
  (assert (megoldas-temp ?*megoldasCounter* programok $?tail))
  (bind ?*megoldasCounter* (+ ?*megoldasCounter* 1))
  (retract ?f)
)

(defrule print
  (declare (salience -10))
  (napok $?NapNevek)
  (napszamok $? ?n $?)
  ?f <- (megoldas-temp ?c
    programok $? ?program ?n $?
    programErtekek $? ?program ?programertek $?
    orak $? ?ora ?n $?
    oraErtekek $? ?ora ?oraertek $?
  )
  =>
  (bind ?napNev (nth$ ?n $?NapNevek))
  (assert (megoldas ?c ?napNev ?program ?ora ?oraertek))
)
