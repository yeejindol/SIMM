CREATE TYPE producto_v2 AS OBJECT (
    id_producto NUMBER,
    nombre VARCHAR2(100),
    precio NUMBER(10,2)
);
/

CREATE TABLE productos_v2 OF producto_v2 (
    id_producto PRIMARY KEY
);
/


INSERT INTO productos_v2 VALUES (producto_v2(1, 'ordenador', 820.00));
INSERT INTO productos_v2 VALUES (producto_v2(2, 'movil', 999.00));
/

COMMIT;