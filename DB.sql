DROP TABLE IF EXISTS Arnia;
DROP TABLE IF EXISTS Fioritura;
DROP TABLE IF EXISTS Apiario;
DROP TABLE IF EXISTS Trattamento;
DROP TABLE IF EXISTS Cura;
DROP TABLE IF EXISTS Prodotto;
DROP TABLE IF EXISTS Clienti;
DROP TABLE IF EXISTS Vendita;
DROP TABLE IF EXISTS Appartiene;

/* Creazione della tabella Arnia */
CREATE TABLE Arnia(
	Matricola int PRIMARY KEY AUTO_INCREMENT,
	Dimensione int(5) NOT NULL,
	Età_regina int(1)
	)ENGINE = InnoDB;

/* Creazione della tabella Fioritura */
CREATE TABLE Fioritura(
	Specie varchar(32) PRIMARY KEY,
	Caratteristiche varchar(64)
	)ENGINE = InnoDB;

/* Creazione della tabella Apiario */
CREATE TABLE Apiario(
	NatId varchar(16) PRIMARY KEY,
	Allevamento varchar(16) NOT NULL,
	Luogo varchar(16) NOT NULL,
	Varietà varchar(32) ,
	FOREIGN KEY (Varietà) REFERENCES Fioritura(Specie) ON DELETE SET NULL ON UPDATE CASCADE
	)ENGINE = InnoDB;

/* Crezione della tabella Trattamento */
CREATE TABLE Trattamento(
	Prodotti varchar(32) PRIMARY KEY,
	Tipo varchar(64) NOT NULL
	)ENGINE = InnoDB;

/* Creazione della tabella Cura */
CREATE TABLE Cura(
	Arnia int,
	Data date,
	Tipo varchar(32),
	Ordinario varchar(2) DEFAULT 'si',
	PRIMARY KEY (Arnia,Data),
	FOREIGN KEY (Arnia) REFERENCES Arnia(Matricola) ON DELETE NO ACTION ON UPDATE CASCADE,
	FOREIGN KEY (Tipo) REFERENCES Trattamento(Prodotti) ON DELETE NO ACTION ON UPDATE NO ACTION
	)ENGINE = InnoDB;

/* Creazione della tabella Prodotto */
CREATE TABLE Prodotto(
	Id int PRIMARY KEY AUTO_INCREMENT,
	Arnia int,
	DataProd date,
	Tipologia varchar(32) NOT NULL,
	Quantità_gr int NOT NULL,
	FOREIGN KEY (Arnia) REFERENCES Arnia(Matricola) ON DELETE NO ACTION ON UPDATE CASCADE
	)ENGINE = InnoDB;

/* Creazione della tabella Clienti*/
CREATE TABLE Cliente(
	Partita_IVA varchar(11) PRIMARY KEY,
	Nome varchar(32) NOT NULL,
	Email varchar(32) DEFAULT ' ',
	Indirizzo varchar(32) NOT NULL,
	Tipo varchar(32) NOT NULL,
	Sconto varchar(4) DEFAULT '00%'
	)ENGINE = InnoDB;

/* Creazione della tabella Vendita */
CREATE TABLE Vendita(
	Prodotto int PRIMARY KEY,
	Cliente varchar(11),
	FOREIGN KEY (Prodotto) REFERENCES Prodotto(Id) ON DELETE NO ACTION ON UPDATE CASCADE,
	FOREIGN KEY (Cliente) REFERENCES Cliente(Partita_IVA) ON DELETE NO ACTION ON UPDATE CASCADE
	)ENGINE = InnoDB;

/* Creazione della tabella Appartiene */
CREATE TABLE Appartiene(
	Matricola int,
	Inizio date,
	Fine date DEFAULT NULL,
	Apiario varchar(16) NOT NULL,
	PRIMARY KEY (Matricola,Inizio),
	FOREIGN KEY(Matricola) REFERENCES Arnia(Matricola) ON DELETE NO ACTION ON UPDATE CASCADE, /* Per mantenere lo storico */
	FOREIGN KEY(Apiario) REFERENCES Apiario(NatId) ON DELETE NO ACTION ON UPDATE CASCADE /* Per mantenere lo storico */
	)ENGINE = InnoDB;

