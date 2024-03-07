----------------------------------------------------------------------------------------------------
-- BUILD SCRIPT FOR EXPEDIA DATABASE
----------------------------------------------------------------------------------------------------
/*
Contains compiled code from deliverables:
- Project 4: Stored Procedures
- Project 5: Check Constraints
- Project 6: Computed Columns

This only contains the code to set up the database - nothing is inserted at this stage! Inserts handled in separate script to make it manageable.

Run the following commented-out lines to tear down DB:
DROP TABLE IF EXISTS REWARD, REWARD_TYPE, Account_Currency, Account_Language, Account, Currency, Language, booking_refund, booking, search_history,customer, state, country, gender, customer_type;
*/

USE EXPEDIA;
----------------------------------------------------------------------------------------------------
-- 1) BUILD TABLES
----------------------------------------------------------------------------------------------------
CREATE TABLE CUSTOMER_TYPE (
    customer_type_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_type_name varchar(30),
    customer_type_descr varchar(55)
);

CREATE TABLE GENDER (
    gender_id int IDENTITY(1,1) primary key,
    gender_name varchar(20)
);

CREATE TABLE COUNTRY (
    country_id int IDENTITY(1,1) primary key,
    country_name varchar(50),
    region_name varchar(50)
);

CREATE TABLE STATE (
    state_id int IDENTITY(1,1) PRIMARY KEY,
    state_name varchar(50),
    country_id int REFERENCES COUNTRY (country_id)
);

CREATE TABLE CUSTOMER (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    cust_Fname varchar (60) NOT NULL,
    cust_Lname varchar (60) NOT NULL,
    birth_date DATE NULL,
    address varchar(120) NULL,
    city varchar(75),
    postal_code varchar(25),
    state_id int references STATE(state_id),
    customer_type_id int references CUSTOMER_TYPE(customer_type_id),
    gender_id int references GENDER(gender_id)
);

CREATE TABLE SEARCH_HISTORY (
    search_record_id int IDENTITY(1,1) primary key,
    search_frequency int,
    search_service_type varchar(50),
    search_term varchar(50),
    customer_id int REFERENCES CUSTOMER(customer_id)
);

CREATE TABLE BOOKING (
    booking_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT REFERENCES CUSTOMER,
    date_booked DATE,
    total_price NUMERIC(8,2),
    payment_method varchar(20)
);

CREATE TABLE BOOKING_REFUND (
    refund_id INT IDENTITY(1,1) PRIMARY KEY,
    refund_date DATETIME,
    refund_amount NUMERIC(8,2),
    booking_id INT REFERENCES BOOKING
)

CREATE TABLE LANGUAGE (
    language_id INT IDENTITY(1,1) PRIMARY KEY,
    language_name VARCHAR(50)
);

CREATE TABLE CURRENCY (
    currency_id INT IDENTITY(1,1) PRIMARY KEY,
    currency_name VARCHAR(10)
);

CREATE TABLE ACCOUNT (
    account_name VARCHAR(20) PRIMARY KEY,
    customer_id INT,
    password VARCHAR(20),
    email VARCHAR(50),
    tel VARCHAR(20),
    language_in_use_id INT,
    currency_in_use_id INT,
    realtime_city VARCHAR(30),
    FOREIGN KEY (language_in_use_id) REFERENCES LANGUAGE(language_id),
    FOREIGN KEY (currency_in_use_id) REFERENCES CURRENCY(currency_id)
);

CREATE TABLE ACCOUNT_LANGUAGE (
    language_in_use_id INT IDENTITY(1,1) PRIMARY KEY,
    language_id INT,
    account_name VARCHAR(20),
    FOREIGN KEY (language_id) REFERENCES LANGUAGE(language_id),
    FOREIGN KEY (account_name) REFERENCES ACCOUNT(account_name)
);

CREATE TABLE ACCOUNT_CURRENCY (
    currency_in_use_id INT IDENTITY(1,1) PRIMARY KEY,
    currency_id INT,
    account_name VARCHAR(20),
    FOREIGN KEY (currency_id) REFERENCES CURRENCY(currency_id),
    FOREIGN KEY (account_name) REFERENCES ACCOUNT(account_name)
);

