-- SQL script for oppgave DB1 c)

-- Sletter tabellene hvis de allerede eksisterer
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS deltar_på_lagtrening;
DROP TABLE IF EXISTS medlem_av_idrettslag;
DROP TABLE IF EXISTS senter_har_fasilitet;
DROP TABLE IF EXISTS lagtrening;
DROP TABLE IF EXISTS gruppetime;
DROP TABLE IF EXISTS sykkel;
DROP TABLE IF EXISTS tredemølle;
DROP TABLE IF EXISTS prikk;
DROP TABLE IF EXISTS idrettslag_gruppe;
DROP TABLE IF EXISTS treningssenter_bemanning;
DROP TABLE IF EXISTS sal;
DROP TABLE IF EXISTS instruktør;
DROP TABLE IF EXISTS bruker;
DROP TABLE IF EXISTS idrettslag;
DROP TABLE IF EXISTS aktivitet;
DROP TABLE IF EXISTS fasilitet;
DROP TABLE IF EXISTS treningssenter;
DROP TABLE IF EXISTS system_tid;


-- Aktiverer sjekk av fremmednøkler
PRAGMA foreign_keys = ON;

-- Oppretter simulering av tid (for testdata)
------------------------------------------------------------------------------------
-- Denne tabellen er et resultat av å simulere tid for at programmet skal være
-- etterprøvbart for sensor, og løsningen er valgt i SQL fordi oppgaven spesifiserer
-- at SQL favoriseres over Python.
CREATE TABLE system_tid (
    simulert_nåtid DATETIME NOT NULL
);

-- Oppretter tabellene
CREATE TABLE treningssenter (
    navn VARCHAR(100) PRIMARY KEY,
    gateadresse VARCHAR(100) NOT NULL,
    åpningstid TIME NOT NULL,
    stengningstid TIME NOT NULL,
    CONSTRAINT sjekk_åpningstider CHECK (åpningstid < stengningstid)
);

CREATE TABLE fasilitet (
    navn VARCHAR(100) PRIMARY KEY
);

CREATE TABLE aktivitet (
    navn VARCHAR(100) PRIMARY KEY,
    beskrivelse VARCHAR(800) NOT NULL
);

CREATE TABLE bruker (
    brukerID INTEGER PRIMARY KEY,
    epost VARCHAR(100) NOT NULL UNIQUE,
    fornavn VARCHAR(50) NOT NULL,
    etternavn VARCHAR(50) NOT NULL,
    mobil VARCHAR(20) NOT NULL
);

CREATE TABLE instruktør (
    brukerID INTEGER PRIMARY KEY,
    FOREIGN KEY (brukerID) REFERENCES bruker(brukerID) ON DELETE CASCADE
);

CREATE TABLE idrettslag (
    navn VARCHAR(100) PRIMARY KEY
);

CREATE TABLE sal (
    senter_navn VARCHAR(100),
    navn VARCHAR(100),
    kapasitet INTEGER NOT NULL CHECK (kapasitet > 0),
    PRIMARY KEY (senter_navn, navn),
    FOREIGN KEY (senter_navn) REFERENCES treningssenter(navn) ON DELETE CASCADE
);

CREATE TABLE treningssenter_bemanning (
    senter_navn VARCHAR(100),
    ukedag VARCHAR(7),
    start_tid TIME,
    slutt_tid TIME NOT NULL,
    CHECK (ukedag IN('Mandag', 'Tirsdag', 'Onsdag', 'Torsdag', 'Fredag', 'Lørdag', 'Søndag')),
    PRIMARY KEY (senter_navn, ukedag, start_tid),
    FOREIGN KEY (senter_navn) REFERENCES treningssenter(navn) ON DELETE CASCADE,
    CONSTRAINT sjekk_bemanningstid CHECK (start_tid < slutt_tid)
);

CREATE TABLE tredemølle (
    senter_navn VARCHAR(100),
    sal_navn VARCHAR(100),
    tredemøllenr INTEGER CHECK (tredemøllenr > 0),
    produsent VARCHAR(50) NOT NULL,
    maks_hastighet INTEGER NOT NULL CHECK (maks_hastighet > 0),
    maks_stigning INTEGER NOT NULL CHECK (maks_stigning > 0),
    PRIMARY KEY (senter_navn, sal_navn, tredemøllenr),
    FOREIGN KEY (senter_navn, sal_navn) REFERENCES sal(senter_navn, navn) ON DELETE CASCADE
);

CREATE TABLE sykkel (
    senter_navn VARCHAR(100),
    sal_navn VARCHAR(100),
    sykkelnr INTEGER CHECK (sykkelnr > 0),
    bodybike_forbindelse INTEGER NOT NULL CHECK (bodybike_forbindelse IN (0,1)),
    PRIMARY KEY (senter_navn, sal_navn, sykkelnr),
    FOREIGN KEY (senter_navn, sal_navn) REFERENCES sal(senter_navn, navn) ON DELETE CASCADE
);

