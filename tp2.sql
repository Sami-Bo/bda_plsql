SQL Serveroutput on ;

Declare
	CURSOR cur is
		Select ename, hiredate
		From emp, dept
		Where loc = 'NEW YORK' and
		Emp.depyno = dept.deptno ;
	date1 emp.hiredate % type := NULL,
	name emp.ename % type;
	rec cur % rowtype;
Begin
	Open cur;
	LOOP
		FETCH cur into rec;
		EXIT when cur%notfound;
		if date1 is null OR date1 > rec.hiredate THEN 
			date1 := rec.hiredate;
			name := rec.ename;
		END IF;
	END LOOP;
	Close cur;
	DBMS_OUTPUT.PUT_LINE('name is' || name);
end;


-- 2. AVEC LOOP

Set SERVEROUTPUT ON;

DECLARE
    CURSOR emp_cur IS
        SELECT comm FROM EMP WHERE comm IS NOT NULL FOR UPDATE;     
    old_comm EMP.comm%TYPE;
    moyenne NUMBER(7,2);
    somme NUMBER(7,2) := 0;
BEGIN
	Open emp_cur;
	LOOP
		FETCH emp_cur into old_comm;
		EXIT when emp_cur % notfound;
		somme := somme + old_comm;
		UPDATE EMP
			set comm = 1.1*old_comm
			where current of emp_cur;
	end loop;
	moyenne := somme*0.1 / emp_cur % rowcount;
	dbms_output.put_line('Somme ' ||  somme*0.1 || 'Moyenne ' || moyenne) ;
	Close emp_cur ;
	commit ;
End;

-- 2. AVEC FOR
Set Serveroutput on;

Declare
	Cursor emp_cur is
		Select comm from EMP where comm is not null for update;
	moyenne number(7,2);
	somme number(7,2) := 0;
	rec emp_cur % rowtype;
Begin
	FOR row1 in emp_cur LOOP
		somme := somme + row1.comm;
		UPDATE EMP
			set comm = 1.1*row1.comm
			where current of emp_cur;
	end loop;
	moyenne := somme*0.1 / emp_cur % rowcount;
	dbms_output.put_line('Somme' ||  somme*0.1 || 'Moyenne' || moyenne) ;
	Close emp_cur ;
	commit ;
End;


-- TP : Pratique
Set Serveroutput on;

Declare
	Cursor cur is
		Select sal from EMP2 where sal is not null for update order by sal;

    nombreDeLignes NUMBER;
    rec cur % rowtype;
Begin
    -- Utilisation de la fonction COUNT dans une requête SQL
    SELECT COUNT(*) INTO nombreDeLignes FROM EMP2;
    
    FOR row1 in cur LOOP
        CASE
            WHEN rowcount < 1/2 * nombreDeLignes THEN
                UPDATE EMP2
			        set sal = 1.08*row1.comm
			        where current of cur;
            WHEN rowcount > 1/2 * nombreDeLignes AND i < 3/4 * nombreDeLignes THEN
                UPDATE EMP2
			        set sal = 1.06*row1.comm
			        where current of cur;
            WHEN rowcount > 3/4 * nombreDeLignes THEN
                UPDATE EMP2
			        set sal = 1.04*row1.comm
			        where current of cur;
            ELSE
                -- Code à exécuter si aucune des conditions n'est satisfaite
                DBMS_OUTPUT.PUT_LINE('Aucun cas');
        END CASE;
    END LOOP
	commit ;
End;