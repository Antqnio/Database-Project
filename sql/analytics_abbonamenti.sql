DELIMITER $$
DROP PROCEDURE IF EXISTS procedure_analytics$$
CREATE PROCEDURE procedure_analytics()
BEGIN
	WITH pagamenti_PianoDiAbbonamento_utente AS (
		SELECT PianoDiAbbonamento, Utente, count(*) AS pagamenti_utente
		FROM Fatturazione
		GROUP BY PianoDiAbbonamento, Utente
	), rinnovi_PianoDiAbbonamento AS (
		SELECT PianoDiAbbonamento, (count(pagamenti_utente)-count(DISTINCT Utente)) AS Rinnovi
        FROM pagamenti_PianoDiAbbonamento_utente
        GROUP BY PianoDiAbbonamento
	)
    SELECT PianoDiAbbonamento, RANK() OVER W AS ClassificaRinnovi
    FROM rinnovi_PianoDiAbbonamento
    WINDOW W AS (PARTITION BY PianoDiAbbonamento ORDER BY Rinnovi DESC);
    
	WITH disdette_per_PianoDiAbbonamento AS (
		SELECT PianoDiAbbonamento, count(*) AS NumeroDisdette
		FROM Fatturazione
		WHERE Scadenza <> Data + INTERVAL 1 MONTH
		GROUP BY PianoDiAbbonamento
	)
    SELECT PianoDiAbbonamento, RANK() OVER Y AS ClassificaDisdette
    FROM disdette_per_PianoDiAbbonamento
    WINDOW Y AS (PARTITION BY PianoDiAbbonamento ORDER BY NumeroDisdette DESC);
	
    WITH nuovi_abbonamenti_per_PianoDiAbbonamento AS (
		SELECT F1.PianoDiAbbonamento, count(*) AS NumeroNuovi
        FROM Fatturazione F1 LEFT OUTER JOIN Fatturazione F2 ON(F1.Data < F2.Data AND F1.Utente = F2.Utente)
        WHERE F2.Data IS NULL
        GROUP BY PianoDiAbbonamento
	)
    
    SELECT PianoDiAbbonamento, RANK() OVER Z AS ClassificaNuoviAbbonamenti
    FROM nuovi_abbonamenti_per_PianoDiAbbonamento
	WINDOW Z AS (PARTITION BY PianoDiAbbonamento ORDER BY NumeroNuovi);
    WITH pagamenti_PianoDiAbbonamento_utente AS (
		SELECT PianoDiAbbonamento, Utente, count(*) AS pagamenti_utente
		FROM Fatturazione
		GROUP BY PianoDiAbbonamento, Utente
	), rinnovi_PianoDiAbbonamento AS (
		SELECT PianoDiAbbonamento, (count(pagamenti_utente)-count(DISTINCT Utente)) AS Rinnovi
        FROM pagamenti_PianoDiAbbonamento_utente
        GROUP BY PianoDiAbbonamento
	)
    SELECT PianoDiAbbonamento AS PianoDiAbbonamentoPiuRinnovato, MaxOre, MaxGigaByte, Tariffa, FIRST_VALUE(Rinnovi) OVER W AS Rinnovi
    FROM rinnovi_PianoDiAbbonamento INNER JOIN PianoDiAbbonamento ON (PianoDiAbbonamento = Pacchetto)
    WINDOW W AS (PARTITION BY PianoDiAbbonamento ORDER BY Rinnovi DESC);
    
    WITH disdette_per_PianoDiAbbonamento AS (
		SELECT PianoDiAbbonamento, count(*) AS NumeroDisdette
		FROM Fatturazione
		WHERE Scadenza <> Data + INTERVAL 1 MONTH
		GROUP BY PianoDiAbbonamento
	)
    SELECT PianoDiAbbonamento AS PianoDiAbbonamentoPiuDisdetto, MaxOre, MaxGigaByte, Tariffa, FIRST_VALUE(NumeroDisdette) OVER Y AS Disdette
    FROM disdette_per_PianoDiAbbonamento INNER JOIN PianoDiAbbonamento ON (PianoDiAbbonamento = Pacchetto)
    WINDOW Y AS (PARTITION BY PianoDiAbbonamento ORDER BY NumeroDisdette DESC);
    
     WITH nuovi_abbonamenti_per_PianoDiAbbonamento AS (
		SELECT F1.PianoDiAbbonamento, count(*) AS NumeroNuovi
        FROM Fatturazione F1 LEFT OUTER JOIN Fatturazione F2 ON(F1.Data < F2.Data AND F1.Utente = F2.Utente)
        WHERE F2.Data IS NULL
        GROUP BY PianoDiAbbonamento
	)
    
    SELECT PianoDiAbbonamento AS PianoDiAbbonamentoPiuScelto, MaxOre, MaxGigaByte, Tariffa, FIRST_VALUE(NumeroNuovi) OVER Z AS NuoviAbbonamenti
    FROM nuovi_abbonamenti_per_PianoDiAbbonamento INNER JOIN PianoDiAbbonamento ON (PianoDiAbbonamento = Pacchetto)
	WINDOW Z AS (PARTITION BY PianoDiAbbonamento ORDER BY NumeroNuovi);
END$$

DROP EVENT IF EXISTS analytics_abbonamenti$$

CREATE EVENT analytics_abbonamenti ON SCHEDULE EVERY 1 MONTH
DO
	CALL procedure_analytics();
$$

DELIMITER ;
