-- Trigger for å sette kø_posisjon basert på antall påmeldinger og salens kapasitet
CREATE TRIGGER sett_kø_posisjon
AFTER INSERT ON booking
FOR EACH ROW
BEGIN
    UPDATE booking
    SET kø_posisjon = (
        SELECT CASE 
            WHEN antall_paameldinger > sal_kapasitet 
            THEN antall_paameldinger - sal_kapasitet
            ELSE 0
        END
        FROM (
            SELECT 
                (SELECT COUNT(*) FROM booking 
                WHERE senter_navn = NEW.senter_navn 
                   AND sal_navn = NEW.sal_navn 
                   AND start_tid = NEW.start_tid) AS antall_paameldinger,
                (SELECT kapasitet FROM sal 
                WHERE senter_navn = NEW.senter_navn 
                    AND navn = NEW.sal_navn) AS sal_kapasitet
        )
    )
    WHERE senter_navn = NEW.senter_navn 
        AND sal_navn = NEW.sal_navn 
        AND start_tid = NEW.start_tid 
        AND brukerID = NEW.brukerID;
END;



-- Trigger for å oppdatere kø_posisjon for alle påmeldte når noen melder seg av en gruppetime
CREATE TRIGGER oppdater_kø_posisjon_ved_avmelding
AFTER UPDATE OF status ON booking
FOR EACH ROW
WHEN NEW.status = 'Avmeldt' AND OLD.status != 'Avmeldt'
BEGIN
    UPDATE booking
    SET kø_posisjon = kø_posisjon - 1
    WHERE senter_navn = OLD.senter_navn 
        AND sal_navn = OLD.sal_navn 
        AND start_tid = OLD.start_tid
        AND kø_posisjon > OLD.kø_posisjon;
    UPDATE booking
    SET status = 'Booket'
    WHERE senter_navn = OLD.senter_navn 
        AND sal_navn = OLD.sal_navn 
        AND start_tid = OLD.start_tid
        AND kø_posisjon = 0
        AND status = 'Venteliste';
END;



-- Trigger for å sjekke svartelisting før booking
CREATE TRIGGER sjekk_svartelisting
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(*)
            FROM prikk
            WHERE brukerID = NEW.brukerID
                AND dato_og_tid >= datetime('now', '-30 days')
        ) >= 3
        THEN RAISE(ABORT, 'Brukeren er svartelistet på grunn av 3 eller flere prikker de siste 30 dagene.')
    END;
END;



-- Trigger for å opprette prikk ved status 'Ikke møtt'
CREATE TRIGGER opprett_prikk_ikke_møtt
AFTER UPDATE OF status ON booking
FOR EACH ROW
WHEN NEW.status = 'Ikke møtt'
BEGIN
    INSERT INTO prikk (brukerID, dato_og_tid)
    VALUES (NEW.brukerID, NEW.start_tid);
END;



-- Triggere som hindrer at en bruker kan være registrert to steder samtidig
----------------------------------------------------------------------------
-- Trigger for å sikre at en bruker ikke kan booke overlappende gruppetimer
CREATE TRIGGER sjekk_overlapp_ved_booking
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM booking b
            JOIN gruppetime g_eksisterende 
                ON b.senter_navn = g_eksisterende.senter_navn 
                AND b.sal_navn = g_eksisterende.sal_navn 
                AND b.start_tid = g_eksisterende.start_tid
            JOIN gruppetime g_ny 
                ON g_ny.senter_navn = NEW.senter_navn 
                AND g_ny.sal_navn = NEW.sal_navn 
                AND g_ny.start_tid = NEW.start_tid
            WHERE b.brukerID = NEW.brukerID
                AND b.status NOT IN ('Avmeldt')
                AND g_ny.start_tid < g_eksisterende.slutt_tid
                AND g_eksisterende.start_tid < g_ny.slutt_tid
        )
        THEN RAISE(ABORT, 'Brukeren er allerede påmeldt denne eller en annen gruppetime i dette tidsrommet.')
    END;
END;