/*
	Un trigger è una procedura eseguita in maniera automatica in coincidenza di un determinato evento.
	Ogni trigger è associato ad una tabella e richiamato automaticamente dal DBMS.
	Può essere invocato before o after l'evento che causa l'attivazione (insert, delete, update).
	Un trigger a livello di riga (definito da "for each row") viene eseguito una volta per ogni riga che causa l'attivazione,
		un trigger a livello di istruzione invece, una volta sola al verificarsi dell'evento 
		(a prescindere dal numero di tuple inserite/cancellate/aggiornate).
	Nei trigger di riga (solo update) è possibile accedere al valore di un attributo prima e dopo la sua modifica,
	in quelli insert solo il nuovo valore:
		:OLD.<colonna>     :NEW.<colonna>
*/

/*	calcola il numero di acquisti effettuati da ogni cliente*/
DROP FUNCTION IF EXISTS NumeroAquistiCliente;
DELIMITER |
CREATE FUNCTION NumeroAcquisti (Partitaiva char(11))
  RETURNS smallint
BEGIN
  DECLARE Numero smallint;
  SELECT COUNT(*) INTO Numero FROM Vendita WHERE Cliente=Partitaiva;
  RETURN Numero;
END;|
DELIMITER ;

/*	ritorna la tipologia del cliente che corrisponde alla partita IVA di invocazione*/
DROP FUNCTION IF EXISTS TipoCliente;
DELIMITER $$
CREATE FUNCTION TipoCliente(Partita char(11))
  RETURNS char(20)
BEGIN
  DECLARE tip char(20);
  SELECT Tipo INTO tip FROM Cliente WHERE Partita_IVA=Partita;
  RETURN tip;
END; $$
DELIMITER ;

/*	Se viene inserito un centro commerciale tra i clienti, questo trigger imposta lo sconto al 10%*/
DROP TRIGGER IF EXISTS Sconto_Commerciale;
DELIMITER |
CREATE TRIGGER Sconto_Commerciale
BEFORE INSERT ON Cliente
FOR EACH ROW
BEGIN
IF NEW.Tipo='Centro Commerciale' THEN
SET NEW.Sconto='10%';
END IF;
END;|
DELIMITER ;

/*	Se un piccolo rivenditore al momento di un acqisto ne ha già effettuati almeno 5 allora viene aggiornato lo sconto risevato all' 08%*/
DROP TRIGGER IF EXISTS Sconto_PRivenditore;
DELIMITER |
CREATE TRIGGER Sconto_PRivenditore
BEFORE INSERT ON Vendita
FOR EACH ROW
BEGIN
IF(TipoCliente(NEW.Cliente)='Piccolo rivenditore') AND (NumeroAcquisti(NEW.Cliente)>=5) THEN
	UPDATE Cliente
	SET Cliente.Sconto='08%' 
	WHERE Cliente.Partita_IVA=NEW.Cliente;
END IF;
END;|
DELIMITER ;


INSERT INTO Arnia (Dimensione,Età_regina) VALUES
(10,2),
(10,4),
(10,3),
(10,1),
(10,5),
(10,3),
(12,3),
(12,3),
(12,5),
(10,3),
(10,2),
(10,1),
(12,1),
(12,2),
(10,3),
(10,2),
(10,4),
(12,3),
(10,4),
(12,5),
(10,2),
(10,3),
(12,4),
(10,4),
(12,3),
(10,1),
(10,4),
(12,3),
(10,1),
(12,2),
(10,2),
(12,3),
(12,3),
(10,4),
(12,3),
(12,3),
(10,3),
(12,4),
(10,2),
(10,1),
(12,1),
(10,1),
(12,1),
(10,1),
(10,5),
(10,5),
(10,2),
(12,5),
(12,1),
(10,1);

INSERT INTO Fioritura(Specie,Caratteristiche) VALUES
('Tarassaco','Fioritura verso inizio primavera, buona produzione di nettare'),
('Agrumi','Fioritura lunga marzo-maggio'),
('Acacia','Fioritura inizio maggio,ottima produzione di nettare'),
('Tiglio-Castagno','Fioritura durante tutto il mese di luglio'),
('Melata di Abete','Secrezione zuccherina provocata da Rincoti Omotteri'),
('Corbezzolo','Fioritura verso fine estate, abbondante produzione di nettare');

INSERT INTO Apiario(NatId,Allevamento,Luogo,Varietà) VALUES
('ITVIB23412','Stanziale','Thiene','Tarassaco'),
('ITVIB34928','Nomade','Brugine','Acacia'),
('ITVIB98341','Nomade','Borgosesia','Tiglio-Castagno'),
('ITVIB34724','Nomade','Cavalese','Melata di Abete'),
('ITVIB21989','Nomade','Mazzano Romano','Corbezzolo'),
('ITVIB43619','Nomade','Piano-vetrale','Agrumi');

