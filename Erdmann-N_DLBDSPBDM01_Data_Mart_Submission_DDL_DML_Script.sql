DROP DATABASE IF EXISTS Rental_Bookings;

CREATE DATABASE Rental_Bookings;

USE Rental_Bookings;

-- First, declare independant tables

-- Table to classify Rental Types
CREATE TABLE `RentalType` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Type` varchar(20)  NOT NULL ,
    PRIMARY KEY (`ID`)
);


-- Table with information about the Rental's location
CREATE TABLE `Location` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Streetname` varchar(100)  NOT NULL ,
    `HouseNo` varchar(5)  NOT NULL ,
    `PostCode` varchar(10)  NOT NULL ,
    `City` varchar(50)  NOT NULL ,
    `Province` varchar(50)  ,
    `Country` varchar(50)  NOT NULL ,
    `latitude` dec(10,8)  NOT NULL ,
    `longitude` dec(11,8)  NOT NULL ,
    `Attributes` varchar(500)  NOT NULL ,
    PRIMARY KEY (`ID`)
);


-- currency table for storing exchange rates so prices can be shown in local currencies
CREATE TABLE `Currencies` (
    `CurCode` char(3) UNIQUE NOT NULL ,
    `RateInDollar` dec(19,9)  NOT NULL ,
    `RateDate` date  NOT NULL ,
    PRIMARY KEY (`CurCode`)
);


-- Table for types of payment methods
CREATE TABLE `PaymentMeth` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Type` varchar(2)  unique NOT NULL ,
    `Text` varchar(25)  NOT NULL ,
    `Active` boolean  NOT NULL ,
    PRIMARY KEY (
        `ID`
    )
);

-- Main Adress Table - 1 Main Adress per Member
CREATE TABLE `MainAdress` (
    `ID` int  NOT null AUTO_INCREMENT ,
    `Streetname` varchar(100)  NOT NULL ,
    `HouseNo` varchar(5)  NOT NULL ,
    `AddInfo` varchar(100)   ,
    `PostCode` varchar(10)  NOT NULL ,
    `City` varchar(50)  NOT NULL ,
    `Province` varchar(50) ,
    `Country` varchar(50)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    )
);

-- Table for storing Fee Classes and their specific Fees
CREATE TABLE `FeeClasses` (
    `Type` char(1)  NOT NULL ,
    `FeeClass` char(1)  NOT NULL ,
    `Fee` int  NOT NULL ,
    PRIMARY KEY (
        `Type`,`FeeClass`
    )
);


-- Table for coupons 
CREATE TABLE `Coupons` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Code` varchar(10)  NOT NULL ,
    `Discount` int  NOT NULL ,
    `ValidFrom` date  NOT NULL ,
    `ValidTo` date  NOT NULL ,
    PRIMARY KEY (
        `ID`
    )
 );



-- now, declare compounded tables

--  Table for all Members 
CREATE TABLE `Members` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Locked` boolean NOT NULL default (0) , -- to close membership
    `RegDate` date  NOT NULL default (CURDATE()) ,
    `MainAdressID` int  NOT NULL ,
    `Birthday` date  NOT NULL , 
    `FirstName` varchar(100)  NOT NULL ,
    `LastName` varchar(100)  NOT NULL ,
    `Gender` char(1) NOT NULL check (`Gender` IN ('M', 'F', 'D')), -- Male, Female, Diverse
    `EMail` varchar(100)  NOT NULL ,
    `LocCur` char(3)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Members_MainAdressID` FOREIGN KEY(`MainAdressID`) REFERENCES `MainAdress` (`ID`) ,
    CONSTRAINT `fk_Members_LocCur` FOREIGN KEY(`LocCur`) REFERENCES `Currencies` (`CurCode`)  ,
    CONSTRAINT `c_members_age_check` check (datediff(`RegDate`, `Birthday`) >= 6574.5) -- Check members are at least 18 years old on date of registration
);


-- Guest details
CREATE TABLE `Guest` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Locked` boolean NOT NULL default (0), -- to close a guest profile
    `MemberID` int  unique NOT NULL ,
    `FeeType` char(1) not null default 'G' ,
    `FeeClass` char(1)  NOT NULL default 'I',
    `Phone` bigint  NOT NULL ,
    PRIMARY KEY (
    	`ID`
    ),
    CONSTRAINT `fk_Guest_MemberID` FOREIGN KEY(`MemberID`) REFERENCES `Members` (`ID`)   ,
    CONSTRAINT `fk_Guest_FeeType_FeeClass` FOREIGN KEY(`FeeType`, `FeeClass`) REFERENCES `FeeClasses` (`Type`, `FeeClass`)  
);


-- Billing Adresses - possibly several per Member, private or business adresses
CREATE TABLE `BillingAdress` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `MemberID` int  NOT NULL ,
    `CorpAdress` boolean  NOT NULL ,
    `FirstName` varchar(100)   ,
    `LastName` varchar(100)   ,
    `CompanyName` varchar(100)   ,
    `Department` varchar(50)   ,
    `Streetname` varchar(100)  NOT NULL ,
    `HouseNo` varchar(5)  NOT NULL ,
    `AddInfo` varchar(100) ,
    `PostCode` varchar(10)  NOT NULL ,	
    `City` varchar(50)  NOT NULL ,
    `Province` varchar(50) ,
    `Country` varchar(50)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_BillingAdress_MemberID` FOREIGN KEY(`MemberID`) REFERENCES `Members` (`ID`)  
);


-- Table to store Host data
CREATE TABLE `Host` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Locked` boolean NOT NULL default (0), -- to close a host profile
    `MemberID` int unique NOT NULL ,
    `FeeType` char(1) not null default 'H',
    `FeeClass` char(1)  NOT NULL default 'I',
    `Phone` bigint  NOT NULL ,
    `PhotoURL` varchar(100)  NOT NULL ,    
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Host_MemberID` FOREIGN KEY(`MemberID`) REFERENCES `Members` (`ID`)   ,
    CONSTRAINT `fk_Host_FeeType_FeeClass` FOREIGN KEY(`FeeType`, `FeeClass`) REFERENCES `FeeClasses` (`Type`, `FeeClass`) 
);


-- Table with information about Rentals
CREATE TABLE `Rental` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `Locked` boolean NOT NULL default (0), -- to permanently remove a rental
    `HostID` int  NOT NULL ,
    `Location` int  NOT NULL ,
    `TypeID` int  NOT NULL ,
    `Title` varchar(200)  NOT NULL ,
    `Status` char(1)  NOT NULL CHECK (`Status` IN ('C', 'P', 'I')), -- Created, Published or (temporarily) Inactive
    `Attributes` varchar(500) ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Rental_HostID` FOREIGN KEY(`HostID`) REFERENCES `Host` (`ID`)   ,
    CONSTRAINT `fk_Rental_Location` FOREIGN KEY(`Location`) REFERENCES `Location` (`ID`) ,
    CONSTRAINT `fk_Rental_TypeID` FOREIGN KEY(`TypeID`) REFERENCES `RentalType` (`ID`) 
);


-- Table to store Guest's Watchlist entries
CREATE TABLE `Watchlist` (
    `ID` int  NOT null AUTO_INCREMENT ,
    `RentalID` int  NOT NULL ,
    `GuestID` int  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Watchlist_RentalID` FOREIGN KEY(`RentalID`) REFERENCES `Rental` (`ID`)   ,
    CONSTRAINT `fk_Watchlist_GuestID` FOREIGN KEY(`GuestID`) REFERENCES `Guest` (`ID`)   
);


-- Table to store rental fares
CREATE TABLE `Pricing` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `RentalID` int  NOT NULL ,
    `NightsFrom` int  NOT NULL ,
    `NightsTo` int  NOT NULL ,
    `CancelOption` boolean  NOT NULL ,
    `Price` dec(12,2)  NOT NULL ,
    `CurCode` char(3)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Pricing_RentalID` FOREIGN KEY(`RentalID`) REFERENCES `Rental` (`ID`)  ,
    CONSTRAINT `fk_Pricing_CurrCode` FOREIGN KEY(`CurCode`) REFERENCES `Currencies` (`CurCode`) 
);


-- Table to store bookings
CREATE TABLE `RentalBookings` (
    `ID` int  NOT null AUTO_INCREMENT ,
    `GuestID` int  NOT NULL ,
    `HostID` int  NOT NULL ,
    `RentalID` int  NOT NULL ,
    `BookingDate` date NOT NULL default (curdate()),
    `RateID` int NOT NULL,
    `DateFrom` Date  NOT NULL ,
    `DateTo` Date  NOT NULL ,
    `NoOfNights` int NOT NULL default (datediff(`DateTo`,`DateFrom`)) ,
    `Cancelled` boolean  NOT NULL default 0 ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_RentalBookings_GuestID` FOREIGN KEY(`GuestID`) REFERENCES `Guest` (`ID`) ,
    CONSTRAINT `fk_RentalBookings_HostID` FOREIGN KEY(`HostID`) REFERENCES `Host` (`ID`) ,
    CONSTRAINT `fk_RentalBookings_RentalID` FOREIGN KEY(`RentalID`) REFERENCES `Rental` (`ID`) ,
    CONSTRAINT `fk_RentalBookings_RateID` FOREIGN KEY(`RateID`) REFERENCES `Pricing` (`ID`) 
);



