-- opgave 1
    alter session set plsql_warnings='ENABLE:ALL';
    -- example usage
    create or replace procedure test_warning_proc(val in number) is
    begin
        delete proc_warning_test where id = 123;
    end;
    /
    drop procedure test_warning_proc;
    
-- opgave 2
    create or replace procedure print(p_printvalue in varchar2) is
    begin
        dbms_output.put_line(p_printvalue);
    end;
    /
    create or replace procedure ontsla_med(p_mnr in number) is
        v_is_chef pls_integer;
        v_is_afdhoofd pls_integer;
        v_bestaat_mnr pls_integer;
        v_bestaat_mnr_uitv pls_integer;
        v_bestaat_mnr_inschr pls_integer;
    begin
        select count(distinct mnr), count(distinct uitvoeringen.begindatum), count(distinct inschrijvingen.begindatum) 
        into v_bestaat_mnr, v_bestaat_mnr_uitv, v_bestaat_mnr_inschr
        from medewerkers 
            left join uitvoeringen on mnr=docent
            left join inschrijvingen on mnr=cursist
        where mnr = p_mnr;

        select count(chef), count(hoofd)
        into v_is_chef, v_is_afdhoofd
        from medewerkers left join afdelingen on chef=hoofd 
        where chef = p_mnr;

        if v_bestaat_mnr = 0 then 
            raise_application_error(-20000, 'Medewerker bestaat niet');
        else
            if v_is_afdhoofd > 0 then 
                raise_application_error(-20001, 'Medewerker is afdelingshoofd, wordt niet verwijderd');
            elsif v_is_chef > 0 then
                raise_application_error(-20002, 'Medewerker is chef van andere medewerker(s), wordt niet verwijderd');
            else
                if v_bestaat_mnr_uitv > 0 then
                    update uitvoeringen
                    set docent = null
                    where docent = p_mnr;
                end if;
                
                if v_bestaat_mnr_inschr > 0 then 
                    delete inschrijvingen
                    where cursist = p_mnr;
                end if;

                delete medewerkers
                where mnr = p_mnr;
            end if;
        end if;
    end ontsla_med;
    /
    create or replace function afdeling_van(p_mnr in pls_integer) return pls_integer is
        cursor c_med_afd is select afd from medewerkers where mnr = p_mnr;
        v_medewerker_afd medewerkers.afd%type;
    begin
        open c_med_afd;
        fetch c_med_afd into v_medewerker_afd;
        close c_med_afd;
        return v_medewerker_afd;
    end afdeling_van;
    /
-- opgave 3
    create or replace function years_between(p_later_date varchar2, p_earlier_date varchar2) return number is
    begin
        return extract(year from to_date(p_later_date, 'dd-mm-rrrr')) - extract(year from to_date(p_earlier_date, 'dd-mm-rrrr'));
    end;
    /
    select gbdatum, years_between(sysdate, gbdatum) from medewerkers;
-- opgave 4
    drop table log_tabel purge;
    create table log_tabel(getal number, tekst varchar2(200), datum date);
    create or replace procedure log_melding(p_tekst varchar2, p_getal number default null) is
        pragma autonomous_transaction;
    begin
        insert into log_tabel values (p_getal, p_tekst, sysdate);
        commit;
    end;
    /
    declare 
        v_tekst varchar2(50);
    begin
        delete from inschrijvingen
        where cursist = 7499 and cursus = 'PLS'
        returning cursus||cursist||'_'||begindatum into v_tekst;
        log_melding(v_tekst);
        rollback;
    end;
    /
    select * from log_tabel;
-- opgave 5
    create or replace procedure show_source(p_unit_name varchar2) is
        cursor c_source is
            select line, text
            from all_source
            where name = upper(p_unit_name);
        v_sourcecode varchar2(32000);
    begin
        dbms_output.put_line('Source code for unit: ' || upper(p_unit_name));
        for r_source in c_source loop 
            v_sourcecode := v_sourcecode||r_source.line||' '||r_source.text||chr(13);
        end loop;
        dbms_output.put_line(v_sourcecode);
    end;
    /
    begin
        show_source('show_source');
    end;
    /
-- opgave 6
    declare
        cursor c_independent_tables is
            select table_name
            from user_tables
            where table_name not in (
                select referenced_name from user_dependencies
            );
    begin
        for r_indep_tables in c_independent_tables loop 
            dbms_output.put_line(r_indep_tables.table_name);
        end loop;
    end;
    /
-- opgave 7
    -- run utldtree.sql located in %ORACLE_HOME%/rdbms/admin
    -- do execute deptree_fill(type, schema, object_name);
    -- select * from deptree;

drop procedure print;
drop procedure ontsla_med;
drop function afdeling_van;
drop function years_between;
drop table log_tabel purge;
drop procedure show_source;