CREATE TABLE REWARD_TYPE (
    reward_type_id INT IDENTITY(1,1) PRIMARY KEY,
    reward_descr varchar(500),
    reward_type_name varchar(50)
);

CREATE TABLE REWARD (
    reward_id INT IDENTITY(1,1) PRIMARY KEY,
    reward_points INT,
    reward_date DATETIME,
    expire_date DATETIME,
    customer_id INT,
    reward_type_id INT,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (reward_type_id) REFERENCES REWARD_TYPE(reward_type_id)
);

CREATE TABLE SUB_BOOKING (
    sub_booking_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    sub_price NUMERIC(8,2) NULL,
    sub_address VARCHAR(200) NULL,
    sub_city VARCHAR(20) NULL,
    state_id INT REFERENCES [STATE] NULL,
    sub_tel VARCHAR(20) NULL,
);

CREATE TABLE REVIEW (
    review_id INT IDENTITY(1,1) NOT NULL,
    sub_booking_id INT REFERENCES SUB_BOOKING,
    rating_numeric NUMERIC(2,1) NULL,
    review_body VARCHAR(500) NULL,
    review_date DATE NULL
);

CREATE TABLE BOOKING_DETAIL (
    booking_id INT REFERENCES BOOKING,
    sub_booking_id INT REFERENCES SUB_BOOKING,
    quantity INT NULL,
    PRIMARY KEY (booking_id, sub_booking_id)
);

GO

----------------------------------------------------------------------------------------------------
-- 2) Stored Procedures
----------------------------------------------------------------------------------------------------
-- Add Customer
CREATE OR ALTER PROCEDURE AddCustomer
    @cust_Fname VARCHAR(30),
    @cust_Lname VARCHAR(30),
    @birth_date DATETIME,
    @address VARCHAR(100),
    @city VARCHAR(10),
    @postal_code INT,
    @state_name VARCHAR(50),
    @customer_type_name VARCHAR(30),
    @gender_name VARCHAR(20)
AS
BEGIN
    DECLARE @state_id INT, @customer_type_id INT, @gender_id INT

    -- Check and insert state if not exists
    SELECT @state_id = state_id FROM STATE WHERE state_name = @state_name
    IF @state_id IS NULL
    BEGIN
        INSERT INTO STATE (state_name) VALUES (@state_name)
        SET @state_id = SCOPE_IDENTITY()
    END

    -- Check and insert customer type if not exists
    SELECT @customer_type_id = customer_type_id FROM CUSTOMER_TYPE WHERE customer_type_name = @customer_type_name
    IF @customer_type_id IS NULL
    BEGIN
        INSERT INTO CUSTOMER_TYPE (customer_type_name, customer_type_descr) VALUES (@customer_type_name, 'Description for ' + @customer_type_name)
        SET @customer_type_id = SCOPE_IDENTITY()
    END

    -- Check and insert gender if not exists
    SELECT @gender_id = gender_id FROM GENDER WHERE gender_name = @gender_name
    IF @gender_id IS NULL
    BEGIN
        INSERT INTO GENDER (gender_name, gender_descr) VALUES (@gender_name, 'Description for ' + @gender_name)
        SET @gender_id = SCOPE_IDENTITY()
    END

    -- Insert customer
    INSERT INTO CUSTOMER (cust_Fname, cust_Lname, birth_date, address, city, postal_code, state_id, customer_type_id, gender_id)
    VALUES (@cust_Fname, @cust_Lname, @birth_date, @address, @city, @postal_code, @state_id, @customer_type_id, @gender_id)
END;
GO

-- Add Reward Points
CREATE OR ALTER PROCEDURE AddRewardPoints
    @customer_id INT,
    @reward_points INT,
    @reward_date DATETIME,
    @expire_date DATETIME,
    @reward_type_name VARCHAR(50)
