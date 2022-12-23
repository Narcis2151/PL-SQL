--1
CREATE TABLE info_fna
(
    utilizator VARCHAR2(100),
    data DATE,
    comanda VARCHAR2(100),
    nr_linii NUMBER,
    eroare VARCHAR2(100)
);

--2
CREATE OR REPLACE FUNCTION f2_fna
 (v_nume employees.last_name%TYPE)
RETURN NUMBER 
IS
 salariu employees.salary%type DEFAULT NULL;
 nr_ang NUMBER := 0;
 BEGIN

 SELECT COUNT(*) INTO nr_ang
 FROM EMPLOYEES
 WHERE LAST_NAME = v_nume;

 SELECT SALARY INTO salariu
 FROM EMPLOYEES
 WHERE LAST_NAME = v_nume;

 INSERT INTO info_fna
 VALUES(user, sysdate, 'f2_fna'||' ('||v_nume||')', 1, 'no_error');

 RETURN nr_ang;

 EXCEPTION

 WHEN NO_DATA_FOUND THEN
 INSERT INTO info_fna
 VALUES(user, sysdate, 'f2_fna'||' ('||v_nume||')', 0, 'Nu exista angajati cu numele dat');
 RETURN nr_ang;

 WHEN TOO_MANY_ROWS THEN
 INSERT INTO info_fna
 VALUES (user, sysdate, 'f2_fna'||' ('||v_nume||')', nr_ang, 'Exista mai multi angajati cu numele dat');
 RETURN nr_ang;
END f2_fna;
/
DECLARE
 numar NUMBER;
BEGIN
 numar := f2_fna('Bell');
 numar := f2_fna('Kimball');
 numar := f2_fna('King');
END;
/
SELECT *
FROM info_fna;

--3
CREATE OR REPLACE FUNCTION f3_fna
(v_oras LOCATIONS.CITY%TYPE)
RETURN NUMBER
IS
nr_ang_2_job NUMBER :=0;
nr_loc NUMBER :=0;
nr_ang_total NUMBER :=0;
BEGIN

SELECT COUNT(*)
INTO nr_loc
FROM LOCATIONS 
WHERE CITY = INITCAP(v_oras);

IF nr_loc = 0 THEN
 INSERT INTO info_fna
 VALUES(user, sysdate, 'f3_fna('||v_oras||')', 0, 'Orasul nu exista');
 RETURN 0;
END IF;

SELECT COUNT(DISTINCT E.EMPLOYEE_ID)
INTO nr_ang_total
FROM EMPLOYEES e
WHERE E.DEPARTMENT_ID IN (
                            SELECT DISTINCT DEPARTMENT_ID
                            FROM DEPARTMENTS D JOIN LOCATIONS L ON (D.LOCATION_ID = L.LOCATION_ID)
                            WHERE L.CITY = INITCAP(v_oras) 
                        );

IF nr_ang_total = 0 THEN
 INSERT INTO info_fna
 VALUES(user, sysdate, 'f3_fna('||v_oras||')', 0, 'In orasul respectiv nu lucreaza nimeni');
 RETURN 0;
END IF;

SELECT COUNT(DISTINCT E.EMPLOYEE_ID)
INTO nr_ang_2_job
FROM EMPLOYEES e RIGHT JOIN JOB_HISTORY j ON (e.EMPLOYEE_ID = j.EMPLOYEE_ID)
WHERE E.DEPARTMENT_ID IN (
                            SELECT DISTINCT DEPARTMENT_ID
                            FROM DEPARTMENTS D JOIN LOCATIONS L ON (D.LOCATION_ID = L.LOCATION_ID)
                            WHERE L.CITY = INITCAP(v_oras) 
                        );
IF nr_ang_2_job = 0 THEN
 INSERT INTO info_fna
 VALUES(user, sysdate, 'f3_fna('||v_oras||')', 0, 'In orasul respectiv nu lucreaza niciun angajat ce a avut 2 job-uri sau mai multe');

 ELSE
  INSERT INTO info_fna
  VALUES(user, sysdate, 'f3_fna('||v_oras||')', 0, 'no_error');
END IF;
RETURN nr_ang_2_job;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE(f3_fna('London'));
END;
/
SELECT *
FROM info_fna;

