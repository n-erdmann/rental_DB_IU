USE Rental_Bookings;

-- select 10 rental types
select * from rentaltype limit 10;

-- show all locations that have attributes
select * from location where `Attributes` != '';

-- show currency conversion rates to USD
select * from currencies ;

-- select currently active payment methods
select * from paymentmeth where Active = 1;

-- select all main adresses in Canada or USA
select * from mainadress where Country = 'United States' OR Country = 'Canada';

-- show fees for top Fee Classes (A,B,C and I) for Guests and Hosts
select * from feeclasses where FeeClass in ('A', 'B', 'C', 'I');

-- members who choose to pay or receive in GB Pounds
select * from members where LocCur = 'GBP';

-- guests whose feeclass is not I (initial)
select * from guest where FeeClass !='I';

-- data of members with more than 1 billing adress
select * from billingadress where MemberID IN (select MemberID from billingadress group by MemberID having count(MemberID) > 1);

-- hosts whose feeclass is not I (initial)
select * from host where FeeClass !='I';

-- select cozy rentals
select * from rental where `Attributes` like  '%cozy%';

--  which rentals does guest with ID 7 watch?
select * from watchlist where GuestID = 7;

-- wich rates are available for rental ID 10?
select * from pricing where RentalID = 10;

-- Bookings in December that are not cancelled
select * from rentalbookings r where ( DateFrom between '2022-12-01'and '2022-12-31' OR DateTo between '2022-12-01' and '2022-12-31') and Cancelled = 0;

-- Selet top rated rentals (4 or 5)
select * from rentalratings r where RatingInt >= 4;

-- Show guest ratings that have a rating text
select * from guestratings where RatingText != '';

-- what is the rental with the most pictures
select RentalID, count(RentalID) as NoPhotos from rentalpictures group by RentalID order by nophotos desc limit 10 ;

-- which coupon is valid today (2022-11-29)?
select * from coupons where ValidFrom <= '2022-11-29' and ValidTo >= '2022-11-29';

-- which credit card expires next?
select * from cc_details where Validity in (select min(Validity) from cc_details);

-- which banks/institutions do our members use?
select distinct institution , count(MemberId) as members from banktransfer group by Institution order by members desc ;

-- select 10 paypal accounts
select * from paypal limit 10;

-- invoices that were charged in November 2022
select * from invoices where InvoiceDate between '2022-11-01' and '2022-11-30' order by InvoiceDate asc ;

-- most recently redeemed coupons
select * from couponsjournal order by RedeemedOn desc limit 10;

-- which receipts were issued to first-time hosts (FeeClass = I)?
select * from receipts where FeeClass = 'I';

-- get some info about the database itself and the tables it contains 
SELECT table_schema 'database', sum(data_length + index_length)/1024 "size in kB", count(TABLE_NAME	) as 'table count' FROM information_schema.TABLES where TABLE_SCHEMA = 'rental_bookings'  GROUP BY table_schema;
SELECT TABLE_NAME as 'table', TABLE_COMMENT as 'description',  TABLE_ROWS as 'row count', (DATA_LENGTH+INDEX_LENGTH)/1024 AS 'size in kB' FROM information_schema.TABLES where TABLE_SCHEMA = 'rental_bookings';