AS
BEGIN
    DECLARE @reward_type_id INT

    -- Check and insert reward type if not exists and get the reward_type_id
    SELECT @reward_type_id = reward_type_id FROM REWARD_TYPE WHERE reward_type_name = @reward_type_name
    IF @reward_type_id IS NULL
    BEGIN
        -- Insert a new reward type if it does not exist. (if this part as needed)
        INSERT INTO REWARD_TYPE (reward_type_name, reward_descr)
        VALUES (@reward_type_name, 'Auto-generated description')
        SET @reward_type_id = SCOPE_IDENTITY()
    END

    -- Insert the reward record
    INSERT INTO REWARD (customer_id, reward_points, reward_date, expire_date, reward_type_id)
    VALUES (@customer_id, @reward_points, @reward_date, @expire_date, @reward_type_id)
END;
GO

-- ADD STATE
CREATE OR ALTER PROCEDURE AddState
@state_name VARCHAR(30),
@country_name VARCHAR(50)
AS
BEGIN
    DECLARE @country_id INT

    SELECT @country_id = country_id
    FROM COUNTRY
    WHERE country_name = @country_name

    IF @country_id IS NULL
    BEGIN
        PRINT 'Country not found. State cannot be added.'
        RETURN; -- Exiting the procedure if country or region not found.
    END

    IF EXISTS (
        SELECT 1
        FROM STATE
        WHERE state_name = @state_name AND country_id = @country_id
    )
    BEGIN
        PRINT 'State already exists for the given country.'
        RETURN; -- Exiting the procedure as the state already exists.
    END

    BEGIN TRANSACTION T1
    PRINT 'Inside Transaction'

    INSERT INTO STATE(country_id, state_name)
    VALUES (@country_id, @state_name)

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION T1
        PRINT 'Transaction rolled back due to error.'
    END
    ELSE
    BEGIN
        COMMIT TRANSACTION T1
        PRINT 'Transaction committed successfully.'
    END
END
GO

-- ADD SEARCH HISTORY
CREATE OR ALTER PROCEDURE AddSearchHistory
    @search_frequency INT,
    @search_service_type VARCHAR(50),
    @search_term VARCHAR(50),
    @cust_Fname VARCHAR(30),
    @cust_Lname VARCHAR(30),
    @birth_date DATETIME,
    @address VARCHAR(100),
    @city VARCHAR(10),
    @postal_code INT,
    @customer_type_name VARCHAR(30)
AS
BEGIN
    DECLARE @customer_id INT
    DECLARE @customer_type_id INT

    BEGIN TRY
        -- Check if customer exists, if not, add the customer
        IF NOT EXISTS (
            SELECT 1
            FROM CUSTOMER
            WHERE cust_Fname = @cust_Fname
            AND cust_Lname = @cust_Lname
            AND birth_date = @birth_date
        )
        BEGIN
            -- Retrieve or add customer type ID
            SELECT @customer_type_id = customer_type_id
            FROM CUSTOMER_TYPE
            WHERE customer_type_name = @customer_type_name

            IF @customer_type_id IS NULL
            BEGIN
                INSERT INTO CUSTOMER_TYPE (customer_type_name, customer_type_descr)
                VALUES (@customer_type_name, 'Description of ' + @customer_type_name)

                SELECT @customer_type_id = SCOPE_IDENTITY();
            END

            -- Add new customer
            INSERT INTO CUSTOMER (cust_Fname, cust_Lname, birth_date, address, city, postal_code, customer_type_id)
            VALUES (@cust_Fname, @cust_Lname, @birth_date, @address, @city, @postal_code, @customer_type_id)

            SET @customer_id = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            -- Customer already exists, retrieve customer ID
            SELECT @customer_id = customer_id
            FROM CUSTOMER
            WHERE cust_Fname = @cust_Fname
            AND cust_Lname = @cust_Lname
            AND birth_date = @birth_date
        END

        -- Add search history record
        INSERT INTO SEARCH_HISTORY (search_frequency, search_service_type, search_term, customer_id)
        VALUES (@search_frequency, @search_service_type, @search_term, @customer_id)
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;

GO
-- ADD LANGUAGE IN USE
CREATE OR ALTER PROCEDURE GetLanguageInUseID
    @LanguageName VARCHAR(50),
    @LanguageInUseID INT OUTPUT
