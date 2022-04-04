accept opgave number prompt 'Geef aan voor welke opgave van hoofdstuk 2 u het antwoord wilt zien (1-9): ';
declare
    opg pls_integer := &opgave;
begin
    case opg
-- opgave 1
        when 1 then
            declare 
                gebruikersnaam varchar2(100) := 'testing';
                datum date := sysdate;
            begin
                dbms_output.put_line(gebruikersnaam);
                dbms_output.put_line(datum);
            end;
-- opgave 2
        when 2 then 
            declare
                v_naam varchar2(50) := 'jordi';
                v_dagen number;
                v_maanden number;
                v_jaren number;
                v_vandaag date default sysdate;
                v_gebdatum date := to_date('14-03-1998', 'dd-mm-yyyy');
            begin
                v_dagen:=trunc(v_vandaag-v_gebdatum, 0);
                v_maanden:=trunc(months_between(v_vandaag, v_gebdatum), 0);
                v_jaren:=trunc((v_vandaag-v_gebdatum)/365, 0);
                dbms_output.put_line('naam: ' || v_naam || ', vandaag: ' || v_vandaag || ', geboren: ' || v_gebdatum);
                dbms_output.put_line('leeftijd in dagen: ' || v_dagen || ', in maanden: ' || v_maanden || ', in jaren: ' || v_jaren);
            end;
-- opgave 3
        when 3 then
            declare
                i pls_integer;
            begin
                dbms_output.put_line('basic loop:');
                i:=1;
                loop
                    dbms_output.put(i || '*6=' || i*6 || ' ');
                    i:=i+1;
                    exit when i>10;
                end loop;
                dbms_output.new_line;
                dbms_output.put_line('while loop:');
                i:=1;
                while i<11 loop 
                    dbms_output.put(i || '*6=' || i*6 || ' ');
                    i:=i+1;
                end loop;
                dbms_output.new_line;
                dbms_output.put_line('for loop:');
                for i in 1..10 loop 
                    dbms_output.put(i || '*6=' || i*6 || ' ');
                end loop;
                dbms_output.new_line;
            end;
-- opgave 4
        when 4 then 
            declare
                v_username varchar2(50) := 'Jordi';
                v_gebdatum date default to_date('14-03-1998', 'dd-mm-yyyy');
                v_gbd_weekend pls_integer := 0;
                v_jaardag date;
                type birthdays_aa is table of date index by pls_integer;
                jarig_weekend birthdays_aa;
            begin
                for i in to_number(to_char(v_gebdatum, 'yyyy')) .. to_number(to_char(sysdate, 'yyyy')) loop 
                    v_jaardag := to_date(to_char(v_gebdatum, 'dd-mm"-"')||i, 'dd-mm-yyyy');
                    exit when v_jaardag > sysdate;
                    if to_char(v_jaardag, 'dy') in ('sun', 'sat') then 
                        v_gbd_weekend:=v_gbd_weekend+1;
                        jarig_weekend(v_gbd_weekend):=v_jaardag;
                    end if;
                end loop;
                dbms_output.put_line('Aantal keren dat ' ||v_username|| ' tot nu toe in het weekend jarig was: ' || v_gbd_weekend);
                dbms_output.put_line('deze waren op: ' || to_char(v_gebdatum, 'dd Month'));
                for i in 1 .. v_gbd_weekend loop 
                    dbms_output.put_line(i || '> ' || to_char(jarig_weekend(i), 'yyyy", dat was op" Dy'));
                end loop;
            end;
-- opgave 5 incomplete, not very discriptive
        when 5 then 
            declare
                co_ouders constant pls_integer := 2;
                co_kinderen constant pls_integer := 1;
                co_poliskost constant pls_integer := 8;
                co_vakantiedagen constant pls_integer := 7;
                totaal pls_integer;
            begin
                dbms_output.put_line('tijdelijke verzekering, gezin: 1 kind, 2 volwassen, 7 dagen vakantie: ');
                totaal:=co_poliskost+((co_ouders*1.25)+(co_kinderen*0.75))*co_vakantiedagen;
                dbms_output.put_line(totaal);

                dbms_output.put_line('doorlopend verzekering, gezin: 1 kind, 2 volwassen, 7 dagen vakantie: ');
                totaal:=co_poliskost+((co_ouders*50)+(co_kinderen*20));
                dbms_output.put_line(totaal);
            end;
-- opgave 6 exec in boek schema
        when 6 then 
            declare
                v_aantal_medewerkers pls_integer;
                co_bedrag constant pls_integer := 8000;
            begin
                select count(mnr) into v_aantal_medewerkers from medewerkers;
                dbms_output.put_line(co_bedrag||' euro gedeeld door '||v_aantal_medewerkers||
                    ' medewerkers is '|| trunc(co_bedrag/v_aantal_medewerkers, 2));
            end;
