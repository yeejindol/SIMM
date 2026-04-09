CREATE OR REPLACE TYPE Client AS OBJECT(
    nif VARCHAR2(50),
    nom VARCHAR2(50),
    adreca VARCHAR2(100),
    telefon VARCHAR2(12),
    MEMBER FUNCTION numCursos RETURN NUMBER 
) NOT FINAL;
/

CREATE TABLE taula_clients OF Client (
    nif PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Curs AS OBJECT(
    idCurs VARCHAR2(10),
    nom VARCHAR2(50),
    hores NUMBER,
    preu NUMBER,
    MEMBER FUNCTION coordinador RETURN VARCHAR2,
    MEMBER FUNCTION actiu RETURN VARCHAR2
) NOT FINAL;
/

CREATE TABLE taula_cursos OF Curs (
    idCurs PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Empleat AS OBJECT(
    dni VARCHAR2(10),
    nom VARCHAR2(50),
    cognoms VARCHAR2(50),
    dataContracte DATE,
    telefon VARCHAR2(12),
    MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;
/

CREATE TABLE taula_empleats OF Empleat (
    dni PRIMARY KEY
);
/

CREATE OR REPLACE TYPE CursActiu UNDER Curs(
    dataInici DATE, 
    dataFiPrevista DATE,
    modalitat VARCHAR2(50),
    MEMBER FUNCTION modulActual RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE CursHistoric UNDER Curs(
    dataFinal DATE,
    valoracio NUMBER
);
/

CREATE OR REPLACE TYPE Formador UNDER Empleat(
    especialitat VARCHAR2(50),
    nivell VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE Coordinador UNDER Empleat(
    area VARCHAR2(50),
    despatx VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE Tecnic UNDER Empleat(
    certificacio VARCHAR2(50),
    sistema VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE Modul AS OBJECT(
    idModul VARCHAR2(10),
    nom VARCHAR2(50),
    dataInici DATE,
    dataFi DATE,
    MEMBER FUNCTION numCursos RETURN NUMBER
);
/

CREATE TABLE taula_moduls OF Modul (
    idModul PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Coordina AS OBJECT (
    ref_curs REF Curs,
    ref_empleat REF Empleat
);
/

CREATE OR REPLACE TYPE Participa AS OBJECT (
    ref_curs REF Curs,
    ref_empleat REF Empleat
);
/

CREATE OR REPLACE TYPE ModulsCurs AS OBJECT (
    ref_cursActiu REF CursActiu,
    ref_modul REF Modul
);
/

CREATE TABLE taula_coordina OF Coordina;
/

CREATE TABLE taula_participa OF Participa;
/

CREATE TABLE taula_moduls_curs OF ModulsCurs;
/

--Insertar datos en clientes
INSERT INTO taula_clients VALUES (Client('Y12345678' ,'Ana', 'Calle Marina 134', '12345678'));
INSERT INTO taula_clients VALUES (Client('Z12368692', 'Joan', 'Avenida Selva 14' , '11223344'));

--Insertar datos en módulos
INSERT INTO taula_moduls VALUES (Modul('M123', 'Base de datos', TO_DATE('01-02-2026', 'DD-MM-YYYY'), NULL));
INSERT INTO taula_moduls VALUES (Modul('M122', 'Multimedia', TO_DATE('05-02-2026', 'DD-MM-YYYY'), TO_DATE('10-06-2026','DD-MM-YYYY')));

--Insertar datos en Empleados
INSERT INTO taula_empleats VALUES (Formador('17382S8N', 'Jose', 'Luis', SYSDATE ,'1123389', 'SQL', 'Senior'));
INSERT INTO taula_empleats VALUES (Coordinador('2678273B', 'Gerard', 'Perez', SYSDATE , '18392628', 'IT', 'D123'));
INSERT INTO taula_empleats VALUES (Tecnic('3782627G', 'Jordi', 'Vila', TO_DATE('22-02-2022','DD-MM-YYYY'), '67822828', 'LINUX', 'LINUX'));

-- Insertar datos en Cursos (incluyendo CursActiu y CursHistoric)
INSERT INTO taula_cursos VALUES (CursActiu('C01', 'Java OO', 100, 500, TO_DATE('01-01-2026','DD-MM-YYYY'), TO_DATE('01-06-2026','DD-MM-YYYY'), 'Online'));
INSERT INTO taula_cursos VALUES (CursHistoric('C02', 'SQL Basic', 40, 150, TO_DATE('20-12-2025','DD-MM-YYYY'), 9));

-- Insertar datos en la tabla Coordina (Asociación Curs y Empleat)
INSERT INTO taula_coordina SELECT REF(c), REF(e) 
FROM taula_cursos c, taula_empleats e 
WHERE c.idCurs = 'C01' AND e.dni = '2678273B';

-- Insertar datos en la tabla Participa (Asociación Curs y Empleat)
INSERT INTO taula_participa SELECT REF(c), REF(e) 
FROM taula_cursos c, taula_empleats e 
WHERE c.idCurs = 'C01' AND e.dni = '17382S8N';

-- Insertar datos en la tabla ModulsCurs (Asociación CursActiu y Modul)
INSERT INTO taula_moduls_curs SELECT TREAT(REF(c) AS REF CursActiu), REF(m) 
FROM taula_cursos c, taula_moduls m 
WHERE c.idCurs = 'C01' AND m.idModul = 'M123';


-- IMPLEMENTAR LOS METODOS DE LAS CLASES CON CREATE OR REPLACE TYPE BODY

-- 1. Metodo coordinador, muestrará el nombre y apellidos del coordinador del curso.
CREATE OR REPLACE TYPE BODY Curs AS 
    MEMBER FUNCTION coordinador RETURN VARCHAR2 IS 
        v_nom_completo VARCHAR2(100); 
    BEGIN
         SELECT DEREF(tc.ref_empleat).nom || ' ' || DEREF(tc.ref_empleat).cognoms
         INTO v_nom_completo
         FROM taula_coordina tc
         WHERE DEREF(tc.ref_curs).idCurs = SELF.idCurs;
         RETURN v_nom_completo;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Sin asignar';
    END;

    MEMBER FUNCTION actiu RETURN VARCHAR2 IS
        v_conteo NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_conteo 
        FROM taula_cursos c 
        WHERE c.idCurs = SELF.idCurs 
        AND VALUE(c) IS OF (CursActiu);
        IF v_conteo > 0 THEN RETURN 'T'; ELSE RETURN 'F'; END IF;
    END;
END;
/

--2. Metodo antiguidad, calculará la diferencia en años entre sysdate(hoy) y dataContracte
CREATE OR REPLACE TYPE BODY Empleat AS
    MEMBER FUNCTION antiguitat RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, SELF.dataContracte) / 12);
    END;
END;
/

--4. Metodo ModulActual, torna el nombre del modulo del curso activo que tiene como dataFi= null
CREATE OR REPLACE TYPE BODY CursActiu AS
    MEMBER FUNCTION ModulActual RETURN VARCHAR2 IS
        v_nom VARCHAR2(50);
    BEGIN
        SELECT DEREF(t.ref_modul).nom INTO v_nom
        FROM taula_moduls_curs t
        WHERE DEREF(t.ref_cursActiu).idCurs = SELF.idCurs
        AND DEREF(t.ref_modul).dataFi IS NULL;
        RETURN v_nom;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Cap';
    END;
END;
/

--6. Metodo numCursos de Modul que cuenta cuantos cursos aparece
CREATE OR REPLACE TYPE BODY Client AS
   MEMBER FUNCTION numCursos RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total 
        FROM taula_participa tp
        WHERE DEREF(tp.ref_curs).idCurs IS NOT NULL;
        RETURN v_total;
    END;
END;
/

-- 7. Mètode numCursos de Modul
CREATE OR REPLACE TYPE BODY Modul AS
    MEMBER FUNCTION numCursos RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total 
        FROM taula_moduls_curs
        WHERE DEREF(ref_modul).idModul = SELF.idModul;
        RETURN v_total;
    END;
END;
/

--COMPROBAR QUE FUNCIONAN BIEN

--1. Ver cuantos cursos tiene cada cliente
SELECT c.nom, c.nif, c.numCursos() AS total
FROM taula_clients c;

--2. Ver si los cursos están activos o no
SELECT c.nom, c.actiu() AS es_activo
FROM taula_cursos c;

--3. Ver en cuantos cursos aperece cada modulo
SELECT m.nom, m.numCursos() AS aparecido
FROM taula_moduls m;

--4. Ver nombre del coordinado y si el curso es activo
SELECT c.nom, c.coordinador() AS responsable, c.actiu() AS activo
FROM taula_cursos c;

--5. Ver antigüedad de empleados
SELECT e.nom, e.antiguitat() AS años_empresa
FROM taula_empleats e;