-- Ratings of each Rental
CREATE TABLE `RentalRatings` (
    `RatingID` int  NOT null AUTO_INCREMENT ,
    `GuestID` int  NOT NULL ,
    `RentalID` int  NOT NULL ,
    `HostID` int  NOT NULL ,
    `RatingText` varchar(500) ,
    `RatingInt` int  NOT NULL ,
    PRIMARY KEY (
        `RatingID`
    ),
    CONSTRAINT `fk_RentalRatings_GuestID` FOREIGN KEY(`GuestID`) REFERENCES `Guest` (`ID`)   ,
    CONSTRAINT `fk_RentalRatings_RentalID` FOREIGN KEY(`RentalID`) REFERENCES `Rental` (`ID`)  ,
    CONSTRAINT `fk_RentalRatings_HostID` FOREIGN KEY(`HostID`) REFERENCES `Host` (`ID`)  
);

-- Ratings of Guests by Hosts
CREATE TABLE `GuestRatings` (
    `RatingID` int  NOT null AUTO_INCREMENT ,
    `HostID` int  NOT NULL ,
    `GuestID` int  NOT NULL ,
    `RatingText` varchar(500)  ,
    `RatingInt` int  NOT NULL ,
    PRIMARY KEY (
        `RatingID`
    ),
    CONSTRAINT `fk_GuestRatings_HostID` FOREIGN KEY(`HostID`) REFERENCES `Host` (`ID`)  ,
    CONSTRAINT `fk_GuestRatings_GuestID` FOREIGN KEY(`GuestID`) REFERENCES `Guest` (`ID`) 
);

-- Table to store links to Rental Pictures
CREATE TABLE `RentalPictures` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `RentalID` int  NOT NULL ,
    `PictureLink` varchar(100)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_RentalPictures_RentalID` FOREIGN KEY(`RentalID`) REFERENCES `Rental` (`ID`)  
);


-- Table for Credit Card details
CREATE TABLE `CC_Details` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `MemberId` int  NOT NULL ,
    `MethID` int  NOT NULL default 1,
    `Owner` varchar(200)  NOT NULL ,
    `Number` bigint  NOT NULL ,
    `Validity` char(7)  NOT NULL,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_CC_Details_MemberId` FOREIGN KEY(`MemberId`) REFERENCES `Members` (`ID`)  ,
    CONSTRAINT `fk_CC_Details_MethID` FOREIGN KEY(`MethID`) REFERENCES `PaymentMeth` (`ID`) 
);

-- Table for bank account details
CREATE TABLE `BankTransfer` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `MemberId` int  NOT NULL ,
    `MethID` int  NOT NULL default 2,
    `Owner` varchar(200)  NOT NULL ,
    `IBAN` varchar(34)  NOT NULL ,
    `BIC` varchar(12)  NOT NULL ,
    `Institution` varchar(100)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_BankTransfer_MemberId` FOREIGN KEY(`MemberId`) REFERENCES `Members` (`ID`)   ,
    CONSTRAINT `fk_BankTransfer_MethID` FOREIGN KEY(`MethID`) REFERENCES `PaymentMeth` (`ID`) 
);

-- Table for PayPal details
CREATE TABLE `PayPal` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `MemberId` int  NOT NULL ,
    `MethID` int  NOT NULL default 3,
    `PPAccount` varchar(100)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_PayPal_MemberId` FOREIGN KEY(`MemberId`) REFERENCES `Members` (`ID`)  ,
    CONSTRAINT `fk_PayPal_MethID` FOREIGN KEY(`MethID`) REFERENCES `PaymentMeth` (`ID`) 
);


