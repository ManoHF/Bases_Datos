--Se crea la base de datos y se empieza a usar
create database proyecto_final;
use proyecto_final;

--Creación de tabla preeliminar hospital: sujeta a cambios
create table hospital(
	id_hospital int primary key,
	latitud float(20),
	longitud float(20),
	altitud float(20),
	nombre varchar(200),
	distrito varchar(200),
	provincia varchar(200),
	pais varchar(200)
);

--Tabla de teléfonos, ya que se puede tener varios
create table telefono(
id_telefono int primary key,
id_hospital int references hospital,
lada numeric(3),
numero numeric(10)
);

--Inserción de datos para probar la conexión con la Web Application
insert into hospital values (1, 9.801, 50.111, 2130, 'Hospital Angeles', 'Ciudad de Mexico', 'Miguel Hidalgo', 'Mexico');
insert into hospital values (2, 9.801, 50.111, 2130, 'Hospital Medica Sur', 'Ciudad de Mexico', 'Tlalpan', 'Mexico');