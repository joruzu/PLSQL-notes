-- opgave 1
    declare
        v_aantal_medewerkers pls_integer;
        co_bedrag constant pls_integer := 8000;
        cursor c_aantal_mnr is select count(mnr) from medewerkers;
    begin
        open c_aantal_mnr;
        fetch c_aantal_mnr into v_aantal_medewerkers;
        dbms_output.put_line(co_bedrag||' euro gedeeld door '||v_aantal_medewerkers||
            ' medewerkers is '|| trunc(co_bedrag/v_aantal_medewerkers, 2));
        close c_aantal_mnr;
    end;
    /
-- opgave 2
    declare
        cursor c_mwr_gegevens is
            select naam, gbdatum
            from medewerkers
            order by gbdatum
            fetch first 4 rows only;
        type t_mwr_gegevens_type is table of c_mwr_gegevens%rowtype;
        t_oudste_mwrs t_mwr_gegevens_type;
        
        i number;
    begin
        open c_mwr_gegevens;
        fetch c_mwr_gegevens bulk collect into t_oudste_mwrs;
        dbms_output.put_line('Hieronder de gegevens van de 4 oudste medewerkers:');
        dbms_output.put_line('NAAM          GBDATUM     ');
        dbms_output.put_line('------------  ------------');
        i := t_oudste_mwrs.first;
        loop
            dbms_output.put_line(rpad(t_oudste_mwrs(i).naam, 12, ' ')||'  '||rpad(t_oudste_mwrs(i).gbdatum, 12, ' '));

            exit when not t_oudste_mwrs.exists(t_oudste_mwrs.next(i));
            i := t_oudste_mwrs.next(i);
        end loop;
        close c_mwr_gegevens;
    end;
    /
-- opgave 3
    declare
        cursor c_mwr_gegevens is
            select naam, gbdatum
            from medewerkers
            order by gbdatum
            fetch first 4 rows only;
    begin
        dbms_output.put_line('Hieronder de gegevens van de 4 oudste medewerkers:');
        dbms_output.put_line('NAAM          GBDATUM     ');
        dbms_output.put_line('------------  ------------');

        for r_mwr_gegevens in c_mwr_gegevens
        loop
            dbms_output.put_line(rpad(r_mwr_gegevens.naam, 12, ' ')||'  '||rpad(r_mwr_gegevens.gbdatum, 12, ' '));
        end loop;
    end;
    /
-- opgave 4
    declare
        l_totaal_budget number := 1500;
        l_verhoging_pct number := 0.1;
        l_verhoging_waarde number;
        cursor c_mwr_verhogingen is
            select mnr, maandsal
            from medewerkers 
            order by maandsal
            for update of maandsal;
    begin
        dbms_output.put_line('Salaris verhoogd voor de volgende medewerkers:');
        
        for r_mwr_verhogingen in c_mwr_verhogingen
        loop 
            l_verhoging_waarde := r_mwr_verhogingen.maandsal * l_verhoging_pct;
            l_totaal_budget := l_totaal_budget - l_verhoging_waarde;

            if l_totaal_budget < 0 then
                l_totaal_budget := l_totaal_budget + l_verhoging_waarde;
                exit;
            end if;
            
            update medewerkers
            set maandsal = maandsal + l_verhoging_waarde
            where current of c_mwr_verhogingen;
            dbms_output.put_line(r_mwr_verhogingen.mnr||' '||'verhoging: '||l_verhoging_waarde);
        end loop;

        dbms_output.put_line('Resterend budget: ' || l_totaal_budget);
    end;
    /
    select * from medewerkers order by maandsal;
    rollback;
