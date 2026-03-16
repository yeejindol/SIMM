CREATE TYPE ADRECA AS OBJECT (
carrer VARCHAR(50),
ciutat VARCHAR(10),
codi_postal NUMBER
);

CREATE TYPE TELEFON AS OBJECT (
tipus VRACHAR(20),
numero VARCHAR(15)
);

CREATE TYPE VEC_TELEFONS AS VARRAY(2) OF TELEFON;

CREATE TYPE PROVEIDOR AS OBJECT (
codi NUMBER,
nom VARCHAR2(50),
adreca ADRECA,
vec_telefons VEC_TELEFONS,
correu_electronic VARCHAR(50)
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

CREATE TABLE Materiales OF MATERIAL(PRIMARY KEY(codi));
CREATE TABLE Proveidores OF PROVEIDOR(PRIMARY KEY(codi));
CREATE TABLE Compras OF COMPRA(PRIMARY KEY(codi));

-- Task 3: Inserció de dades

INSERT INTO Materiales VALUES (MATERIAL(1, 'Cargol', 'Cargol de ferro 5mm', 0.50));
INSERT INTO Materiales VALUES (MATERIAL(2, 'Martell', 'Martell de fuster', 15.00));


INSERT INTO Proveidores VALUES (
    PROVEIDOR(100, 'Ferreteria Central', 
    ADRECA(08001, 'Carrer Major 10', 'BCN'),
    VEC_TELEFONS(TELEFON('Fix', '933445566'), TELEFON('Mobil', '600112233')),
    'info@ferreteria.com')
);


INSERT INTO Compras VALUES (
    COMPRA(5001, 20260311, 
    (SELECT REF(p) FROM Proveidores p WHERE codi = 100),
    linies(
        LINIA_COMPRA(1, (SELECT REF(m) FROM Materiales m WHERE codi = 1), 100, 5), -- 100 units, 5€ discount
        LINIA_COMPRA(2, (SELECT REF(m) FROM Materiales m WHERE codi = 2), 2, 0)    -- 2 units, 0 discount
    ))
);

-- Task 4: Cridar als mètodes a través d'una consulta

SELECT c.codi, c.cost_total() AS total_factura
FROM Compras c;


SELECT c.codi AS compra_id, l.codi AS linia_id, l.subtotal() AS subtotal_linia
FROM Compras c, TABLE(c.taula_linies) l;




