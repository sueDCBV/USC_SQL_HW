-- Homework Assignment
-- Code by Sue Del Carpio Bellido Vargas

-- 1a. Display the first and last names of all actors from the table actor.
use sakila;
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
select UPPER(CONCAT(first_name," ",last_name)) AS actor_name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id,first_name,last_name from actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
select actor_id,last_name, first_name from actor
where last_name like "%LI%"
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country in ("Afghanistan","Bangladesh","China");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name varchar(50) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the middle_name column to blobs.	
ALTER TABLE actor MODIFY middle_name blob;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor 
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(*) as actor_same_last_name
from actor
group by last_name
order by 2 desc;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

-- Temporary table to store actors who shared their first_name at least twice
CREATE TEMPORARY TABLE temp_actor_first_name (select first_name,count(*) from actor group by first_name having count(*) >1);

select last_name, count(*) as actor_same_last_name
from actor
where first_name in (select first_name from temp_actor_first_name)
group by last_name
order by 2 desc;

-- Delete temporary table because I don't need anymore.
drop table temp_actor_first_name;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

-- Find actor to update
select * from actor
where first_name ="GROUCHO" and last_name = "WILLIAMS";

-- actor_id to update = 172
update actor
set first_name = "HARPO"
where actor_id=172;

-- Verify changes
select * from actor
where first_name ="HARPO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
-- (Hint: update the record using a unique identifier.)

-- Find actor to update
select * from actor
where first_name ="HARPO" and last_name = "WILLIAMS";

-- actor_id to update = 172
update actor
set first_name = "GROUCHO"
where actor_id=172;

-- Verify changes
select * from actor
where first_name ="GROUCHO" and last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address, a.address2
from staff s
left outer join address a on (s.address_id = a.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
select s.first_name, s.last_name, sum(p.amount) as total_amount_082005
from staff s
left outer join payment p on (s.staff_id = p.staff_id)
where year(p.payment_date) = 2005
and month(p.payment_date) = 8
group by s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.film_id,f.title,count(fa.actor_id) as num_actors
from film f
inner join film_actor fa on (f.film_id=fa.film_id)
group by f.film_id,f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(inventory_id) as num_copies_Hunchback_Impossible
from inventory
where film_id = (select film_id from film where title = "Hunchback Impossible");

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)

select c.last_name, c.first_name, sum(p.amount) as total_amount_customer
from customer c
left outer join payment p on (c.customer_id = p.customer_id)
group by c.last_name, c.first_name
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 
select film_id,title
from film
where title like ("K%") or title like ("Q%")
and language_id = (select  language_id from language where name="English");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select fa.actor_id,a.first_name, a.last_name
from film_actor fa
left join actor a on (fa.actor_id=a.actor_id)
where film_id = (select film_id from film where title = "Alone Trip");

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cu.first_name,cu.last_name,cu.email 
from customer cu
left join address ad on (cu.address_id = ad.address_id)
left join city ci on (ad.city_id = ci.city_id)
where ci.country_id = (select country_id from country where country="Canada");

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select f.film_id,f.title
from film f
left join film_category fa on (f.film_id=fa.film_id)
where fa.category_id = (select category_id from category where name = "Family");

-- 7e. Display the most frequently rented movies in descending order.
select fi.title,count(re.rental_id) num_rental
from rental re
left join inventory iv on (re.inventory_id=iv.inventory_id)
left join film fi on (iv.film_id=fi.film_id)
group by fi.title
order by 2 desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select st.store_id, ad.address, sum(py.amount) payment_store
from payment py 
inner join rental re on (py.rental_id=re.rental_id)
inner join inventory iv on (re.inventory_id=iv.inventory_id)
inner join store st on (iv.store_id=st.store_id)
inner join address ad on (st.address_id=ad.address_id)
group by st.store_id, ad.address;

-- 7g. Write a query to display for each store its store ID, city, and country.
select st.store_id,ci.city,co.country 
from store st 
inner join address ad on (st.address_id=ad.address_id)
inner join city ci on (ad.city_id=ci.city_id)
inner join country co on (ci.country_id=co.country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select ca.name,sum(py.amount) category_revenue
from payment py 
inner join rental re on (py.rental_id=re.rental_id)
inner join inventory iv on (re.inventory_id=iv.inventory_id)
inner join film_category fc on (iv.film_id = fc.film_id)
inner join category ca on (fc.category_id = ca.category_id)
group by ca.name
order by 2 desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top5_genres_view AS 
select ca.name,sum(py.amount) category_revenue
from payment py 
inner join rental re on (py.rental_id=re.rental_id)
inner join inventory iv on (re.inventory_id=iv.inventory_id)
inner join film_category fc on (iv.film_id = fc.film_id)
inner join category ca on (fc.category_id = ca.category_id)
group by ca.name
order by 2 desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top5_genres_view;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top5_genres_view;
