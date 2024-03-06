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
--** Add State ---------------------------------------------------------------------------------------------------------------------------------------


-- Add ~10,000 Customers using the PEEPS db --------------------------------------------------------------------------------------------------------
-- Populate tblCustomer with ~100 records from Peeps.dbo.tblCUSTOMER
-- INSERT INTO tblCUSTOMER (CustFname, CustLname, CustBirthDate)
-- SELECT TOP 10000 CustomerFname, CustomerLname, DateOfBirth FROM Peeps.dbo.tblCUSTOMER;

GO
-- Choose random customer from PEEPS

-- Grab matching customer FName, LName, DateOfBirth,Address, City, ZIP, State (conv to stateID)
-- Generate StateID, customer_type_id, gender_id
GO

