
DELIMITER $$

DROP TRIGGER IF EXISTS aggiorna_visualizzazioni$$
CREATE TRIGGER aggiorna_visualizzazioni
AFTER INSERT ON visualizzazioneattuale
FOR EACH ROW
	BEGIN
		UPDATE film
        SET Visualizzazioni = Visualizzazioni + 1
        WHERE Codice = NEW.Film;
    
    
    END$$

DROP TRIGGER IF EXISTS controlla_banda$$
CREATE TRIGGER controlla_banda
BEFORE INSERT ON Server
FOR EACH ROW
BEGIN
	IF NEW.Banda < 0.2 OR NEW.Banda > 0.9 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Server non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_banda$$
CREATE TRIGGER controlla_banda
BEFORE UPDATE ON Server
FOR EACH ROW
BEGIN
	IF NEW.Banda < 0.2 OR NEW.Banda > 0.9 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Server non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_capacita $$
CREATE TRIGGER controlla_capacita
BEFORE INSERT ON Server
FOR EACH ROW 
BEGIN 
	IF NEW.Capacità <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Server non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_capacita $$
CREATE TRIGGER controlla_capacita
BEFORE UPDATE ON Server
FOR EACH ROW 
BEGIN 
	IF NEW.Capacità <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Server non inseribile';
	END IF;
END $$


DROP TRIGGER IF EXISTS controlla_identificatore $$
CREATE TRIGGER controlla_identificatore
BEFORE INSERT ON Server
FOR EACH ROW
BEGIN 
	IF LENGTH(NEW.Identificatore) > 4 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Server non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_codice_AG $$
CREATE TRIGGER controlla_codice_AG
BEFORE INSERT ON AreaGeografica
FOR EACH ROW 
BEGIN
	IF LENGTH(NEW.Codice) > 4 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Area geografica non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_anno_di_produzione$$
CREATE TRIGGER controlla_anno_di_produzione
BEFORE INSERT ON Film
FOR EACH ROW
BEGIN
	IF NEW.AnnoDiProduzione > YEAR(current_date()) OR NEW.AnnoDiProduzione < 1891 OR NEW.Durata <= 0 OR NEW.Visualizzazioni < 0 OR NEW.Rating < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Film non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_anno_di_produzione$$
CREATE TRIGGER controlla_anno_di_produzione
BEFORE UPDATE ON Film
FOR EACH ROW
BEGIN
	IF NEW.AnnoDiProduzione > YEAR(current_date()) OR NEW.AnnoDiProduzione < 1891 OR NEW.Durata <= 0 OR NEW.Visualizzazioni < 0 OR NEW.Rating < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Film non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_stelle $$
CREATE TRIGGER controlla_stelle
BEFORE INSERT ON Visualizzazionepassata
FOR EACH ROW
BEGIN
	IF NEW.Stelle < 0 OR NEW.Stelle > 5 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valutazione non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_stelle $$
CREATE TRIGGER controlla_stelle
BEFORE UPDATE ON Visualizzazionepassata
FOR EACH ROW
BEGIN
	IF NEW.Stelle < 0 OR NEW.Stelle > 5 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Valutazione non inseribile';
	END IF;
END $$

DROP TRIGGER IF EXISTS fine_visualizzazione_attuale $$
CREATE TRIGGER fine_visualizzazione_attuale
AFTER DELETE ON VisualizzazioneAttuale
FOR EACH ROW
BEGIN
	INSERT INTO connessionepassata (Utente, indirizzoIP, Server, Inizio, Formato, Dispositivo, Fine, Film)
    SELECT CA.Utente, CA.indirizzoIP, CA.Server, CA.Inizio, CA.Formato, CA.Dispositivo, CURRENT_TIME(), OLD.Film
    FROM connessioneattuale CA
    WHERE CA.Utente = OLD.Utente;
	DELETE FROM connessioneattuale CA
    WHERE CA.Utente = OLD.Utente;
    
	IF NOT EXISTS ( SELECT *
					FROM VisualizzazionePassata VP
                    WHERE VP.Film = OLD.Film AND VP.Utente = OLD.Utente) THEN
		INSERT INTO VisualizzazionePassata(Utente, Film, NumeroVolte)
        VALUES(OLD.Utente, OLD.Film, 1);
	END IF;
	IF EXISTS ( SELECT *
					FROM VisualizzazionePassata VP
                    WHERE VP.Film = OLD.Film AND VP.Utente = OLD.Utente) THEN
		UPDATE VisualizzazionePassata VP
        SET NumeroVolte = NumeroVolte+1
        WHERE VP.Film = OLD.Film AND VP.Utente = OLD.Utente;
	END IF;
    