-- Trigger som sjekker overlapp fra booking mot lagtrening
CREATE TRIGGER sjekk_booking_mot_lagtrening
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 
            FROM deltar_på_lagtrening d
            JOIN lagtrening l ON d.idrettslag_navn = l.idrettslag_navn 
                AND d.gruppe_navn = l.gruppe_navn 
                AND d.start_tid = l.start_tid
            JOIN gruppetime g_ny ON g_ny.senter_navn = NEW.senter_navn 
                AND g_ny.sal_navn = NEW.sal_navn 
                AND g_ny.start_tid = NEW.start_tid
            WHERE d.brukerID = NEW.brukerID
                AND g_ny.start_tid < l.slutt_tid
                AND l.start_tid < g_ny.slutt_tid
        )
        THEN RAISE(ABORT, 'Du er allerede registrert på en lagtrening i dette tidsrommet.')
    END;
END;

-- Trigger som sjekker overlapp for lagtrening mot booking
CREATE TRIGGER sjekk_lagtrening_mot_booking
BEFORE INSERT ON deltar_på_lagtrening
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 
            FROM booking b
            JOIN gruppetime g ON b.senter_navn = g.senter_navn 
                AND b.sal_navn = g.sal_navn 
                AND b.start_tid = g.start_tid
            JOIN lagtrening l_ny ON l_ny.idrettslag_navn = NEW.idrettslag_navn 
                AND l_ny.gruppe_navn = NEW.gruppe_navn 
                AND l_ny.start_tid = NEW.start_tid
            WHERE b.brukerID = NEW.brukerID
              AND b.status IN ('Booket', 'Møtt')
              AND l_ny.start_tid < g.slutt_tid
              AND g.start_tid < l_ny.slutt_tid
        )
        THEN RAISE(ABORT, 'Brukeren har en aktiv booking på en gruppetime i dette tidsrommet.')
    END;
END;



-- Triggere for å sikre at en instruktør ikke kan finnes flere steder på en gang:
---------------------------------------------------------------------------------
-- Trigger for å hindre instruktør fra å booke en gruppetime når hen er
-- oppsatt som instruktør i samme tidsrom
CREATE TRIGGER hindre_instruktør_booking_overlapp
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM gruppetime g_leder
            JOIN gruppetime g_ny_deltakelse 
                ON g_ny_deltakelse.senter_navn = NEW.senter_navn 
                AND g_ny_deltakelse.sal_navn = NEW.sal_navn 
                AND g_ny_deltakelse.start_tid = NEW.start_tid
            WHERE g_leder.instruktørID = NEW.brukerID
                AND g_ny_deltakelse.start_tid < g_leder.slutt_tid
                AND g_leder.start_tid < g_ny_deltakelse.slutt_tid
        )
        THEN RAISE(ABORT, 'Brukeren er satt opp som instruktør i dette tidsrommet og kan ikke booke timen.')
    END;
END;

-- Trigger for å hindre instruktør fra å delta på en lagtrening når hen er
-- oppsatt som instruktør i samme tidsrom
--
-- Siden instruktør-rollen trumfer vanlig brukerfunksjonalitet, sørger vi for at en
-- instruktør ikke kan delta på lagtrening når hen er oppsatt til å lede en gruppetime
-- Dette er spesielt for instruktører da de er nødt til å møte opp til gruppetimen de skal
-- lede, og ikke har samme mulighet som en bruker å bare droppe en gruppetime for å delta
-- på lagtrening isteden.
CREATE TRIGGER hindre_instruktør_lagtrening_overlapp
BEFORE INSERT ON deltar_på_lagtrening
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1
            FROM gruppetime g_leder
            JOIN lagtrening l_ny 
                ON l_ny.idrettslag_navn = NEW.idrettslag_navn 
                AND l_ny.gruppe_navn = NEW.gruppe_navn 
                AND l_ny.start_tid = NEW.start_tid
            WHERE g_leder.instruktørID = NEW.brukerID
                AND l_ny.start_tid < g_leder.slutt_tid
                AND g_leder.start_tid < l_ny.slutt_tid
        )
        THEN RAISE(ABORT, 'Brukeren er opptatt som instruktør og kan ikke delta på lagtrening samtidig.')
    END;
