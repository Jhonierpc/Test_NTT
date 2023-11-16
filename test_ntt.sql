/*
Preguntas teóricas:

1.  ¿Qué es PL/SQL y cuál es su propósito en el desarrollo de aplicaciones?
    Respuesta:  PL/SQL es un lenguaje de programación con el que se puede trabajar con bases de datos relacionales, usan un motor de bases de datos
                de Oracle.
                Su proposito, es realizar desarrollos de procedimientos almacenados, funciones, triggers y consultas optimizadas.

2.  Explique la diferencia entre un procedimiento almacenado y una función en PL/SQL.
    Respuesta:  Los procedimientos almacenados pueden aceptar diferentes tipos de parámetros tanto de entrada como de salida y no necesariamente
                devuelven valores, en cambio las funciones si retornan un valor el cual se puede usar en una consulta posteriormente.

3.  ¿Qué es una excepción en PL/SQL y cómo se manejan?
    Respuesta:  Las execpciones son manejadores de errores que permiten poder validar el correcto funcionamiento en las transacciones principalmente,
                Se pueden condicionar estás excepciones para determinar como activar la exception, se manejan dentro de bloques con 'BEGIN' y 'END'.
*/

/*
Ejercicios Prácticos:

4.  Creación de una Tabla: Cree una tabla llamada Empleados con los siguientes campos:
    • ID(Número de Empleado, Clave Primaria)
    • Nombre(Nombre del Empleado, máximo 50 caracteres)
    • Puesto(Puesto del Empleado, máximo 50 caracteres)
    • Salario(Salario del Empleado, tipo de datos NÚMERO)
    Respuesta:
*/
BEGIN
    EXECUTE IMMEDIATE ('drop table Empleados cascade constraints');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE Empleados (
    ID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Puesto VARCHAR2(50),
    Salario NUMBER
);
/

/*
5.  Procedimiento Almacenado: Cree un procedimiento almacenado llamado AumentarSalario que
    tome dos parámetros de entrada: el ID del empleado y el PorcentajeAumento. Este procedimiento
    debe aumentar el salario del empleado en el porcentaje dado. Asegúrese de manejar posibles
    errores, como si el empleado no existe.
    Respuesta:
*/
CREATE OR REPLACE PROCEDURE AumentarSalario (
    p_id NUMBER,
    p_porcentaje_aumento NUMBER
)
AS
    v_salario_actual NUMBER;
BEGIN
    -- Primero consultamos y obtenermos el salario actual del empleado
    select  Salario
    into    Empleados
    where   ID = p_id;

    -- Validamos que el empleados exista en la tabla
    if v_salario_actual is null then
        DBMS_OUTPUT.PUT_LINE('No existe el empleado con ID: ' || p_id):
        return;
    end if;

    -- Actualizamos el salario en la variable local
    v_salario_actual := v_salario_actual + (1 + p_porcentaje_aumento / 100);

    -- Actualizamos el salario del empleado en la tabla
    update Empleados
    set Salario = v_salario_actual
    where ID = p_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe el empleado con ID: ' || p_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error.');
END AumentarSalario;
/

/*
6.  Función: Cree una función llamada CalcularBonificacion que tome el Salario del empleado como
    entrada y devuelva el monto de asignación. La aplicación se calcula de la siguiente manera:
    • Si el salario es menor o igual a 30000, la compensación es el 20% del salario.
    • Si el salario es mayor a 30000 pero menor o igual a 50000, la asignación es el 15% del salario.
    • Si el salario es mayor a 50000, la compensación es el 10% del salario.
    Respuesta:
*/
CREATE OR REPLACE FUNCTION CalcularBonificacion(
    p_Salario NUMBER
) RETURN NUMBER AS
    v_Bonificacion NUMBER;
BEGIN
    -- Caculamos la bonificación
    IF p_Salario <= 30000 THEN
        v_Bonificacion := p_Salario * 0.20;
    ELSIF p_Salario <= 50000 THEN
        v_Bonificacion := p_Salario * 0.15;
    ELSE
        v_Bonificacion := p_Salario * 0.10;
    END IF;

    -- Devolvemos el valor de la bonificación
    RETURN v_Bonificacion;
