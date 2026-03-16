-- Brukstilfelle 1:
-- 'Legg inn treningssenter, saler, noen sykler, noen brukere,
-- noen trenere og treninger som nevnt over.'

-- Setter en simulert nåtid for å sikre at programmet er etterprøvbart
INSERT INTO system_tid (simulert_nåtid)
VALUES ('2026-03-17 17:30:00');

-- Legger til treningssentrene
INSERT INTO treningssenter (navn, gateadresse, åpningstid, stengningstid)
VALUES
    ('Gløshaugen idrettsbygg', 'Chr. Frederiks gate 20, 7030 Trondheim', '05:00:00', '23:59:59'),
    ('Moholt treningssenter', 'Moholt allmenning 12, 7050 Trondheim', '05:00:00', '23:59:59'),
    ('DMMH treningsrom', 'Thrond Nergaards veg 7, 7044 Trondheim', '06:00:00', '23:30:00'),
    ('Øya treningssenter', 'Vangslundsgate 2, 7030 Trondheim', '05:00:00', '23:59:59'),
    ('Dragvoll idrettssenter', 'Loholt allé 81, 7049 Trondheim', '05:00:00', '23:59:59');

-- Legger til bemanning for noen treningssentre
INSERT INTO treningssenter_bemanning (senter_navn, ukedag, start_tid, slutt_tid)
VALUES
    ('Øya treningssenter', 'Mandag', '08:00:00', '12:00:00'),
    ('Øya treningssenter', 'Onsdag', '08:00:00', '12:00:00'),
    ('Øya treningssenter', 'Fredag', '08:00:00', '12:00:00'),

    ('Øya treningssenter', 'Mandag', '15:00:00', '22:00:00'),
    ('Øya treningssenter', 'Tirsdag', '15:00:00', '22:00:00'),
    ('Øya treningssenter', 'Onsdag', '15:00:00', '22:00:00'),
    ('Øya treningssenter', 'Torsdag', '15:00:00', '22:00:00'),
    ('Øya treningssenter', 'Fredag', '15:00:00', '22:00:00'),

    ('Øya treningssenter', 'Lørdag', '09:00:00', '12:00:00'),
    ('Øya treningssenter', 'Søndag', '09:00:00', '12:00:00');


-- Legger til saler
INSERT INTO sal (senter_navn, navn, kapasitet)
VALUES
    ('Gløshaugen idrettsbygg', 'Løperom', 15),
    ('Gløshaugen idrettsbygg', 'Sal 1', 30),
    ('Gløshaugen idrettsbygg', 'Idrettshall', 40),
    ('Gløshaugen idrettsbygg', 'Sal 3', 30),
    ('Gløshaugen idrettsbygg', 'Sal 4', 100),

    ('Øya treningssenter', 'Sykkelsal', 38),
    ('Øya treningssenter', 'HIIT-sal', 26),
    ('Øya treningssenter', 'Yogasal', 32),
    ('Øya treningssenter', 'Functional fitness', 16),
    ('Øya treningssenter', 'Gruppesal', 30),

    ('Dragvoll idrettssenter', 'Spinningsal', 20),
    ('Dragvoll idrettssenter', 'Aerobicsal', 25),
    ('Dragvoll idrettssenter', 'Gymsal', 20),
    ('Dragvoll idrettssenter', 'Hall B', 20);


-- Legger til noen sykler
INSERT INTO sykkel (senter_navn, sal_navn, sykkelnr, bodybike_forbindelse)
VALUES
    ('Øya treningssenter', 'Sykkelsal', 1, 1),
    ('Øya treningssenter', 'Sykkelsal', 2, 1),
    ('Øya treningssenter', 'Sykkelsal', 3, 0),
    ('Øya treningssenter', 'Sykkelsal', 4, 1),
    ('Øya treningssenter', 'Sykkelsal', 5, 0),
    ('Øya treningssenter', 'Sykkelsal', 6, 1),

    ('Dragvoll idrettssenter', 'Spinningsal', 1, 1),
    ('Dragvoll idrettssenter', 'Spinningsal', 2, 0),
    ('Dragvoll idrettssenter', 'Spinningsal', 3, 1),
    ('Dragvoll idrettssenter', 'Spinningsal', 4, 0),
    ('Dragvoll idrettssenter', 'Spinningsal', 5, 1),
    ('Dragvoll idrettssenter', 'Spinningsal', 6, 0);


