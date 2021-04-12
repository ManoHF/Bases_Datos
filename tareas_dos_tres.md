# Solución a las tareas 2 y 3

## Tarea 2: análisis del *credit scoring* en la BD Sakila

En la primera parte es necesario obtener los promedios de tiempo entre los pagos de cada uno de los clientes. Para contesta eso, se realizó el siguiente query:

```
with pay_lapse as(
	select p.customer_id as id, (p.payment_date - lag(payment_date) over(partition by customer_id)) 
	as time_bt_payments from payment p)
select pl.id, c.last_name, c.first_name, avg(pl.time_bt_payments) as tiempo_promedio from pay_lapse pl 
join customer c on pl.id = c.customer_id where pl.time_bt_payments is not null
group by pl.id, c.last_name, c.first_name 
```

Se obtienen las diferencias restando la fecha del pago actual menos la del anterior con la *window function* lag(); como la primer
resta es null, se eliminan las columnas con null al sacar los promedios por cliente. Esto nos da como resultado:

![tarea2](https://user-images.githubusercontent.com/70402438/114288447-a65d2b00-9a35-11eb-8e35-a46e6f948802.png)

Después pasamos a analizar la distribución de los datos obtenidos. ¿Seguirá una distribución normal? Para responderla hacemos uso de la función histogram vista en clase

```
select * from histogram('(with pay_lapse as(
	select p.customer_id as id, extract(epoch from (p.payment_date - lag(payment_date)over(partition by customer_id)))/86400
	as time_bt_payments from payment p)
select pl.id, c.last_name, c.first_name, avg(pl.time_bt_payments) as tiempo_promedio from pay_lapse pl 
join customer c on pl.id = c.customer_id where pl.time_bt_payments is not null
group by pl.id, c.last_name, c.first_name) as t' , 'tiempo_promedio'); 
```

Para poder utilizar la función extrajimos los segundos usando epoch() y dividimos entre 86400 para obtener los números en días. De ese manera le damos los argumentos correctos
histograma mostrado a continuación:

![tarea2_2](https://user-images.githubusercontent.com/70402438/114289718-a95d1900-9a3f-11eb-9d74-5d2c02a6cadc.png)

A simple vista podemos notar que los datos **no siguen una distribución normal**. Algo que puede complicar las cosas al hacer un análisis estadístico.

Para finalizar pasamos a analizar el promedio de días que pasan entre las distintas rentas de cada uno de nuestros clientes para posteriormente compararlos con los tiempos 
de venta. Seguimos la misma dinámica que en la primera parte, solo que ahora los datos los obtendremos de la tabla rental. Obtenemos el siguiente query con sus respectivos
resultados:

```
with rental_ordered as(
	select r2.customer_id, r2.rental_date from rental r2
	group by r2.customer_id, r2.rental_date order by r2.customer_id)
,rental_lapse as(
	select ro.customer_id as id, (ro.rental_date - lag(ro.rental_date)over(partition by ro.customer_id))
	as time_bt_rentals from rental_ordered ro)
select rl.id, c.last_name, c.first_name, avg(rl.time_bt_rentals) as tiempo_promedio from rental_lapse rl 
join customer c on rl.id = c.customer_id where rl.time_bt_rentals is not null
group by rl.id, c.last_name, c.first_name order by rl.id;
```

![tarea2_3](https://user-images.githubusercontent.com/70402438/114290487-b7ae3380-9a45-11eb-94b9-9a2b857f0d22.png)

```
select * from histogram('(with rental_ordered as(
	select r2.customer_id, r2.rental_date from rental r2
	group by r2.customer_id, r2.rental_date order by r2.customer_id)
,rental_lapse as(
	select ro.customer_id as id, extract( epoch from (ro.rental_date - lag(ro.rental_date)over(partition by ro.customer_id)))/86400
	as time_bt_rentals from rental_ordered ro)
select rl.id, c.last_name, c.first_name, avg(rl.time_bt_rentals) as tiempo_promedio from rental_lapse rl 
join customer c on rl.id = c.customer_id where rl.time_bt_rentals is not null
group by rl.id, c.last_name, c.first_name order by rl.id) as t' , 'tiempo_promedio');
```

![tarea2_4](https://user-images.githubusercontent.com/70402438/114290494-bc72e780-9a45-11eb-80e0-1ae70e884886.png)

A simple vista vemos que son muy parecidos, pero para confirmar haremos una columna con la resta de ambos promedio para ver su diferencia:

```
--resta de promedios
with pay_lapse as(
	select p.customer_id as id, (p.payment_date - lag(payment_date)over(partition by customer_id))
	as time_bt_payments from payment p)
,rental_ordered as(
	select r2.customer_id, r2.rental_date from rental r2
	group by r2.customer_id, r2.rental_date order by r2.customer_id)
,rental_lapse as(
	select ro.customer_id as id, (ro.rental_date - lag(ro.rental_date)over(partition by ro.customer_id))
	as time_bt_rentals from rental_ordered ro)
, avg_times as(
	select rl.id, c.last_name, c.first_name, avg(rl.time_bt_rentals) as tiempo_promedio_rent, 
	avg(pl.time_bt_payments) as tiempo_promedio_pay
	from rental_lapse rl join customer c on rl.id = c.customer_id join pay_lapse pl on pl.id = c.customer_id
	where rl.time_bt_rentals is not null
	group by rl.id, c.last_name, c.first_name order by rl.id)
select ats.id, ats.last_name, ats.first_name, ats.tiempo_promedio_rent - ats.tiempo_promedio_pay as diferencia from avg_times ats;
```
![tarea2_5](https://user-images.githubusercontent.com/70402438/114290779-93ebed00-9a47-11eb-904b-6f87788d279d.png)

Dada las mínimas diferencias obtenida en las tablas, finalmente podemos afirmar que **ambos promedios son muy parecidos**.

## Tarea 3: automatización de películas

Necesitamos determinas las medidas de un cilindro que almacena blu-rays en cajas de 30cm x 21cm x 8cm para un espacio total de 5040 centímetros cúbicos y un peso de 500 gr por película. Sabemos que un clindro 50 kg como máximo y cada tienda tiene un cilindro con mismas dimensiones. Como suposición adicional, decimos que se tiene un número máximo de películas por tienda, por lo que la llegada de algunas copias, puede implicar la salida de otras. De esa forma las tiendas no enfrentan el problema de falta de clindros o de cilindros en desuso.

Primero obtenemos el número de películas por tienda; de ahí vemos dos tiendas con 2,270 y 2,311 películas, por lo que podemos suponer que se tiene un inventario máximo de 2,311 películas agregando 50 como de "colchón" (para estrenos) que tenemos que organizar en algún número de cilindros. Después pasamos a generar las medidas del cilindro para finalmente obtener su volumen.

```
with num_pelis as (
	select i.store_id, count(i.inventory_id) + 50 as inventario from inventory i group by i.store_id)
select np.store_id, ceil(np.inventario::float/100) as num_cilindros from num_pelis np group by np.store_id, np.inventario;
```

1) Se obtiene el número de películas por tienda y se agrega 50 para tener espacio extra para estrenos y tener tiempo de actualizar el catálogo
2) Se divide entre cien que es el número de películas que puede sostener un cílindro. Se usa la función ceil(), ya que cada cilindro tiene que ser completo

```
with medidas as (
	select ((21*5)+50)::float/2 as radio, 0.500*10 as peso_por_nivel, (div(50, 5)*20)+50 as altura)
select (power(m.radio,2)*pi()*m.altura)::text || ' cm3' as volumen_cilindro from medidas m
```

3) Se obtienen las medidas dado que nuestro diseño es de la siguiente manera
4) El radio lo elegimos como la distancia que fuera más grandes (5 películas dado su ancho (21 cm) o 2 películas dado su largo (30 cm)). Además se añade cierto espacio entre cada película para el agarre del brazo
5) Obtenemos el peso por nivel dado que sabemos que cada empaque pesa 500 gr y finalmente sacamos el número de niveles (altura) usando la restricción de 50 kg. Aquí sí podemos usar div(), ya que es una división de enteros que resultará un entrero sin perder datos (la use para practicar); sin embargo, en otra circunstancia convendría usar el símbolo  y un cast nada más para mejor eficiencia.

Con base en esto tenemos nuestro diseño, el número de cilindros en cada store y su volumen:

![IMG_0201](https://user-images.githubusercontent.com/70402438/114438416-5db88580-9b8d-11eb-9dec-2fb423f55bad.JPG) con 24 cilindros necesarios en ambas tiendas, 10 niveles por cilindro y un volumen de 4717.297719 metros cúbicos