END;

-- Trigger som sørger for at en instruktør ikke dobbeltbookes
CREATE TRIGGER hindre_instruktør_dobbeltbooking
BEFORE INSERT ON gruppetime
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM gruppetime
            WHERE instruktørID = NEW.instruktørID
                AND NEW.start_tid < slutt_tid 
                AND start_tid < NEW.slutt_tid
        )
        THEN RAISE(ABORT, 'Instruktøren er allerede satt opp på en annen gruppetime i dette tidsrommet.')
    END;
END;



-- Trigger for å sørge for at en bruker ikke kan booke en gruppetime dersom brukeren
-- allerede har booket en gruppetime med overlappende tilspunkt
CREATE TRIGGER sjekk_bruker_overlapp_gruppetimer
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM booking b
            JOIN gruppetime g_eksisterende 
                ON b.senter_navn = g_eksisterende.senter_navn 
                AND b.sal_navn = g_eksisterende.sal_navn 
                AND b.start_tid = g_eksisterende.start_tid
            JOIN gruppetime g_ny 
                ON g_ny.senter_navn = NEW.senter_navn 
                AND g_ny.sal_navn = NEW.sal_navn 
                AND g_ny.start_tid = NEW.start_tid
            WHERE b.brukerID = NEW.brukerID
                AND b.status != 'Avmeldt'
                AND g_ny.start_tid < g_eksisterende.slutt_tid
                AND g_eksisterende.start_tid < g_ny.slutt_tid
        )
        THEN RAISE(ABORT, 'Brukeren har allerede booket denne eller en annen gruppetime i dette tidsrommet.')
    END;
END;



-- Trigger som sørger for at man ikke kan booke en gruppetime tidligere enn 48 timer før den starter
CREATE TRIGGER sjekk_booking_48_timer
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        -- Den kommenterte linjen er den riktige løsningen for triggeren, men vi har valgt å endre
        -- sjekken av tid til en simulert tid for å sikre at programmet er etterprøvbart
        -- for de gitte brukstilfellene og kravene til treningsøkter mellom 16. og 18. mars
        -- WHEN datetime('now') < datetime(NEW.start_tid, '-48 hours')
        WHEN (SELECT simulert_nåtid FROM system_tid) < datetime(NEW.start_tid, '-48 hours')
        THEN RAISE(ABORT, 'Det er ikke mulig å booke denne timen ennå. Booking åpner 48 timer før start.')
    END;
END;



-- Trigger som hindrer booking av en gruppetime etter at oppmøte-fristen har gått ut
CREATE TRIGGER sjekk_booking_tidsfrist
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NEW.status = 'Booket'
            -- Den kommenterte linjen under er den riktige løsningen, men vi velger å bruke
            -- systemtid i prosjektet for å sikre etterprøvbarhet
            -- AND datetime('now', 'localtime') > datetime(NEW.start_tid, '-5 minutes')
            AND (SELECT simulert_nåtid FROM system_tid) > datetime(NEW.start_tid, '-5 minutes')
        THEN RAISE(ABORT, 'Det er for sent å melde seg på denne timen.')
    END;
END;



-- Triggere som sørger for at en sal ikke dobbeltbookes:
--------------------------------------------------------
-- Trigger som sjekker om en ny gruppetime overlapper eksisterende aktiviteter i en sal
CREATE TRIGGER sjekk_sal_overlapp_gruppetime
BEFORE INSERT ON gruppetime
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM gruppetime
            WHERE senter_navn = NEW.senter_navn 
                AND sal_navn = NEW.sal_navn
                AND NEW.start_tid < slutt_tid 
                AND start_tid < NEW.slutt_tid
            
            UNION ALL
            
            SELECT 1 FROM lagtrening
            WHERE senter_navn = NEW.senter_navn 
                AND sal_navn = NEW.sal_navn
                AND NEW.start_tid < slutt_tid 
                AND start_tid < NEW.slutt_tid
        )
        THEN RAISE(ABORT, 'Salen er opptatt i dette tidsrommet.')
    END;
