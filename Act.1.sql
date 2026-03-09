CREATE TYPE ADRECA AS OBJECT (
codi_postal NUMBER,
carrer VARCHAR(50),
ciutat VARCHAR(10)
);

CREATE TYPE TELEFON AS VARRAY(2) OF NUMBER;

CREATE TYPE PROVEIDOR AS OBJECT (
codi NUMBER,
nom VARCHAR2(50),
adreca ADRECA,
vec_telefons TELEFON,
correu_electronic VARCHAR(50),
);

CREATE TYPE MATERIAL AS OBJECT (
codi NUMBER,
nom VARCHAR(50),
descripcio VARCHAR(200),
cost_unitari NUMBER(5,2)
);

CREATE TYPE LINIA_COMPRA AS OBJECT (
codi NUMBER,
ref_material REF material,
quantitat NUMBER,
descompte NUMBER
);

CREATE TYPE linies AS TABLE OF LINIA_COMPRA;

CREATE TYPE COMPRA AS OBJECT (
codi NUMBER, 
data_compra NUMBER,
ref_proveidor REF PROVEIDOR,
taula_linies linies
);

