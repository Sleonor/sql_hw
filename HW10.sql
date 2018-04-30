USE sakila; 

-- 1a. Display the first and last names of all actors from the table actor. 
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT CONCAT(first_name, last_name) 
AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor.first_name, actor.last_name, actor.actor_id
FROM actor
WHERE actor.first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor.last_name, actor.first_name
FROM actor
WHERE actor.last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country, c.country_id
FROM country c
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR (40);

SELECT actor_id, first_name, middle_name, last_name, last_update
FROM actor; 

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
MODIFY COLUMN middle_name blob; 

-- 3c. Now delete the middle_name column.
ALTER TABLE actor 
DROP COLUMN middle_name; 

-- 4a. List the last names of actors, as well as how many actors have that last name.    
SELECT last_name,
COUNT(*) AS count
FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,
COUNT(*) AS 'count' FROM actor
GROUP BY last_name 
HAVING  COUNT(last_name) >= 2; 

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husbands yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, 
-- HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE sakila.address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address FROM staff s
INNER JOIN address a
ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
SELECT s.first_name, s.last_name, SUM(p.amount) AS sum_amount FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
WHERE payment_date  >= '2005-11-01'
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS actor_count FROM film f
INNER JOIN film_actor fa
ON fa.film_id = f.film_id
GROUP BY f.film_id;
 
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(i.film_id)
FROM inventory i
WHERE i.film_id IN
(
SELECT film_id
FROM film 
WHERE title = 'HUNCHBACK IMPOSSIBLE'
);

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name: ![Total amount paid](Images/total_payment.png)
SELECT c.first_name, c.last_name,
SUM(p.amount) AS 'payment_amount'
FROM customer c
JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY c.customer_id
ORDER BY last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id = 1;
 
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN 
		(SELECT film_id FROM film_actor
	WHERE film_id =
				(SELECT film_id FROM film
            WHERE title = 'ALONE TRIP'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT  first_name, last_name, email 
FROM customer c 
	 INNER JOIN address a
			ON c.address_id = a.address_id
	INNER JOIN city cy
			ON cy.city_id = a.city_id
	INNER JOIN country co
			ON cy.country_id=co.country_id
WHERE country = 'CANADA';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT title FROM film f
	INNER JOIN film_category fc
		ON f.film_id = fc.film_id
	INNER JOIN category c
		ON fc.category_id= c.category_id
WHERE name='FAMILY';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title FROM film f
	INNER JOIN inventory i
		ON f.film_id=i.film_id
	INNER JOIN rental r
		ON i.inventory_id=r.inventory_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT i.store_id,
SUM(p.amount) AS 'revenue'
FROM inventory i
	INNER JOIN rental r
		ON r.inventory_id= i.inventory_id
	INNER JOIN payment p
		ON r.rental_id=p.rental_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city, country FROM store s
	INNER JOIN address a 
		ON a.address_id = s.address_id
	INNER JOIN city cy 
		ON a.city_id = cy.city_id
	INNER JOIN country co
		ON co.country_id= cy.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS 'Gross Revenue'
FROM category c
    INNER JOIN film_category fc
		ON c.category_id= fc.category_id
	INNER JOIN inventory i
		ON i.film_id = fc.film_id
	INNER JOIN rental r
		ON r.inventory_id = i.inventory_id
	INNER JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
	-- If you havent solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT c.name, SUM(p.amount) AS 'Gross Revenue'
FROM category c
    INNER JOIN film_category fc
		ON c.category_id= fc.category_id
	INNER JOIN inventory i
		ON i.film_id = fc.film_id
	INNER JOIN rental r
		ON r.inventory_id = i.inventory_id
	INNER JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW top_five_genres;