# Tarea 4: window functions

Debemos calcular para cada cliente su promedio mensual de deltas en los pagos de sus órdenes en la tabla order_details en la BD de Northwind, es decir,
la diferencia entre el monto total de una orden en tiempo t y el anterior en t-1, para tener la foto completa sobre el customer lifetime value de cada miembro de nuestra cartera.

El problema se resolvió utilizando el siguiente query:

```
with pagos as (
	select o2.customer_id as customer, o2.order_date as fecha, sum(od.quantity*od.unit_price) as total_pedido,
	lag(sum(od.quantity*od.unit_price), 1) over(w) as pedido_anterior,
	sum(od.quantity*od.unit_price) - lag(sum(od.quantity*od.unit_price), 1) over(w) as delta
	from order_details od join orders o2 using (order_id)
	group by o2.customer_id, o2.order_date 
	window w as (partition by o2.customer_id order by o2.order_date))
select p.customer, extract(year from p.fecha) as year, extract(month from p.fecha) as month, avg(p.delta) as delta_average from pagos p 
group by p.customer, extract(year from p.fecha), extract(month from p.fecha) 
order by p.customer asc, extract(year from p.fecha), extract(month from p.fecha);
```
Consideraciones extras:
* Existen valores nulls que representan la columna con el primer pedido de cada cliente, ya que todavía no se tiene registro de un pedido anterior. 
* Se tuvo que agrupar por año antes para no promediar pedidos del mismo mes, pero diferente año

El resultado obtenido del query es:

![tarea4](https://user-images.githubusercontent.com/70402438/114810956-c4e35f00-9d72-11eb-8120-bc192ba4928a.png)
