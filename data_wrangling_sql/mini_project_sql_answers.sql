/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name, 
       membercost 
FROM   country_club.facilities 
WHERE  membercost != 0; 

/* Tennis Court 1	5
Tennis Court 2	5
Massage Room 1	9.9
Massage Room 2	9.9
Squash Court	3.5 */

/* Q2: How many facilities do not charge a fee to members? */
SELECT Count(*) 
FROM   country_club.facilities 
WHERE  membercost = 0; 
--4

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, 
       name, 
       membercost, 
       monthlymaintenance 
FROM   country_club.facilities 
WHERE  membercost != 0 
       AND membercost < ( 20 * monthlymaintenance ) / 100; 
       
/* 0	Tennis Court 1	5	200
1	Tennis Court 2	5	200
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80 */

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM   country_club.facilities 
WHERE  facid IN ( 1, 5 ); 
/*1	Tennis Court 2	5	25	8000	200
5	Massage Room 2	9.9	80	4000	3000 */

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, 
       monthlymaintenance, 
       CASE 
         WHEN monthlymaintenance > 100 THEN 'expensive' 
         ELSE 'cheap' 
       END AS monthly_cost 
FROM   country_club.facilities; 
/*
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap
*/


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, 
       surname 
FROM   country_club.members 
WHERE  memid = (SELECT Max(memid) 
                FROM   country_club.members);
 

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

-- Using JOINS
SELECT DISTINCT f.name, 
                Concat(m.firstname, m.surname) AS Member_Name 
FROM   country_club.bookings b 
       join country_club.facilities f 
         ON b.facid = f.facid 
            AND f.name LIKE '%Tennis Court%' 
       join country_club.members m 
         ON b.memid = m.memid 
ORDER  BY member_name; 

-- Using Sub-Queries
SELECT DISTINCT f.name                         AS Court_Name, 
                Concat(m.firstname, m.surname) AS Member_Name 
FROM   (SELECT name, 
               facid 
        FROM   country_club.facilities 
        WHERE  name LIKE '%Tennis Court%') f, 
       country_club.bookings b, 
       country_club.members m 
WHERE  b.facid = f.facid 
       AND b.memid = m.memid 
ORDER  BY member_name; 

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name as Facility_Name, 
       concat(m.firstname, m.surname) as Member_Name, 
       SUM(CASE 
             WHEN m.firstname = 'GUEST' THEN ( b.slots * 2 * f.guestcost ) 
             ELSE ( b.slots * 2 * f.membercost ) 
           END) AS Cost 
FROM   country_club.bookings b 
       join country_club.facilities f 
         ON b.facid = f.facid 
            AND b.starttime LIKE '2012-09-14%' 
       join country_club.members m 
         ON b.memid = m.memid 
GROUP  BY f.name, 
          Member_Name,
HAVING SUM(CASE 
             WHEN m.firstname = 'GUEST' THEN ( b.slots * 2 * f.guestcost ) 
             ELSE ( b.slots * 2 * f.membercost ) 
           END) > 30; 

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT result.name, 
       result.member_name, 
       sum(result.cost )
FROM   (SELECT f.name, 
               Concat(m.firstname, m.surname) AS member_name, 
               CASE 
                 WHEN m.memid = '0' THEN ( b.slots * 2 * f.guestcost ) 
                 ELSE ( b.slots * 2 * f.membercost ) 
               END                            AS cost 
        FROM   (SELECT facid, 
                       memid, 
                       SUM(slots) AS slots 
                FROM   country_club.bookings 
                WHERE  starttime LIKE '2012-09-14%' 
                GROUP  BY facid, 
                          memid 
                ORDER  BY memid,facid) b, 
               country_club.facilities f, 
               country_club.members m 
        WHERE  b.facid = f.facid 
               AND b.memid = m.memid) result 
WHERE  result.cost > 30 
group by result.name, 
       result.member_name;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT result.name, 
       SUM(result.revenue) 
FROM   (SELECT f.name, 
               m.memid, 
               CASE 
                 WHEN m.memid = '0' THEN (x.slots * 2 * f.guestcost) 
                 ELSE (X.slots * 2 * f.membercost) 
               END AS revenue 
        FROM   country_club.facilities f, 
               (SELECT facid, 
                       memid, 
                       SUM(slots) AS SLOTS 
                FROM   country_club.bookings 
                GROUP  BY facid, 
                          memid 
                ORDER  BY facid) x, 
               country_club.members m 
        WHERE  f.facid = x.facid 
               AND x.memid = m.memid 
        ) result 
GROUP  BY result.name 
HAVING SUM(result.revenue) < 1000 
ORDER  BY 2; 

-- Tables data
SELECT
    bookid,
    facid,
    memid,
    starttime,
    slots
FROM
    country_club.bookings order by memid ;
    
SELECT
    memid,
    surname,
    firstname,
    address,
    zipcode,
    telephone,
    recommendedby,
    joindate
FROM
    country_club.members;
    
SELECT
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
FROM
    country_club.facilities;