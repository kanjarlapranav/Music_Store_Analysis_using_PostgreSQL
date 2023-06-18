                                    /* SQL_Music_Store_Analysis */

/* Q1: Who is the senior most employee based on job title? */

Select first_name, last_name
From employee
Order by levels Desc
Limit 1

/* Q2: Which countries have the most Invoices? */

Select count(*) as count, billing_country
From invoice
Group by billing_country 
Order by count Desc

/* Q3: What are top 3 values of total invoice? */
Select total 
From invoice
Order by total Desc
Limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

Select Sum(total) as net, billing_city
From invoice
Group by billing_city
Order by net Desc
Limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */

Select customer.customer_id, customer.first_name, customer.last_name, Sum(invoice.total) as total
From customer
Join invoice on customer.customer_id = invoice.customer_id
Group by customer.customer_id
Order by total Desc
Limit 1

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

Select Distinct customer.email, customer.first_name, customer.last_name
From customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
Join track on invoice_line.track_id = track.track_id
Join genre on track.genre_id = genre.genre_id
Where genre.name Like 'Rock'
Order by email Asc

/* Q7: Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

Select artist.name, count(track.track_id) as total
From artist
Join album on artist.artist_id = album.artist_id
Join track on album.album_id = track.album_id
Join genre on track.genre_id = genre.genre_id
Where genre.name Like 'Rock'
Group by artist.artist_id
Order by total Desc
Limit 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

Select name, Milliseconds
From track
Where Milliseconds > (
	Select Avg(Milliseconds) as average
	From track
	)
Order by Milliseconds Desc;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

WITH best_selling_artist AS 
(
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q11: Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */

WITH Customer_with_country as 
(
	Select customer.customer_id, first_name, last_name, billing_country, SUM(total) as total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	From invoice
	Join customer on invoice.customer_id = customer.customer_id 
	Group by 1, 2, 3, 4
	Order by 4 Asc, 5 Desc 
)
Select * From customer_with_country Where RowNo <= 1

/* by Kanjarla Pranav */
