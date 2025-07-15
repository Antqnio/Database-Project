DELIMITER $$
DROP PROCEDURE IF EXISTS raccomanda_contenuti$$
CREATE PROCEDURE raccomanda_contenuti(IN _email VARCHAR(30), OUT film_ VARCHAR(30), OUT formato_ VARCHAR(30))
	BEGIN
		WITH visualizzazioni_per_genere AS (
			SELECT F.Genere, SUM(VP.NumeroVolte) AS VisualizzazioniGenere
			FROM visualizzazionepassata VP INNER JOIN film F ON VP.Film = F.Codice
            WHERE VP.Utente = _email
			GROUP BY F.Genere
		), genere_preferito AS (
			SELECT FIRST_VALUE(Genere) OVER w AS GenerePreferito
            FROM visualizzazioni_per_genere
            WINDOW w AS (
                         ORDER BY VisualizzazioniGenere DESC
						)
		), films_target AS (
			SELECT F.Codice AS Film, F.Rating, F.Visualizzazioni
            FROM film F INNER JOIN genere_preferito GP ON F.Genere = GP.GenerePreferito LEFT OUTER JOIN visualizzazionepassata VP ON (VP.Utente = _email AND F.Codice = VP.Film)
            WHERE VP.Film IS NULL
		), film_preferito_non_visto AS (
			SELECT FIRST_VALUE(Film) OVER w AS FilmPreferito
            FROM films_target
            WINDOW w AS (
						 ORDER BY Rating DESC, Visualizzazioni DESC
						)
			LIMIT 1
		)
         SELECT FilmPreferito
         FROM film_preferito_non_visto
         INTO film_;
         
         WITH usi_per_dispositivo AS (
			SELECT Dispositivo, COUNT(*) AS Usi
            FROM connessionepassata
            WHERE Utente = _email
            GROUP BY Dispositivo
		), dispositivo_piu_utilizzato AS (
			SELECT FIRST_VALUE(Dispositivo) OVER w AS Dispositivo
            FROM usi_per_dispositivo
            WINDOW w AS (
						 ORDER BY Usi DESC
						)
			LIMIT 1
		), formato_consigliato AS (
			SELECT FormatoIdeale
            FROM dispositivo_piu_utilizzato DU INNER JOIN dispositivo D ON DU.Dispositivo = D.Nome
		)
         SELECT FormatoIdeale
         FROM formato_consigliato
         INTO formato_;
    END$$
DELIMITER ;