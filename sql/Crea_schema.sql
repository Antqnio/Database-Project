DROP SCHEMA IF EXISTS filmsphere;
CREATE SCHEMA filmsphere;
USE filmsphere;

/*************************************
 Area Formato
 *************************************/
 
    
CREATE TABLE formato (
	Codice VARCHAR(30) PRIMARY KEY,
    LunghezzaRapporto TINYINT,
    AltezzaRapporto TINYINT,
    LarghezzaRisoluzione SMALLINT,
    AltezzaRisoluzione SMALLINT,
    Codec VARCHAR(30),
    Bitrate DOUBLE,
    QualitaAudio INT,
    QualitaVideo INT,
    DataRilascio DATE
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE formatopassato (
	Codice VARCHAR(30) PRIMARY KEY,
    LunghezzaRapporto TINYINT,
    AltezzaRapporto TINYINT,
    LarghezzaRisoluzione SMALLINT,
    AltezzaRisoluzione SMALLINT,
    Codec VARCHAR(30),
    Bitrate DOUBLE,
    QualitaAudio DOUBLE,
    QualitaVideo DOUBLE,
    DataRilascio DATE,
    FormatoAttuale VARCHAR(30) NOT NULL,
    FOREIGN KEY(FormatoAttuale) REFERENCES formato(Codice)
) ENGINE = InnoDB CHARSET = latin1;


/**************************************
Area Film
**************************************/

CREATE TABLE film (
	Codice INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Durata INT,
    Genere VARCHAR(20),
    AnnoDiProduzione INT,
    Titolo VARCHAR(30),
    Rating FLOAT,
    Descrizione VARCHAR(255),
    PaeseDiProduzione VARCHAR(50),
    Visualizzazioni INT,
    KEY (Titolo, AnnoDiProduzione)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE regista (
	CodiceFiscale VARCHAR(5) PRIMARY KEY,
    Nome VARCHAR(30),
    Cognome VARCHAR(30),
    Popolarità INT
    ) ENGINE = InnoDB CHARSET = latin1;
    
CREATE TABLE direzione (
	Regista VARCHAR(20),
    Film INT NOT NULL,
    PRIMARY KEY (Regista, Film),
    FOREIGN KEY (Regista) REFERENCES regista(CodiceFiscale),
    FOREIGN KEY (Film) REFERENCES film(Codice)
    ) ENGINE = InnoDB CHARSET = latin1;
    
CREATE TABLE lingua (
	Nome VARCHAR(30) PRIMARY KEY
	) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE doppiaggio (
	Film INT NOT NULL,
    Lingua VARCHAR(30) NOT NULL,
    PRIMARY KEY(Film, Lingua),
    FOREIGN KEY (Film) REFERENCES film(Codice),
    FOREIGN KEY(Lingua) REFERENCES lingua(Nome)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE sottotitolaggio (
	Film INT NOT NULL,
    Lingua VARCHAR(30) NOT NULL,
    PRIMARY KEY(Film, Lingua),
    FOREIGN KEY (Film) REFERENCES film(Codice),
    FOREIGN KEY(Lingua) REFERENCES lingua(Nome)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE premiofilm (
	Nome VARCHAR(30) PRIMARY KEY
	) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE premiazionefilm (
	Premio VARCHAR(30) NOT NULL,
    Film INT NOT NULL,
    PRIMARY KEY(Premio, Film),
    FOREIGN KEY(Premio) REFERENCES premiofilm(Nome),
    FOREIGN KEY (Film) REFERENCES film(Codice)
    
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE attore (
	CodiceFiscale VARCHAR(20) PRIMARY KEY,
    Nome VARCHAR(30),
    Cognome VARCHAR(30),
    Popolarità INT
    ) ENGINE = InnoDB CHARSET = latin1;


CREATE TABLE recitazione (
	Film INT NOT NULL,
    Attore VARCHAR(20) NOT NULL,
    Principale VARCHAR(2),
    Premio VARCHAR(50),
    PRIMARY KEY (Film, Attore),
    FOREIGN KEY (Film) REFERENCES film(Codice),
    FOREIGN KEY (Attore) REFERENCES attore(CodiceFiscale)
    
	) ENGINE = InnoDB CHARSET = latin1;
    
 /*************************************
 Area Geografica
 *************************************/

CREATE TABLE areageografica (
	Codice VARCHAR(4) PRIMARY KEY,
    IPIniziale BIGINT,
    IPFinale BIGINT
    ) ENGINE = InnoDB CHARSET = latin1;
 
  /*************************************
 Area Server
 *************************************/
 
 CREATE TABLE `server` (
	Identificatore VARCHAR(20) PRIMARY KEY,
    Capacità INT,
    Banda FLOAT,
    AreaGeografica VARCHAR(30) NOT NULL,
    OffCounter INT DEFAULT 0,
    FOREIGN KEY(AreaGeografica) REFERENCES areageografica(Codice)
    ) ENGINE = InnoDB CHARSET = latin1;
 
 /*************************************
 Area Utente
 *************************************/
 
 CREATE TABLE utente (
	Email VARCHAR(50) NOT NULL,
    Codice INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(30),
    Cognome VARCHAR(30),
    Password VARCHAR(30),
    PRIMARY KEY (Email),
    KEY(Codice)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE pianodiabbonamento (
	Pacchetto VARCHAR(15) NOT NULL,
    Tariffa DOUBLE,
    MaxOre INT,
    MaxGigabyte INT,
    PRIMARY KEY(Pacchetto)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE fatturazione (
	Fattura INT NOT NULL AUTO_INCREMENT,
    Utente VARCHAR(50) NOT NULL,
    `Data` DATE,
    Scadenza DATE,
    CartaDiCredito BIGINT,
    PianoDiAbbonamento VARCHAR(30) NOT NULL,
    PRIMARY KEY(Fattura),
    FOREIGN KEY(Utente) REFERENCES utente(Email),
    FOREIGN KEY(PianoDiAbbonamento) REFERENCES pianodiabbonamento(Pacchetto)
    ) ENGINE = InnoDB CHARSET = latin1;


CREATE TABLE caratterizzazione (
	Descrizione VARCHAR(255) PRIMARY KEY
	) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE caratteristica (
	PianoDiAbbonamento VARCHAR(15) NOT NULL,
    Caratterizzazione VARCHAR(255) NOT NULL,
    PRIMARY KEY(PianoDiAbbonamento, Caratterizzazione),
    FOREIGN KEY(PianoDiAbbonamento) REFERENCES pianodiabbonamento(Pacchetto),
    FOREIGN KEY(Caratterizzazione) REFERENCES caratterizzazione(Descrizione)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE eta (
	Eta TINYINT NOT NULL,
    PRIMARY KEY(Eta)
	) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE limite (
	Eta TINYINT NOT NULL,
    PianoDiAbbonamento VARCHAR(15) NOT NULL,
    PRIMARY KEY(Eta, PianoDiAbbonamento),
    FOREIGN KEY(PianoDiAbbonamento) REFERENCES pianodiabbonamento(Pacchetto),
    FOREIGN KEY(Eta) REFERENCES eta(Eta)
    
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE dispositivo (
	Nome VARCHAR(30) PRIMARY KEY
) ENGINE = InnoDB CHARSET = latin1;


CREATE TABLE connessionepassata (
	Codice INT NOT NULL AUTO_INCREMENT,
    IndirizzoIP VARCHAR(50),
    Inizio TIMESTAMP,
    Fine TIMESTAMP,
    Utente VARCHAR(50) NOT NULL,
    Film INT NOT NULL,
    Formato VARCHAR(30) NOT NULL,
    Dispositivo VARCHAR(30) NOT NULL,
    `Server` VARCHAR(20) NOT NULL,
    PRIMARY KEY(Codice),
    FOREIGN KEY(Utente) REFERENCES utente(Email),
    FOREIGN KEY(Formato) REFERENCES formato(Codice),
    FOREIGN KEY(Film) REFERENCES film(Codice),
    FOREIGN KEY(Dispositivo) REFERENCES dispositivo(Nome),
    FOREIGN KEY(`Server`) REFERENCES `server`(Identificatore),
    KEY(Utente, Inizio)
    ) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE connessioneattuale (
	Utente VARCHAR(50) NOT NULL,
    IndirizzoIP VARCHAR(50),
    Inizio TIMESTAMP,
    Formato VARCHAR(30) NOT NULL,
    Dispositivo VARCHAR(30) NOT NULL,
    `Server` VARCHAR(20) NOT NULL,
    PRIMARY KEY(Utente),
    FOREIGN KEY(Utente) REFERENCES utente(Email),
    FOREIGN KEY(Formato) REFERENCES formato(Codice),
    FOREIGN KEY(Dispositivo) REFERENCES dispositivo(Nome),
    FOREIGN KEY(`Server`) REFERENCES `server`(Identificatore)
    ) ENGINE = InnoDB CHARSET = latin1;
	


    


 /*************************************
 Relazioni "generiche"
 *************************************/
 

CREATE TABLE contenuto(
	Film INT NOT NULL,
    Server VARCHAR(20) NOT NULL,
    PRIMARY KEY(Film, Server),
    FOREIGN KEY (Film) REFERENCES film(Codice),
    FOREIGN KEY(Server) REFERENCES Server(Identificatore)
) ENGINE = InnoDB CHARSET = latin1;


CREATE TABLE VisualizzazionePassata(
	Utente VARCHAR(50) NOT NULL, 
    Film INT NOT NULL,
    NumeroVolte INT DEFAULT 0,
    Stelle INT DEFAULT 0,
    PRIMARY KEY(Utente, Film),
    FOREIGN KEY(Utente) REFERENCES Utente(Email),
    FOREIGN KEY(Film) REFERENCES film(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE VisualizzazioneAttuale(
	Utente VARCHAR(50) NOT NULL, 
    Film INT NOT NULL,
    PRIMARY KEY(Utente, Film),
    FOREIGN KEY(Utente) REFERENCES Utente(Email),
    FOREIGN KEY(Film) REFERENCES film(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE Caching(
	Utente VARCHAR(50) NOT NULL,
    Film INT NOT NULL,
    Server VARCHAR(20) NOT NULL,
    PRIMARY KEY (Utente, Film, Server),
    FOREIGN KEY(Utente) REFERENCES Utente(Email),
    FOREIGN KEY(Film) REFERENCES film(Codice),
    FOREIGN KEY(Server) REFERENCES Server(Identificatore)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE Disponibilita (
	Film INT NOT NULL,
	Formato VARCHAR(30) NOT NULL,
    DimensioneFile FLOAT,
    PRIMARY KEY (Film, Formato),
    FOREIGN KEY(Film) REFERENCES film(Codice),
    FOREIGN KEY(Formato) REFERENCES formato(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE DisponibilitaPassata (
	Film INT NOT NULL,
	FormatoPassato VARCHAR(30) NOT NULL,
    DimensioneFile FLOAT,
    PRIMARY KEY (Film, FormatoPassato),
    FOREIGN KEY(Film) REFERENCES film(Codice),
    FOREIGN KEY(FormatoPassato) REFERENCES formatopassato(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE Limitazione(
	PianoDiAbbonamento VARCHAR(15) NOT NULL,
    AreaGeografica VARCHAR(30) NOT NULL,
    PRIMARY KEY(PianoDiAbbonamento, AreaGeografica),
    FOREIGN KEY(PianoDiAbbonamento) REFERENCES pianodiabbonamento(Pacchetto),
    FOREIGN KEY(AreaGeografica) REFERENCES areageografica(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE Restrizione (
	Formato VARCHAR(30) NOT NULL,
    AreaGeografica VARCHAR(30) NOT NULL,
    PRIMARY KEY(Formato, AreaGeografica),
    FOREIGN KEY(Formato) REFERENCES formato(Codice),
    FOREIGN KEY(AreaGeografica) REFERENCES areageografica(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE RestrizionePassata(
	FormatoPassato VARCHAR(30) NOT NULL,
    AreaGeografica VARCHAR(30) NOT NULL,
    PRIMARY KEY(FormatoPassato, AreaGeografica),
    FOREIGN KEY(FormatoPassato) REFERENCES formatopassato(Codice),
    FOREIGN KEY(AreaGeografica) REFERENCES areageografica(Codice)
) ENGINE = InnoDB CHARSET = latin1;

CREATE TABLE Distanza(
	Server VARCHAR(20) NOT NULL,
    AreaGeografica VARCHAR(30) NOT NULL,
    Kilometri INT NOT NULL,
    PRIMARY KEY(Server, AreaGeografica),
    FOREIGN KEY(Server) REFERENCES Server(Identificatore),
    FOREIGN KEY(AreaGeografica) REFERENCES areageografica(Codice)
) ENGINE = InnoDB CHARSET = latin1;