END;

-- Trigger som sjekker om en ny lagtrening overlapper eksisterende aktiviteter i en sal
CREATE TRIGGER sjekk_sal_overlapp_lagtrening
BEFORE INSERT ON lagtrening
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM gruppetime
            WHERE senter_navn = NEW.senter_navn 
              AND sal_navn = NEW.sal_navn
              AND NEW.start_tid < slutt_tid 
              AND start_tid < NEW.slutt_tid
            
            UNION ALL
            
            SELECT 1 FROM lagtrening
            WHERE senter_navn = NEW.senter_navn 
              AND sal_navn = NEW.sal_navn
              AND NEW.start_tid < slutt_tid 
              AND start_tid < NEW.slutt_tid
        )
        THEN RAISE(ABORT, 'Salen er opptatt i dette tidsrommet.')
    END;
END;



-- Trigger som sørger for at en bruker er medlem av laget til gruppen som holder en lagtrening
CREATE TRIGGER sjekk_medlemskap_idrettslag
BEFORE INSERT ON deltar_på_lagtrening
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 
            FROM medlem_av_idrettslag
            WHERE brukerID = NEW.brukerID 
              AND idrettslag_navn = NEW.idrettslag_navn
        )
        THEN RAISE(ABORT, 'Du må være medlem av idrettslaget for å kunne delta på denne lagtreningen.')
    END;
END;



-- Trigger som endrer status på en booking til 'Ikke møtt' ved for sen avmelding
CREATE TRIGGER sjekk_sen_avmelding
AFTER UPDATE OF status ON booking
FOR EACH ROW
WHEN NEW.status = 'Avmeldt'
AND datetime('now') > datetime(OLD.start_tid, '-1 hour')
BEGIN
    UPDATE booking 
    SET status = 'Ikke møtt'
    WHERE brukerID = NEW.brukerID 
        AND start_tid = NEW.start_tid
        AND senter_navn = NEW.senter_navn
        AND sal_navn = NEW.sal_navn;
END;



-- Trigger som hindrer flere brukere enn salen har kapasitet til i å delta på en lagtrening
CREATE TRIGGER sjekk_kapasitet_lagtrening
BEFORE INSERT ON deltar_på_lagtrening
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (
            SELECT COUNT(*) 
            FROM deltar_på_lagtrening 
            WHERE idrettslag_navn = NEW.idrettslag_navn 
                AND gruppe_navn = NEW.gruppe_navn 
                AND start_tid = NEW.start_tid
        ) >= (
            SELECT s.kapasitet 
            FROM sal s
            JOIN lagtrening l ON s.senter_navn = l.senter_navn AND s.navn = l.sal_navn
            WHERE l.idrettslag_navn = NEW.idrettslag_navn 
                AND l.gruppe_navn = NEW.gruppe_navn 
                AND l.start_tid = NEW.start_tid
        )
        THEN RAISE(ABORT, 'Lagtreningen er fullbooket (salens kapasitet er nådd).')
    END;
END;


-- Trigger som hindrer registrering av en gruppetime for tidlig
CREATE TRIGGER sjekk_tidlig_oppmøte
BEFORE UPDATE OF status ON booking
FOR EACH ROW
WHEN NEW.status = 'Møtt' AND OLD.status = 'Booket'
BEGIN
    SELECT CASE
        -- Den kommenterte linjen er den riktige løsningen for triggeren, men vi har valgt å endre
        -- sjekken av tid til en simulert tid for å sikre at programmet er etterprøvbart
        -- for de gitte brukstilfellene og kravene til treningsøkter mellom 16. og 18. mars
        -- WHEN datetime('now') < datetime(NEW.start_tid, '-90 minutes')
        WHEN (SELECT simulert_nåtid FROM system_tid) < datetime(NEW.start_tid, '-90 minutes')
        THEN RAISE(ABORT, 'Det er for tidlig å registrere oppmøte. Registrering kan skje tidligst 90 minutter før start.')
    END;
END;