END $$

DROP TRIGGER IF EXISTS validita_fatturazione$$
CREATE TRIGGER validita_fatturazione
BEFORE INSERT ON fatturazione -- in questo caso non facciamo anche il caso update perchè esiste la possibilità, seppur remota, che qualcuno disdica l'abbonamento il giorno stesso dell'acquisto
FOR EACH ROW
BEGIN
	IF NEW.Data >= NEW.Scadenza THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Fatturazione non valida";
	END IF;
END$$

DROP TRIGGER IF EXISTS validita_carta_di_credito$$
CREATE TRIGGER validita_carta_di_credito
BEFORE INSERT ON fatturazione -- non facciamo il caso di update, perché non ha senso cambiare la carta di credito una volta che la fatturazione è stata eseguita
FOR EACH ROW
BEGIN
	IF NEW.CartaDiCredito <= 0 OR  NEW.CartaDiCredito > 9999999999999999 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Carta di credito non valida";
	END IF;
END$$


DROP TRIGGER IF EXISTS controlla_piano_inserito$$
CREATE TRIGGER controlla_piano_inserito
BEFORE INSERT ON pianodiabbonamento
FOR EACH ROW
BEGIN
	IF NEW.Pacchetto <> 'Basic' AND NEW.Pacchetto <> 'Premium' AND NEW.Pacchetto <> 'Pro' AND NEW.Pacchetto <> 'Deluxe' AND NEW.Pacchetto <> 'Ultimate' THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il nome del piano non è valido";
	ELSEIF NEW.Tariffa <= 0 OR NEW.MaxOre <= 0 OR NEW.MaxGigabyte <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Sono stati inseriti valori non positivi";
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_piano_inserito$$
CREATE TRIGGER controlla_piano_inserito
BEFORE UPDATE ON pianodiabbonamento
FOR EACH ROW
BEGIN
	IF NEW.Pacchetto <> 'Basic' AND NEW.Pacchetto <> 'Premium' AND NEW.Pacchetto <> 'Pro' AND NEW.Pacchetto <> 'Deluxe' AND NEW.Pacchetto <> 'Ultimate' THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Il nome del piano non è valido";
	ELSEIF NEW.Tariffa <= 0 OR NEW.MaxOre <= 0 OR NEW.MaxGigabyte <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Sono stati inseriti valori non positivi";
	END IF;
END$$

DROP TRIGGER IF EXISTS qualita_audio_video_passato$$
CREATE TRIGGER qualita_audio_video_passato
BEFORE INSERT ON formatopassato
FOR EACH ROW
BEGIN
	IF NEW.QualitaAudio < 1 OR NEW.QualitaAudio > 100 THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' audio non valida";
	ELSEIF NEW.QualitaVideo < 1 OR NEW.QualitaVideo > 100 THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' video non valida";
	ELSEIF NEW.LunghezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Lunghezza rapporto non valida";
	ELSEIF NEW.AltezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza rapporto non valida";
	ELSEIF NEW.AltezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza risoluzione non valida";
	ELSEIF NEW.LarghezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Larghezza risoluzione non valida";
	END IF;
END$$

DROP TRIGGER IF EXISTS qualita_audio_video_passato$$
CREATE TRIGGER qualita_audio_video_passato
BEFORE UPDATE ON formatopassato
FOR EACH ROW
BEGIN
	IF NEW.QualitaAudio < 1 OR NEW.QualitaAudio > 100 THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' audio non valida";
	ELSEIF NEW.QualitaVideo < 1 OR NEW.QualitaVideo > 100 THEN
    	SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' video non valida";
	ELSEIF NEW.LunghezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Lunghezza rapporto non valida";
	ELSEIF NEW.AltezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza rapporto non valida";
	ELSEIF NEW.AltezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza risoluzione non valida";
	ELSEIF NEW.LarghezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Larghezza risoluzione non valida";
	END IF;
END$$