-- opgave 7 warning uncommitted dml, rollback immediately after
        when 7 then 
            declare
                co_max_maandsal constant pls_integer := 55000;
                v_som_maandsal pls_integer;
                i pls_integer:=0;
            begin
                loop 
                    savepoint A;
                    update medewerkers
                    set maandsal = maandsal*1.1;

                    select sum(maandsal) 
                    into v_som_maandsal
                    from medewerkers;
                    if v_som_maandsal > co_max_maandsal then 
                        rollback to savepoint A;
                        exit;
                    end if;
                    i:=i+1;
                end loop;
                select sum(maandsal) 
                into v_som_maandsal
                from medewerkers;
                dbms_output.put_line('Er is ' || i || ' keer met 10% verhoogd, som van salarissen: ' || v_som_maandsal);
                dbms_output.put_line('rollback a.u.b.');
                --rollback;
            end;
-- opgave 8 warning uncommitted dml, should rollback unless you want to do opgave 9
        when 8 then 
            declare
                v_som_percent pls_integer;
                v_som_vast pls_integer;
                v_aantal_medewerkers pls_integer;
                co_vast_verh_bedrag constant pls_integer := 80;
            begin
                select sum(sal) into v_som_percent
                from (select maandsal*0.1 as sal from medewerkers);
                select count(mnr) into v_aantal_medewerkers 
                from medewerkers;
                v_som_vast := v_aantal_medewerkers*co_vast_verh_bedrag;
                dbms_output.put_line('totaal percent verhoging: ' || v_som_percent || ', totaal vast bedrag verhoging: ' || v_som_vast);
                if v_som_vast <= v_som_percent then 
                    dbms_output.put_line('Iedereen 80 euro verhoging is voordeliger voor werkgever, dit wordt doorgevoerd.');
                    update medewerkers
                    set maandsal = maandsal + co_vast_verh_bedrag;
                else
                    dbms_output.put_line('Iedereen 10% salaris verhoging is voordeliger voor werkgever, dit wordt doorgevoerd.');
                    update medewerkers
                    set maandsal = maandsal*1.1;
                end if;
            end;
-- opgave 9, voer 8 eerst uit hiervoor, warning implicit dml commit, volg de instructies
        when 9 then 
            declare
                v_sqlcre_log_tabel varchar2(1000);
                v_sqlupd_log_tabel varchar2(1000);
                v_sqldrop_log_tabel varchar2(1000);
                v_sqlins_log_tabel varchar2(1000);
                v_som_maandsal pls_integer;
                v_tabel_bestaat pls_integer;
            begin
                v_sqlcre_log_tabel := 
                    'create table log_tabel(
                        getal number,
                        tekst varchar2(200),
                        datum date
                    )';
                v_sqlins_log_tabel := 
                    'insert into log_tabel(getal, tekst, datum)
                    values (:a, :b, :c)';
                select count(*) into v_tabel_bestaat 
                from user_tables where table_name = 'LOG_TABEL';
                
                if v_tabel_bestaat <= 0 then 
                execute immediate v_sqlcre_log_tabel;
                end if;
                
                select sum(maandsal) into v_som_maandsal
                from medewerkers;
                select count(*) into v_tabel_bestaat 
                from user_tables where table_name = 'LOG_TABEL';
                if v_tabel_bestaat > 0 then 
                    execute immediate v_sqlins_log_tabel using v_som_maandsal, 'gelukt', sysdate;
                    dbms_output.put_line('Tabel LOG_TABEL bestaat of created en waarden ingevoerd, '||
                    'DROP deze tabel aan het einde a.u.b. en update de medewerkers tabel naar zijn originele staat. '||
                    'Simpelweg run deze opgave opnieuw zonder comments bij de laatste if block '||
                    'execute immediate "v_sqlupd_log_tabel" en "v_sqldrop_log_tabel"');
                end if;
                v_sqlupd_log_tabel:=
                'update medewerkers set maandsal = maandsal-80'; 
                v_sqldrop_log_tabel:=
                'drop table log_tabel purge';

                -- if v_tabel_bestaat > 0 and v_som_maandsal=29995 then 
                -- execute immediate v_sqlupd_log_tabel;
                -- execute immediate v_sqldrop_log_tabel;
                -- dbms_output.put_line('Tabel MEDEWERKERS geupdate naar originele waarden en tabel LOG_TABEL gedropped');
                -- elsif v_tabel_bestaat > 0 and v_som_maandsal!=29995 then
                -- execute immediate v_sqldrop_log_tabel;
                -- dbms_output.put_line('Tabel LOG_TABEL gedropped.');
                -- end if;
            end;
--
        else
            dbms_output.put_line('Invalide input voor opgave van hoofdstuk 2: kies tussen 1 en 9');
    end case;
end;
/
