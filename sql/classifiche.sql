DELIMITER $$
DROP PROCEDURE IF EXISTS classifiche$$
CREATE PROCEDURE classifiche()
BEGIN
	WITH connessioni_per_area AS (
		SELECT CP.*, A.Codice AS CodiceArea
        FROM ConnessionePassata CP INNER JOIN Areageografica A ON (CP.indirizzoIP >= A.IPIniziale AND CP.indirizzoIP < A.IPFinale)
	), abbonamento_per_connessione AS (
		SELECT CA.*, F.PianoDiAbbonamento AS Pacchetto
        FROM connessioni_per_area CA INNER JOIN Fatturazione F ON (CA.Utente = F.Utente AND CA.Inizio >= F.Data AND CA.Inizio <= F.Scadenza)
    ), conteggio_film_formato_per_AG AS (
		SELECT Film, Formato, CodiceArea AS AreaGeografica, Pacchetto, count(*) AS Visualizzazioni
        FROM abbonamento_per_connessione APC
        GROUP BY Film, Formato, CodiceArea, Pacchetto
	), conteggio_film_per_AG AS (
		SELECT Film, CodiceArea AS AreaGeografica, Pacchetto, count(*) AS VisualizzazioniPerFilm
        FROM abbonamento_per_connessione APC
        GROUP BY Film, CodiceArea, Pacchetto
	), formato_piu_visto_per_film AS (
		SELECT Film, AreaGeografica, Pacchetto, FIRST_VALUE(Formato) OVER w AS FormatoPiuVisualizzato
        FROM conteggio_film_formato_per_AG
		WINDOW w AS (PARTITION BY Formato ORDER BY Visualizzazioni DESC)
	)
    
	SELECT AreaGeografica, Pacchetto, Film, FormatoPiuVisualizzato, RANK() OVER w AS Classifica
	FROM conteggio_film_per_AG NATURAL JOIN formato_piu_visto_per_film 
	WINDOW w AS (PARTITION BY AreaGeografica, Pacchetto, Film ORDER BY VisualizzazioniPerFilm DESC);
	
END $$

DELIMITER ;
