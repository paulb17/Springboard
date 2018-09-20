/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT f.name
FROM country_club.Facilities f
WHERE f.membercost >0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(  f.name ) 
FROM  country_club.Facilities f 
WHERE  f.membercost >0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT  f.facid,  f.name,  f.membercost,  f.monthlymaintenance 
FROM  country_club.Facilities f
WHERE  f.membercost < 0.2 *  f.monthlymaintenance;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM  country_club.Facilities f
WHERE  f.facid 
IN ( 1, 5 ); 


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT  f.name,  f.monthlymaintenance, 
CASE WHEN  f.monthlymaintenance >100
THEN  'cheap'
ELSE  'expensive'
END  AS Label
FROM  Facilities f;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT  m.firstname ,  m.surname 
FROM  Members m;

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT f.name 'Facility Name', CONCAT( m.firstname, ' ', m.surname )  'Member'
FROM country_club.Members m
INNER JOIN country_club.Bookings b ON m.memid = b.memid
INNER JOIN country_club.Facilities f ON b.facid = f.facid
WHERE f.name LIKE  "%Tennis Court%"
GROUP BY Member;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name 'Facilities', surname 'Member', f.guestcost * b.slots 'Cost'
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
JOIN country_club.Members m ON m.memid = b.memid
WHERE m.memid =0
AND b.starttime LIKE  "%2012-09-14%"
UNION 
SELECT f.name 'Facilities', CONCAT( m.firstname,  ' ', m.surname )  'Member', SUM( f.membercost * b.slots )  'Cost'
FROM country_club.Bookings b
INNER JOIN country_club.Facilities f ON b.facid = f.facid
INNER JOIN country_club.Members m ON m.memid = b.memid
WHERE m.memid !=0
AND b.starttime LIKE  "%2012-09-14%"
GROUP BY m.memid
HAVING cost >30
ORDER BY cost DESC; 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT g.name 'Facilities', surname 'Member', g.cost 'Cost'
FROM country_club.Members m
INNER JOIN (

SELECT b.memid, f.name, slots * guestcost 'cost'
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
WHERE b.starttime LIKE  "%2012-09-14%"
AND memid =0
)g ON m.memid = g.memid
WHERE cost >30
UNION 
SELECT me.name 'Facilities', CONCAT( m.firstname,  ' ', m.surname )  'Member', me.cost 'Cost'
FROM country_club.Members m
JOIN (

SELECT b.memid, f.name, SUM( f.membercost * b.slots )  'cost'
FROM country_club.Bookings b
JOIN country_club.Facilities f ON b.facid = f.facid
JOIN country_club.Members m ON m.memid = b.memid
WHERE b.starttime LIKE  "%2012-09-14%"
AND m.memid !=0
GROUP BY m.memid
)me ON m.memid = me.memid
WHERE cost >30
ORDER BY cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT f.name, SUM( 
CASE WHEN b.memid =0
THEN f.guestcost * b.slots
ELSE f.membercost * b.slots
END ) AS revenue
FROM country_club.Facilities f
JOIN country_club.Bookings b ON f.facid = b.facid
GROUP BY f.name
HAVING revenue <1000
ORDER BY revenue DESC 
LIMIT 0 , 30