END CalcularBonificacion;
/

/*
7.  Triggers: Crea un disparador (trigger) que se activa antes de insertar un nuevo empleado en la
    tabla empleados. El disparador debe generar automáticamente el ID del empleado utilizando una
    secuencia.
    Respuesta:
*/
-- Primero creamos una secuencia para generar automáticamente el ID del empleado
CREATE SEQUENCE seq_empleados
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;
/

-- Creamos el trigger
CREATE OR REPLACE TRIGGER antes_de_insertar_empleado
BEFORE INSERT ON Empleados
FOR EACH ROW
BEGIN
    -- Se asigna el próximo valor de la secuencia al nuevo ID del empleado
    :NEW.ID := seq_empleados.NEXTVAL;
END antes_de_insertar_empleado;
/

/*
8.  Cursores y Colecciones: Escribe una función llamada obtener_ventas_empleado que acepte un
    parámetro de entrada: el ID de un empleado. Utilice un cursor para recorrer la tabla ventas. Esta
    tabla tendrá los siguientes campos:
    • ID_Venta (Número Consecutivo, Clave Primaria)
    • ID_Empleado (Número de Empleado, Llave Foránea)
    • Descripción_Venta(Descripción de la venta, máximo 200 caracteres)
    • Valor_Venta (Valor de la vena, tipo de datos NÚMERO)
    En dicha tabla, obtener todas las ventas realizadas por ese empleado. Devuelve los resultados como
    una colección de registros que contienen el ID de venta y el monto de la venta.
    Respuesta:
*/
BEGIN
    EXECUTE IMMEDIATE ('drop table Ventas cascade constraints');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Creamos la tabla Ventas
CREATE TABLE Ventas (
    ID_Venta NUMBER PRIMARY KEY,
    ID_Empleado NUMBER,
    Descripcion_Venta VARCHAR2(200),
    Valor_Venta NUMBER,
    FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID)
);
/

-- Creamos un tipo de registro para almacenar los resultados
CREATE OR REPLACE TYPE venta_registro AS OBJECT (
    ID_Venta NUMBER,
    Valor_Venta NUMBER
);

-- Creamos un tipo de tabla de registros
CREATE OR REPLACE TYPE venta_tabla AS TABLE OF venta_registro;

-- Crear la función
CREATE OR REPLACE FUNCTION obtener_ventas_empleado(p_ID_Empleado NUMBER)
    RETURN venta_tabla
    PIPELINED
AS
  -- Declarar el cursor
    CURSOR cur_ventas IS
        SELECT v.ID_Venta, v.Valor_Venta
        FROM Ventas v
        WHERE v.ID_Empleado = p_ID_Empleado;

  -- Declarar una variable del tipo de registro
  v_venta venta_registro;

BEGIN
  -- Recorrer el cursor y devolver los resultados como una colección
    FOR r_venta IN cur_ventas LOOP
        v_venta := venta_registro(r_venta.ID_Venta, r_venta.Valor_Venta);
        PIPE ROW(v_venta);
    END LOOP;

  -- Cerrar el cursor
  CLOSE cur_ventas;

  -- Terminar la función
  RETURN;
END obtener_ventas_empleado;
/

/*
9.  Consultas SQL: Escriba consultas SQL para:
    • Seleccione todos los empleados cuyos salarios estén entre 40000 y 60000.
    Respuesta:
*/
SELECT  *
FROM    Empleados
WHERE   Salario BETWEEN 40000 AND 60000;
/

/*
    • Obtener el salario promedio de todos los empleados.
    Respuesta:
*/
SELECT  AVG(Salario) AS SalarioPromedio
FROM    Empleados;
/

/*
    • Contar cuántos empleados tienen un salario superior a 70000.
    Respuesta:
*/
SELECT  COUNT(*) AS EmpleadosConSalarioSuperior
FROM    Empleados
WHERE   Salario > 70000;
/