CREATE TABLE prikk (
    brukerID INTEGER,
    dato_og_tid DATETIME NOT NULL,
    PRIMARY KEY (brukerID, dato_og_tid),
    FOREIGN KEY (brukerID) REFERENCES bruker(brukerID) ON DELETE CASCADE
);

CREATE TABLE idrettslag_gruppe (
    idrettslag_navn VARCHAR(100),
    gruppe_navn VARCHAR(100),
    PRIMARY KEY (idrettslag_navn, gruppe_navn),
    FOREIGN KEY (idrettslag_navn) REFERENCES idrettslag(navn) ON DELETE CASCADE
);

CREATE TABLE gruppetime (
    senter_navn VARCHAR(100),
    sal_navn VARCHAR(100),
    start_tid DATETIME,
    slutt_tid DATETIME NOT NULL,
    aktivitet_navn VARCHAR(100) NOT NULL,
    instruktørID INTEGER NOT NULL,
    PRIMARY KEY (senter_navn, sal_navn, start_tid),
    UNIQUE (instruktørID, start_tid),
    FOREIGN KEY (senter_navn, sal_navn) REFERENCES sal(senter_navn, navn) ON DELETE CASCADE,
    FOREIGN KEY (aktivitet_navn) REFERENCES aktivitet(navn) ON DELETE CASCADE,
    FOREIGN KEY (instruktørID) REFERENCES instruktør(brukerID) ON DELETE CASCADE,
    CONSTRAINT sjekk_gruppetime_tid CHECK (start_tid < slutt_tid)
);

CREATE TABLE lagtrening (
    idrettslag_navn VARCHAR(100),
    gruppe_navn VARCHAR(100),
    start_tid DATETIME,
    slutt_tid DATETIME NOT NULL,
    senter_navn VARCHAR(100) NOT NULL,
    sal_navn VARCHAR(100) NOT NULL,
    PRIMARY KEY (idrettslag_navn, gruppe_navn, start_tid),
    UNIQUE (senter_navn, sal_navn, start_tid),
    FOREIGN KEY (idrettslag_navn, gruppe_navn) REFERENCES idrettslag_gruppe(idrettslag_navn, gruppe_navn) ON DELETE CASCADE,
    FOREIGN KEY (senter_navn, sal_navn) REFERENCES sal(senter_navn, navn) ON DELETE CASCADE,
    CONSTRAINT sjekk_lagtrening_tid CHECK (start_tid < slutt_tid)
);

CREATE TABLE senter_har_fasilitet (
    fasilitet VARCHAR(100),
    senter_navn VARCHAR(100),
    PRIMARY KEY (fasilitet, senter_navn),
    FOREIGN KEY (fasilitet) REFERENCES fasilitet(navn) ON DELETE CASCADE,
    FOREIGN KEY (senter_navn) REFERENCES treningssenter(navn) ON DELETE CASCADE
);

CREATE TABLE medlem_av_idrettslag (
    brukerID INTEGER,
    idrettslag_navn VARCHAR(100),
    PRIMARY KEY (brukerID, idrettslag_navn),
    FOREIGN KEY (brukerID) REFERENCES bruker(brukerID) ON DELETE CASCADE,
    FOREIGN KEY (idrettslag_navn) REFERENCES idrettslag(navn) ON DELETE CASCADE
);

CREATE TABLE deltar_på_lagtrening (
    brukerID INTEGER,
    idrettslag_navn VARCHAR(100),
    gruppe_navn VARCHAR(100),
    start_tid DATETIME,
    PRIMARY KEY (brukerID, idrettslag_navn, gruppe_navn, start_tid),
    FOREIGN KEY (brukerID, idrettslag_navn) REFERENCES medlem_av_idrettslag(brukerID, idrettslag_navn) ON DELETE CASCADE,
    FOREIGN KEY (idrettslag_navn, gruppe_navn, start_tid) REFERENCES lagtrening(idrettslag_navn, gruppe_navn, start_tid) ON DELETE CASCADE
);

CREATE TABLE booking (
    senter_navn VARCHAR(100),
    sal_navn VARCHAR(100),
    start_tid DATETIME,
    brukerID INTEGER,
    status VARCHAR(10) NOT NULL DEFAULT 'Booket',
    kø_posisjon INTEGER CHECK (kø_posisjon >= 0),
    CHECK (status IN('Møtt', 'Ikke møtt', 'Booket', 'Avmeldt', 'Venteliste')),
    PRIMARY KEY (senter_navn, sal_navn, start_tid, brukerID),
    FOREIGN KEY (senter_navn, sal_navn, start_tid) REFERENCES gruppetime(senter_navn, sal_navn, start_tid) ON DELETE CASCADE,
    FOREIGN KEY (brukerID) REFERENCES bruker(brukerID) ON DELETE CASCADE
);
