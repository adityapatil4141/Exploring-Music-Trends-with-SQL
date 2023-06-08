-- MUSIC DATASET --


--1. Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1

--2. Which countries have the most Invoices?
select sum(total) as total_count, billing_country from invoice
group by billing_country
order by sum(total) desc

--3. What are top 3 values of total invoice?
select distinct total from invoice
order by total desc
limit 3

--4. Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all invoice totals

select billing_city, sum(total) as total_invoice from invoice
group by billing_city
order by sum(total) desc
limit 1


-- 5. Who is the best customer? 
-- The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money


select c.customer_id , c.first_name ,c.last_name, sum(total) as total_spent from invoice i
inner join customer c on c.customer_id = i.customer_id
group by c.customer_id
order by sum(total) desc
limit 1

-- 6.Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

select distinct g.genre_id ,c.email, c.first_name , c.last_name from customer c
inner join invoice i on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track t on t.track_id = il.track_id 
inner join genre g on t.genre_id = g.genre_id
where g.name LIKE 'Rock' 
group by g.genre_id, c.email, c.first_name , c.last_name
order by c.email 
 
 
------------------------ OR ------------
select distinct email , first_name , last_name from customer c
inner join invoice i on i.customer_id = c.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
where track_id in(
select track_id from track t
inner join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
)
order by email 


-- 7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select ar.artist_id , ar.name , count(ar.artist_id) as no_of_songs from artist ar
inner join album al on al.artist_id = ar.artist_id
inner join track tr on tr.album_id = al.album_id
inner join genre g on g.genre_id = tr.genre_id
where g.name like 'Rock'
group by ar.artist_id
order by no_of_songs desc 
limit 10




-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first
 
select name , milliseconds from track
where milliseconds > (
	select avg(milliseconds) as average_time from track) 
order by milliseconds desc


--9. Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent
WITH best_selling_artist AS (
	select ar.artist_id as artist_id ,ar.name as artist_name , sum(il.unit_price * il.quantity)
	as total_sales 
	from invoice_line il
	inner join track tr on tr.track_id = il.track_id
	inner join album al on al.album_id = tr.album_id
	inner join artist ar on ar.artist_id = al.artist_id
	group by 1
	order by 3 desc
	LIMIT 1)
      


select c.customer_id , c.first_name ,c.last_name ,bsa.artist_name,
sum(il.unit_price * il.quantity) as total_sales from invoice i
inner join customer c on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track tr on tr.track_id = il.track_id
inner join album al on al.album_id = tr.album_id
inner join best_selling_artist  bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc

-- 10. We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres

with most_popular_genre as (
	select  count(il.quantity) as purchase , c.country ,g.name, g.genre_id ,
	row_number() over(partition by c.country order by count(il.quantity )desc )as ROW_NO
	from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track tr on tr.track_id = il.track_id 
	join genre g on g.genre_id = tr.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select *from most_popular_genre where row_no =1


--11.  Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared,
-- provide all customers who spent this amount

with recursive customer_with_country as (
	select c.customer_id , c.first_name , c.last_name, i.billing_country, sum(i.total) as total_spending
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 1,5 desc
),

country_max_spending as (
	select billing_country , max(total_spending) as max_spending
	from customer_with_country
	group by billing_country
	
	)

select cc.billing_country , cc.total_spending, cc.first_name , cc.last_name
from customer_with_country cc
join country_max_spending cm on cm.billing_country = cc.billing_country
where cc.total_spending = cm.max_spending
order by 1


--======================--======================--======================--======================--======================--======================--======================--







