-- opgave 1
    drop table uit_audit purge;
    create table uit_audit(
        wie varchar2(50),
        wat varchar2(50),
        wanneer date
    );
    create or replace trigger uit_audit_trg
        after
            insert or
            update or
            delete 
        on uitvoeringen
    begin
        case
            when inserting then
                insert into uit_audit values(user, 'INSERT', sysdate);
            when updating then
                insert into uit_audit values(user, 'UPDATE', sysdate);
            when deleting then
                insert into uit_audit values(user, 'DELETE', sysdate);
        end case;
    end;
    /
    delete from uitvoeringen where cursus = 'ERM';
    insert into uitvoeringen(cursus, begindatum) values ('GEN', sysdate);
    select * from uit_audit;
    rollback;
-- opgave 2

-- opgave 3

-- opgave 4



drop trigger uit_audit_trg;
drop table uit_audit purge;