-- Legger til noen tredemøller
INSERT INTO tredemølle (senter_navn, sal_navn, tredemøllenr, produsent, maks_hastighet, maks_stigning)
VALUES
    ('Øya treningssenter', 'HIIT-sal', 1, 'Life-fitness', 25, 15),
    ('Øya treningssenter', 'HIIT-sal', 2, 'Life-fitness', 25, 15),
    ('Øya treningssenter', 'HIIT-sal', 3, 'Life-fitness', 25, 15),
    ('Øya treningssenter', 'HIIT-sal', 4, 'Life-fitness', 25, 15),
    ('Øya treningssenter', 'HIIT-sal', 5, 'Life-fitness', 25, 15);


-- Legger til fasiliteter
INSERT INTO fasilitet (navn)
VALUES
    ('Egentrening'),
    ('Styrke'),
    ('Garderober'),
    ('Utholdenhet'),
    ('Ubemannet treningssenter'),
    ('Spinning'),
    ('Yoga'),
    ('Squash'),
    ('Hall'),
    ('Badstue'),
    ('Dusj'),
    ('Bemannet resepsjon'),
    ('Gruppetrening'),
    ('Klatring');


-- Legger til fasiliteter til sentre
INSERT INTO senter_har_fasilitet (fasilitet, senter_navn)
VALUES
    ('Egentrening', 'DMMH treningsrom'),
    ('Ubemannet treningssenter', 'DMMH treningsrom'),
    ('Styrke', 'DMMH treningsrom'),
    ('Garderober', 'DMMH treningsrom'),
    ('Utholdenhet', 'DMMH treningsrom'),

    ('Egentrening', 'Dragvoll idrettssenter'),
    ('Spinning', 'Dragvoll idrettssenter'),
    ('Yoga', 'Dragvoll idrettssenter'),
    ('Squash', 'Dragvoll idrettssenter'),
    ('Hall', 'Dragvoll idrettssenter'),
    ('Badstue', 'Dragvoll idrettssenter'),
    ('Dusj', 'Dragvoll idrettssenter'),
    ('Garderober', 'Dragvoll idrettssenter'),
    ('Bemannet resepsjon', 'Dragvoll idrettssenter'),

    ('Egentrening', 'Gløshaugen idrettsbygg'),
    ('Gruppetrening', 'Gløshaugen idrettsbygg'),
    ('Styrke', 'Gløshaugen idrettsbygg'),
    ('Hall', 'Gløshaugen idrettsbygg'),
    ('Yoga', 'Gløshaugen idrettsbygg'),
    ('Utholdenhet', 'Gløshaugen idrettsbygg'),
    ('Dusj', 'Gløshaugen idrettsbygg'),
    ('Badstue', 'Gløshaugen idrettsbygg'),
    ('Garderober', 'Gløshaugen idrettsbygg'),
    ('Bemannet resepsjon', 'Gløshaugen idrettsbygg'),

    ('Egentrening', 'Moholt treningssenter'),
    ('Ubemannet treningssenter', 'Moholt treningssenter'),
    ('Styrke', 'Moholt treningssenter'),
    ('Utholdenhet', 'Moholt treningssenter'),

    ('Gruppetrening', 'Øya treningssenter'),
    ('Egentrening', 'Øya treningssenter'),
    ('Utholdenhet', 'Øya treningssenter'),
    ('Styrke', 'Øya treningssenter'),
    ('Yoga', 'Øya treningssenter'),
    ('Klatring', 'Øya treningssenter'),
    ('Spinning', 'Øya treningssenter'),
    ('Hall', 'Øya treningssenter'),
    ('Garderober', 'Øya treningssenter'),
    ('Badstue', 'Øya treningssenter'),
    ('Dusj', 'Øya treningssenter'),
    ('Ubemannet treningssenter', 'Øya treningssenter');    