AS
BEGIN
    SELECT @LanguageInUseID = language_in_use_id
    FROM ACCOUNT_LANGUAGE
    WHERE language_name = @LanguageName;
END
GO
CREATE OR ALTER PROCEDURE GetCurrencyInUseID
    @CurrencyName VARCHAR(50),
    @CurrencyInUseID INT OUTPUT
AS
BEGIN
    SELECT @CurrencyInUseID = currency_in_use_id
    FROM ACCOUNT_CURRENCY
    WHERE currency_name = @CurrencyName;
END
GO

-- INSERT NEW ACCOUNT

CREATE OR ALTER PROCEDURE InsertNewAccount
    @AccountName VARCHAR(20),
    @CustomerID INT,
    @Password VARCHAR(20),
    @Email VARCHAR(50),
    @Tel VARCHAR(20),
    @LanguageName VARCHAR(10),
    @CurrencyName VARCHAR(10),
    @RealtimeCity VARCHAR(30)
AS
BEGIN
    DECLARE @LanguageInUseID INT;
    DECLARE @CurrencyInUseID INT;

    EXEC GetLanguageInUseID
        @LanguageName = @LanguageName,
        @LanguageInUseID = @LanguageInUseID OUTPUT;

    IF @LanguageInUseID IS NULL
    BEGIN
        PRINT 'Hey...uhhhh....@LanguageInUseID is empty and will fail; check spelling?';
        THROW 54336, '@LanguageInUseID cannot be NULL; process is terminating', 1;
        RETURN;
    END

    EXEC GetCurrencyInUseID
        @CurrencyName = @CurrencyName,
        @CurrencyInUseID = @CurrencyInUseID OUTPUT;

    IF @CurrencyInUseID IS NULL
    BEGIN
        PRINT 'Hey...uhhhh....@CurrencyInUseID is empty and will fail; check spelling?';
        THROW 54336, '@CurrencyInUseID cannot be NULL; process is terminating', 1;
        RETURN;
    END

    BEGIN TRANSACTION InsertAccount
    BEGIN TRY
        INSERT INTO ACCOUNT (account_name, customer_id, password, email, tel, language_in_use_id, currency_in_use_id, realtime_city)
        VALUES (@AccountName, @CustomerID, @Password, @Email, @Tel, @LanguageInUseID, @CurrencyInUseID, @RealtimeCity);

        COMMIT TRANSACTION InsertAccount;
    END TRY
    BEGIN CATCH
        PRINT 'Hey...lots of trouble going on; rolling back';
        ROLLBACK TRANSACTION InsertAccount;
        THROW; -- Re-throw the original error
    END CATCH
END
GO

-- ADD BOOKING
CREATE OR ALTER PROCEDURE addBooking
@CustomerFirst VARCHAR(30),
@CustomerLast VARCHAR(30),
@CustomerBirthdate DATE,
@date_booked DATE,
@total_price NUMERIC(8,2),
@payment_method varchar(20)
AS
DECLARE @CustomerID INT
SET @CustomerID = (
    SELECT customer_id
    FROM CUSTOMER
    WHERE cust_Fname = @CustomerFirst
    AND cust_Lname = @CustomerLast
    AND birth_date = @CustomerBirthdate
)

IF @CustomerID IS NULL
    BEGIN
    PRINT 'Customer not found; check spelling';
    THROW 54547, 'Customer ID cannot be null; terminating process',1;
    END

BEGIN TRANSACTION txn1

INSERT INTO BOOKING(customer_id, date_booked, total_price,payment_method)
VALUES(@CustomerID, @date_booked, @total_price, @payment_method)
IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION txn1
    END
ELSE
    COMMIT TRANSACTION txn1

GO

-- ADD REFUND
CREATE OR ALTER PROCEDURE createRefund
@CustomerFirst VARCHAR(30),
@CustomerLast VARCHAR(30),
@date_booked DATE,
@date DATETIME,
@amount NUMERIC(8,2)
AS
DECLARE @bookingID INT, @maxRefund INT

