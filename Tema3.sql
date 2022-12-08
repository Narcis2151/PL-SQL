--1
DECLARE
    TYPE TABLOU_ANG IS
        TABLE OF EMP_FNA%ROWTYPE INDEX BY BINARY_INTEGER;
    T TABLOU_ANG;
BEGIN
    SELECT
        * BULK COLLECT INTO T
    FROM
        (
            SELECT
                *
            FROM
                EMP_FNA
            WHERE
                COMMISSION_PCT IS NULL
            ORDER BY
                SALARY ASC
        )
    WHERE
        ROWNUM <=5;
    DBMS_OUTPUT.PUT_LINE('Valorile vechi ale salariilor: ');
    FOR I IN T.FIRST..T.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(T(I).SALARY);
    END LOOP;
 --Actualizarea salariilor
    FOR I IN T.FIRST..T.LAST LOOP
        T(I).SALARY := T(I).SALARY * 1.05;
        UPDATE EMP_FNA
        SET
            SALARY = T(
                I
            ).SALARY
        WHERE
            EMPLOYEE_ID = T(
                I
            ).EMPLOYEE_ID;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Valorile noi ale salariilor: ');
    FOR I IN T.FIRST..T.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(T(I).SALARY);
    END LOOP;
    ROLLBACK;
END;
 --2
 CREATE OR REPLACE TYPE TIP_ORASE_FNA IS VARRAY(300) OF VARCHAR2(20);
CREATE TABLE EXCURSIE_FNA( COD_EXCURSIE NUMBER(4), DENUMIRE VARCHAR2(20), ORASE TIP_ORASE_FNA, STATUS VARCHAR2(20));
 --a
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE;
    LISTA_ORASE   TIP_ORASE_FNA;
BEGIN
    FOR I IN 1..5 LOOP
        INSERT INTO EXCURSIE_FNA(
            COD_EXCURSIE,
            DENUMIRE,
            ORASE,
            STATUS
        ) VALUES (
            I,
            'Excursie ' || I,
            TIP_ORASE_FNA ('Oras' || I, 'Oras' || (I+1)),
            'disponibila'
        );
    END LOOP;
END;
/

--b
DECLARE
 --b.1.ad?uga?i un ora? nou �n list?, ce va fi ultimul vizitat �n excursia respectiv?;
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    LISTA_ORASE.EXTEND();
    LISTA_ORASE(LISTA_ORASE.COUNT) := 'Oras adaugat';
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.2
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    LISTA_ORASE.EXTEND();
    FOR I IN REVERSE 2..LISTA_ORASE.COUNT LOOP
        LISTA_ORASE(I) := LISTA_ORASE(I-1);
    END LOOP;
    LISTA_ORASE(2) := 'Oras adaugat 2';
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.3
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
    ORAS1         VARCHAR2(20) := '&nume_oras_1';
    ORAS2         VARCHAR2(20) := '&nume_oras_2';
    AUX           VARCHAR2(20);
    ID_1          NUMBER;
    ID_2          NUMBER;
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        IF LISTA_ORASE(I) = ORAS1 THEN
            ID_1 := I;
        END IF;
        IF LISTA_ORASE(I) = ORAS2 THEN
            ID_2 := I;
        END IF;
    END LOOP;
    AUX := LISTA_ORASE(ID_1);
    LISTA_ORASE(ID_1) := LISTA_ORASE(ID_2);
    LISTA_ORASE(ID_2) := AUX;
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.4
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
    ORAS          VARCHAR2(20) := '&nume_oras';
    AUX           TIP_ORASE_FNA := TIP_ORASE_FNA();
    IND           NUMBER := 1;
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        IF LISTA_ORASE(I) != ORAS THEN
            AUX.EXTEND;
            AUX(IND) := LISTA_ORASE(I);
            IND := IND + 1;
        END IF;
    END LOOP;
    UPDATE EXCURSIE_FNA
    SET
        ORASE = AUX
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--c
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    DBMS_OUTPUT.PUT_LINE('Numar orase: ' || LISTA_ORASE.COUNT);
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(LISTA_ORASE(I));
    END LOOP;
