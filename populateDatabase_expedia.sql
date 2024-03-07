---------------------------------------------------------------------------------------------------------------------------------------------------
-- POPULATE SCRIPT FOR EXPEDIA DATABASE
---------------------------------------------------------------------------------------------------------------------------------------------------
/*
This only handles insert procedures so that you can just TRUNCATE any tables you want to re-fill, without worrying about re-running anything else.
*/
----------------------------------------------------------------------------------------------------------------------------------------------------
USE EXPEDIA;
GO
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Customer Types ------------------------------------------------------------------------------------------------------------------------------
INSERT INTO CUSTOMER_TYPE (customer_type_name, customer_type_descr)
VALUES
('Regular', 'Normal sign-up'),
('VIP', 'Extremely valuable customer'),
('Platinum', 'Top tier of yearly spending'),
('Business', 'Manages travel for a business or organization'),
('Employee', 'Eligible for special discounts');
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Gender --------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO GENDER (gender_name)
VALUES
('Female'), ('Male'), ('Nonbinary'), ('Other');
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Country -------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO COUNTRY(country_name, region_name)
VALUES
('United States','North America'),('Canada', 'North America'),
('China', 'Asia'), ('Thailand', 'Asia'), ('Japan','Asia'),
('Italy', 'Europe'), ('France','Europe');
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Reward Type ---------------------------------------------------------------------------------------------------------------------------------
INSERT INTO REWARD_TYPE(reward_type_name, reward_descr)
VALUES
('Loyalty','Earned via purchase'),
('Promo','Given as part of promotion'),
('Retention','Part of customer engagement');

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Language Type -------------------------------------------------------------------------------------------------------------------------------
INSERT INTO LANGUAGE(language_name)
VALUES
('English'),('French'),('Italian'),('Japanese'),('Simplified Chinese'),('Traditional Chinese'),('Thai');
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Currency Type -------------------------------------------------------------------------------------------------------------------------------
INSERT INTO CURRENCY(currency_name)
VALUES
('USD'),('Euro'),('CAD'),('Yuan'),('Yen');
GO

----------------------------------------------------------------------------------------------------------------------------------------------------
-- Add State ---------------------------------------------------------------------------------------------------------------------------------------
EXEC AddState @state_name = 'California', @country_name = 'United States';
EXEC AddState @state_name = 'Washington', @country_name = 'United States';
EXEC AddState @state_name = 'Alberta', @country_name = 'Canada';
EXEC AddState @state_name = 'Guangdong', @country_name = 'China';
EXEC AddState @state_name = 'Bangkok', @country_name = 'Thailand';
EXEC AddState @state_name = 'Tokyo', @country_name = 'Japan';
EXEC AddState @state_name = 'Lombardy', @country_name = 'Italy';
EXEC AddState @state_name = 'IleDeFrance', @country_name = 'France';

GO

-- Add Customers using the PEEPS db ----------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_addCustomer
@RunNumber INT
AS
DECLARE
    @w_first VARCHAR(60),
    @w_last VARCHAR(60),
    @w_birth DATE,
    @w_address VARCHAR(100),
    @w_city VARCHAR(10),
    @w_zip VARCHAR(25)

-- Vars for FK table row counts
DECLARE @CustomerRowCount INT = (SELECT COUNT(*) FROM Peeps.dbo.tblCUSTOMER)
DECLARE @CustomerTypeRowCount INT = (SELECT COUNT(*) FROM CUSTOMER_TYPE)
DECLARE @StateRowCount INT = (SELECT COUNT(*) FROM [STATE])
DECLARE @GenderRowCount INT = (SELECT COUNT(*) FROM [GENDER])

-- Vars for PK values
DECLARE @CustomerPK INT, @CustomerTypePK INT, @StatePK INT, @GenderPK INT
DECLARE @RAND INT