INSERT INTO Trattamento(Prodotti,Tipo) VALUES
('Acido ossalico Gocciolato','Cura Varroa'),
('Acido ossalico Sublimato','Cura Varroa'),
('Apiguard','Timolo in vaschetta'),
('Apivar','Amitraz in strisce'),
('Apistan','Strisce'),
('ApilifeVar','Barrette al timolo'),
('Coumaphos','Insetticida contro l’Aethina tumida'),
('Acido ossalico Spruzzato','Cura Varroa');

INSERT INTO Cura(Arnia,Data,Tipo) VALUES
(1,'2016-08-01','Apivar'),
(2,'2016-08-01','Acido ossalico Sublimato'),
(3,'2016-08-01','Acido ossalico Sublimato'),
(4,'2016-08-01','Acido ossalico Sublimato'),
(5,'2016-08-01','Acido ossalico Sublimato'),
(8,'2016-08-01','Acido ossalico Sublimato'),
(12,'2016-08-01','Acido ossalico Sublimato'),
(13,'2016-08-01','Acido ossalico Sublimato'),
(14,'2016-08-01','Acido ossalico Sublimato'),
(15,'2016-08-01','Acido ossalico Sublimato'),
(16,'2016-08-01','Acido ossalico Sublimato'),
(17,'2016-08-01','Acido ossalico Gocciolato'),
(18,'2016-08-01','Acido ossalico Gocciolato'),
(19,'2016-08-01','Acido ossalico Gocciolato'),
(20,'2016-08-01','Acido ossalico Gocciolato'),
(21,'2016-08-01','Acido ossalico Gocciolato'),
(25,'2016-08-01','Acido ossalico Spruzzato'),
(30,'2016-08-23','Apistan'),
(31,'2016-08-23','Apistan'),
(32,'2016-08-23','Apistan'),
(33,'2016-08-23','Apistan'),
(38,'2016-08-23','Apivar'),
(39,'2016-08-25','Apivar'),
(40,'2016-08-25','ApilifeVar'),
(41,'2016-08-25','Apiguard'),
(42,'2016-08-25','Acido ossalico Gocciolato'),
(43,'2016-08-25','Acido ossalico Gocciolato'),
(44,'2016-08-25','Acido ossalico Gocciolato'),
(45,'2016-09-01','Acido ossalico Gocciolato'),
(47,'2016-09-01','Acido ossalico Gocciolato'),
(48,'2016-09-01','Acido ossalico Gocciolato'),
(50,'2016-09-02','Apiguard');

INSERT INTO Cura(Arnia,Data,Tipo,Ordinario) VALUES
(26,'2016/10/07','Coumaphos','No');

INSERT INTO Prodotto(Arnia,DataProd,Tipologia,Quantità_gr) VALUES
(1,'2016-06-30','Propoli',800),
(2,'2016-05-30','Propoli',560),
(3,'2016-05-30','Propoli',330),
(4,'2016-05-30','Propoli',900),
(5,'2016-05-30','Propoli',780),
(6,'2016-06-30','Pappa reale',100),
(7,'2016-06-30','Pappa reale',350),
(8,'2016-06-30','Pappa reale',450),
(9,'2016-06-30','Pappa reale',210),
(10,'2016-05-23','Veleno',30),
(11,'2016-08-13','Veleno',25),
(12,'2016-06-02','Cera',4000),
(13,'2016-06-17','Cera',6000),
(14,'2016-06-12','Cera',3000),
(15,'2016-05-30','Miele Tarassaco',25000),
(16,'2016-05-30','Miele Tarassaco',22000),
(17,'2016-05-30','Miele Tarassaco',31000),
(18,'2016-05-24','Miele Acacia',25000),  
(19,'2016-05-25','Miele Acacia',25000),
(20,'2016-05-28','Miele Acacia',25000),
(21,'2016-06-12','Miele Acacia',35000),
(26,'2016-05-26','Miele Agrumi',30000),
(27,'2016-05-26','Miele Agrumi',36000),
(28,'2016-05-23','Miele Agrumi',27000),
(29,'2016-05-22','Miele Agrumi',24000),
(30,'2016-05-29','Miele Agrumi',32000),
(31,'2016-05-28','Miele Agrumi',32000),
(32,'2016-05-27','Miele Agrumi',35000),
(33,'2016-10-25','Miele Tiglio-Castagno',30000),
(34,'2016-10-25','Miele Tiglio-Castagno',23000),
(35,'2016-10-25','Miele Tiglio-Castagno',30000),
(40,'2016-09-24','Melata di Abete',50000),
(41,'2016-09-23','Melata di Abete',57000),
(42,'2016-09-23','Melata di Abete',23000),
(43,'2016-09-23','Melata di Abete',39000),
(44,'2016-09-24','Melata di Abete',46000),
(45,'2016-10-24','Miele Corbezzolo',11000),
(46,'2016-10-26','Miele Corbezzolo',34000),
(47,'2016-10-30','Miele Corbezzolo',45000),
(50,'2016-10-21','Miele Corbezzolo',21000);