DROP TRIGGER IF EXISTS qualita_audio_video_corrente$$
CREATE TRIGGER qualita_audio_video_corrente
BEFORE INSERT ON formato
FOR EACH ROW
BEGIN
    IF NEW.QualitaAudio < 1 OR NEW.QualitaAudio > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' audio non valida";
    ELSEIF NEW.QualitaVideo < 1 OR NEW.QualitaVideo > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' video non valida";
	ELSEIF NEW.LunghezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Lunghezza rapporto non valida";
	ELSEIF NEW.AltezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza rapporto non valida";
	ELSEIF NEW.AltezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza risoluzione non valida";
	ELSEIF NEW.LarghezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Larghezza risoluzione non valida";
	
    END IF;
END$$

DROP TRIGGER IF EXISTS qualita_audio_video_corrente$$
CREATE TRIGGER qualita_audio_video_corrente
BEFORE UPDATE ON formato
FOR EACH ROW
BEGIN
    IF NEW.QualitaAudio < 1 OR NEW.QualitaAudio > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' audio non valida";
    ELSEIF NEW.QualitaVideo < 1 OR NEW.QualitaVideo > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Qualita' video non valida";
	ELSEIF NEW.LunghezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Lunghezza rapporto non valida";
	ELSEIF NEW.AltezzaRapporto <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza rapporto non valida";
	ELSEIF NEW.AltezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Altezza risoluzione non valida";
	ELSEIF NEW.LarghezzaRisoluzione <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Larghezza risoluzione non valida";
	
    END IF;
END$$

DROP TRIGGER IF EXISTS controllo_registi$$
CREATE TRIGGER controllo_registi
BEFORE INSERT ON Regista
FOR EACH ROW 
BEGIN
	IF NEW.Popolarità < 0 OR NEW.Popolarità > 10 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Regista con popolarità non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controllo_registi$$
CREATE TRIGGER controllo_registi
BEFORE UPDATE ON Regista
FOR EACH ROW 
BEGIN
	IF NEW.Popolarità < 0 OR NEW.Popolarità > 10 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Regista con popolarità non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controllo_attori$$
CREATE TRIGGER controllo_attori
BEFORE INSERT ON Regista
FOR EACH ROW 
BEGIN
	IF NEW.Popolarità < 0 OR NEW.Popolarità > 10 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Attore con popolarità non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controllo_attori$$
CREATE TRIGGER controllo_attori
BEFORE UPDATE ON Regista
FOR EACH ROW 
BEGIN
	IF NEW.Popolarità < 0 OR NEW.Popolarità > 10 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Attore con popolarità non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_disponibilita$$
CREATE TRIGGER controlla_disponibilita
BEFORE INSERT ON Disponibilita
FOR EACH ROW
BEGIN
	IF NEW.DimensioneFile <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dimensione non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_disponibilita$$
CREATE TRIGGER controlla_disponibilita
BEFORE UPDATE ON Disponibilita
FOR EACH ROW
BEGIN
	IF NEW.DimensioneFile <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dimensione non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_disponibilita_passata$$
CREATE TRIGGER controlla_disponibilita_passata
BEFORE INSERT ON Disponibilitapassata
FOR EACH ROW
BEGIN
	IF NEW.DimensioneFile <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dimensione non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_disponibilita_passata$$
CREATE TRIGGER controlla_disponibilita_passata
BEFORE UPDATE ON Disponibilitapassata
FOR EACH ROW
BEGIN
	IF NEW.DimensioneFile <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dimensione non accettabile';
	END IF;
END$$

DROP TRIGGER IF EXISTS controlla_distanza$$
CREATE TRIGGER controlla_distanza
BEFORE INSERT ON Distanza
FOR EACH ROW
BEGIN
	IF NEW.Kilometri <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Distanza non accettabile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_distanza$$
CREATE TRIGGER controlla_distanza
BEFORE UPDATE ON Distanza
FOR EACH ROW
BEGIN
	IF NEW.Kilometri <= 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Distanza non accettabile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_eta$$
CREATE TRIGGER controlla_eta
BEFORE INSERT ON Eta
FOR EACH ROW
BEGIN 
	IF NEW.Eta < 3 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Età non accettabile';
	END IF;
END $$

DROP TRIGGER IF EXISTS controlla_eta$$
CREATE TRIGGER controlla_eta
BEFORE UPDATE ON Eta
FOR EACH ROW
BEGIN 
	IF NEW.Eta < 3 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Età non accettabile';
	END IF;
END $$


DELIMITER ;