END;
/

--d
DECLARE
    TYPE EXC IS
        VARRAY(20) OF EXCURSIE_FNA.COD_EXCURSIE%TYPE;
    EXCURSII    EXC;
    LISTA_ORASE TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        COD_EXCURSIE BULK COLLECT INTO EXCURSII
    FROM
        EXCURSIE_FNA;
    FOR I IN 1..EXCURSII.LAST LOOP
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = EXCURSII(I);
        DBMS_OUTPUT.PUT_LINE('Excursia ' || EXCURSII(I) || ': ');
        FOR I IN 1..LISTA_ORASE.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(LISTA_ORASE(I) || ', ');
        END LOOP;
    END LOOP;
END;
/

--e
DECLARE
    TYPE EXC IS
        VARRAY(20) OF EXCURSIE_FNA.COD_EXCURSIE%TYPE;
    EXCURSII    EXC;
    LISTA_ORASE TIP_ORASE_FNA := TIP_ORASE_FNA();
    ID          NUMBER;
    MINIM       NUMBER;
BEGIN
    SELECT
        COD_EXCURSIE BULK COLLECT INTO EXCURSII
    FROM
        EXCURSIE_FNA;
    ID := EXCURSII(1);
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = ID;
    MINIM := LISTA_ORASE.COUNT;
    FOR I IN 2..EXCURSII.LAST LOOP
        ID := EXCURSII(I);
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = ID;
        IF LISTA_ORASE.COUNT < MINIM THEN
            MINIM := LISTA_ORASE.COUNT;
        END IF;
    END LOOP;
    FOR I IN EXCURSII.FIRST..EXCURSII.LAST LOOP
        ID := EXCURSII(I);
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = ID;
        IF LISTA_ORASE.COUNT = MINIM THEN
            UPDATE EXCURSIE_FNA
            SET
                STATUS = 'anulata'
            WHERE
                COD_EXCURSIE = ID;
        END IF;
    END LOOP;
END;
/

--3
DROP TABLE EXCURSIE_FNA;

DROP TYPE TIP_ORASE_FNA;

CREATE OR REPLACE TYPE TIP_ORASE_FNA IS
    TABLE OF VARCHAR2(
        20
    );
    CREATE TABLE EXCURSIE_FNA(
        COD_EXCURSIE NUMBER(4),
        DENUMIRE VARCHAR2(20),
        ORASE TIP_ORASE_FNA,
        STATUS VARCHAR2(20)
    ) NESTED TABLE ORASE STORE AS
        LISTA_ORASE_FNA;
        DECLARE
            EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE;
            LISTA_ORASE   TIP_ORASE_FNA;
        BEGIN
            FOR I IN 1..5 LOOP
                INSERT INTO EXCURSIE_FNA(
                    COD_EXCURSIE,
                    DENUMIRE,
                    ORASE,
                    STATUS
                ) VALUES (
                    I,
                    'Excursie ' || I,
                    TIP_ORASE_FNA ('Oras' || I, 'Oras' || (I+1)),
                    'disponibila'
                );
            END LOOP;
        END;
/