INSERT INTO Cliente(Partita_IVA,Nome,Email,Indirizzo,Tipo) VALUES
('00012354321','Rossi','rossi@gmail.com','viale bruni 9','Piccolo rivenditore'),
('00012354322','Bruno','bruno@gmail.com','via venezia 45','Piccolo rivenditore'),
('00012354323','Bianchi','bianchi@gmail.com','via europa 3','Piccolo rivenditore'),
('00012354324','Cavion','cavion@gmail.com','viale della pace 54','Piccolo rivenditore'),
('00012354325','Rizzato','rizzato@gmail.com','via veneto 23','Piccolo rivenditore'),
('00012354326','Iper Market SPA','ufficio@centro.com','via tropico 93','Centro Commerciale');

INSERT INTO Vendita(Prodotto,Cliente) VALUES
(1,'00012354326'),
(2,'00012354326'),
(3,'00012354326'),
(7,'00012354326'),
(8,'00012354326'),
(9,'00012354326'),
(12,'00012354326'),
(13,'00012354326'),
(14,'00012354326'),
(15,'00012354321'),
(16,'00012354321'),
(17,'00012354321'),
(18,'00012354321'),
(19,'00012354321'),
(20,'00012354321'),
(21,'00012354326'),
(27,'00012354322'),
(28,'00012354322'),
(29,'00012354322'),
(30,'00012354323'),
(31,'00012354323'),
(32,'00012354323'),
(33,'00012354323'),
(34,'00012354324'),
(35,'00012354324'),
(40,'00012354326'),
(4,'00012354324'),
(5,'00012354325'),
(6,'00012354325'),
(10,'00012354325'),
(11,'00012354325'),
(23,'00012354325');

INSERT INTO Appartiene(Matricola,Inizio,Apiario) VALUES
(1,'2016-01-01','ITVIB23412'),
(2,'2016-01-01','ITVIB23412'),
(3,'2016-01-01','ITVIB23412'),
(4,'2016-01-01','ITVIB23412'),
(5,'2016-01-01','ITVIB23412'),
(6,'2016-01-01','ITVIB23412'),
(7,'2016-01-01','ITVIB23412'),
(8,'2016-01-01','ITVIB23412'),
(9,'2016-01-01','ITVIB23412'),
(10,'2016-01-01','ITVIB23412'),
(11,'2016-01-01','ITVIB23412'),
(12,'2016-01-01','ITVIB23412'),
(13,'2016-01-01','ITVIB23412'),
(14,'2016-01-01','ITVIB23412'),
(15,'2016-01-01','ITVIB23412'),
(16,'2016-01-01','ITVIB23412'),
(17,'2016-01-01','ITVIB23412'),
(26,'2016-01-01','ITVIB43619'),
(27,'2016-01-01','ITVIB43619'),
(28,'2016-01-01','ITVIB43619'),
(29,'2016-01-01','ITVIB43619'),
(30,'2016-01-01','ITVIB43619'),
(31,'2016-01-01','ITVIB43619'),
(32,'2016-01-01','ITVIB43619'),
(18,'2016-01-01','ITVIB34928'),
(19,'2016-01-01','ITVIB34928'),
(20,'2016-01-01','ITVIB34928'),
(21,'2016-01-01','ITVIB34928'),
(22,'2016-01-01','ITVIB34928'),
(23,'2016-01-01','ITVIB34928'),
(24,'2016-01-01','ITVIB34928'),
(25,'2016-01-01','ITVIB34928'),
(33,'2016-01-01','ITVIB98341'),
(34,'2016-01-01','ITVIB98341'),
(35,'2016-01-01','ITVIB98341'),
(36,'2016-01-01','ITVIB98341'),
(37,'2016-01-01','ITVIB98341'),
(38,'2016-01-01','ITVIB98341'),
(39,'2016-01-01','ITVIB98341'),
(40,'2016-01-01','ITVIB34724'),
(41,'2016-01-01','ITVIB34724'),
(42,'2016-01-01','ITVIB34724'),
(43,'2016-01-01','ITVIB34724'),
(44,'2016-01-01','ITVIB34724'),
(45,'2016-01-01','ITVIB21989'),
(46,'2016-01-01','ITVIB21989'),
(47,'2016-01-01','ITVIB21989'),
(48,'2016-01-01','ITVIB21989'),
(49,'2016-01-01','ITVIB21989'),
(50,'2016-01-01','ITVIB21989');

