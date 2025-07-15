DELIMITER $$
DROP PROCEDURE IF EXISTS cambio$$
CREATE PROCEDURE cambio()
BEGIN
	DECLARE _server VARCHAR(20);
	DECLARE codice INT;
	DECLARE utente VARCHAR(50);
	DECLARE indirizzoIP BIGINT;
	DECLARE dispositivo VARCHAR(30);
	DECLARE inizio TIMESTAMP;
	DECLARE formato VARCHAR(30);
	-- DECLARE server_migliore VARCHAR(20);
	DECLARE area_geografica_di_connessione VARCHAR(4);
	DECLARE _film INT;
    DECLARE counter INT;
    DECLARE counter_ausiliario INT DEFAULT 0;
    
	
	DECLARE cursore CURSOR FOR	
		WITH connessioni_per_server AS ( -- Non si prendono i server senza connessioni
			SELECT `Server`, COUNT(*) AS Connessioni
			FROM connessioneattuale
			GROUP BY `Server`
		), server_da_smistare AS (
			SELECT CPS.`Server`, Banda * Capacità / 10000 AS Coefficiente
			FROM connessioni_per_server CPS INNER JOIN `server` S ON CPS.`Server` = S.Identificatore
			WHERE Connessioni >= Banda * Capacità / 10000
		) -- Connessioni da smistare
		SELECT SDS.`Server`, CA.Utente, CA.IndirizzoIP, CA.Dispositivo, CA.Inizio, CA.Formato, VA.Film
		FROM server_da_smistare SDS NATURAL JOIN connessioneattuale CA NATURAL JOIN visualizzazioneattuale VA
        ORDER BY Coefficiente DESC;
		
	
	
	WITH connessioni_per_server AS ( -- Non si prendono i server senza connessioni
			SELECT `Server`, COUNT(*) AS Connessioni
			FROM connessioneattuale
			GROUP BY `Server`
		), server_da_smistare AS (
			SELECT CPS.`Server`
			FROM connessioni_per_server CPS INNER JOIN `server` S ON CPS.`Server` = S.Identificatore
			WHERE Connessioni >= Banda * Capacità /10000
		)
		UPDATE `server` S
		SET S.OffCounter = S.OffCounter + 1
		WHERE S.Identificatore IN (
								   SELECT `Server`
								   FROM server_da_smistare
								  );
	
	OPEN cursore;
	WITH connessioni_per_server AS ( -- Non si prendono i server senza connessioni
			SELECT `Server`, COUNT(*) AS Connessioni
			FROM connessioneattuale
			GROUP BY `Server`
		), server_da_smistare AS (
			SELECT CPS.`Server`, Banda * Capacità / 10000 AS Coefficiente
			FROM connessioni_per_server CPS INNER JOIN `server` S ON CPS.`Server` = S.Identificatore
			WHERE Connessioni >= Banda * Capacità / 10000
		) -- Connessioni da smistare
		SELECT SDS.`Server`, CA.Utente, CA.IndirizzoIP, CA.Dispositivo, CA.Inizio, CA.Formato, VA.Film, Coefficiente
		FROM server_da_smistare SDS NATURAL JOIN connessioneattuale CA NATURAL JOIN visualizzazioneattuale VA
        ORDER BY Coefficiente DESC;
        WITH connessioni_per_server AS ( -- Non si prendono i server senza connessioni
			SELECT `Server`, COUNT(*) AS Connessioni
			FROM connessioneattuale
			GROUP BY `Server`
		), server_da_smistare AS (
			SELECT CPS.`Server`, Banda * Capacità / 10000 AS Coefficiente
			FROM connessioni_per_server CPS INNER JOIN `server` S ON CPS.`Server` = S.Identificatore
			WHERE Connessioni >= Banda * Capacità / 10000
		) -- Connessioni da smistare
        SELECT count(*)
		FROM server_da_smistare SDS NATURAL JOIN connessioneattuale CA NATURAL JOIN visualizzazioneattuale VA
        INTO counter;
	ciclo : LOOP
		IF counter = counter_ausiliario THEN 
			LEAVE ciclo;
		END IF;
		FETCH cursore INTO _server, utente, indirizzoIP, dispositivo, inizio, formato, _film;
        
		SELECT A.Codice AS AreaGeografica
		FROM areageografica A
		WHERE indirizzoIP >= IPIniziale AND indirizzoIP < IPFinale
		INTO area_geografica_di_connessione;
        SET @server_migliore = '';
		WITH server_validi AS (
			SELECT S.Identificatore AS `Server`, S.Banda, S.Capacità, D.Kilometri  
			FROM `server` S INNER JOIN distanza D ON S.Identificatore = D.`Server` INNER JOIN contenuto C ON C.`Server` = S.Identificatore
				INNER JOIN connessioneattuale CA ON S.Identificatore = CA.`Server`
			WHERE C.Film = _film  AND D.AreaGeografica = area_geografica_di_connessione
			GROUP BY S.Identificatore, D.`Server`, D.AreaGeografica
			HAVING COUNT(CA.Utente) < S.Banda * S.Capacità / 10000 -- Raggruppo su D.Server, che è, grazie al join con S, chiave primaria della relazione server
		)
        
		SELECT `Server`
		FROM server_validi
		WHERE Kilometri = (
						   SELECT MIN(Kilometri)
						   FROM server_validi
						  )
        INTO @server_migliore;
        SET counter_ausiliario = counter_ausiliario + 1;
        IF @server_migliore = '' THEN 
			ITERATE ciclo;
		END IF;
		
		
	
        IF _server <> @server_migliore AND @server_migliore IS NOT NULL THEN
			DELETE FROM connessioneattuale CA
			WHERE CA.Utente = utente;
			IF NOT EXISTS (SELECT CP.Utente, CP.IndirizzoIP, CP.Dispositivo, CP.Inizio, CP.Formato, CP.`Server`
							FROM connessionepassata CP
                            WHERE utente = CP.Utente AND IndirizzoIP = CP.IndirizzoIP AND Dispositivo = CP.Dispositivo AND
								Inizio = CP.Inizio AND Formato = CP.Formato AND `Server` = CP.Server) THEN
				INSERT INTO connessionepassata(Utente, IndirizzoIP, Dispositivo, Inizio, Fine, Formato, Film, `Server`)
				VALUES(utente, indirizzoIP, dispositivo, inizio, CURRENT_TIME, formato, _film, _server);
			END IF;
			IF NOT EXISTS (SELECT CA.Utente
							FROM connessioneattuale CA
                            WHERE CA.Utente = utente) THEN
				INSERT INTO connessioneattuale(Utente, IndirizzoIP, Dispositivo, Inizio, Formato, `Server`)
				VALUES(utente, indirizzoIP, dispositivo, current_time, formato, @server_migliore);
			END IF;
		END IF;
        
		
	END LOOP;
	CLOSE cursore;

END$$
DROP EVENT IF EXISTS cambio_server$$
CREATE EVENT cambio_server
ON SCHEDULE EVERY 15 MINUTE
DO
	CALL cambio()$$	
DELIMITER ;
/*
Con i cursori, e' possibile verificare lo stato dei server in cui stiamo inserendo le connessioni passaggio per passaggio.
Cio' impedisce di portare i server che subiscono inserimenti in uno stato inconsistente.
Se un utente si trova in un server inizialmente invalido ma che, successivamente, ritorna valido a causa dei vari smistamenti, ci sono due possibilita':
	- L'utente resta nello stesso server.
    - L'utente si connette a un server in uno stato valido e piu' vicino alla sua area geografica rispetto a quello in cui si trovava a inizio operazione.
*/