--b
DECLARE
 --b.1.ad?uga?i un ora? nou �n list?, ce va fi ultimul vizitat �n excursia respectiv?;
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    LISTA_ORASE.EXTEND();
    LISTA_ORASE(LISTA_ORASE.COUNT) := 'Oras adaugat';
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.2
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    LISTA_ORASE.EXTEND();
    FOR I IN REVERSE 2..LISTA_ORASE.COUNT LOOP
        LISTA_ORASE(I) := LISTA_ORASE(I-1);
    END LOOP;
    LISTA_ORASE(2) := 'Oras adaugat 2';
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.3
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
    ORAS1         VARCHAR2(20) := '&nume_oras_1';
    ORAS2         VARCHAR2(20) := '&nume_oras_2';
    AUX           VARCHAR2(20);
    ID_1          NUMBER;
    ID_2          NUMBER;
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        IF LISTA_ORASE(I) = ORAS1 THEN
            ID_1 := I;
        END IF;
        IF LISTA_ORASE(I) = ORAS2 THEN
            ID_2 := I;
        END IF;
    END LOOP;
    AUX := LISTA_ORASE(ID_1);
    LISTA_ORASE(ID_1) := LISTA_ORASE(ID_2);
    LISTA_ORASE(ID_2) := AUX;
    UPDATE EXCURSIE_FNA
    SET
        ORASE = LISTA_ORASE
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--b.4
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
    ORAS          VARCHAR2(20) := '&nume_oras';
    AUX           TIP_ORASE_FNA := TIP_ORASE_FNA();
    IND           NUMBER := 1;
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        IF LISTA_ORASE(I) != ORAS THEN
            AUX.EXTEND;
            AUX(IND) := LISTA_ORASE(I);
            IND := IND + 1;
        END IF;
    END LOOP;
    UPDATE EXCURSIE_FNA
    SET
        ORASE = AUX
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
END;
/

--c
DECLARE
    EXCURSIE_SPEC EXCURSIE_FNA.COD_EXCURSIE%TYPE := &COD_EXCURSIE_SPECIFICATA;
    LISTA_ORASE   TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = EXCURSIE_SPEC;
    DBMS_OUTPUT.PUT_LINE('Numar orase: ' || LISTA_ORASE.COUNT);
    FOR I IN 1..LISTA_ORASE.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(LISTA_ORASE(I));
    END LOOP;
END;
/

--d
DECLARE
    TYPE EXC IS
        VARRAY(20) OF EXCURSIE_FNA.COD_EXCURSIE%TYPE;
    EXCURSII    EXC;
    LISTA_ORASE TIP_ORASE_FNA := TIP_ORASE_FNA();
BEGIN
    SELECT
        COD_EXCURSIE BULK COLLECT INTO EXCURSII
    FROM
        EXCURSIE_FNA;
    FOR I IN 1..EXCURSII.LAST LOOP
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = EXCURSII(I);
        DBMS_OUTPUT.PUT_LINE('Excursia ' || EXCURSII(I) || ': ');
        FOR I IN 1..LISTA_ORASE.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(LISTA_ORASE(I) || ', ');
        END LOOP;
    END LOOP;
END;
/

--e
DECLARE
    TYPE EXC IS
        VARRAY(20) OF EXCURSIE_FNA.COD_EXCURSIE%TYPE;
    EXCURSII    EXC;
    LISTA_ORASE TIP_ORASE_FNA := TIP_ORASE_FNA();
    ID          NUMBER;
    MINIM       NUMBER;
BEGIN
    SELECT
        COD_EXCURSIE BULK COLLECT INTO EXCURSII
    FROM
        EXCURSIE_FNA;
    ID := EXCURSII(1);
    SELECT
        ORASE INTO LISTA_ORASE
    FROM
        EXCURSIE_FNA
    WHERE
        COD_EXCURSIE = ID;
    MINIM := LISTA_ORASE.COUNT;
    FOR I IN 2..EXCURSII.LAST LOOP
        ID := EXCURSII(I);
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = ID;
        IF LISTA_ORASE.COUNT < MINIM THEN
            MINIM := LISTA_ORASE.COUNT;
        END IF;
    END LOOP;
    FOR I IN EXCURSII.FIRST..EXCURSII.LAST LOOP
        ID := EXCURSII(I);
        SELECT
            ORASE INTO LISTA_ORASE
        FROM
            EXCURSIE_FNA
        WHERE
            COD_EXCURSIE = ID;
        IF LISTA_ORASE.COUNT = MINIM THEN
            UPDATE EXCURSIE_FNA
            SET
                STATUS = 'anulata'
            WHERE
                COD_EXCURSIE = ID;
        END IF;
    END LOOP;
END;
/