-- Legger til noen brukere
INSERT INTO bruker (brukerID, epost, fornavn, etternavn, mobil)
VALUES
    (1, 'bruker1@stud.ntnu.no', 'Adam', 'A.', '12345678'),
    (2, 'bruker2@stud.ntnu.no', 'Brage', 'B.', '12345678'),
    (3, 'bruker3@stud.ntnu.no', 'Cassandra', 'C.', '12345678'),
    (4, 'bruker4@stud.ntnu.no', 'Dina', 'D.', '12345678'),
    (5, 'bruker5@stud.ntnu.no', 'Eirin', 'E.', '12345678'),
    (6, 'bruker6@stud.ntnu.no', 'Fredrik', 'F.', '12345678'),
    (7, 'bruker7@stud.ntnu.no', 'Gaute', 'G.', '12345678'),
    (8, 'bruker8@stud.ntnu.no', 'Helene', 'H.', '12345678'),
    (9, 'bruker9@stud.ntnu.no', 'Iben', 'I.', '12345678'),
    (10, 'johnny@stud.ntnu.no', 'Johnny', 'J.', '12345678'),
    (11, 'eirinh@stud.ntnu.no', 'Eirin', 'H.', '12345678'),
    (12, 'siriml@stud.ntnu.no', 'Siri', 'M. L.', '12345678'),
    (13, 'jorunnbb@stud.ntnu.no', 'Jorunn', 'B. B.', '12345678'),
    (14, 'ramonals@stud.ntnu.no', 'Ramona', 'L. S.', '12345678'),
    (15, 'triner@stud.ntnu.no', 'Trine', 'R', '12345678'),
    (16, 'norad@stud.ntnu.no', 'Nora', 'D.', '12345678'),
    (17, 'håkonw@stud.ntnu.no', 'Håkon', 'W.', '12345678'),
    (18, 'hanneh@stud.ntnu.no', 'Hanne', 'H.', '12345678'),
    (19, 'adajr@stud.ntnu.no', 'Ada', 'J. R.', '12345678'),
    (20, 'sindreks@stud.ntnu.no', 'Sindre', 'K. S.', '12345678'),
    (21, 'kajas@stud.ntnu.no', 'Kaja', 'S.', '12345678'),
    (22, 'amaliemh@stud.ntnu.no', 'Amalie', 'M. H.', '12345678');


-- Legger til instruktører
INSERT INTO instruktør (brukerID)
VALUES
    (11),
    (12),
    (13),
    (14),
    (15),
    (16),
    (17),
    (18),
    (19),
    (20),
    (21),
    (22);


-- Legger til aktiviteter
INSERT INTO aktivitet (navn, beskrivelse)
VALUES
    ('Spin 4x4', 'En forutsigbar intervalltime: 4 stående intervaller på 4 minutter hver, med ca 2 minutter aktiv pause mellom hvert drag. God oppvarming og nedsykling inkludert.'),
    ('Spin45', 'En variert spinningtime med 2-3 arbeidsperioder som passer for alle. Perfekt for deg som er ny på spinning! Du styrer intensiteten selv, og vi bruker takta til å tråkke oss gjennom timen.'),
    ('Spin 8x3', 'En forutsigbar intervalltime med 8 intervaller på 3 minutter hver, der du sitter og står annethvert drag. 90-120 sek pause mellom hvert intervall. God oppvarming og nedsykling inkludert.'),
    ('Spin60', 'En variert spinningtime som er noe mer utfordrende enn Spin45 med lengre varighet og tidvis høyere tempo. Du styrer likevel intensiteten selv, og timen passer alle som liker å tråkke i takt! Timen inneholder 2-4 arbeidsperioder med variert løype.');


-- Legger til gruppetimene
INSERT INTO gruppetime (senter_navn, sal_navn, start_tid, slutt_tid, aktivitet_navn, instruktørID)
VALUES
    ('Øya treningssenter', 'Sykkelsal', '2026-03-16 07:00:00', '2026-03-16 07:45:00', 'Spin 4x4', 11),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-03-16 16:30:00', '2026-03-16 17:15:00', 'Spin 4x4', 12),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-16 16:30:00', '2026-03-16 17:15:00', 'Spin45', 13),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-16 17:40:00', '2026-03-16 18:35:00', 'Spin 8x3', 14),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-16 19:00:00', '2026-03-16 20:00:00', 'Spin60', 15),

    ('Øya treningssenter', 'Sykkelsal', '2026-03-17 07:00:00', '2026-03-17 07:55:00', 'Spin 8x3', 16),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-17 18:30:00', '2026-03-17 19:30:00', 'Spin60', 17),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-17 19:45:00', '2026-03-17 20:30:00', 'Spin 4x4', 18),

    ('Øya treningssenter', 'Sykkelsal', '2026-03-18 16:15:00', '2026-03-18 17:15:00', 'Spin60', 16),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-03-18 16:30:00', '2026-03-18 17:15:00', 'Spin45', 19),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-18 17:30:00', '2026-03-18 18:15:00', 'Spin 4x4', 20),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-18 18:30:00', '2026-03-18 19:15:00', 'Spin45', 21),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-18 19:30:00', '2026-03-18 20:25:00', 'Spin 8x3', 22),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-18 20:30:00', '2026-03-18 21:25:00', 'Spin 8x3', 22);