/*
PRIMA QUERY: Età della regina delle arnie che hanno prodotto miele di tiglio/castagno in quantità superiore a 25 kg
*/
CREATE VIEW Età_ AS
SELECT DISTINCT Matricola, Età_regina
FROM Arnia JOIN Prodotto ON Matricola=Arnia
WHERE Tipologia='Miele Tiglio-Castagno' AND Quantità_gr>=2500;

/* SECONDA QUERY: Id e tipologia dei prodotti derivati da arnie appartenenti in data di produzione ad un apiario stanziale e che non hanno subito trattamenti
				  straordinari in tempi precedenti */
CREATE VIEW Stanziale_Trattamenti_Ordinari AS
SELECT p.Id, p.Tipologia
FROM Prodotto p, Appartiene ap, Apiario api
WHERE api.Allevamento='Stanziale' AND p.Arnia=ap.Matricola AND ap.Apiario=api.Natid AND p.Id IN(
	SELECT w.Id
	FROM Prodotto w
	WHERE w.DataProd < ALL (
		SELECT a.Data 
		FROM Cura a
		WHERE w.Arnia=a.Arnia AND a.Ordinario='no'
	)
);

/*	TERZA QUERY: Id e tipologia dei prodotti acquistati da centri commerciali e derivati da arnie appartenenti in data 
				 di produzione ad un apiario stanziale e che non hanno subito trattamenti straordinari in tempi precedenti. */
CREATE VIEW Commerciale_Trattamenti_Ordinari AS
SELECT z.Id, z.Tipologia
FROM Prodotto z, Vendita v, Cliente c
WHERE c.Tipo='Centro Commerciale' AND v.Cliente=c.Partita_IVA AND z.Id=v.Prodotto AND z.Id IN(
	SELECT p.Id
	FROM Prodotto p, Appartiene ap, Apiario api
	WHERE api.Allevamento='Stanziale' AND p.Arnia=ap.Matricola AND ap.Apiario=api.Natid AND p.Id IN(
		SELECT w.Id
		FROM Prodotto w
		WHERE w.DataProd < ALL (
			SELECT a.Data 
			FROM Cura a
			WHERE w.Arnia=a.Arnia AND a.Ordinario='no'
			)
	)
);

/*	QUARTA QUERY: seleziona l 'email dei clienti che hanno acquistato più di 500 kg di prodotti e più di 200 gr di Pappa reale  */
CREATE VIEW  Clienti_500 AS
SELECT Cliente, SUM(Quantità_gr) AS Spesa, Email
FROM (Vendita JOIN Cliente ON Cliente=Partita_IVA),Prodotto #JOIN Prodotto ON Prodotto=Id (e non ,Prodotto) 
	GROUP BY Cliente HAVING Spesa>=500000 AND Cliente IN(
		SELECT Cliente
		FROM Vendita JOIN Prodotto ON Prodotto=Id
		WHERE Tipologia='Pappa reale' AND Quantità_gr>200
	);

/*	QUINTA QUERY: trova la media dei grammi dei prodotti acquistati da piccoli rivenditori, escludendo il veleno d'api  */
CREATE VIEW Media_Acquisti AS
SELECT AVG(Quantità_gr)
FROM Cliente JOIN (Vendita JOIN Prodotto ON Prodotto=Id AND Tipologia <> 'Veleno') ON Partita_IVA=Cliente
WHERE Tipo='Piccolo rivenditore';

/*	SESTA QUERY: Trova gli identificativi nazionali degli apiari nomadi contenenti almeno un'arnia 
    			 trattata almeno una volta con Acido ossalico Gocciolato o Sublimato e mai con Apivar */
CREATE VIEW Nomade_Trattamenti AS
SELECT DISTINCT NatId 
FROM Apiario JOIN Appartiene ON NatId=Apiario
WHERE Allevamento <> 'Stanziale' AND Matricola IN (
	SELECT Arnia
	FROM Cura
	WHERE (Tipo='Acido ossalico Sublimato' OR Tipo='Acido ossalico Gocciolato') AND Tipo <> 'Apivar');

