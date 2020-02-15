/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:



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

SELECT *
FROM Facilities
WHERE membercost = 0.0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( * )
FROM Facilities
WHERE membercost = 0.0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, 
	name, 
	membercost,
	monthlymaintenance
FROM Facilities
WHERE membercost < (monthlymaintenance * 0.2) AND membercost != 0.0


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
	monthlymaintenance,
	CASE WHEN monthlymaintenance < 100 THEN 'cheap' ELSE 'expensive' END AS cost
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, 
	surname, 
	joindate
FROM `Members`
ORDER BY joindate DESC


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT b.memid,
	CONCAT(m.surname, ', ', m.firstname) AS fullname,
	f.facid,
	f.name
FROM Bookings b
JOIN Members m ON m.memid = b.memid
JOIN Facilities f ON f.facid = b.facid
WHERE f.facid = 1 OR f.facid = 0
ORDER BY fullname 


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT CONCAT(m.surname, ', ', m.firstname) AS fullname, f.name AS facname,
	CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost) ELSE (b.slots * f.membercost) END AS bookingcost
FROM Bookings b
JOIN Facilities f ON f.facid = b.facid
JOIN Members m ON m.memid = b.memid
WHERE b.starttime > "2012-09-14 00:00:00" 
	AND b.starttime < "2012-09-15 00:00:00" 
	AND 1 = CASE 
		WHEN b.memid = 0 THEN (b.slots * f.guestcost) > 30.0
		WHEN b.memid > 0 THEN (b.slots * f.membercost) > 30.0 
		ELSE 0
		END
ORDER BY bookingcost DESC



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT x.fullname, x.facname, x.bookingcost
FROM (SELECT CONCAT(m.surname, ', ', m.firstname) AS fullname, 
	f.name AS facname, 
    b.starttime,
	CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost) ELSE (b.slots * f.membercost) END AS bookingcost
	FROM Bookings b
	JOIN Facilities f ON f.facid = b.facid
	JOIN Members m ON m.memid = b.memid) AS x
WHERE x.starttime > "2012-09-14 00:00:00" 
	AND x.starttime < "2012-09-15 00:00:00" 
	AND bookingcost > 30.0
ORDER BY bookingcost DESC



/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT x.facname, 
	x.totalbookingcost - x.maintenanceTwoMonths AS revenue
FROM (SELECT f.name AS facname, 
    f.monthlymaintenance * 2 AS maintenanceTwoMonths,
	SUM(CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost) ELSE (b.slots * f.membercost) END) AS totalbookingcost
	FROM Bookings b
	JOIN Facilities f ON f.facid = b.facid
	JOIN Members m ON m.memid = b.memid
    GROUP BY f.name) AS x
WHERE 1 = CASE 
		WHEN x.totalbookingcost - x.maintenanceTwoMonths < 1000 THEN 1
		ELSE 0
		END
ORDER BY facname