-- Legger til noen idrettslag
INSERT INTO idrettslag (navn)
VALUES
    ('NTNUI Håndball'),
    ('NTNUI Basketball');


INSERT INTO medlem_av_idrettslag (brukerID, idrettslag_navn)
VALUES
    (1, 'NTNUI Håndball'),
    (2, 'NTNUI Håndball'),
    (3, 'NTNUI Håndball'),
    (4, 'NTNUI Basketball'),
    (5, 'NTNUI Basketball');


-- Legger til noen idrettslag-grupper
INSERT INTO idrettslag_gruppe (idrettslag_navn, gruppe_navn)
VALUES
    ('NTNUI Håndball', 'H1 - 2.divisjon'),
    ('NTNUI Håndball', 'D1 - 3.divisjon'),
    ('NTNUI Basketball', 'Basket');


-- Legger til noen lagtreninger
INSERT INTO lagtrening (idrettslag_navn, gruppe_navn, start_tid, slutt_tid, senter_navn, sal_navn)
VALUES
    ('NTNUI Håndball', 'H1 - 2.divisjon', '2026-03-17 18:30:00', '2026-03-17 19:30:00', 'Dragvoll idrettssenter', 'Hall B'),
    ('NTNUI Basketball', 'Basket', '2026-03-17 19:45:00', '2026-03-17 20:45:00', 'Dragvoll idrettssenter', 'Gymsal');


-- Legger til noen gruppetimer og lagtreninger til personlig besøkshistorikk (brukstilfelle 5)
INSERT INTO gruppetime (senter_navn, sal_navn, start_tid, slutt_tid, aktivitet_navn, instruktørID)
VALUES
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-01-10 07:00:00', '2026-01-10 07:45:00', 'Spin 4x4', 11),
    ('Øya treningssenter', 'Sykkelsal', '2026-01-18 10:00:00', '2026-01-18 10:45:00', 'Spin45', 12),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-01-30 18:00:00', '2026-01-30 18:45:00', 'Spin 8x3', 13),
    ('Øya treningssenter', 'Sykkelsal', '2026-02-10 07:00:00', '2026-02-10 07:45:00', 'Spin60', 14),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-02-20 20:00:00', '2026-02-20 20:45:00', 'Spin 4x4', 15),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-10 17:00:00', '2026-03-10 17:45:00', 'Spin45', 16);

INSERT INTO booking (senter_navn, sal_navn, start_tid, brukerID, status)
VALUES
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-01-10 07:00:00', 10, 'Møtt'),
    ('Øya treningssenter', 'Sykkelsal', '2026-01-18 10:00:00', 10, 'Møtt'),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-01-30 18:00:00', 10, 'Møtt'),
    ('Øya treningssenter', 'Sykkelsal', '2026-02-10 07:00:00', 10, 'Møtt'),
    ('Dragvoll idrettssenter', 'Spinningsal', '2026-02-20 20:00:00', 10, 'Møtt'),
    ('Øya treningssenter', 'Sykkelsal', '2026-03-10 17:00:00', 10, 'Møtt');

INSERT INTO medlem_av_idrettslag (brukerID, idrettslag_navn)
VALUES
    (10, 'NTNUI Håndball');

INSERT INTO lagtrening (idrettslag_navn, gruppe_navn, start_tid, slutt_tid, senter_navn, sal_navn)
VALUES
    ('NTNUI Håndball', 'H1 - 2.divisjon', '2026-01-14 18:30:00', '2026-01-14 19:30:00', 'Dragvoll idrettssenter', 'Hall B'),
    ('NTNUI Håndball', 'H1 - 2.divisjon', '2026-02-08 19:45:00', '2026-02-08 20:45:00', 'Dragvoll idrettssenter', 'Gymsal');

INSERT INTO deltar_på_lagtrening (brukerID, idrettslag_navn, gruppe_navn, start_tid)
VALUES
    (10, 'NTNUI Håndball', 'H1 - 2.divisjon', '2026-01-14 18:30:00'),
    (10, 'NTNUI Håndball', 'H1 - 2.divisjon', '2026-02-08 19:45:00');
