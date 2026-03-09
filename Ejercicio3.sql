CREATE OR REPLACE TYPE Client AS OBJECT(
    nif VARCHAR2(10),
    nom VARCHAR2(10),
    adreca VARCHAR2(10),
    telefon VARCHAR2(12),
    MEMBER FUNCTION numCursos RETURN NUMBER 
);
/

CREATE TABLE taula_clients OF Client (
    nif PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Curs AS OBJECT(
    idCurs VARCHAR2(10),
    nom VARCHAR2(10),
    hores NUMBER,
    preu NUMBER,
    MEMBER FUNCTION coordinador RETURN VARCHAR2,
    MEMBER FUNCTION actiu RETURN VARCHAR2
)NOT FINAL;
/

CREATE TABLE taula_cursos OF Curs (
    idCurs PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Empleat AS OBJECT(
    dni VARCHAR2(10),
    nom VARCHAR2(10),
    cognoms VARCHAR2(10),
    dataContracte DATE,
    telefon VARCHAR2(12),
    MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE CursActiu UNDER Curs(
dataInici DATE, 
dataFiPrevista DATE,
modalitat VARCHAR2(10),
MEMBER FUNCTION modulActual RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE CursHistoric UNDER Curs(
 dataFinal DATE,
 valoracio VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Formador UNDER Empleat(
    especialitat VARCHAR2(10),
    nivell VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Coordinador UNDER Empleat(
   area VARCHAR2(10),
   despatx VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Tecnic UNDER Empleat(
 certificacio VARCHAR2(10),
 sistema VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Modul AS OBJECT(
idModul VARCHAR2(10),
nom VARCHAR2(10),
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