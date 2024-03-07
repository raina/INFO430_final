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