SET @bookingID = (
    SELECT booking_id
    FROM booking B JOIN customer C ON C.customer_id = B.customer_id
    WHERE C.Cust_Fname = @CustomerFirst
    AND C.Cust_Lname = @CustomerLast
    AND B.date_booked = @date_booked)

IF @bookingID IS NULL
    BEGIN
    PRINT 'Booking not found; check spelling and date';
    THROW 54548, 'Booking ID cannot be null; terminating process',1;
    END

SET @maxRefund = (
    SELECT total_price
    FROM BOOKING
    WHERE booking_id = @bookingID
)

IF @amount > @maxRefund
    BEGIN
    PRINT 'Refund cannot be more than price paid; check amount';
    THROW 54549, 'Refund cannot be more than max; terminating process',1;
    END

BEGIN TRANSACTION txn1

INSERT INTO BOOKING_REFUND(refund_date, refund_amount, booking_id)
VALUES(@date, @amount, @bookingID)

IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION txn1
    END
ELSE
    COMMIT TRANSACTION txn1

GO
----------------------------------------------------------------------------------------------------
-- 3)  CHECK CONSTRAINTS (aka 'BUSINESS RULE')
----------------------------------------------------------------------------------------------------
-- 1. No customer can spend more reward points than the total price of the bookings.
CREATE OR ALTER FUNCTION fnRewardPointsCheck()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INTEGER = 0;

    IF EXISTS (
        SELECT B.customer_id
        FROM BOOKING B
        JOIN (
            SELECT customer_id, SUM(reward_points) AS total_reward_points
            FROM REWARD
            GROUP BY customer_id
        ) R ON B.customer_id = R.customer_id
        WHERE B.total_price < R.total_reward_points / 140
    )
    BEGIN
        SET @RET = 1;
    END

    RETURN @RET;
END;
GO

-- Verify the function
SELECT dbo.fnRewardPointsCheck();

-- Add check constraint
ALTER TABLE REWARD WITH NOCHECK
ADD CONSTRAINT RewardPoints_Check
CHECK (dbo.fnRewardPointsCheck() = 0);
GO

-- 2. No customer can be resgitered into the system with a future birthday.
CREATE OR ALTER FUNCTION fnFutureBirthdayCheck()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INTEGER = 0;

    IF EXISTS (
        SELECT *
        FROM CUSTOMER
        WHERE birth_date > GETDATE()
    )
    BEGIN
        SET @RET = 1;
    END

    RETURN @RET;
END;
GO

-- Verify the function
SELECT dbo.fnFutureBirthdayCheck();

-- Add check constraint
ALTER TABLE CUSTOMER WITH NOCHECK
ADD CONSTRAINT FutureBirthday_Check
CHECK (dbo.fnFutureBirthdayCheck() = 0);
GO

-- 3. No total refunds for a booking can be more than the total price
CREATE OR ALTER FUNCTION refundAmountValidity()
RETURNS INTEGER
AS
BEGIN

DECLARE @returnedValue INTEGER = 0
IF
EXISTS (
    SELECT B.booking_id
    FROM BOOKING B JOIN BOOKING_REFUND BR ON B.booking_id = BR.booking_id
    GROUP BY BR.booking_id, B.booking_id, B.total_price
    HAVING SUM(BR.refund_amount) > B.total_price
    )
    BEGIN
    SET @returnedValue = 1
    END
RETURN @returnedValue
END

GO

ALTER TABLE BOOKING_REFUND WITH NOCHECK
ADD CONSTRAINT refundAmountCeiling
CHECK (dbo.refundAmountValidity() = 0)
GO

-- 4. No refunds can be issued before the corresponding booking date
CREATE OR ALTER FUNCTION refundDateValidity()
RETURNS INTEGER
AS
BEGIN

DECLARE @returnedValue INTEGER = 0
IF
EXISTS (
    SELECT BR.booking_id
    FROM BOOKING B JOIN BOOKING_REFUND BR ON B.booking_id = BR.booking_id
    GROUP BY BR.booking_id, BR.refund_date, B.date_booked
    HAVING BR.refund_date < B.date_booked
    )
    BEGIN
    SET @returnedValue = 1
    END
RETURN @returnedValue
END

GO

