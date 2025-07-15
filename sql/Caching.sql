DELIMITER $$
DROP PROCEDURE IF EXISTS procedure_caching$$
CREATE PROCEDURE procedure_caching()
BEGIN
	TRUNCATE TABLE caching;
    DROP TABLE IF EXISTS tabella_per_inserimenti;
    CREATE TEMPORARY TABLE tabella_per_inserimenti (
		Utente VARCHAR(50) PRIMARY KEY,
        FilmPreferito INT,
        FilmRaccomandato INT,
        PrimoServer VARCHAR(20) ,
        SecondoServer VARCHAR(20)
	) ENGINE = InnoDB CHARSET = latin1;
    
    INSERT INTO tabella_per_inserimenti (Utente, FilmPreferito, FilmRaccomandato, PrimoServer, SecondoServer)
	WITH film_preferito AS (
		SELECT DISTINCT VP.Utente, FIRST_VALUE(F.Codice) OVER w AS FilmPreferito
		FROM visualizzazionepassata VP INNER JOIN film F ON VP.Film = F.Codice
		WINDOW w AS (
					 PARTITION BY VP.Utente
					 ORDER BY VP.NumeroVolte DESC, F.Rating DESC
					)
	), server_con_connessioni AS (
		SELECT Utente, Server, COUNT(*) AS ConnessioniPerServer 
		FROM connessionepassata
		GROUP BY Utente, `Server`
	), server_preferiti AS (
		SELECT DISTINCT Utente, FIRST_VALUE(Server) OVER w AS PrimoServer, NTH_VALUE(Server, 2) OVER w AS SecondoServer
		FROM server_con_connessioni
		WINDOW w AS (
					 PARTITION BY Utente
					 ORDER BY ConnessioniPerServer DESC
					 )
	), visualizzazioni_per_genere AS (
		SELECT VP.Utente, F.Genere, SUM(VP.NumeroVolte) AS VisualizzazioniGenere
		FROM visualizzazionepassata VP INNER JOIN film F ON VP.Film = F.Codice
		GROUP BY VP.Utente, F.Genere
	), genere_preferito AS (
		SELECT Utente, FIRST_VALUE(Genere) OVER w AS GenerePreferito
		FROM visualizzazioni_per_genere
		WINDOW w AS (
					 PARTITION BY Utente
					 ORDER BY VisualizzazioniGenere DESC
					)
	), films_target AS (
		SELECT DISTINCT GP.Utente, F.Codice AS Film, F.Rating, F.Visualizzazioni
		FROM film F INNER JOIN genere_preferito GP ON F.Genere = GP.GenerePreferito LEFT OUTER JOIN visualizzazionepassata VP ON (VP.Utente = GP.Utente AND F.Codice = VP.Film)
		WHERE VP.Film IS NULL
	), film_raccomandato AS (
		SELECT DISTINCT Utente, FIRST_VALUE(Film) OVER w AS FilmRaccomandato
		FROM films_target
		WINDOW w AS (
					 PARTITION BY Utente
					 ORDER BY Rating DESC, Visualizzazioni DESC
					)
	)
	 SELECT DISTINCT FP.Utente, FilmPreferito, FilmRaccomandato, PrimoServer, SecondoServer
	 FROM film_preferito FP NATURAL JOIN server_preferiti SP NATURAL JOIN film_raccomandato
	 WHERE SecondoServer IS NOT NULL;
     
	INSERT INTO Caching(Utente, Film, `Server`)
		SELECT Utente, FilmPreferito, PrimoServer
		FROM tabella_per_inserimenti;
	INSERT INTO Caching(Utente, Film, `Server`)
		SELECT Utente, FilmPreferito, SecondoServer
		FROM tabella_per_inserimenti;
	INSERT INTO Caching(Utente, Film, `Server`)
		SELECT Utente, FilmRaccomandato, PrimoServer
		FROM tabella_per_inserimenti;
	INSERT INTO Caching(Utente, Film, `Server`)
		SELECT Utente, FilmRaccomandato, SecondoServer
		FROM tabella_per_inserimenti;
        
	REPLACE INTO contenuto(Film, `Server`)
		SELECT DISTINCT FilmPreferito, PrimoServer
		FROM tabella_per_inserimenti;
	REPLACE INTO contenuto(Film, `Server`)
		SELECT DISTINCT FilmPreferito, SecondoServer
		FROM tabella_per_inserimenti;
	REPLACE INTO contenuto(Film, `Server`)
		SELECT DISTINCT FilmRaccomandato, PrimoServer
		FROM tabella_per_inserimenti;
	REPLACE INTO contenuto(Film, `Server`)
		SELECT DISTINCT FilmRaccomandato, SecondoServer
		FROM tabella_per_inserimenti;
		
END$$

DROP EVENT IF EXISTS event_caching$$
CREATE EVENT event_caching
ON SCHEDULE EVERY 1 MONTH
STARTS '2023-11-22 03:00:00'
	DO
	CALL procedure_caching()$$
DELIMITER ;