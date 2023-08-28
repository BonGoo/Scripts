SELECT
	CASE
		WHEN SUM(il.TwI_Ilosc - il.TwI_Rezerwacje) >= 20 THEN 20
		ELSE SUM(il.TwI_Ilosc - il.TwI_Rezerwacje)
	END AS Ilosc,
	MAX(ta7.TwA_WartoscTxt) AS Producent,
	MAX(ta9.TwA_WartoscTxt) AS Predkosc,
	MAX(ta10.TwA_WartoscTxt) AS Nosnosc,
	MAX(ta8.TwA_WartoscTxt) AS Sezon,
	CASE
		WHEN MAX(t.Twr_TwGGIDNumer) = 2483 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.10))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2482 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.15))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2485 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2484 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2735 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.24))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2486 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0)) 
		--WHEN MAX(t.Twr_TwGGIDNumer) = 4349 THEN MAX(ISNULL(round(((tc.TwC_Wartosc)/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 4348 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2488 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.18))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2489 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2487 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 11504 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.18))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2733 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2506 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0)) 
		WHEN MAX(t.Twr_TwGGIDNumer) = 2496 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2498 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2737 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.24))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2497 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2495 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2504 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2501 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2498 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2503 THEN MAX(ISNULL(round(((tc.TwC_Wartosc - (tc.TwC_Wartosc*0.20))/ 1.23),2),0))
		WHEN MAX(t.Twr_TwGGIDNumer) = 2733 THEN MAX(ISNULL(round(((tc.TwC_Wartosc)/ 1.23),2),0))
	END AS Cena,
	ta12.TwA_WartoscTxt AS data_produkcji,
	MAX(ta5.TwA_WartoscTxt) AS Rozmiar,
	MAX(t.Twr_Nazwa) AS Nazwa,
	MAX(ta3.TwA_WartoscTxt) AS Dostawa,
	t.Twr_ProducentKod AS Kod,
	MAX(ta11.TwA_WartoscTxt) AS Typ,
	t.Twr_AutoKodSeria AS Opis --Pole wartość która się podgrywa, jako fantom dla pola opis
	FROM
		CDN_DB.cdn.TwrIlosci il
			inner JOIN (
				SELECT
						til.TwI_TwrId,
						max(til.TwI_Data) AS [DATA]
				FROM
						CDN_DB.CDN.TwrIlosci til 
				WHERE
						til.TwI_MagId = 1 
					AND til.TwI_Data <= convert(varchar(25),
					getdate(),
					120)
				GROUP BY
						til.TwI_TwrId) AS il_data ON
					il.TwI_TwrId = il_data.TwI_TwrId AND il.twi_data = il_data.data	AND il.TwI_MagId = 1
LEFT OUTER JOIN CDN_DB.CDN.Towary t ON
	t.Twr_TwrId = il.TwI_TwrId
LEFT OUTER JOIN CDN_DB.CDN.Magazyny m ON
	m.Mag_MagId  = il.TwI_MagId 
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta3 ON
	ta3.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrCeny tc ON
	tc.TwC_TwrID = t.Twr_TwrId
	AND tc.TwC_Typ = 2
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta5 ON
	ta5.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta6 ON
	ta6.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta7 ON
	ta7.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta8 ON
	ta8.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta9 ON
	ta9.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta10 ON
	ta10.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta11 ON
	ta11.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta12 ON
	ta12.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta13 ON
	ta13.TwA_TwrId = t.Twr_TwrId
LEFT OUTER JOIN CDN_DB.CDN.TwrAtrybuty ta14 ON
	ta14.TwA_TwrId = t.Twr_TwrId
WHERE 
	( m.Mag_MagId = 1
		AND ta5.TwA_DeAId = 54
		AND ta7.TwA_DeAId = 25 
		AND (ta6.TwA_DeAId = 74 AND ta6.TwA_WartoscTxt = 'TAK')
		AND ta8.TwA_DeAId = 60
		AND ta9.TwA_DeAId = 56
		AND ta10.TwA_DeAId = 55
		AND ta11.TwA_DeAId = 30
			AND (ta12.TwA_DeAId = 73)
			AND ta13.TwA_DeAId = 32
			AND ta3.TwA_DeAId = 59
			AND ta14.TwA_DeAId = 72
			AND t.Twr_UdostepniajWCenniku = 1
		)
GROUP BY
	t.Twr_ProducentKod,
	t.Twr_AutoKodSeria ,
	ta12.TwA_WartoscTxt
HAVING 
SUM(il.TwI_Ilosc - il.TwI_Rezerwacje) > 0
Order BY 
t.Twr_ProducentKod,
ta12.TwA_WartoscTxt;