ALTER TABLE BOOKING_REFUND WITH NOCHECK
ADD CONSTRAINT refundDateCeiling
CHECK (dbo.refundDateValidity() = 0)
GO

-- 5. Ratings must be between 0 and 5, inclusive, ensuring reviews have valid ratings.
CREATE OR ALTER FUNCTION checkRatingRangeValidity()
RETURNS INTEGER
AS
BEGIN
    DECLARE @returnedValue INTEGER = 0
    IF EXISTS (
        SELECT 1
        FROM REVIEW
        WHERE rating_numeric < 0 OR rating_numeric > 5
    )
    BEGIN
        SET @returnedValue = 1
    END
    RETURN @returnedValue
END

GO

ALTER TABLE REVIEW WITH NOCHECK
ADD CONSTRAINT validRatingRangeCheck
CHECK (dbo.checkRatingRangeValidity() = 0);
GO

--- 6. Customers must be at least 18 years old at the time of booking
CREATE OR ALTER FUNCTION checkCustomerAgeValidity()
RETURNS INTEGER
AS
BEGIN
    DECLARE @returnedValue INTEGER = 0
    IF EXISTS (
        SELECT 1
        FROM BOOKING B
        JOIN CUSTOMER C ON B.customer_id = C.customer_id
        WHERE DATEDIFF(year, C.birth_date, B.date_booked) < 18
    )
    BEGIN
        SET @returnedValue = 1
    END
    RETURN @returnedValue
END

GO

ALTER TABLE BOOKING WITH NOCHECK
ADD CONSTRAINT ageRestrictionForBooking
CHECK (dbo.checkCustomerAgeValidity() = 0);
GO

--- 7. No email address can be added in the wrong format
CREATE OR ALTER FUNCTION checkEmailValidity(@Email VARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT;

    IF @Email LIKE '%@%.%' AND @Email NOT LIKE '% %' AND
       CHARINDEX('.', REVERSE(SUBSTRING(@Email, CHARINDEX('@', @Email) + 1, LEN(@Email)))) > 1
    BEGIN
        SET @IsValid = 1;
    END
    ELSE
    BEGIN
        SET @IsValid = 0;
    END

    RETURN @IsValid;
END;
GO
-- Add check constraint using the email validation UDF
ALTER TABLE ACCOUNT
ADD CONSTRAINT CK_Account_Email
CHECK (dbo.checkEmailValidity(email) = 1);
GO

--- 8. No telephone number can be added in the wrong format
CREATE OR ALTER FUNCTION checkTelephoneValidity(@Tel VARCHAR(20))
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT;
    IF @Tel LIKE '(___) ___-____'
    BEGIN
        SET @IsValid = 1;
    END
    ELSE
    BEGIN
        SET @IsValid = 0;
    END

    RETURN @IsValid;
END;
GO

-- Add check constraint using the telephone number format validation UDF
ALTER TABLE ACCOUNT
ADD CONSTRAINT CK_Account_Tel
CHECK (dbo.checkTelephoneValidity(tel) = 1);

----------------------------------------------------------------------------------------------------
-- 4)  COMPUTED COLUMNS
----------------------------------------------------------------------------------------------------
--- 1. Calculate the percentage of refund out of total booking price
GO
CREATE OR ALTER FUNCTION fnCalcRefundPercentage(@PK INT)
RETURNS NUMERIC(5,2)
AS
BEGIN
    DECLARE @RefundPercentage NUMERIC(5,2);
    DECLARE @TotalBookingPrice NUMERIC(8,2);
    SET @TotalBookingPrice = (SELECT total_price 
                              FROM BOOKING
                              WHERE booking_id = (SELECT booking_id FROM BOOKING_REFUND WHERE refund_id = @PK));
    DECLARE @RefundAmount NUMERIC(8,2);
    SET @RefundAmount = (SELECT refund_amount 
                         FROM BOOKING_REFUND 
                         WHERE refund_id = @PK);
    
    SET @RefundPercentage = (@RefundAmount / @TotalBookingPrice) * 100;
    
    RETURN @RefundPercentage;
END
GO