--4
CREATE OR REPLACE PROCEDURE ex4_fna
(cod_manager IN EMPLOYEES.EMPLOYEE_ID%TYPE)
IS
numar_ang_cod NUMBER;
numar_ang_condusi NUMBER := 0;
id_manager EMPLOYEES.EMPLOYEE_ID%TYPE;
salariu_nou EMPLOYEES.SALARY%TYPE;
--Toti angajatii care nu sunt manager-ul dat
CURSOR C IS
(SELECT * 
FROM EMPLOYEES
WHERE EMPLOYEE_ID != cod_manager) ;
BEGIN
    --Cazul in care id-ul dat nu exista nu exista
    SELECT COUNT(EMPLOYEE_ID)
    INTO numar_ang_cod
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = cod_manager;

    IF numar_ang_cod = 0 THEN
        INSERT INTO INFO_FNA
        VALUES(user, sysdate, 'ex4_fna(' || cod_manager || ')', 0, 'Nu exista angajati cu acest ID');
    ELSE
        --daca exista angajati cu codul dat
        FOR employee in C LOOP
            id_manager := employee.MANAGER_ID;
            --mergem pe lantul angajat->manager pana ajungem la un angajat care nu are manager
            --sau al carui manager este cel dat ca parametru
            WHILE id_manager IS NOT NULL AND id_manager != cod_manager LOOP
                SELECT MANAGER_ID
                INTO id_manager
                FROM EMPLOYEES
                WHERE EMPLOYEE_ID = id_manager;
            END LOOP;

            IF id_manager = cod_manager THEN
                UPDATE EMP_FNA
                SET SALARY = SALARY * 1.10
                WHERE EMPLOYEE_ID = employee.EMPLOYEE_ID
                RETURNING SALARY INTO salariu_nou;
                numar_ang_condusi := numar_ang_condusi + 1;
                DBMS_OUTPUT.PUT_LINE(salariu_nou);
            END IF;
        END LOOP;
        IF numar_ang_condusi = 0 THEN
            INSERT INTO INFO_FNA
            VALUES(user, sysdate, 'ex4_fna(' || cod_manager || ')', 0, 'Nu exista angajati condusi de acest manager');
        ELSE
           INSERT INTO INFO_FNA
           VALUES(user, sysdate, 'ex4_fna(' || cod_manager || ')', numar_ang_condusi, 'No error'); 
        END IF;
    END IF;
END;
/
BEGIN
ex4_fna(190);
END;
/
SELECT *
FROM info_fna;

--5
CREATE OR REPLACE PROCEDURE ex5_fna
IS
nume_departament DEPARTMENTS.DEPARTMENT_NAME%TYPE;
ziua VARCHAR2(10);
nr_ang_dep NUMBER;
nr_ang_zi NUMBER;
BEGIN
    FOR department IN (SELECT D.DEPARTMENT_NAME, D.DEPARTMENT_ID, COUNT(E.EMPLOYEE_ID) "Number of employees"
                       FROM DEPARTMENTS D LEFT JOIN EMPLOYEES E ON (D.DEPARTMENT_ID = E.DEPARTMENT_ID)
                       GROUP BY D.DEPARTMENT_NAME, D.DEPARTMENT_ID) LOOP
        
        SELECT COUNT(DISTINCT E.employee_id)
        INTO nr_ang_dep
        FROM DEPARTMENTS D LEFT JOIN EMPLOYEES E ON(D.DEPARTMENT_ID = E.DEPARTMENT_ID)
        WHERE D.DEPARTMENT_ID = department.DEPARTMENT_ID;

        IF nr_ang_dep = 0 THEN
        DBMS_OUTPUT.PUT_LINE('In departamentul ' || department.DEPARTMENT_NAME || ' nu lucreaza nimeni');
        ELSE
            SELECT "Numar de angajati", "Ziua saptamanii"
            INTO nr_ang_zi, ziua
            FROM
                ((SELECT COUNT(EMPLOYEE_ID) "Numar de angajati", NVL(TO_CHAR(HIRE_DATE, 'DY'), 0) "Ziua saptamanii"
                        --INTO nr_ang_zi, ziua
                        FROM EMPLOYEES
                        WHERE DEPARTMENT_ID = department.DEPARTMENT_ID
                        GROUP BY  NVL(TO_CHAR(HIRE_DATE, 'DY'), 0)
                        HAVING COUNT(EMPLOYEE_ID) = (SELECT MAX(COUNT(EMPLOYEE_ID))
                                                    FROM EMPLOYEES
                                                    WHERE DEPARTMENT_ID = department.DEPARTMENT_ID
                                                    GROUP BY  NVL(TO_CHAR(HIRE_DATE, 'DY'), 0)
                                                    ))
                )
            WHERE ROWNUM<2;
            DBMS_OUTPUT.PUT_LINE('In departamentul ' || department.DEPARTMENT_NAME || ', ziua cu cele mai multe angajari(' || nr_ang_zi || ') a fost ' || ziua);
            FOR employee IN (SELECT FIRST_NAME || ' ' || LAST_NAME "Nume Complet", ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE),0) "Vechime in luni", SALARY
                            FROM EMPLOYEES
                            WHERE DEPARTMENT_ID = department.DEPARTMENT_ID AND TO_CHAR(HIRE_DATE, 'DY') = ziua) LOOP
                DBMS_OUTPUT.PUT_LINE(employee."Nume Complet" || ' cu vechimea de: ' || employee."Vechime in luni" || ' luni si salariul: ' || employee.SALARY);
            END LOOP;
        END IF;
    END LOOP;


