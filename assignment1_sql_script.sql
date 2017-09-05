# a. Show the reservation number and the location ID of all rentals in 5/20/2015

select reservationID, pickupLocationID 
from reservation
where pickupDate = '2015-05-01';

#b. Show the first and the last name and the mobile phone number of those customers 
#that have rented a car in the category that has label = 'luxury'

select distinct c.firstName, c.lastName, c.mobile
from customers as c, reservation as r, car_type as t, car 
where c.customerID=r.customerID and r.carID=car.carID and car.typeID=t.typeID and t.typeLabel='Luxury';

#c. Show the total amount of rentals per location ID (pick up)

select pickupLocationID, count(carID)
from reservation 
group by pickupLocationID;

#d. Show the total amount of rentals per car's category ID and month

select car.typeID,  extract(year from r.pickupDate) "Year", extract(month from r.pickupDate) "Month", count(r.carID) "No. of Cars"
from  reservation as r, car
where r.carID=car.carID 
group by car.typeID, year, month
order by car.typeID ASC, year ASC, month ASC;

#e. For each rental’s state (pick up) show the top renting category

create view State as
select o.state, t.typeLabel, count(reservationID) as rentals
from reservation as r, CRC_office as o, car as c, car_type as t
where r.pickupLocationID=o.locationID and r.carID=c.carID and c.typeID=t.typeID 
group by o.state, c.typeID
order by o.state, rentals DESC;

#drop view State;

select state, typeLabel , max(rentals) 
from State
group by state;

#f. Show how many rentals there were in May 2015 in ‘NY’, ‘NJ’ and ‘CA’ (in three columns)

create view transpose as
select o.state, count(r.reservationID) as rentals
from reservation as r, CRC_office as o
where r.pickupLocationID=o.locationID and (o.state="NY" or o.state="NJ" or o.state="CA") and extract(year from r.pickupDate)=2015 and extract(month from r.pickupDate)=5
group by o.state; 

#drop view transpose;

select 
  sum(if(state = 'NY', rentals, 0)) AS 'NY', 
  sum(if(state = 'NJ', rentals, 0)) AS 'NJ', 
  sum(if(state = 'CA', rentals, 0)) AS 'CA'
        from transpose;

#g. For each month of 2015, count how many rentals had amount greater than - this - month's average rental amount

SELECT year(a.pickupdate) as yr, month(a.pickupDate) as mnth, count(a.reservationID) as counter
FROM reservation as a
WHERE year(a.pickupDate)=2015 and a.amount > 
(SELECT avg(b.amount)
from reservation as b
where month(a.pickupDate)=month(b.pickupDate) and year(a.pickupDate)=year(b.pickupDate) 
group by month(b.pickupDate))
group by month(a.pickupDate)

#g. For each month of 2015, count how many rentals had amount greater than - every - month's average rental amount

select year(pickupdate) as yr, month(pickupDate) as mnth, count(reservationID) as counter
from reservation
where amount>all
(select avg(amount)
from reservation
group by month(pickupDate))
and reservationID in
(select reservationID 
from reservation
where year(pickupDate)=2015 )
group by month(pickupDate);
																				
#h. For each month of 2015, show the percentage change of the 
#total amount of rentals over the total amount of rentals of the same month of 2014

SELECT year(t.pickupdate) as yr, month(t.pickupdate) as mnth, ROUND((t.amount- l.amount) * 100 / 
       t.amount, 2) as percent
FROM      reservation as l
INNER JOIN reservation as t 
ON month(t.pickupdate) = month(l.pickupdate) AND year(l.pickupdate) = year(t.pickupdate) - 1 where year(t.pickupdate)=2015;

#For each month of 2015, show in three columns: the total rentals’ amount of the previous months,
# the total rentals’ amount of this month and the total rentals’ amount of the following months


select cumTi-ti as prevMonths, ti as thisMonth, cumulativeTotal-cumTi as nextMonths  from
	(SELECT 
			year(b.pickupdate) AS yr, month(b.pickupdate) AS mnth,
			sum(b.amount) AS ti, (select sum(amount) from reservation where year(pickupdate)=2015) as cumulativeTotal,

				(SELECT   
						 sum(a.amount) as cumTi 
					  FROM reservation as a
					  WHERE month(a.pickupdate) <= mnth and year(a.pickupdate)=yr
                      GROUP BY mnth ASC
				)as cumTi
			
            FROM reservation AS b
			where year(b.pickupdate)=2015 
			GROUP BY month(b.pickupdate) ASC
		) as tiandTi
        
        
