DELIMITER $$

-- Operazione 1

DROP PROCEDURE IF EXISTS inserisci_film$$
CREATE PROCEDURE inserisci_film(IN _titolo VARCHAR(30), IN _durata INT, IN _anno INT, IN _paese VARCHAR(50), IN _descrizione VARCHAR(255), IN _genere VARCHAR(50),
	IN _formato1 VARCHAR(30), IN _formato2 VARCHAR(30), IN _formato3 VARCHAR(30),
	IN _formato4 VARCHAR(30), IN _formato5 VARCHAR(30), IN _formato6 VARCHAR(30), IN _formato7 VARCHAR(30), IN _formato8 VARCHAR(30))
		BEGIN
			IF _anno < 1891 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Anno non valido';
			ELSEIF _durata < 0 THEN
				SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Durata non valida';
			END IF;
            BEGIN
				DECLARE rapportoDAspetto INT;
				DECLARE risoluzione INT;
                DECLARE _codice INT;
				INSERT INTO film(Durata, Genere, AnnoDiProduzione, Titolo, Rating, Descrizione, PaeseDiProduzione, Visualizzazioni)
				VALUES(_durata, _genere, _anno, _titolo, 0, _descrizione, _paese, 0);
				SELECT Codice INTO _codice
                FROM Film F
                WHERE F.Titolo = _titolo AND F.AnnoDiProduzione = _anno;
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato1
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato1
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita(Film, Formato, DimensioneFile)
					VALUES(_codice, _formato1, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato2
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato2
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato2, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato3
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato3
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato3, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato4
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato4
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato4, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato5
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato5
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato5, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
				
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato6
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato6
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato6, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato7
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato7
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato7, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
                
                IF EXISTS (
						   SELECT Codice
						   FROM formato
						   WHERE Codice = _formato8
						  ) THEN
					SELECT LunghezzaRapporto/AltezzaRapporto, LarghezzaRisoluzione*AltezzaRisoluzione
					FROM formato
					WHERE Codice = _formato8
					INTO rapportoDAspetto, risoluzione;
					
					INSERT INTO disponibilita
					VALUES(_codice, _formato8, _durata * rapportoDAspetto * risoluzione / 10000000);
				END IF;
            END;
		END$$

-- Operazione 2

DROP PROCEDURE IF EXISTS inserisci_utente$$
CREATE PROCEDURE inserisci_utente(IN _nome VARCHAR(30), IN _cognome VARCHAR(30), IN _email VARCHAR(50), IN _password VARCHAR(30), IN _carta BIGINT, IN _pacchetto VARCHAR(15))
	BEGIN
		IF LOCATE('.', _email) = 0 OR LOCATE('@', _email) = 0 THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Indirizzo email non valido';
		ELSEIF LENGTH(_password) < 8 THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La password è troppo corta";
		ELSEIF LENGTH(_password) > 30 THEN 
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "La password è troppo lunga";
		ELSEIF LOCATE('$', _password) = 0 AND LOCATE('§', _password) = 0 AND LOCATE('@', _password) = 0
			AND LOCATE('£', _password) = 0 AND  LOCATE('-', _password) = 0 AND LOCATE('.', _password) = 0
				THEN
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = "Inserisca un carattere speciale";
		ELSEIF _pacchetto NOT IN (
								  SELECT Pacchetto
                                  FROM PianoDiAbbonamento
								 )
			THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Pacchetto inesistente';
		ELSEIF _carta < 0 OR _carta > 9999999999999999 THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Carta non valida';
		END IF;
        
		INSERT INTO utente (Email, Nome, Cognome, `Password`)
		VALUES(_email, _nome, _cognome, _password);
		
		INSERT INTO fatturazione (Utente, Scadenza, `Data`, CartaDiCredito, PianoDiAbbonamento)
		VALUES(_email, CURRENT_DATE + INTERVAL 31 DAY, CURRENT_DATE, _carta, _pacchetto);
		
        
    END$$
    
-- Operazione 3

DELIMITER $$
DROP PROCEDURE IF EXISTS calcolo_rating$$
CREATE PROCEDURE calcolo_rating()
BEGIN
	WITH visualizzazione_con_valutazione AS (
		SELECT *
        FROM visualizzazionepassata
        WHERE Stelle IS NOT NULL
	), fattori_film AS (
		SELECT F.Codice AS Film, AVG(V.Stelle) AS VotoMedioUtenti, SUM(IF(R.Premio IS NOT NULL, 1, 0)) AS PremiOscar, AVG(A.Popolarità) AS PopolaritaAttori, AVG(REG.Popolarità) AS PopolaritaRegisti
		FROM film F INNER JOIN visualizzazione_con_valutazione V ON F.Codice = V.Film INNER JOIN recitazione R ON F.Codice = R.Film
			INNER JOIN attore A ON R.Attore = A.CodiceFiscale INNER JOIN direzione D ON F.Codice = D.film INNER JOIN regista REG ON D.Regista = REG.CodiceFiscale 
		WHERE R.Principale = 'Si' OR R.Premio IS NOT NULL
		GROUP BY Codice
	), rating_film AS (
		SELECT Film, AVG(VotoMedioUtenti + PopolaritaAttori + PopolaritaRegisti) + 0.1*PremiOscar AS Valutazione
		FROM fattori_film
		GROUP BY Film
	)
	UPDATE film INNER JOIN rating_film RF ON Codice = RF.Film
    SET rating = Valutazione;
    
END$$

DROP PROCEDURE IF EXISTS rating_film$$
CREATE PROCEDURE rating_film (IN _CodiceFilm INT)
	BEGIN
		SELECT Titolo, Durata, Genere, AnnoDiProduzione, Rating, Descrizione, PaeseDiProduzione, Visualizzazioni
        FROM film 
        WHERE Codice = _CodiceFilm;
        
        SELECT Lingua
        FROM doppiaggio
        WHERE Film = _CodiceFilm;
        
        SELECT Lingua
        FROM sottotitolaggio
        WHERE Film = _CodiceFilm;
        
        SELECT Nome AS NomeAttore, Cognome AS CognomeAttore, Principale, Premio
        FROM recitazione INNER JOIN attore ON Attore = CodiceFiscale
        WHERE Film = _CodiceFilm;
        
        SELECT Formato
        FROM disponibilita
        WHERE Film = _CodiceFilm;
        
        SELECT Nome AS NomeRegista, Cognome AS CognomeRegista, Popolarità
        FROM direzione INNER JOIN regista ON Regista = CodiceFiscale
        WHERE Film = _CodiceFilm;
        
        SELECT Premio AS PremioFilm
        FROM premiazionefilm
		WHERE Film = _CodiceFilm;
END$$

DROP EVENT IF EXISTS aggiorna_rating$$
CREATE EVENT aggiorna_rating
ON SCHEDULE EVERY 2 WEEK
DO
	CALL calcolo_rating();


-- Operazione 4

DROP PROCEDURE IF EXISTS crea_visualizzazione_attuale$$

CREATE PROCEDURE crea_visualizzazione_attuale(IN _email VARCHAR(30), IN _film INT, IN _indirizzoIP BIGINT, IN _dispositivo VARCHAR(30), IN _formato VARCHAR(20))
BEGIN
	IF _email NOT IN (SELECT Email FROM utente) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Utente non presente';
	ELSEIF _film NOT IN (SELECT Codice FROM film) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Film non presente';
	ELSEIF _formato NOT IN (SELECT Codice FROM formato) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Formato non presente';
	ELSEIF _dispositivo NOT IN (SELECT Nome FROM dispositivo) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dispositivo non valido';
	ELSEIF NOT EXISTS (
					   SELECT *
                       FROM (
							 SELECT *, _indirizzoIP AS IP
                             FROM AreaGeografica
							) AS D
						WHERE IP BETWEEN IPIniziale AND IPFinale
					  )
                      THEN
						  SIGNAL SQLSTATE '45000'
						  SET MESSAGE_TEXT = 'IP non valido';
	END IF;
		
	REPLACE INTO visualizzazioneattuale(Utente, Film)
    VALUES(_email, _film);
    BEGIN
		DECLARE Server1 VARCHAR(20) DEFAULT NULL;
		DECLARE Server2 VARCHAR(20) DEFAULT NULL;
		DECLARE Server_target VARCHAR(20) DEFAULT NULL;
		SELECT C1.Server, C2.Server INTO Server1, Server2
		FROM Caching C1 INNER JOIN Caching C2 ON (C1.Utente = C2.Utente AND C1.Film = C2.Film AND C1.Server <> C2.Server)
		WHERE C1.Utente = _email AND C1.Film = _film
		LIMIT 1;
		
		IF (Server1 IS NOT NULL AND ((SELECT count(*)
									 FROM ConnessioneAttuale
									 WHERE Server = Server1) <= (SELECT Banda*Capacità
																FROM Server
																WHERE Identificatore = Server1))) THEN
			INSERT INTO ConnessioneAttuale(IndirizzoIP, Dispositivo, Inizio, Utente, Server, Formato)
			VALUES (_indirizzoIP, _dispositivo, current_time(),_email, Server1, _formato);
			INSERT INTO VisualizzazioneAttuale(Film, Utente)
			VALUES (_film, _email);
		ELSEIF (Server2 IS NOT NULL AND ((SELECT count(*)
									 FROM ConnessioneAttuale
									 WHERE Server = Server2) <= (SELECT Banda*Capacità
																FROM Server
																WHERE Identificatore = Server2))) THEN
			INSERT INTO ConnessioneAttuale(IndirizzoIP, Dispositivo, Inizio, Utente, Server, Formato)
			VALUES (_indirizzoIP, _dispositivo, current_time(),_email, Server2, _formato);
			INSERT INTO VisualizzazioneAttuale(Film, Utente)
			VALUES (_film, _email);
		ELSE
			WITH Server_disponibilita AS (
				SELECT Server
				FROM Contenuto
				WHERE Film = _film
			), 
			geolocalizzazione AS (
				SELECT Codice
				FROM AreaGeografica
				WHERE _indirizzoIP >= IPIniziale
					AND _indirizzoIP < IPFinale
			) 
			SELECT Server INTO Server_target
			FROM Server_disponibilita SB INNER JOIN Distanza D USING (Server) INNER JOIN geolocalizzazione G ON G.Codice = D.AreaGeografica
			WHERE D.Kilometri = (SELECT MIN(D1.Kilometri)
								FROM Server_disponibilita SB1 INNER JOIN Distanza D1 USING (Server) INNER JOIN geolocalizzazione G1 ON G1.Codice = D1.AreaGeografica);
			INSERT INTO ConnessioneAttuale(IndirizzoIP, Dispositivo, Inizio, Utente, Server, Formato)
			VALUES (_indirizzoIP, _dispositivo, CURRENT_TIME(), _email, Server_target, _formato); 
		END IF;
	END;
    
END $$

-- Operazione 5

DROP PROCEDURE IF EXISTS film_sopra_soglia$$

CREATE PROCEDURE film_sopra_soglia(IN _soglia FLOAT)
BEGIN
	SELECT codice, Titolo, Rating
    FROM  Film
    WHERE Rating >= _soglia;
END $$

-- Operazione 6

DROP PROCEDURE IF EXISTS rinnovo_cambio_disdetta$$
CREATE PROCEDURE rinnovo_cambio_disdetta(IN _utente VARCHAR(50), IN _carta BIGINT, IN _policy VARCHAR(30), IN _nuovo_piano VARCHAR(30))
BEGIN
	DECLARE ultima_scadenza DATE;
    DECLARE ultimo_piano VARCHAR(50);
	IF _policy = 'Rinnovo' THEN
		SELECT MAX(Scadenza) INTO ultima_scadenza
        FROM Fatturazione
        WHERE Utente = _utente;
        
        SELECT PianoDiAbbonamento INTO ultimo_piano
        FROM Fatturazione
        WHERE Utente = _utente AND Scadenza = ultima_scadenza;
	
        IF ultima_scadenza IS NULL THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non esiste un abbonamento precedente';
		END IF;
        IF ultima_scadenza >= CURRENT_DATE() THEN
			INSERT INTO Fatturazione(Utente, Scadenza, Data, CartaDiCredito, PianoDiAbbonamento)
            VALUES (_utente, ultima_scadenza + INTERVAL 32 DAY, CURRENT_DATE(), _carta, ultimo_piano);
		ELSE 
			INSERT INTO Fatturazione(Utente, Scadenza, Data, CartaDiCredito, PianoDiAbbonamento)
            VALUES (_utente, CURRENT_DATE() + INTERVAL 31 DAY, CURRENT_DATE(), _carta, ultimo_piano);
		END IF;
	ELSEIF _policy = 'Disdetta' THEN
		SELECT MAX(Scadenza) INTO ultima_scadenza
        FROM Fatturazione
        WHERE Utente = _utente;
        IF ultima_scadenza IS NULL OR ultima_scadenza < CURRENT_DATE() THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non esiste un abbonamento in corso';
		END IF;
        UPDATE Fatturazione
        SET Scadenza = CURRENT_DATE()
        WHERE Utente = _utente AND Scadenza = ultima_scadenza;
	ELSEIF _policy = 'Cambio' THEN
		SELECT MAX(Scadenza) INTO ultima_scadenza
        FROM Fatturazione
        WHERE Utente = _utente;
        SELECT PianoDiAbbonamento INTO ultimo_piano
        FROM Fatturazione
        WHERE Utente = _utente AND Scadenza = ultima_scadenza;
        
        IF ultima_scadenza IS NULL OR ultima_scadenza < CURRENT_DATE() THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non esiste un abbonamento in corso';
		END IF;
        IF ultimo_piano = _nuovo_piano THEN
			SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Il nuovo piano è uguale al precedente';
		END IF;
        INSERT INTO Fatturazione(Utente, Scadenza, Data, CartaDiCredito, PianoDiAbbonamento)
		VALUES (_utente, CURRENT_DATE() + INTERVAL 31 DAY, CURRENT_DATE(), _carta, _nuovo_piano);
	ELSE 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Policy non valida';
	END IF;
END$$

-- Operazione 7

DROP PROCEDURE IF EXISTS connessioni_attuali$$
CREATE PROCEDURE connessioni_attuali()
	BEGIN
		WITH connessioni_con_AG AS (
			SELECT CA.Utente, CA.Inizio, CA.IndirizzoIP, CA.Server, CA.Dispositivo, AG.Codice AS LocazioneUtente
            FROM connessioneattuale CA CROSS JOIN AreaGeografica AG 
            WHERE CA.indirizzoIP >= AG.IPIniziale AND CA.IndirizzoIP < AG.IPFinale
            )
		SELECT *
        FROM connessioni_con_AG;
    END $$
    
-- Operazione 8

DROP PROCEDURE IF EXISTS film_con_visualizzazioni$$

CREATE PROCEDURE film_con_visualizzazioni(IN _visualizzazioni INT)
	BEGIN
		SELECT Codice, Titolo, Visualizzazioni
		FROM Film
		WHERE Visualizzazioni >= _visualizzazioni;
	END $$

DELIMITER ;