-- Loop:
WHILE @RunNumber > 0
BEGIN
    -- Customer info
    SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
    IF NOT EXISTS (SELECT * FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
	    BEGIN
	        PRINT 'Customer came back empty, running again'
            SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
            
            IF NOT EXISTS (SELECT * FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
            BEGIN
                PRINT 'Customer came back empty a second time...running a third time'
                SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
                                
                IF NOT EXISTS (SELECT * FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
                    BEGIN
                        SET @CustomerPK = 1
                    END
		    END
	    END

    SET @w_first = (SELECT customerFname FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
    SET @w_last = (SELECT customerLname FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
    SET @w_birth = (SELECT DateOfBirth FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
    SET @w_address = (SELECT CustomerAddress FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
    SET @w_city = (SELECT CustomerCity FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)
    SET @w_zip = (SELECT CustomerZIP FROM Peeps.dbo.tblCUSTOMER WHERE CustomerID = @CustomerPK)

    -- Customer Type
    SET @CustomerTypePK = (SELECT RAND() * @CustomerTypeRowCount + 1)
    IF NOT EXISTS (SELECT * FROM CUSTOMER_TYPE WHERE customer_type_id = @CustomerTypePK)
	    BEGIN
	        PRINT 'Customer Type came back empty, running again'
            SET @CustomerTypePK = (SELECT RAND() * @CustomerTypeRowCount + 1)
            IF NOT EXISTS (SELECT * FROM CUSTOMER_TYPE WHERE customer_type_id = @CustomerTypePK)
            BEGIN
                PRINT 'Customer Type came back empty a second time...running a third time'
                SET @CustomerTypePK = (SELECT RAND() * @CustomerTypeRowCount + 1)
                                
                IF NOT EXISTS (SELECT * FROM CUSTOMER_TYPE WHERE customer_type_id = @CustomerTypePK)
                    BEGIN
                        SET @CustomerTypePK = 1
                    END
		    END
	    END

    -- State
    SET @StatePK = (SELECT RAND() * @StateRowCount + 1)
    IF NOT EXISTS (SELECT * FROM [STATE] WHERE state_id = @StatePK)
	    BEGIN
	        PRINT 'State came back empty, running again'
            SET @StatePK = (SELECT RAND() * @StateRowCount + 1)
            IF NOT EXISTS (SELECT * FROM [STATE] WHERE state_id = @StatePK)
            BEGIN
                PRINT 'State came back empty a second time...running a third time'
                SET @StatePK = (SELECT RAND() * @StateRowCount + 1)
                                
                IF NOT EXISTS (SELECT * FROM [STATE] WHERE state_id = @StatePK)
                    BEGIN
                        SET @StatePK = 1
                    END
		    END
	    END
    
    -- Gender
    SET @GenderPK = (SELECT RAND() * @GenderRowCount + 1)
    IF NOT EXISTS (SELECT * FROM GENDER WHERE gender_id = @GenderPK)
	    BEGIN
	        PRINT 'Gender came back empty, running again'
            SET @GenderPK = (SELECT RAND() * @GenderRowCount + 1)
            IF NOT EXISTS (SELECT * FROM GENDER WHERE gender_id = @GenderPK)
            BEGIN
                PRINT 'Gender came back empty a second time...running a third time'
                SET @GenderPK = (SELECT RAND() * @GenderRowCount + 1)
                                
                IF NOT EXISTS (SELECT * FROM GENDER WHERE gender_id = @GenderPK)
                    BEGIN
                        SET @GenderPK = 1
                    END
		    END
	    END

    INSERT INTO CUSTOMER(cust_Fname, cust_Lname, birth_date, address, city, postal_code, state_id, customer_type_id, gender_id)
    VALUES(@w_first, @w_last, @w_birth, @w_address, @w_city, @w_zip, @StatePK, @CustomerTypePK, @GenderPK)

    SET @RunNumber = @RunNumber - 1
END
GO

-- RUN Populate Customer Table
-- NOTE: This is either horribly unoptimized or slow due to grabbing rows from another db. Took ~19 mins to add 1000 rows. Only run if really needed!
-- EXEC wrapper_addCustomer 1000

-- Add Rewards ----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_addRewards
@RunNumber INT
AS
DECLARE
    @w_points INT,
    @w_date DATETIME,
    @w_expiry DATETIME

-- Vars for FK table row counts
DECLARE @CustomerRowCount INT = (SELECT COUNT(*) FROM CUSTOMER)
DECLARE @RewardTypeRowCount INT = (SELECT COUNT(*) FROM REWARD_TYPE)

-- Vars for PK values
DECLARE @CustomerPK INT, @RewardTypePK INT
DECLARE @RAND INT

-- Loop:
WHILE @RunNumber > 0
BEGIN
    SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
    IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
	    BEGIN
	        PRINT 'Customer came back empty, running again'
            SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
            IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
            BEGIN
                PRINT 'Customer came back empty a second time...running a third time'
                SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)              
                IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
                    BEGIN
                        SET @CustomerPK = 1
                    END
		    END
	    END

    SET @RewardTypePK = (SELECT RAND() * @RewardTypeRowCount + 1)
    IF NOT EXISTS (SELECT * FROM REWARD_TYPE WHERE reward_type_id = @RewardTypePK)
	    BEGIN
	        PRINT 'Reward Type came back empty, running again'
            SET @RewardTypePK = (SELECT RAND() * @RewardTypeRowCount + 1)
            IF NOT EXISTS (SELECT * FROM REWARD_TYPE WHERE reward_type_id = @RewardTypePK)
            BEGIN
                PRINT 'Reward Type came back empty a second time...running a third time'
                SET @RewardTypePK = (SELECT RAND() * @RewardTypeRowCount + 1)
                IF NOT EXISTS (SELECT * FROM REWARD_TYPE WHERE reward_type_id = @RewardTypePK)
                    BEGIN
                        SET @RewardTypePK = 1
                    END
		    END
	    END

    SET @w_points = (SELECT RAND() * @RewardTypePK + 100)
    SET @w_date = GETDATE()
    SET @w_expiry = DATEADD(year, 1, @w_date)

    INSERT INTO REWARD(reward_points, reward_date, expire_date, customer_id, reward_type_id)
    VALUES(@w_points, @w_date, @w_expiry, @CustomerPK, @RewardTypePK)
    
    SET @RunNumber = @RunNumber - 1
END

GO

-- Add rewards to table
-- EXEC wrapper_addRewards 10000

-- Add Bookings ----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_addBookings
@RunNumber INT
AS
DECLARE 
    @w_dateBooked DATE,
    @w_price Numeric(8,2),
    @w_paymentMethod VARCHAR(20) = 'Online',
    @CustomerPK INT

DECLARE @CustomerRowCount INT = (SELECT COUNT(*) FROM CUSTOMER)

-- Loop:
WHILE @RunNumber > 0
BEGIN
    SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
    IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
	    BEGIN
	        PRINT 'Customer came back empty, running again'
            SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)
            IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
            BEGIN
                PRINT 'Customer came back empty a second time...running a third time'
                SET @CustomerPK = (SELECT RAND() * @CustomerRowCount + 1)              
                IF NOT EXISTS (SELECT * FROM customer WHERE customer_id = @CustomerPK)
                    BEGIN
                        SET @CustomerPK = 1
                    END
		    END
	    END

    SET @w_dateBooked = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 1820 ), '2017-01-01')
    SET @w_price = ROUND(RAND(CHECKSUM(NEWID())) * (1000), 2)

    INSERT INTO BOOKING(customer_id, date_booked, total_price, payment_method)
    VALUES(@CustomerPK, @w_dateBooked, @w_price, @w_paymentMethod)

    SET @RunNumber = @RunNumber - 1
END
GO
-- Add bookings
-- EXEC wrapper_addBookings 10000

-- Add Sub-Bookings ----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_AddSubAndDetail
@RunNumber INT
AS
DECLARE
    @w_subPrice NUMERIC(8,2),
    @w_quantity INT,
    @bookingPrice NUMERIC(8,2),
    @statePK INT,
    @bookingPK INT,
    @subPK INT

DECLARE @BookingRowCount INT = (SELECT COUNT(*) FROM BOOKING)
DECLARE @StateRowCount INT = (SELECT COUNT(*) FROM [STATE])

-- Loop:
WHILE @RunNumber > 0
BEGIN
    -- Booking
    SET @BookingPK = (SELECT RAND() * @BookingRowCount + 10000)
    IF NOT EXISTS (SELECT * FROM BOOKING WHERE booking_id = @BookingPK)
	    BEGIN
	        PRINT 'Booking came back empty, running again'
            SET @BookingPK = (SELECT RAND() * @BookingRowCount + 10000)              
                IF NOT EXISTS (SELECT * FROM BOOKING WHERE booking_id = @BookingPK)
                    BEGIN
                        SET @BookingPK = 1
                    END
		END
    -- State
    SET @StatePK = (SELECT RAND() * @StateRowCount + 1)
    IF NOT EXISTS (SELECT * FROM [STATE] WHERE state_id = @StatePK)
	    BEGIN
	        PRINT 'State came back empty, running again'
            SET @StatePK = (SELECT RAND() * @StateRowCount + 1)
                IF NOT EXISTS (SELECT * FROM [STATE] WHERE state_id = @StatePK)
                    BEGIN
                        SET @StatePK = 1
                    END
	    END

    -- Price based on booking price
    SET @bookingPrice = (SELECT total_price FROM BOOKING WHERE booking_id = @BookingPK)
    SET @w_subPrice = ROUND(RAND()*(@bookingPrice-1)+1,2)

    INSERT INTO SUB_BOOKING(sub_price, state_id)
    VALUES (@w_subPrice, @StatePK)
    SELECT @SubPK = SCOPE_IDENTITY();

    SET @w_quantity = ROUND(RAND()*(6-1)+1,0)

    INSERT INTO BOOKING_DETAIL(booking_id, sub_booking_id, quantity)
    VALUES(@BookingPK, @SubPK, @w_quantity)
    SET @RunNumber = @RunNumber - 1
END
GO
-- Add sub bookings and details
-- EXEC wrapper_AddSubAndDetail 10000

-- Add Refunds ----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_AddRefunds
@RunNumber INT
AS
DECLARE
    @w_refundDate DATE,
    @w_refundAmount Numeric(8,2),
    @BookingPK INT,
    @maxPrice NUMERIC(8,2),
    @bookingDate DATE

DECLARE @BookingRowCount INT = (SELECT COUNT(*) FROM BOOKING)

-- Loop:
WHILE @RunNumber > 0
BEGIN
    -- Booking
    SET @BookingPK = (SELECT RAND() * @BookingRowCount + 10000)
    IF NOT EXISTS (SELECT * FROM BOOKING WHERE booking_id = @BookingPK)
	    BEGIN
	        PRINT 'Booking came back empty, running again'
            SET @BookingPK = (SELECT RAND() * @BookingRowCount + 10000)              
                IF NOT EXISTS (SELECT * FROM BOOKING WHERE booking_id = @BookingPK)
                    BEGIN
                        SET @BookingPK = 1
                    END
		END

    SET @maxPrice = (SELECT total_price FROM BOOKING WHERE booking_id = @BookingPK)
    SET @w_refundAmount = ROUND(RAND()*(@maxPrice-1)+1,2)

    SET @bookingDate = (SELECT date_booked FROM BOOKING WHERE booking_id = @BookingPK)
    SET @w_refundDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 31 ), @bookingDate) 

    INSERT INTO BOOKING_REFUND(refund_date, refund_amount, booking_id)
    VALUES(@w_refundDate, @w_refundAmount, @BookingPK)
    SET @RunNumber = @RunNumber - 1
END
GO
-- Add Refunds
-- EXEC wrapper_AddRefunds 1000

-- Add Reviews ----------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE wrapper_addReviews
@RunNumber INT
AS
DECLARE
    @w_ratingNum INT,
    @w_reviewDesc VARCHAR(50) = 'Review text',
    @w_bookingDate DATE,
    @w_reviewDate DATE,
    @SubPK INT

DECLARE @SubRowCount INT = (SELECT COUNT(*) FROM SUB_BOOKING)

-- Loop:
WHILE @RunNumber > 0
BEGIN
    -- Sub Booking
    SET @SubPK = (SELECT RAND() * @SubRowCount + 20000)
    IF NOT EXISTS (SELECT * FROM SUB_BOOKING WHERE sub_booking_id = @SubPK)
	    BEGIN
	        PRINT 'Sub Booking came back empty, running again'
            SET @SubPK = (SELECT RAND() * @SubRowCount + 20000)              
                IF NOT EXISTS (SELECT * FROM SUB_BOOKING WHERE sub_booking_id = @SubPK)
                    BEGIN
                        SET @SubPK = 1
                    END
		END
    
    SET @w_bookingDate = (
        SELECT b.date_booked
        FROM BOOKING b
            JOIN BOOKING_DETAIL bd ON bd.booking_id = b.booking_id
            JOIN SUB_BOOKING sb ON sb.sub_booking_id = bd.sub_booking_id
        WHERE sb.sub_booking_id = @SubPK)

    SET @w_reviewDate = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 364 ), @w_bookingDate)
    SET @w_ratingNum = ROUND(RAND()*(5-1)+1,0)

    INSERT INTO REVIEW(sub_booking_id, rating_numeric, review_body, review_date)
    VALUES (@SubPK, @w_ratingNum, @w_reviewDesc, @w_reviewDate)
    SET @RunNumber = @RunNumber - 1
END
GO

-- Add reviews
-- EXEC wrapper_addReviews 5000