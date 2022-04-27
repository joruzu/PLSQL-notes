accept opgave number prompt 'Geef aan voor welke opgave van hoofdstuk 3 u het antwoord wilt zien (1-4): ';
declare
    opg pls_integer := &opgave;
begin
    case opg
-- opgave 1    
        when 1 then
            begin
                dbms_output.put_line('For this opgave execute h3-1.sql, you can uncomment it below');                
            end;
-- opgave 2            
        when 2 then 
            declare
                unique_cons_violated exception;
                no_parent_key exception;
                pragma exception_init(unique_cons_violated, -1);
                pragma exception_init(no_parent_key, -2291);
            begin
                update afdelingen
                set naam = 'VERKOOP'
                where naam = 'PERSONEELSZAKEN';        

                update medewerkers 
                set afd = 50
                where naam = 'DE KONING';
            exception 
                when unique_cons_violated then 
                    raise_application_error(-20001, 'Afdelingsnaam komt al voor');
                when no_parent_key then 
                    raise_application_error(-20002, 'Afdelingsnummer bestaat niet');
            end;
-- opgave 3            
        when 3 then
            declare
                v_mnr number := 7876; 
                v_bestaat_mnr number;
                v_bestaat_mnr_uitv number;
                v_bestaat_mnr_inschr number;
                v_is_chef number;
                v_is_afdhoofd number;
            begin
                select count(distinct mnr), count(distinct uitvoeringen.begindatum), count(distinct inschrijvingen.begindatum) 
                into v_bestaat_mnr, v_bestaat_mnr_uitv, v_bestaat_mnr_inschr
                from medewerkers 
                    left join uitvoeringen on mnr=docent
                    left join inschrijvingen on mnr=cursist
                where mnr = v_mnr;

                select count(chef), count(hoofd)
                into v_is_chef, v_is_afdhoofd
                from medewerkers left join afdelingen on chef=hoofd 
                where chef = v_mnr;

                if v_bestaat_mnr = 0 then 
                    raise_application_error(-20000, 'Medewerkernummer bestaat niet');
                elsif v_bestaat_mnr = 1 then
                    if v_bestaat_mnr_uitv>0 then
                        update uitvoeringen set docent = null where docent = v_mnr;
                        dbms_output.put_line('Docent '||v_mnr||' verwijderd van '||v_bestaat_mnr_uitv||' uitvoeringen, deze hebben momenteel geen docent');                      
                    end if;
                    if v_bestaat_mnr_inschr>0 then 
                        delete inschrijvingen where cursist = v_mnr;
                        dbms_output.put_line('Alle '||v_bestaat_mnr_inschr||' inschrijvingen van cursist '||v_mnr||' verwijderd');
                    end if;
                    if  v_is_afdhoofd > 0 then
                        raise_application_error(-20002, 'Medewerker is hoofd van een afdeling. Zal niet worden verwijderd');                        
                    elsif v_is_chef > 0 then 
                        raise_application_error(-20001, 'Medewerker is chef van andere medewerker(s). Zal niet worden verwijderd');
                    end if;

                    delete medewerkers where mnr = v_mnr;
                    dbms_output.put_line('Medewerker '||v_mnr||' verwijderd uit tabel medewerkers');
                end if;                
            end;
-- opgave 4            
        when 4 then
            declare
                r_cursussen cursussen%ROWTYPE;
                unique_cons_violated exception;
                pragma exception_init(unique_cons_violated, -1);
            begin
                r_cursussen.code := 'S02';
                r_cursussen.omschrijving := 'Dit is een omschrijving';
                r_cursussen.type := 'BLD';
                r_cursussen.lengte := 1;

                insert into cursussen values r_cursussen;
            exception 
                when unique_cons_violated then 
                    update cursussen 
                    set omschrijving = r_cursussen.omschrijving,
                        type = r_cursussen.type,
                        lengte = r_cursussen.lengte
                    where code = r_cursussen.code;
            end;
        else
            dbms_output.put_line('Invalide input voor opgave van hoofdstuk 3: kies tussen 1 en 4');
    end case;
end;
/
