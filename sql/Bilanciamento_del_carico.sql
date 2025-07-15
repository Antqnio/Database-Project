DELIMITER $$
DROP PROCEDURE IF EXISTS bilanciamento_carico$$
CREATE PROCEDURE bilanciamento_carico()
BEGIN
	DECLARE _server_ VARCHAR(20);
	DECLARE filmpiuvisto INT;
	DECLARE finito INT DEFAULT 0;
	DECLARE server_vicino VARCHAR(20);
	DECLARE cursore CURSOR FOR
		WITH server_target AS (
			SELECT Identificatore AS `Server`
			FROM `server`
			WHERE OffCounter >= 5
		), visualizzazioni_per_server AS (
			SELECT `Server`, Film, COUNT(*) AS Visualizzazioni
			FROM connessionepassata NATURAL JOIN server_target
			GROUP BY `Server`, Film
		)
		SELECT DISTINCT `Server`, FIRST_VALUE(Film) OVER w AS FilmPiuVisto
		FROM visualizzazioni_per_server
		WINDOW w AS (
					 PARTITION BY  `Server`
					 ORDER BY Visualizzazioni DESC
					);
	DECLARE CONTINUE HANDLER FOR NOT FOUND 
		SET finito = 1;

	OPEN cursore;
	ciclo : LOOP
		FETCH cursore INTO _server_, filmpiuvisto;
		IF finito = 1 THEN
			LEAVE ciclo;
		END IF;
		WITH server_non_possibili AS (
			SELECT `Server`
			FROM contenuto
			WHERE Film = filmpiuvisto
		), server_ausiliari AS (
			SELECT C.`Server`, OffCounter, AreaGeografica
			FROM contenuto C LEFT OUTER JOIN server_non_possibili SNP ON (C.`Server` = SNP.`Server`) NATURAL JOIN `server`
			WHERE SNP.`Server` IS NULL AND OffCounter <= 5
		), server_vicini AS (
		SELECT DISTINCT SA.`Server`, OffCounter
		FROM distanza D INNER JOIN server_ausiliari SA ON D.AreaGeografica = SA.AreaGeografica
		WHERE D.`Server` = _server_ AND D.Kilometri = (
													   SELECT MIN(D1.Kilometri)
													   FROM distanza D1 INNER JOIN server_ausiliari SA1 ON D1.AreaGeografica = SA1.AreaGeografica
													   WHERE D1.`Server` = _server_
													  )
		)
		SELECT `Server`
		FROM server_vicini
		WHERE OffCounter = (
							SELECT MIN(OffCounter)
							FROM server_vicini
						   )
		LIMIT 1
        INTO server_vicino;
		IF server_vicino IS NOT NULL AND NOT EXISTS (SELECT *
						FROM Contenuto
                        WHERE Server = server_vicino AND Film = filmpiuvisto) THEN
			INSERT INTO Contenuto(`Server`, Film)
			VALUES(server_vicino, filmpiuvisto);
		END IF;
			
	END LOOP;
	CLOSE cursore;
	UPDATE `server`
	SET OffCounter = 0;
END$$

DROP EVENT IF EXISTS bilanciamento_del_carico$$
CREATE EVENT bilanciamento_del_carico
ON SCHEDULE EVERY 1 MONTH
DO
	CALL bilanciamento_carico$$


$$
DELIMITER ;