END;
/
BEGIN
 ex5_fna;
END;
/

--6
CREATE OR REPLACE PROCEDURE ex6_fna
IS
index_ang NUMBER := 1;
numar_ang NUMBER := 0;
nume_departament DEPARTMENTS.DEPARTMENT_NAME%TYPE;
ziua VARCHAR2(10);
nr_ang_dep NUMBER;
nr_ang_zi NUMBER;
CURSOR C(p1 DEPARTMENTS.DEPARTMENT_ID%TYPE, p2 VARCHAR2, p3 NUMBER) IS
(SELECT FIRST_NAME || ' ' || LAST_NAME "Nume Complet", ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE),0) "Vechime in luni", SALARY
FROM EMPLOYEES
WHERE DEPARTMENT_ID = p1 AND TO_CHAR(HIRE_DATE, 'DY') = p2 and ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE),0) = p3 );
BEGIN
    FOR department IN (SELECT D.DEPARTMENT_NAME, D.DEPARTMENT_ID, COUNT(E.EMPLOYEE_ID) "Number of employees"
                       FROM DEPARTMENTS D LEFT JOIN EMPLOYEES E ON (D.DEPARTMENT_ID = E.DEPARTMENT_ID)
                       GROUP BY D.DEPARTMENT_NAME, D.DEPARTMENT_ID) LOOP
        
        SELECT COUNT(DISTINCT E.employee_id)
        INTO nr_ang_dep
        FROM DEPARTMENTS D LEFT JOIN EMPLOYEES E ON(D.DEPARTMENT_ID = E.DEPARTMENT_ID)
        WHERE D.DEPARTMENT_ID = department.DEPARTMENT_ID;

        IF nr_ang_dep = 0 THEN
        DBMS_OUTPUT.PUT_LINE('In departamentul ' || department.DEPARTMENT_NAME || ' nu lucreaza nimeni');
        ELSE
            SELECT "Numar de angajati", "Ziua saptamanii"
            INTO nr_ang_zi, ziua
            FROM
                ((SELECT COUNT(EMPLOYEE_ID) "Numar de angajati", NVL(TO_CHAR(HIRE_DATE, 'DY'), 0) "Ziua saptamanii"
                        --INTO nr_ang_zi, ziua
                        FROM EMPLOYEES
                        WHERE DEPARTMENT_ID = department.DEPARTMENT_ID
                        GROUP BY  NVL(TO_CHAR(HIRE_DATE, 'DY'), 0)
                        HAVING COUNT(EMPLOYEE_ID) = (SELECT MAX(COUNT(EMPLOYEE_ID))
                                                    FROM EMPLOYEES
                                                    WHERE DEPARTMENT_ID = department.DEPARTMENT_ID
                                                    GROUP BY  NVL(TO_CHAR(HIRE_DATE, 'DY'), 0)
                                                    ))
                )
            WHERE ROWNUM<2;
            index_ang  := 1;
            numar_ang  := 0;
            DBMS_OUTPUT.PUT_LINE('In departamentul ' || department.DEPARTMENT_NAME || ', ziua cu cele mai multe angajari(' || nr_ang_zi || ') a fost ' || ziua);
            FOR vechime IN (SELECT DISTINCT ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE),0) "Vechime in luni"
                            FROM EMPLOYEES
                            WHERE DEPARTMENT_ID = department.DEPARTMENT_ID AND TO_CHAR(HIRE_DATE, 'DY') = ziua
                            ORDER BY "Vechime in luni" DESC) LOOP
                DBMS_OUTPUT.PUT(index_ang || '. ');
                FOR employee in C(department.DEPARTMENT_ID, ziua, vechime."Vechime in luni") LOOP
                    numar_ang := numar_ang + 1;
                    DBMS_OUTPUT.PUT(employee."Nume Complet" || ' cu vechimea de: ' || employee."Vechime in luni" || ' luni si salariul: ' || employee.SALARY ||', ');
                END LOOP;
                index_ang := index_ang + 1;
                DBMS_OUTPUT.PUT_LINE('');
                EXIT WHEN numar_ang = nr_ang_zi;
            END LOOP;
        END IF;
    END LOOP;


END;
/
BEGIN
 ex6_fna;
END;
/

