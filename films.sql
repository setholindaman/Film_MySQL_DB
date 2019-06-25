use sakila;

-- Display the first and last names of all actors from the table actor.
select last_name, first_name from actor;

-- Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
alter table actor
add column actor_name varchar(50) not null;

update actor 
set actor_name = concat(first_name," ", last_name);

select * from actor;

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name 
from actor 
where first_name = "Joe";

-- Find all actors whose last name contain the letters GEN:
select actor_name 
from actor 
where last_name 
like'%GEN%';

-- Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name
from actor
where last_name
like'%LI%';

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country 
where country in ('Afghanistan', 'Bangladesh', 'China')
order by country_id;

-- You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add column description blob;

-- select * from actor;

-- Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description; 

-- List the last names of actors, as well as how many actors have that last name.
-- List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) as count
FROM actor
group by last_name
having count > 1
order by count desc;

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record
update actor 
set first_name = 'Harpo' 
where first_name = 'Groucho';

update actor
set actor_name = 'Harpo Williams'
where actor_name = 'Groucho Williams';

select actor_name from actor
where last_name = 'Williams';

-- Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
update actor 
set first_name = 'Groucho' 
where first_name = 'Harpo';

update actor
set actor_name = 'Groucho Williams'
where actor_name = 'Harpo Williams';

-- You cannot locate the schema of the address table. Which query would you use to re-create it?
show create table address;
select * from address;

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff ON
staff.staff_id=address.address_id;

-- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, sum(payment.amount) "total amount"
FROM payment
INNER JOIN staff ON
staff.staff_id=payment.staff_id
WHERE MONTH(payment.payment_date) = 08 AND YEAR(payment.payment_date) = 2005
group by staff.staff_id;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, count(film_actor.actor_id) "Number of actors"
FROM film
INNER JOIN film_actor ON
film.film_id=film_actor.film_id
group by film.film_id;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, count(inventory.last_update) "Copies"
FROM film
INNER JOIN inventory ON
film.film_id=inventory.film_id
where film.title = 'Hunchback Impossible';

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name
SELECT customer.customer_id,customer.first_name, customer.last_name, sum(payment.amount) "total payment"
FROM customer
INNER JOIN payment ON
customer.customer_id=payment.customer_id
group by customer_id
order by last_name asc;

-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film 
where title
like 'K%' or 'Q%'
and language_id IN
  (
   SELECT language_id
   FROM language
   WHERE name = 'English'
  );
;

-- Use subqueries to display all actors who appear in the film Alone Trip
select actor.first_name, actor.last_name "Actor"
from actor, film, film_actor
where film.title = 'Alone Trip' and film.film_id = film_actor.film_id and film_actor.actor_id = actor.actor_id
group by actor.actor_id; 

-- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT customer.email, country.country
FROM customer
JOIN address ON
customer.address_id=address.address_id
join city on
city.city_id = address.city_id
JOIN country ON
country.country_id = city.country_id
where country.country = 'canada';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select film.title, category.name
from film
join film_category
on film.film_id = film_category.film_id
join category
on category.category_id = film_category.category_id
where category.name = 'family';

-- Display the most frequently rented movies in descending order.
select title, rental_duration from film
order by rental_duration desc;

-- Write a query to display how much business, in dollars, each store brought in.
select store.store_id "Store", sum(payment.amount) as "Amount of Business"
from store
join staff
on store.store_id = staff.store_id
join payment
on payment.staff_id = staff.staff_id
join rental
on rental.rental_id = payment.rental_id
group by store.store_id;


-- Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
join address
on store.address_id = address.address_id
join city
on address.city_id = city.city_id
join country
on city.country_id = country.country_id;

-- List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount) as 'Gross Revenue'
from category
join film_category
on category.category_id = film_category.category_id
join inventory
on inventory.film_id = film_category.film_id
join rental
on rental.inventory_id = inventory.inventory_id
join payment
on payment.rental_id = rental.rental_id
group by category.name
order by 'Gross Revenue' desc
limit 5;

-- In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five_genres as 
select category.name as 'Genre', sum(payment.amount) as 'Gross Revenue'
from payment
inner join rental
on payment.rental_id = rental.rental_id
inner join inventory
on rental.inventory_id = inventory.inventory_id
inner join film_category
on inventory.film_id = film_category.film_id
inner join category
on film_category.category_id = category.category_id
group by category.name
order by sum(payment.amount) desc
limit 5;

-- How would you display the view that you created in 8a?
select * from top_five_genres;

-- You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view if exists
	top_five_genres;