--Tarea 1
--Manuel Hermida

--Cómo obtenemos todos los nombres y correos de nuestros clientes canadienses para una campaña?
select  c.last_name, c.first_name, c.email, c3.country from customer c 
join address a using (address_id) join city c2 on a.city_id = c2.city_id join country c3 on c2.country_id = c3.country_id 
where c3.country = 'Canada';

--Qué cliente ha rentado más de nuestra sección de adultos?
--Se considero la sección de adultos como las películas con Rating NC-167
select c2.last_name, c2.first_name, r.customer_id, count(r.customer_id) from rental r 
join inventory i using(inventory_id) join film f2 using (film_id) join customer c2 on c2.customer_id = r.customer_id 
where f2.rating = 'NC-17'
group by r.customer_id, c2.first_name, c2.last_name order by count(r.customer_id) desc limit 1;

--Qué películas son las más rentadas en todas nuestras stores?
select f2.title, count(r.inventory_id), i2.store_id from rental r 
join inventory i2 using (inventory_id) join film f2 using (film_id)
group by grouping sets ((f2.title), (i2.store_id))
order by count(r.inventory_id) desc;

--Cuál es nuestro revenue por store? 
--Se considero revenue como la suma total de todas las rentas por store
select s2.store_id, a2.address , sum(p.amount) from rental r 
join payment p using (rental_id) join inventory i2 using (inventory_id) join store s2 using (store_id)
join address a2 using (address_id)
group by s2.store_id, a2.address;