-- Table to store invoice details (each booking generates a seperate invoice)
CREATE TABLE `Invoices` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `BookingID` int unique NOT NULL ,
    `FeeType` char(1) not null default 'G',
    `FeeClass` char(1)  NOT NULL ,
    `InvoiceDate` date  NOT NULL default (curdate()),
    `BillingAdressID` int NOT NULL,
    `BookingAmount` dec(12,2)  NOT NULL ,
    `DiscountAmount` dec(12,2)  NOT NULL ,
    `FeeAmount` dec(12,2)  NOT NULL ,
    `BillingAmount` dec(12,2)  NOT NULL ,
    `CurCode` char(3)  NOT NULL ,
    `PaymentMethod` int NOT NULL,
    `Paid` boolean  NOT NULL ,
    `Refunded` boolean  NOT NULL default '0' ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Invoices_BookingID` FOREIGN KEY(`BookingID`) REFERENCES `RentalBookings` (`ID`)  ,
    CONSTRAINT `fk_Invoices_FeeType_FeeClass` FOREIGN KEY(`FeeType`, `FeeClass`) REFERENCES `FeeClasses` (`Type`, `FeeClass`) ,
    CONSTRAINT `fk_Invoices_CurrID` FOREIGN KEY(`CurCode`) REFERENCES `Currencies` (`CurCode`) ,
    CONSTRAINT `fk_Invoices_PaymentMethod` FOREIGN KEY(`PaymentMethod`) REFERENCES `PaymentMeth` (`ID`) 
);

-- coupons journal to track redemptions
create table `CouponsJournal` (
	`ID` int  NOT NULL AUTO_INCREMENT,
	`CouponID` int NOT NULL,
	`RedeemedOn` date NOT NULL,
	`InvoiceID` int NOT NULL,
	Primary Key (`ID`),
	 CONSTRAINT `fk_CouponsJournal_CouponID` FOREIGN KEY(`CouponID`) REFERENCES `Coupons` (`ID`) ,
	 CONSTRAINT `fk_CouponsJournal_InvoiceID` FOREIGN KEY(`InvoiceID`) REFERENCES `Invoices` (`ID`)  
	);		


-- Table to store details of cash out to Hosts 
CREATE TABLE `Receipts` (
    `ID` int  NOT NULL AUTO_INCREMENT,
    `BookingID` int unique NOT NULL ,
    `HostID` int  NOT NULL ,
    `FeeType` char(1) not null default 'H',
    `FeeClass` char(1)  NOT NULL ,    
    `BookingAmount` dec(12,2)  NOT NULL ,
    `FeeAmount` dec(12,2)  NOT NULL ,
    `PayoutAmount` dec(12,2)  NOT NULL ,
    `CurCode` char(3)  NOT NULL ,
    PRIMARY KEY (
        `ID`
    ),
    CONSTRAINT `fk_Receipts_BookingID` FOREIGN KEY(`BookingID`) REFERENCES `RentalBookings` (`ID`)  ,
    CONSTRAINT `fk_Receipts_FeeType_FeeClass` FOREIGN KEY(`FeeType`, `FeeClass`) REFERENCES `FeeClasses` (`Type`, `FeeClass`)  ,
    CONSTRAINT `fk_Receipts_HostID` FOREIGN KEY(`HostID`) REFERENCES `Host` (`ID`)  ,
    CONSTRAINT `fk_Receipts_CurrID` FOREIGN KEY(`CurCode`) REFERENCES `Currencies` (`CurCode`) 
);




-- all tables are declared, now fill the tables with mock data

-- USE Rental_Bookings;

-- fill independant tables first

INSERT INTO RentalType(`Type`) 
	VALUES 
		('Room'),
	    ('Studio'), 
	    ('Appartment'), 
	    ('House'),
	    ('Cabin'), 
	    ('House Boat'), 
	    ('Treehouse'),
	    ('Tinyhouse'), 
	    ('Camper'),
	   	('Hotel Room'),
	    ('Apparthotel'), 
	    ('Guesthouse'), 
	    ('Hostel'),
	    ('Bed and Breakfast'), 
	    ('Holiday Village'), 
	    ('Marina'),
	    ('Farmstay'), 
	    ('Premium Resort'),
	   	('Camp Ground'),
 	   	('Other');
		


insert into location (Streetname, HouseNo, PostCode, City, Province, Country, latitude, longitude, `Attributes`)
	values 	('Wolf Street','403','T1L','Banff','Alberta','Canada',51.1845319,-116.025616,'Downtown| National Park| Hiking'),
			('Carioca Street','81648','1140','Sydney','New South Wales','Australia',-27.9424308,153.3970962,''),
			('Marchstra?e','23','10587','Berlin','Berlin','Germany',52.5170826,13.3236611,'Einsteinufer| University'),
			('Oranienstr.','4','10997','Berlin','Berlin','Germany',52.500039,13.425306,'cozy'),
			('Grunaer Stra?e','7','1069','Dresden','Sachsen','Germany',51.049176,13.747096,'Old Town| Br?hlscher Garten '),
			('Carberry Street','38038','1140','Sydney','New South Wales','Australia',-27.9424308,153.3970962,''),
			('Mendota Street','9412','EH9','Edinburgh','Scotland','United Kingdom',55.9309486,-3.1859102,''),
			('Forest Run Street','8','EH9','Edinburgh','Scotland','United Kingdom',55.9309486,-3.1859102,'Suburb| Quiet| Residential Area'),
			('Old Shore Street','651','969-7208','Fuji','','Japan',37.5568153,139.747389,'rural| cozy| relaxed'),
			('Green Street','61026','J1K','Invermere','British Columbia','Canada',50.507057,-116.03538,'Lake Invermere| National Park'),
			('Lexington Street','54','W1F','London','England','United Kingdom',51.5136143,-0.1365486,'SOHO| Shopping| Entertainment'),
			('Menomonie Street','1','90410','Santa Monica','California','United States',34.02,-118.5,''),
			('Center Street','99','57105','Sioux Falls','South Dakota','United States',43.521619,-96.722641,''),
			('Fairfield Street','5436','98687','Vancouver','Washington','United States',45.63,-122.52,''),
			('Troy Street','964','11205','Brooklyn','New York','United States',40.6945036,-73.9565551,''),
			('Forster Street','2736','34102','Naples','Florida','United States',26.132433,-81.7951054,''),
			('Springview Street','904','93773','Fresno','California','United States',36.74,-119.8,''),
			('26th Street','240E','10010','New York City','New York','United States',40.7400016,-73.9800078,'Manhattan| Bellevue Park| East Side'),
			('Logan Street','562','EC1V','London','England','United Kingdom',51.5267946,-0.0983812,''),
			('Warrior Street','84','W1F','London','England','United Kingdom',51.5136143,-0.1365486,''),
			('Grasskamp Street','751-1','904-2244','Okinawa','','Japan',26.3448341,127.833984,'quiet| close to park'),
			('Rue des Anglais','4','75005','Paris','?le-de-France','France',48.850627,2.347434,'Quartier Latin| lively area| Close to Metro'),
			('Grantham Street','3','2011','Sydney','New South Wales','Australia',-33.867296,151.224685,'Botanical Garden| Green| Night Life| Potts Point'),
			('Dottie Street','400','8411','Winterthur','Kanton Z?rich','Switzerland',47.49476,8.740263,'');


INSERT INTO Currencies(CurCode, RateInDollar, RateDate) 
	Values ('AUD','1.566371','2022-10-31'),
			('CAD','1.367057','2022-10-31'),
			('CHF','1.00111','2022-10-31'),
			('CNY','7.300787','2022-10-31'),
			('CZK','24.700424','2022-10-31'),
			('EUR','1.008675','2022-10-31'),
			('GBP','0.86862','2022-10-31'),
			('IDR','15623.91568','2022-10-31'),
			('ISK','144.54','2022-10-31'),
			('JPY','148.678636','2022-10-31'),
			('KRW','1428.404277','2022-10-31'),
			('NOK','10.392173','2022-10-31'),
			('NZD','1.724733','2022-10-31'),
			('PLN','4.749344','2022-10-31'),
			('RUB','61.3589','2022-10-31'),
			('SEK','10.995562','2022-10-31'),
			('SGD','1.415977','2022-10-31'),
			('THB','38.075449','2022-10-31'),
			('TRY','18.61630018','2022-10-31'),
			('USD','1','2022-10-31');

INSERT INTO PaymentMeth(`Type`, `Text`, Active) 
	VALUES 	('CC', 'Credit Card', '1'), 
			('BT', 'Bank Transfer', '1'), 
			('PP', 'Paypal','1'),
			('SO', 'Sofort?berweisung', '0'),
			('AP','Apple Pay','0'),
			('MP', 'Amazon Pay','0'),
			('GP', 'Google Pay','0'),
			('SP', 'Samsung Pay','0'),
			('EM', 'eBay Managed Payments','0'),
			('LP', 'AliPay','0'),
			('WP', 'WePay Chat','0'),
			('BC', 'Bitcoin','0'),
			('AF', 'AfterPay','0'),
			('KL', 'Klarna','0'),
			('D1', 'Dummy 1','0'),
			('D2', 'Dummy 2','0'),
			('D3', 'Dummy 3','0'),
			('D4', 'Dummy 4','0'),
			('D5', 'Dummy 5','0'),
			('D6', 'Dummy 6','0');

		
insert into mainadress (Streetname, HouseNo, AddInfo, PostCode, City, Province, Country)
	values 	('Fairview Street','1','','1009','Sydney','New South Wales','Australia'),
			('Westridge Street','758','','5839','Adelaide','South Australia','Australia'),
			('Hallows Street','5','c/o Emma Wilson','1694','Northern Suburbs Mc','New South Wales','Australia'),
			('Summerview Street','5','','1181','Sydney','New South Wales','Australia'),
			('Prentice Street','9','','5874','Adelaide Mail Centre','South Australia','Australia'),
			('Manitowish Street','96','','T4J','Ponoka','Alberta','Canada'),
			('Summer Ridge Street','9552','','J7A','Lanigan','Saskatchewan','Canada'),
			('Milwaukee Street','891','','H9K','Sainte-Marthe-sur-le-Lac','Qu?bec','Canada'),
			('Sheridan Street','9','','T5G','Niverville','Manitoba','Canada'),
			('Coleman Street','77','','N5C','Ingersoll','Ontario','Canada'),
			('Schlimgen Street','2110','','T4T','Rocky Mountain House','Alberta','Canada'),
			('Esch Street','1','','13088','Berlin','Berlin','Germany'),
			('Aberg Street','2405','','30453','Hannover','Niedersachsen','Germany'),
			('Morning Street','1','','22179','Hamburg','Hamburg','Germany'),
			('Hansons Street','1265','','30453','Hannover','Niedersachsen','Germany'),
			('Golf Street','48249','','81543','M?nchen','Bayern','Germany'),
			('Park Meadow Street','23136','','M34','Denton','England','United Kingdom'),
			('Logan Street','562','','EC1V','London','England','United Kingdom'),
			('Warrior Street','84','','W1F','London','England','United Kingdom'),
			('Brentwood Street','70','','KW10','Kirkton','Scotland','United Kingdom'),
			('Rutledge Street','3270','','NE46','Newbiggin','England','United Kingdom'),
			('Dapin Street','91371','','PR1','Preston','England','United Kingdom'),
			('Mcbride Street','4518','','DL10','Whitwell','England','United Kingdom'),
			('Sloan Street','75508','','NN11','Norton','England','United Kingdom'),
			('Fair Oaks Street','292','','LN6','Stapleford','England','United Kingdom'),
			('Tony Street','45050','','24048','Roanoke','Virginia','United States'),
			('Brown Street','121','','20380','Washington','District of Columbia','United States'),
			('Colorado Street','9','','68117','Omaha','Nebraska','United States'),
			('Springview Street','904','','93773','Fresno','California','United States'),
			('Lakewood Gardens Street','949','','46857','Fort Wayne','Indiana','United States'),
			('Acker Street','9349','','14604','Rochester','New York','United States'),
			('Bluestem Street','18974','','45020','Hamilton','Ohio','United States'),
			('Grasskamp Street','496','','76598','Gatesville','Texas','United States'),
			('Dottie Street','673','','73135','Oklahoma City','Oklahoma','United States'),
			('La Follette Street','23083','','6015','Luzern','Kanton Luzern','Switzerland'),
			('Packers Street','7429','','4024','Basel','Kanton Basel-Stadt','Switzerland'),
			('Dottie Street','400','','8411','Winterthur','Kanton Z?rich','Switzerland'),
			('Oakridge Street','556','','8023','Z?rich','Kanton Z?rich','Switzerland'),
			('Bultman Street','987','','B0L','Rosthern','Saskatchewan','Canada'),
			('Oranienstr.','4','(im Gartenhaus)','10997','Berlin','Berlin','Germany'),
			('Grasskamp Street','01','','904-2244','Okinawa','','Japan'),
			('Old Shore Street','651','','969-7208','Fuji','','Japan');

insert into feeclasses (`Type`, FeeClass, Fee) 
	values 	('G', 'I', 5),
			('G', 'B', 10),
			('G', 'C', 12),
			('G', 'A', 7),
			('H', 'I', 1),
			('H', 'B', 5),
			('H', 'A', 3),
			('H', 'C', 7),
			('H', 'D', 9),
			('H', 'E', 9),
			('H', 'F', 10),
			('H', 'G', 11),
			('H', 'H', 11),
			('H', 'J', 12),
			('G', 'D', 12),
			('G', 'E', 13),
			('G', 'F', 13),
			('G', 'G', 14),
			('G', 'H', 14),
			('G', 'J', 15);
		
		
-- Fill compounded tables next

 	insert into members (MainAdressID,RegDate,Birthday,FirstName,LastName, Gender, EMail,LocCur)
 		values	('1','2022-10-17','1975-02-23','Sherri','Millican','F','smillican2p@utexas.edu','AUD'),
				('2','2022-10-05','2002-09-14','Gay','Simms','M','gsimms2q@house.gov','AUD'),
				('3','2022-10-20','1972-08-31','Sharona','Gawler','F','sgawler2r@timesonline.co.uk','AUD'),
				('4','2022-10-01','1966-07-05','Vin','Arnaldo','M','varnaldo2s@jugem.jp','AUD'),
				('5','2022-10-02','1986-09-26','Charmane','Brewood','F','cbrewood2t@uiuc.edu','AUD'),
				('6','2022-10-22','1996-12-19','Devonne','Capozzi','F','dcapozzi6@ustream.tv','CAD'),
				('7','2022-10-09','1997-02-06','Inglebert','Serrurier','M','iserrurier7@imgur.com','CAD'),
				('8','2022-10-26','1981-11-05','Ronald','Lindborg','M','rlindborg15@ed.gov','CAD'),
				('9','2022-10-15','1966-03-25','Dalt','Restill','M','drestill16@vimeo.com','CAD'),
				('10','2022-10-04','1983-03-08','Lem','Wolsey','M','lwolsey17@slashdot.org','CAD'),
				('11','2022-10-26','2000-06-15','Aguie','Alishoner','M','aalishoner18@patch.com','CAD'),
				('12','2022-10-25','1984-08-03','Darleen','Bertl','F','dbertl1@vk.com','EUR'),
				('13','2022-10-07','1985-11-16','Eadith','McGarvey','F','emcgarvey2@usnews.com','EUR'),
				('14','2022-10-01','1993-10-29','Fania','Daymond','F','fdaymond3@mtv.com','EUR'),
				('15','2022-10-16','1990-06-14','Charlotta','OGlassane','F','coglassane4@java.com','EUR'),
				('16','2022-10-18','1999-02-15','Teodora','Timmis','F','ttimmis5@comcast.net','EUR'),
				('17','2022-10-08','1989-06-23','Sallyanne','Merriott','F','smerriotte@wiley.com','GBP'),
				('18','2022-10-02','1973-04-28','Lizette','Holtom','F','lholtomg@sciencedirect.com','GBP'),
				('19','2022-10-12','1982-07-17','Gan','Ruhben','M','gruhbenh@acquirethisname.com','GBP'),
				('20','2022-10-26','1980-04-11','Gae','Reims','F','greimsi@wordpress.org','GBP'),
				('21','2022-10-22','1972-07-26','Marcus','Moncarr','M','mmoncarrj@tinypic.com','GBP'),
				('22','2022-10-18','1965-04-27','Sarena','Pogue','F','spoguek@storify.com','GBP'),
				('23','2022-10-01','1990-07-22','Doloritas','Standring','F','dstandringl@chicagotribune.com','GBP'),
				('24','2022-10-06','1989-02-26','Gilberta','Cabotto','F','gcabottom@instagram.com','GBP'),
				('25','2022-10-29','2002-12-07','Dennis','Gemelli','M','dgemellin@oaic.gov.au','GBP'),
				('26','2022-10-26','2004-05-21','Delaney','Brelsford','M','dbrelsford16@ucla.edu','USD'),
				('27','2022-10-22','1999-05-12','Alic','Gabbat','M','agabbat17@amazon.co.jp','USD'),
				('28','2022-10-15','1979-04-10','Weston','Gravatt','M','wgravatt18@issuu.com','USD'),
				('29','2022-10-21','1989-08-04','Rosamund','McIvor','F','rmcivor19@php.net','USD'),
				('30','2022-10-28','1986-05-20','Vick','Edgeller','M','vedgeller1b@issuu.com','USD'),
				('31','2022-10-12','1979-11-07','Dagmar','Shellard','F','dshellard1c@globo.com','USD'),
				('32','2022-10-19','1987-05-02','Oswell','ODaly','M','oodaly1d@forbes.com','USD'),
				('33','2022-10-14','1967-06-24','Erda','Astling','F','eastling1e@narod.ru','USD'),
				('34','2022-10-12','1978-07-06','Glendon','Proom','M','gproom1f@amazon.com','USD'),
				('35','2022-10-29','1989-06-07','Sol?ne','Allanson','F','zallanson1@paginegialle.it','CHF'),
				('36','2022-10-27','1965-09-25','Ad?lie','Casone','F','acasone2@hubpages.com','CHF'),
				('37','2022-10-25','1983-08-24','S?verine','Redfern','M','aredfern3@jalbum.net','CHF'),
				('38','2022-10-25','1985-02-19','Eli?s','McLernon','F','gmclernon4@ucoz.ru','CHF'),
				('39','2022-10-19','1988-04-12','Winna','Sandwich','F','wsandwich9@printfriendly.com','CAD'),
				('40','2022-10-01','1982-03-26','Anna','Widmann','F','annaw199845@gmx.de','EUR'),
				('41','2022-10-11','1981-09-08','Robinson','Riddiough','M','rriddiough2g@reuters.com','JPY'),
				('42','2022-10-09','1990-01-23','Ofelia','Casaccio','F','ocasaccio82@ustream.tv','JPY');
			
	insert into guest (MemberID,FeeType ,FeeClass ,Phone)
	 	values 	('1','G','I','00616994297579'),
				('2','G','I','00619685148447'),
				('3','G','I','00617821312223'),
				('4','G','I','00611708963380'),
				('5','G','I','00614709369202'),
				('6','G','I','0013875183709'),
				('7','G','I','0018931833606'),
				('8','G','I','0016345361397'),
				('9','G','B','0019572876683'),
				('10','G','I','0019514629601'),
				('11','G','I','0015848841125'),
				('12','G','I','00494587453520'),
				('13','G','B','00493473562041'),
				('14','G','I','00495441326716'),
				('15','G','I','00496854465951'),
				('16','G','I','00496702153630'),
				('17','G','I','00445424247224'),
				('18','G','I','00446803850009'),
				('19','G','I','00448831092449'),
				('20','G','I','00445968270936'),
				('21','G','I','00449575975044'),
				('22','G','I','00447774943214'),
				('23','G','I','00445429797676'),
				('24','G','B','00448313302726'),
				('25','G','B','00445638470452'),
				('26','G','I','0016029263411'),
				('27','G','I','0015408460937'),
				('28','G','I','0012022069093'),
				('29','G','I','0014024393543'),
				('30','G','I','0018052403713'),
				('31','G','I','0012604067643'),
				('32','G','B','0015858655168'),
				('33','G','B','0014197080691'),
				('34','G','B','0012543078161'),
				('35','G','I','00414052852689'),
				('36','G','I','00418325151222'),
				('37','G','I','00416605260049'),
				('38','G','I','00416835081807'),
				('39','G','I','0019708269038'),
				('40','G','I','0049308269042'),
				('41','G','I','00815925855833'),
				('42','G','I','00811692107913');

insert into billingadress (MemberID,CorpAdress,FirstName,LastName,CompanyName,Department,Streetname,HouseNo,AddInfo,PostCode,City,Province,Country)
values 	('1','0','Sherri','Millican','','','Fairview Street','1','','1009','Sydney','New South Wales','Australia'),
		('2','0','Gay','Simms','','','Westridge Street','758','','5839','Adelaide','South Australia','Australia'),
		('3','0','Sharona','Gawler','','','Hallows Street','5','','1694','Northern Suburbs Mc','New South Wales','Australia'),
		('4','0','Vin','Arnaldo','','','Summerview Street','5','','1181','Sydney','New South Wales','Australia'),
		('4','1','','','Fadel and Hoppe','Product Management','Sage Street','38972','Leanora Wilkenson','1206','Sydney','New South Wales','Australia'),
		('5','0','Charmane','Brewood','','','Prentice Street','9','','5874','Adelaide Mail Centre','South Australia','Australia'),
		('6','1','','','Bayer LLC','A1ounting','Dryden Street','91','Nike Cockley','T6L','Hanna','Alberta','Canada'),
		('7','0','Inglebert','Serrurier','','','Summer Ridge Street','9552','','J7A','Lanigan','Saskatchewan','Canada'),
		('8','0','Ronald','Lindborg','','','Bultman Street','987','','B0L','Rosthern','Saskatchewan','Canada'),
		('8','1','','','Mayer-Rogahn','Sales','Mandrake Street','3150','Brandy Berntssen','P3L','Maple Creek','Saskatchewan','Canada'),
		('9','1','','','Ritchie and Braun','Business Development','Stuart Street','45','Ninnette July','J5T','Lavaltrie','Qu?bec','Canada'),
		('10','0','Lem','Wolsey','','','Sheridan Street','9','','T5G','Niverville','Manitoba','Canada'),
		('11','0','Aguie','Alishoner','','','Coleman Street','77','','N5C','Ingersoll','Ontario','Canada'),
		('12','0','Darleen','Bertl','','','Schlimgen Street','2110','','T4T','Rocky Mountain House','Alberta','Canada'),
		('13','0','Eadith','McGarvey','','','Esch Street','0','','13088','Berlin','Berlin','Germany'),
		('14','1','','','Gottlieb and Gutkowski"','A1ounting','Park Meadow Street','75548','Niko Dilon','30453','Hannover','Niedersachsen','Germany'),
		('15','0','Charlotta','OGlassane','','','Morning Street','1','','22179','Hamburg','Hamburg','Germany'),
		('16','0','Teodora','Timmis','','','Hansons Street','1265','','30453','Hannover','Niedersachsen','Germany'),
		('16','1','','','Hyatt LLC','Support','Porter Street','99','Ri1a Valenti','30453','Hannover','Niedersachsen','Germany'),
		('17','0','Sallyanne','Merriott','','','Golf Street','48249','','81543','M?nchen','Bayern','Germany'),
		('18','1','','','Wisoky Group','Training','Maryland Street','0855','Meade Batthew','M34','Denton','England','United Kingdom'),
		('19','0','Gan','Ruhben','','','Logan Street','562','','EC1V','London','England','United Kingdom'),
		('20','0','Gae','Reims','','','Warrior Street','84','','W1F','London','England','United Kingdom'),
		('21','0','Marcus','Moncarr','','','Brentwood Street','70','','KW10','Kirkton','Scotland','United Kingdom'),
		('22','1','','','M1ullough and Rogahn','Sales','Burrows Street','934','Cullin Hanfrey','NE46','Newbiggin','England','United Kingdom'),
		('23','0','Doloritas','Standring','','','Dapin Street','91371','','PR1','Preston','England','United Kingdom'),
		('24','0','Gilberta','Cabotto','','','Mcbride Street','4518','','DL10','Whitwell','England','United Kingdom'),
		('25','1','','','Hagenes and Beahan"','Support','Elgar Street','342','Lidia Eason','NN11','Norton','England','United Kingdom'),
		('26','1','','','Greenholt Inc','Legal','Westport Street','26','Cullen MacDearmid','B40','Birmingham','England','United Kingdom'),
		('27','1','','','Kirlin and Hayes','Services','Scott Street','7','Jamil Prantoni','23324','Chesapeake','Virginia','United States'),
		('28','0','Weston','Gravatt','','','Brown Street','121','','20380','Washington','District of Columbia','United States'),
		('29','0','Rosamund','McIvor','','','Colorado Street','9','','68117','Omaha','Nebraska','United States'),
		('30','0','Vick','Edgeller','','','Roth Street','7820','','93094','Simi Valley','California','United States'),
		('31','1','','','Frami and Brakus"','Engineering','Claremont Street','044','Teodoro Bean','47732','Evansville','Indiana','United States'),
		('32','1','','','Nienow-Dickinson','Sales','Ludington Street','6','Bryce Larner','14205','Buffalo','New York','United States'),
		('33','0','Erda','Astling','','','Bluestem Street','18974','','45020','Hamilton','Ohio','United States'),
		('34','1','','','Gaylord LLC','Business Development','Knutson Street','4941','Hart Rathmell','77713','Beaumont','Texas','United States'),
		('35','0','Sol?ne','Allanson','','','Dottie Street','673','','73135','Oklahoma City','Oklahoma','United States'),
		('36','0','Ad?lie','Casone','','','La Follette Street','23083','','6015','Luzern','Kanton Luzern','Switzerland'),
		('37','1','','','Quigley-Berge','Training','Center Street','660','Aurie Veness','4024','Basel','Kanton Basel-Stadt','Switzerland'),
		('38','0','Eli?s','McLernon','','','Dottie Street','400','','8411','Winterthur','Kanton Z?rich','Switzerland'),
		('39','0','Winna','Sandwich','','','Oakridge Street','556','','8023','Z?rich','Kanton Z?rich','Switzerland'),
		('40','0','Anna','Widmann','','','Oranienstr.','4','','10997','Berlin','Berlin','Germany'),
		('41','0','Robinson','Riddiough','','','Grasskamp Street','01','','904-2244','Okinawa','','Japan'),
		('42','0','Ofelia','Casa1io','','','Old Shore Street','651','','969-7208','Fuji','','Japan');
			
insert into host (MemberID,FeeType,FeeClass,Phone,PhotoURL)
values	('1','H','I','00616994297579','http://dummyimage.com/117x100.png/ff4444/ffffff'),
		('4','H','B','00611708963380','http://dummyimage.com/158x100.png/ff4444/ffffff'),
		('6','H','I','0013875183709','http://dummyimage.com/126x100.png/dddddd/000000'),
		('12','H','I','00494587453520','http://dummyimage.com/166x100.png/10000/ffffff'),
		('13','H','A','00493473562041','http://dummyimage.com/241x100.png/5fa2dd/ffffff'),
		('16','H','I','00496702153630','http://dummyimage.com/197x100.png/dddddd/000000'),
		('19','H','I','00448831092449','http://dummyimage.com/108x100.png/10000/ffffff'),
		('20','H','A','00445968270936','http://dummyimage.com/181x100.png/5fa2dd/ffffff'),
		('21','H','I','00449575975044','http://dummyimage.com/140x100.png/5fa2dd/ffffff'),
		('25','H','I','00445638470452','http://dummyimage.com/108x100.png/5fa2dd/ffffff'),
		('27','H','I','0015408460937','http://dummyimage.com/162x100.png/5fa2dd/ffffff'),
		('28','H','B','0012022069093','http://dummyimage.com/111x100.png/10000/ffffff'),
		('29','H','I','0014024393543','http://dummyimage.com/138x100.png/dddddd/000000'),
		('31','H','I','0012604067643','http://dummyimage.com/175x100.png/dddddd/000000'),
		('32','H','I','0015858655168','http://dummyimage.com/194x100.png/5fa2dd/ffffff'),
		('37','H','B','00416605260049','http://dummyimage.com/250x100.png/ff4444/ffffff'),
		('38','H','I','00416835081807','http://dummyimage.com/198x100.png/10000/ffffff'),
		('40','H','I','0049308269042','http://dummyimage.com/163x100.png/10011/ffffff'),
		('41','H','I','00811692107913','http://dummyimage.com/148x100.png/ff4444/ffffff'),
		('42','H','I','00811692107913','http://dummyimage.com/187x100.png/10000/ffffff');

insert into rental (HostID,Location,TypeID,Title,Status,`Attributes`)
values 	('3','1','5','Rocky Mountains Cabin','P','wooden refuge'),
		('1','2','3','spacious modern appartment','I','spacious | kitchen | bathtub'),
		('5','3','3','modern appartment','P','modern | kitchen | bathtub | elevator'),
		('18','4','1','spacious room in quiet neighborhood','P','spacious | comfy bed | shared kitchen | private bathroom'),
		('6','5','3','perfect for sightseeing!','P','fully equipped | elevator | central location | kitchen'),
		('2','6','3','downtown appartment','P','downtown | fully eqipped kitchen | bathroom with shower'),
		('10','7','1','cozy room in nice shared flat','I','cozy | shared kitchen and bathroom | desk with monitor | '),
		('9','8','4','modern suburban house ','P','garden | barbeque | sunbeds | badminton sets | spacious | bathroom with bathtub'),
		('20','9','4','rural retreat','P','rural | fully eqipped kitchen | bathroom with bathtub | garden with barbeque | carport'),
		('4','10','3','your basecamp near the lake','P','fully equipped appartment | washing machine | kitchen'),
		('8','11','1','bustling downtown atmosphere','P','shared kitchen | shared bathroom | perfect for enjoying nightlife'),
		('13','12','2','beach life studio','P','beach condo | maritime style | sunbeds '),
		('12','13','8','tiny house - big fun!','P','heating | bathroom with shower | cooking facilities | cozy interior | front porch'),
		('12','14','1','cozy room','P','cozy | fully eqipped kitchen | bathroom with shower'),
		('14','15','2','Brooklyn Studio','P','Brooklyn | Kitchenette | bathroom with shower'),
		('11','16','3','picturesque place','P','modern | fully eqipped kitchen | bathroom with shower'),
		('13','17','2','sunny studio','P','sunny | kitchenette | bathroom with shower | desk | flatscreen TV'),
		('15','18','2','"modern spacious Bellevue Park studio"','P','spacious | sunny | quiet | Kitchenette | city view'),
		('7','19','1','The place to be','P','central | large room | desk'),
		('8','20','3','Big city appartment','C','Big | kitchen | bathtub'),
		('19','21','4','lovely vacation home ','P','garden | barbeque | sunboks | badminton sets | spacious | bathroom with bathtub'),
		('16','22','2','central Paris studio','P','stylish | central | fully equiped'),
		('2','23','2','modern studio in perfect location ','P','popular area | modern | perfect for couples'),
		('17','24','2','Studio','C','');
		
insert into watchlist (RentalID,GuestID)
values 	(3,1),
		(4,1),
		(5,1),
		(19,3),
		(11,3),
		(8,3),
		(14,7),
		(16,7),
		(17,7),
		(7,9),
		(8,9),
		(22,9),
		(23,23),
		(2,23),
		(6,23),
		(13,27),
		(12,27),
		(18,27),
		(10,31),
		(1,31),
		(21,31);
	
insert into pricing (RentalID,NightsFrom, NightsTo,CancelOption,Price,CurCode)
values 	('1','3','20','1','120','CAD'),
		('2','1','3','1','154','AUD'),
		('2','4','14','1','140','AUD'),
		('3','1','14','1','100','EUR'),
		('4','1','7','1','55','EUR'),
		('4','8','90','0','40','EUR'),
		('5','1','20','1','110','EUR'),
		('5','1','20','0','125','EUR'),
		('6','1','28','1','150','AUD'),
		('7','1','99','1','45','GBP'),
		('8','1','190','1','89','GBP'),
		('9','1','30','1','8750','JPY'),
		('10','7','28','0','200','CAD'),
		('10','7','28','1','220','CAD'),
		('11','1','90','1','49','GBP'),
		('12','1','21','1','200','USD'),
		('13','1','21','1','90','USD'),
		('14','1','21','1','65','USD'),
		('15','1','14','1','120','USD'),
		('16','1','21','1','250','USD'),
		('17','1','14','1','120','USD'),
		('18','1','28','1','160','USD'),
		('19','1','21','1','42','GBP'),
		('20','1','14','1','170','GBP'),
		('21','1','28','1','27680','JPY'),
		('22','1','21','1','140','EUR'),
		('23','1','14','1','145','AUD'),
		('24','1','30','1','165','CHF');
		
insert into rentalbookings (GuestID,HostID,RentalID,BookingDate, RateID, DateFrom,DateTo, Cancelled)
values 	('13','1','2','2022-10-07','3','2022-11-01','2022-11-10','0'),
		('7','2','6','2022-10-19','9','2022-11-01','2022-11-07','1'),
		('17','3','1','2022-10-18','1','2022-11-03','2022-11-11','0'),
		('20','4','10','2022-10-26','13','2022-11-15','2022-11-30','0'),
		('2','5','3','2022-11-05','4','2022-11-28','2022-12-06','0'),
		('5','6','5','2022-11-02','7','2022-12-03','2022-12-17','0'),
		('12','7','19','2022-10-25','23','2022-12-18','2022-12-30','0'),
		('22','8','11','2022-10-18','15','2022-11-14','2022-11-20','1'),
		('3','9','8','2022-10-21','11','2022-12-03','2022-12-17','0'),
		('4','10','7','2022-11-11','10','2022-12-07','2022-12-20','0'),
		('6','11','16','2022-10-22','20','2022-12-03','2022-12-17','0'),
		('33','12','13','2022-10-31','17','2022-11-27','2022-12-08','0'),
		('40','13','12','2022-10-30','16','2022-12-07','2022-12-20','0'),
		('9','14','15','2022-10-15','19','2022-11-14','2022-11-20','0'),
		('42','15','18','2022-10-09','22','2022-12-18','2022-12-30','0'),
		('28','16','22','2022-10-15','26','2022-11-01','2022-11-07','1'),
		('15','7','19','2022-10-16','23','2022-12-03','2022-12-17','0'),
		('19','18','4','2022-10-12','6','2022-12-18','2022-12-30','0'),
		('36','19','21','2022-10-27','25','2022-12-03','2022-12-17','0'),
		('8','11','16','2022-11-26','20','2022-12-18','2022-12-30','0'),
		('42','3','1','2022-11-09','1','2022-11-23','2022-12-02','0'),
		('14','5','3','2022-10-01','4','2022-11-14','2022-11-20','0'),
		('37','13','17','2022-10-25','21','2022-11-01','2022-11-10','0'),
		('4','12','14','2022-11-01','18','2022-12-03','2022-12-17','1');
	
		
insert into rentalratings (GuestID,RentalID,HostID,RatingText,RatingInt)
values 	('13','2','1','lovely appartment but could improve on cleanlyness','3'),
		('7','6','2','','3'),
		('17','1','3','','4'),
		('20','10','4','Perfect for  exploring the National Park!','5'),
		('2','3','5','"lovely place in Berlin and close to Spree"','4'),
		('5','5','6','','4'),
		('12','19','7','','4'),
		('22','11','8','nice room but area was too noisy for me and bathroom very small','2'),
		('3','8','9','Everything was good.','5'),
		('4','7','10','perfect for a weekend in Edinburgh','5'),
		('6','16','11','','3'),
		('33','13','12','','4'),
		('40','12','13','','4'),
		('9','15','14','great place to stay when visiting Brooklyn','4'),
		('42','18','15','','2'),
		('28','22','16','','3'),
		('15','19','7','','3'),
		('19','4','18','lovely room - really cozy and comfy. Flatmates are also gorgeous. Recommended.','5'),
		('36','21','19','','4'),
		('8','16','11','','4'),
		('42','1','3','','3'),
		('14','3','5','','4'),
		('37','17','13','','5'),
		('4','14','12','','2');
		
insert into guestratings (HostID,GuestID,RatingText,RatingInt)
values	('1','13','','4'),
		('2','7','','5'),
		('3','17','Left the place in mess!','2'),
		('4','20','','4'),
		('5','2','All is good','5'),
		('6','5','','4'),
		('7','12','Lovely guest','5'),
		('8','22','I had good time hosting her showing her my city','5'),
		('9','3','','5'),
		('10','4','','4'),
		('11','6','','5'),
		('12','33','','5'),
		('13','40','Anna is a nice guest','5'),
		('14','9','','4'),
		('15','42','','4'),
		('16','28','','4'),
		('7','15','','3'),
		('18','19','','4'),
		('19','36','','4'),
		('11','8','','4'),
		('3','42','','5'),
		('5','14','','5'),
		('13','37','','5'),
		('12','4','','5');
		
insert into rentalpictures (RentalID,PictureLink)
values	('1','http://dummyimage.com/211x703.png/ff4444/ffffff'),
		('1','http://dummyimage.com/298x523.png/ff4444/ffffff'),
		('1','http://dummyimage.com/356x690.png/10000/ffffff'),
		('2','http://dummyimage.com/320x565.png/dddddd/000000'),
		('2','http://dummyimage.com/350x638.png/ff4444/ffffff'),
		('2','http://dummyimage.com/315x775.png/ff4444/ffffff'),
		('2','http://dummyimage.com/211x743.png/5fa2dd/ffffff'),
		('3','http://dummyimage.com/235x434.png/ff4444/ffffff'),
		('3','http://dummyimage.com/362x771.png/5fa2dd/ffffff'),
		('3','http://dummyimage.com/297x589.png/10000/ffffff'),
		('4','http://dummyimage.com/277x437.png/ff4444/ffffff'),
		('4','http://dummyimage.com/288x516.png/5fa2dd/ffffff'),
		('4','http://dummyimage.com/367x787.png/ff4444/ffffff'),
		('5','http://dummyimage.com/204x461.png/10000/ffffff'),
		('5','http://dummyimage.com/247x613.png/10000/ffffff'),
		('5','http://dummyimage.com/248x412.png/dddddd/000000'),
		('6','http://dummyimage.com/205x499.png/10000/ffffff'),
		('6','http://dummyimage.com/258x505.png/5fa2dd/ffffff'),
		('6','http://dummyimage.com/316x407.png/10000/ffffff'),
		('7','http://dummyimage.com/296x675.png/5fa2dd/ffffff'),
		('7','http://dummyimage.com/262x723.png/10000/ffffff'),
		('7','http://dummyimage.com/354x404.png/5fa2dd/ffffff'),
		('8','http://dummyimage.com/246x741.png/10000/ffffff'),
		('8','http://dummyimage.com/302x437.png/dddddd/000000'),
		('8','http://dummyimage.com/276x765.png/10000/ffffff'),
		('9','http://dummyimage.com/225x545.png/dddddd/000000'),
		('9','http://dummyimage.com/339x545.png/ff4444/ffffff'),
		('9','http://dummyimage.com/297x643.png/5fa2dd/ffffff'),
		('10','http://dummyimage.com/283x528.png/5fa2dd/ffffff'),
		('10','http://dummyimage.com/372x642.png/ff4444/ffffff'),
		('10','http://dummyimage.com/257x422.png/5fa2dd/ffffff'),
		('11','http://dummyimage.com/386x700.png/5fa2dd/ffffff'),
		('11','http://dummyimage.com/385x632.png/5fa2dd/ffffff'),
		('11','http://dummyimage.com/204x641.png/10000/ffffff'),
		('12','http://dummyimage.com/376x702.png/ff4444/ffffff'),
		('12','http://dummyimage.com/278x764.png/10000/ffffff'),
		('12','http://dummyimage.com/311x591.png/10000/ffffff'),
		('13','http://dummyimage.com/209x587.png/dddddd/000000'),
		('13','http://dummyimage.com/290x457.png/dddddd/000000'),
		('13','http://dummyimage.com/206x573.png/ff4444/ffffff'),
		('13','http://dummyimage.com/247x745.png/10000/ffffff'),
		('14','http://dummyimage.com/208x660.png/ff4444/ffffff'),
		('14','http://dummyimage.com/240x728.png/5fa2dd/ffffff'),
		('14','http://dummyimage.com/258x553.png/dddddd/000000'),
		('15','http://dummyimage.com/254x576.png/10000/ffffff'),
		('15','http://dummyimage.com/350x729.png/ff4444/ffffff'),
		('15','http://dummyimage.com/380x695.png/dddddd/000000'),
		('16','http://dummyimage.com/312x459.png/dddddd/000000'),
		('16','http://dummyimage.com/353x491.png/5fa2dd/ffffff'),
		('16','http://dummyimage.com/329x657.png/dddddd/000000'),
		('17','http://dummyimage.com/204x585.png/ff4444/ffffff'),
		('17','http://dummyimage.com/314x567.png/ff4444/ffffff'),
		('17','http://dummyimage.com/264x450.png/ff4444/ffffff'),
		('18','http://dummyimage.com/344x731.png/ff4444/ffffff'),
		('18','http://dummyimage.com/356x702.png/ff4444/ffffff'),
		('18','http://dummyimage.com/317x593.png/dddddd/000000'),
		('19','http://dummyimage.com/326x564.png/ff4444/ffffff'),
		('19','http://dummyimage.com/321x488.png/10000/ffffff'),
		('19','http://dummyimage.com/309x497.png/5fa2dd/ffffff'),
		('20','http://dummyimage.com/282x688.png/dddddd/000000'),
		('20','http://dummyimage.com/369x639.png/10000/ffffff'),
		('20','http://dummyimage.com/399x770.png/ff4444/ffffff'),
		('21','http://dummyimage.com/357x777.png/ff4444/ffffff'),
		('21','http://dummyimage.com/319x552.png/dddddd/000000'),
		('21','http://dummyimage.com/366x411.png/5fa2dd/ffffff'),
		('21','http://dummyimage.com/363x603.png/ff4444/ffffff'),
		('22','http://dummyimage.com/238x618.png/ff4444/ffffff'),
		('22','http://dummyimage.com/356x747.png/5fa2dd/ffffff'),
		('22','http://dummyimage.com/211x751.png/5fa2dd/ffffff'),
		('23','http://dummyimage.com/348x702.png/dddddd/000000'),
		('23','http://dummyimage.com/228x541.png/10000/ffffff'),
		('23','http://dummyimage.com/259x795.png/dddddd/000000'),
		('24','http://dummyimage.com/232x486.png/5fa2dd/ffffff'),
		('24','http://dummyimage.com/214x752.png/5fa2dd/ffffff'),
		('24','http://dummyimage.com/235x754.png/10000/ffffff');

insert into coupons (Code,Discount,ValidFrom,ValidTo)
values	('IHIE04276T','5','2022-10-15','2022-10-29'),
		('DPNY4087BV','7','2022-11-01','2022-11-15'),
		('PEUR2788DK','7','2022-10-17','2022-12-31'),
		('IJVF3076UH','10','2022-10-15','2022-10-29'),
		('JDPQ2687P9','5','2022-10-19','2022-10-31'),
		('NOPU83468M','10','2022-11-05','2022-11-19'),
		('BDEU1381CH','10','2022-10-21','2022-11-04'),
		('IMIT6579JT','20','2022-11-05','2022-11-19'),
		('SLTE4096M6','10','2022-10-15','2022-10-29'),
		('SCFN4853YO','5','2022-12-15','2022-12-31'),
		('ZMOU3805IK','10','2022-10-25','2022-11-25'),
		('CWZC3098KT','7','2022-11-05','2022-11-19'),
		('PRCH9217GX','20','2022-10-27','2022-11-10'),
		('MLII2281C1','10','2022-11-05','2022-11-19'),
		('KHQY38265G','5','2022-11-01','2022-11-15'),
		('HNLV6286UC','10','2022-10-15','2022-10-29'),
		('BPSL8986DS','7','2022-10-31','2022-11-13'),
		('CSOJ9348FU','7','2022-11-10','2022-11-24'),
		('TTUL7900S4','10','2022-10-15','2022-10-29'),
		('PMPA163550','5','2022-12-01','2022-12-31'),
		('CDRQ1035KH','10','2022-11-05','2022-11-19'),
		('NWVQ6916IQ','10','2022-12-01','2022-11-30');

		
insert into CC_details (MemberId,MethID,Owner,`Number`,Validity)
values 	('1','1','Sherri Millican','4041370389959','2023-04'),
		('2','1','Gay Simms','4017950159723','2024-06'),
		('3','1','Sharona Gawler','4041376783149054','2023-09'),
		('4','1','Vin Arnaldo','4017955854153','2025-10'),
		('5','1','Charmane Brewood','4041374551576384','2026-01'),
		('6','1','Devonne Capozzi','372301724786878','2023-11'),
		('7','1','Inglebert Serrurier','5010126941575904','2024-08'),
		('8','1','Ronald Lindborg','5007666199997016','2023-05'),
		('9','1','Dalt Restill','5010125259251132','2023-12'),
		('10','1','Lem Wolsey','5010127030641862','2025-02'),
		('11','1','Aguie Alishoner','5010123487803402','2023-05'),
		('12','1','Darleen Bertl','3555289976731267','2025-03'),
		('13','1','Eadith McGarvey','5112023804674204','2024-01'),
		('14','1','Fania Daymond','676397984265231715','2023-02'),
		('15','1','Charlotta OGlassane','5602244627502763','2024-03'),
		('16','1','Teodora Timmis','5602211772859512','2026-07'),
		('17','1','Sallyanne Merriott','374288371831230','2026-07'),
		('18','1','Lizette Holtom','374283879813137','2023-02'),
		('19','1','Gan Ruhben','374288174072693','2025-12'),
		('20','1','Gae Reims','374288240966340','2024-02'),
		('21','1','Marcus Moncarr','374288403686859','2023-04'),
		('22','1','Sarena Pogue','374288687912468','2024-09'),
		('23','1','Doloritas Standring','374288474935425','2024-03'),
		('24','1','Gilberta Cabotto','374283225549377','2024-11'),
		('25','1','Dennis Gemelli','374288774034333','2023-01'),
		('26','1','Delaney Brelsford','5048378425111906','2023-10'),
		('27','1','Alic Gabbat','5048376481301718','2024-02'),
		('28','1','Weston Gravatt','5108756936230066','2024-11'),
		('29','1','Rosamund McIvor','5048371642044588','2024-05'),
		('30','1','Vick Edgeller','5048379268064939','2024-12'),
		('31','1','Dagmar Shellard','5108750891322703','2023-04'),
		('32','1','Oswell ODaly','5048374701800213','2025-04'),
		('33','1','Erda Astling','5048377601094043','2025-01'),
		('34','1','Glendon Proom','5108752145348211','2024-12'),
		('35','1','Sol?ne Allanson','4041599927509582','2026-04'),
		('36','1','Ad?lie Casone','4041599897899575','2026-05'),
		('37','1','S?verine Redfern','4041599162835049','2024-08'),
		('38','1','Eli?s McLernon','4041597643758','2024-06'),
		('39','1','Winna Sandwich','5002357131715634','2026-06'),
		('40','1','Anna Widmann','4017950280552','2025-08'),
		('41','1','Robinson Riddiough','3549585597091620','2024-04'),
		('42','1','Ofelia Casa1io','5602248893011973722','2026-07');
		
insert into banktransfer (MemberId,MethID,Owner,IBAN,BIC,Institution)
values 	('12','2','Darleen Bertl','DE42 ZWDI OYO1 AFBP GWLG 5HXI','NTSBDEB1XXX','N26 Bank'), 
		('13','2','Eadith McGarvey','DE72 8137 8474 56AZ BEWX PIHY G39','PBNKDEFFXXX','Postbank'),
		('14','2','Fania Daymond','DE17 7190 3354 731','HASPDEHHXXX','Hamburger Sparkasse'),
		('15','2','Charlotta OGlassane','DE14 5396 3429 3976 3718 7991','PBNKDEFFXXX','Postbank'),
		('16','2','Teodora Timmis','DE75 2347 6410 721F BD8L K8FZ C52','PBNKDEFFXXX','Postbank'),
		('17','2','Sallyanne Merriott','GB26 5815 9377 0872 7059 4886','HBUKGB4BXXX','HSBC UK'),
		('18','2','Lizette Holtom','GB21 4426 QSVX GBDU UZYZ','HBUKGB4BXXX','HSBC UK'),
		('19','2','Gan Ruhben','GB95 9680 9481 0758 5371 227','MYMBGB2L','Metro Bank'),
		('20','2','Gae Reims','GB80 3614 5393 25HE 8BNT YSAE D35','TSBSGB2AXXX','TSB Bank'),
		('21','2','Marcus Moncarr','GB18 675S Y3OS 2ML0 YOJB','MYMBGB2L','Metro Bank'),
		('22','2','Sarena Pogue','GB89 8632 1964 4219 9213 1','HBUKGB4BXXX','HSBC UK'),
		('23','2','Doloritas Standring','GB15 4414 9127 044','MYMBGB2L','Metro Bank'),
		('24','2','Gilberta Cabotto','GB45 9178 HTJF JZE2 EBAV CIQN RPWB','MYMBGB2L','Metro Bank'),
		('25','2','Dennis Gemelli','GB48 F958 5165 051E TRY5 GMPM GHO','HBUKGB4BXXX','HSBC UK'),
		('35','2','Sol?ne Allanson','CH22 8361 0619 0889 8773 1348 3573','UBSWCHZH80A','UBS'),
		('36','2','Ad?lie Casone','CH39 4843 302A CPMW SPYM NNEY GNN','UBSWCHZH80A','UBS'),
		('37','2','S?verine Redfern','CH47 6350 8237 2726 4790 44','ZKBKCHZZ80A','Z?rcher Kantonalbank'),
		('38','2','Eli?s McLernon','CH03 4565 8890 76B6 T3ZB PYD0 147','UBSWCHZH80A','UBS'),
		('40','2','Anna Widmann','DE10 5136 4248 2122 4232 11','BELADEBEXXX','Berliner Sparkasse '),
		('42','2','Ofelia Casa1io','JP51 VCRY 4JNP BIAZ VGRF Q','KOJAHKH1','Japan Finance Corporation');
		
insert into paypal (MemberId,MethID,PPAccount)
values 	('1','3','smillican2p@house.gov'),
		('2','3','gsimms2q@list-manage.com'),
		('3','3','sgawler2r@princeton.edu'),
		('4','3','varnaldo2s@dyndns.org'),
		('5','3','cbrewood2t@walmart.com'),
		('6','3','dcapozzi6@hibu.com'),
		('7','3','iserrurier7@yellowpages.com'),
		('8','3','rlindborg15@ehow.com'),
		('9','3','drestill16@salon.com'),
		('10','3','lwolsey17@virginia.edu'),
		('11','3','aalishoner18@yahoo.com'),
		('12','3','dbertl1@goodreads.com'),
		('13','3','emcgarvey2@abc.net.au'),
		('14','3','fdaymond3@hao123.com'),
		('15','3','coglassane4@archive.org'),
		('16','3','ttimmis5@nbcnews.com'),
		('17','3','smerriotte@indiegogo.com'),
		('18','3','lholtomg@thetimes.co.uk'),
		('19','3','gruhbenh@icio.us'),
		('20','3','greimsi@sun.com'),
		('21','3','mmoncarrj@constantcontact.com'),
		('22','3','spoguek@altervista.org'),
		('23','3','dstandringl@fda.gov'),
		('24','3','gcabottom@tuttocitta.it'),
		('25','3','dgemellin@twitter.com'),
		('26','3','dbrelsford16@google.co.uk'),
		('27','3','agabbat17@fotki.com'),
		('28','3','wgravatt18@ucoz.ru'),
		('29','3','rmcivor19@drupal.org'),
		('30','3','vedgeller1b@state.tx.us'),
		('31','3','dshellard1c@technorati.com'),
		('32','3','oodaly1d@hao123.com'),
		('33','3','eastling1e@blogtalkradio.com'),
		('34','3','gproom1f@pagesperso-orange.fr'),
		('35','3','zallanson1@europa.eu'),
		('36','3','acasone2@bloglines.com'),
		('37','3','aredfern3@webmd.com'),
		('38','3','gmclernon4@de.vu'),
		('39','3','wsandwich9@ustream.tv'),
		('40','3','annaw199845@gmx.de'),
		('41','3','rriddiough2g@tmall.com'),
		('42','3','ocasa1io82@google.cn');
		

insert into invoices (BookingID,FeeType,FeeClass,InvoiceDate,BillingAdressID,BookingAmount,DiscountAmount,FeeAmount,BillingAmount,CurCode,PaymentMethod,Paid,Refunded)	
	values	('1','G','B','2022-10-07','15','1260','0','126','1386','AUD','2','1','0'),
			('2','G','I','2022-10-19','8','900','5','45','900','AUD','1','1','1'),
			('3','G','I','2022-10-18','20','960','10','48','912','CAD','3','1','0'),
			('4','G','I','2022-10-26','23','3000','10','150','2850','CAD','2','1','0'),
			('5','G','I','2022-11-05','2','800','7','40','784','EUR','3','1','0'),
			('6','G','I','2022-11-02','6','1540','10','77','1463','EUR','1','1','0'),
			('7','G','I','2022-10-25','14','504','10','25.2','478.8','GBP','1','1','0'),
			('8','G','I','2022-10-18','25','294','10','14.7','279.3','GBP','2','1','1'),
			('9','G','I','2022-10-21','3','1246','10','62.3','1183.7','GBP','3','1','0'),
			('10','G','I','2022-11-11','5','585','10','29.25','555.75','GBP','1','1','0'),
			('11','G','I','2022-10-22','7','3500','7','175','3430','USD','1','1','0'),
			('12','G','B','2022-10-31','36','1080','10','108','1080','USD','2','1','0'),
			('13','G','I','2022-10-30','43','2600','10','130','2470','USD','1','1','0'),
			('14','G','B','2022-10-15','11','720','10','72','720','USD','1','1','0'),
			('15','G','I','2022-10-09','45','1920','0','96','2016','USD','3','1','1'),
			('16','G','I','2022-10-15','31','840','10','42','798','EUR','3','1','0'),
			('17','G','I','2022-10-16','17','588','10','29.4','558.6','GBP','1','1','0'),
			('18','G','I','2022-10-12','22','480','10','24','456','EUR','2','1','0'),
			('19','G','I','2022-10-27','39','387520','5','19376','387520','JPY','1','1','0'),
			('20','G','I','2022-11-26','9','3000','7','150','2940','USD','3','1','0'),
			('21','G','I','2022-10-09','45','1200','0','60','1260','CAD','1','1','0'),
			('22','G','I','2022-10-01','16','600','0','30','630','EUR','2','1','0'),
			('23','G','I','2022-10-25','40','1080','10','54','1026','USD','1','1','0'),
			('24','G','I','2022-11-11','4','910','5','45.5','910','USD','1','1','1');


insert into CouponsJournal (CouponID,redeemedOn,InvoiceID)
	values	('4','2022-10-18','8'),
			('3','2022-10-22','11'),
			('7','2022-10-30','13'),
			('20','2022-10-27','19'),
			('5','2022-10-19','2'),
			('9','2022-10-18','3'),
			('16','2022-10-26','4'),
			('2','2022-11-05','5'),
			('9','2022-11-02','6'),
			('19','2022-10-25','7'),
			('7','2022-10-21','9'),
			('21','2022-11-11','10'),
			('7','2022-10-31','12'),
			('4','2022-10-15','14'),
			('19','2022-10-15','16'),
			('16','2022-10-16','17'),
			('16','2022-10-12','18'),
			('2','2022-11-26','20'),
			('7','2022-10-25','23'),
			('15','2022-11-11','24');
		
		
insert into receipts(BookingID,HostID,FeeType,FeeClass,BookingAmount,FeeAmount,PayoutAmount,CurCode)
values 	('1','1','H','A','1260','12.6','1247.4','AUD'),
		('2','2','H','B','900','45','855','AUD'),
		('3','3','H','A','960','9.6','950.4','CAD'),
		('4','4','H','A','3000','30','2970','CAD'),
		('5','5','H','I','800','24','776','EUR'),
		('6','6','H','A','1540','15.4','1524.6','EUR'),
		('7','7','H','A','504','5.04','498.96','GBP'),
		('8','8','H','I','294','8.82','285.18','GBP'),
		('9','9','H','A','1246','12.46','1233.54','GBP'),
		('10','10','H','A','585','5.85','579.15','GBP'),
		('11','11','H','A','3500','35','3465','USD'),
		('12','12','H','B','1080','54','1026','USD'),
		('13','13','H','A','2600','26','2574','USD'),
		('14','14','H','A','720','7.2','712.8','USD'),
		('15','15','H','A','1920','19.2','1900.8','USD'),
		('16','16','H','B','840','42','798','CHF'),
		('17','7','H','A','588','5.88','582.12','GBP'),
		('18','18','H','A','480','4.8','475.2','EUR'),
		('19','19','H','A','387520','3875.2','383644.8','JPY'),
		('20','11','H','A','3000','30','2970','USD'),
		('21','3','H','A','1200','12','1188','CAD'),
		('22','5','H','I','600','18','582','EUR'),
		('23','13','H','A','1080','10.8','1069.2','USD'),
		('24','12','H','B','910','45.5','864.5','USD');
		
	
	
	
-- all tables filled with data - test cases can now be run