ALTER TABLE BOOKING_REFUND
ADD refund_amount_percentage AS (dbo.fnCalcRefundPercentage(refund_id));
GO

--- 2. Calcualte the age of customers based on their birthdays
CREATE OR ALTER FUNCTION fnCalcCustomerAge(@BirthDate DATETIME)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    
    SET @Age = DATEDIFF(YEAR, @BirthDate, GETDATE());
    
    RETURN @Age;
END
GO

ALTER TABLE CUSTOMER
ADD customer_age AS (dbo.fnCalcCustomerAge(birth_date));
GO

--- 3. Calculate total valid reward points for each customer (does not count expired rewards)
CREATE FUNCTION fnCalcRewardPoints(@PK INT)
RETURNS NUMERIC(8,2)
AS
BEGIN
DECLARE @RET NUMERIC(8,2) = (
    SELECT SUM(reward_points)
    FROM CUSTOMER C JOIN REWARD R ON C.customer_id = R.customer_id
    WHERE R.expire_date > GETDATE()
    AND @PK = C.customer_id
)
RETURN @RET
END
GO

ALTER TABLE CUSTOMER
ADD calcValidRewards AS (dbo.fnCalcRewardPoints(customer_id))
GO

--- 4. Customer amount spent for calculating TYPE
CREATE FUNCTION fnLifetimeSpending(@PK INT)
RETURNS NUMERIC(8,2)
AS
BEGIN
    DECLARE @RET NUMERIC(8,2) =
        (
            SELECT SUM(total_price)
            FROM CUSTOMER C
                JOIN BOOKING B ON C.customer_id = B.customer_id
            WHERE @PK = C.customer_id
        )
    RETURN @RET
END
GO

ALTER TABLE CUSTOMER
ADD calcLifetimeSpent AS (dbo.fnLifetimeSpending(customer_id))
GO

--- 5. Calculate how many bookings are refunded
CREATE FUNCTION dbo.GetRefundCount (@booking_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @refund_count INT;
    SELECT @refund_count = COUNT(refund_id)
    FROM BOOKING_REFUND
    WHERE booking_id = @booking_id;
    RETURN @refund_count;
END;
GO
ALTER TABLE booking
ADD refund_count AS dbo.GetRefundCount(booking_id)
GO

--- 6. Calculate the amount of refunds
CREATE FUNCTION dbo.GetTotalRefundAmount (@booking_id INT)
RETURNS NUMERIC(18, 2)
AS
BEGIN
    DECLARE @total_refund_amount NUMERIC(18, 2);
    SELECT @total_refund_amount = ISNULL(SUM(refund_amount), 0)
    FROM BOOKING_REFUND
    WHERE booking_id = @booking_id;
    RETURN @total_refund_amount;
END;
GO
ALTER TABLE BOOKING
ADD total_refund_amount AS dbo.GetTotalRefundAmount(booking_id);
GO

--- 7. Calculate the average rating for sub-booking based on customer reviews.
CREATE FUNCTION fnCalcAverageRating(@SubBookingId INT)
RETURNS NUMERIC(3,2)
AS
BEGIN
    DECLARE @AverageRating NUMERIC(3,2);

    SELECT @AverageRating = AVG(rating_numeric)
    FROM REVIEW
    WHERE sub_booking_id = @SubBookingId;

    RETURN ISNULL(@AverageRating, 0); -- Return 0 if no reviews
END;
GO

-- Alter the table to add the computed column
ALTER TABLE SUB_BOOKING
ADD average_rating AS (dbo.fnCalcAverageRating(sub_booking_id));
GO

--- 8. Calculate the price per booking for each customer
CREATE OR ALTER FUNCTION fnCalcAveragePricePerBooking()
RETURNS NUMERIC(8,2)
AS
BEGIN
    DECLARE @AveragePrice NUMERIC(8,2);
    
    -- Calculate the average price per booking
    SET @AveragePrice = (SELECT SUM(total_price) / COUNT(*) 
                         FROM BOOKING);
    
    RETURN @AveragePrice;
END
GO

ALTER TABLE CUSTOMER
ADD average_price_per_booking AS (dbo.fnCalcAveragePricePerBooking());

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------