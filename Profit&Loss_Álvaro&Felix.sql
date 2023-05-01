USE `H_Accounting`;

#  First create a view with the merged general table
DROP VIEW IF EXISTS `fboelck_view`;   
CREATE VIEW `fboelck_view` AS
SELECT 
	`je`.`entry_date`,
	`jeli`.`company_id`,
    `je`.`journal_entry_id`,
    `jeli`.`line_item`,
    `ac`.`account_id`,
    `ac`.`account_code`,
    `ac`.`account`,
    `ac`.`inventory_type`,
    `ac`.`bank_account_type`,
    `ac`.`balance_sheet_section_id`,
	`ac`.`profit_loss_section_id`,
	`ss`.`statement_section_order`,
    `ss`.`statement_section_code`,
    `ss`.`statement_section`,
    `ac`.`fiscal_id`,
    `jeli`.`description`,
    `je`.`journal_entry`,
    `ss`.`debit_is_positive`,
	`jeli`.`debit`,
    `jeli`.`credit`,
    `je`.`debit_credit_balanced`,
    `je`.`cancelled`
	FROM `H_Accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `H_Accounting`.`account` AS `ac` ON `ac`.`account_id` = `jeli`.`account_id`
	INNER JOIN `H_Accounting`.`journal_entry` AS `je` ON `je`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `H_Accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `ac`.`profit_loss_section_id`
    WHERE `jeli`.`company_id` = 1
    AND `je`.`closing_type` <> 1
;

-- A stored procedure, or a stored routine, is like a function in other programming languages
-- We write the code once, and the code can then be reused over and over again
-- We can pass on arguments into the stored procedure. 
-- i.e. we can give a specific input to a store procedure
-- For example we could determine the specific for which we want to produce the profit and loss statement (year)

-- Before wrting a stored procedure we have to change the DELIMTER (;)
-- This has to be done, so the compiler of SQL will know when we are closing the stored procedure and when we are
-- closing the specific Select command

DROP PROCEDURE IF EXISTS `H_Accounting`.`sp_profitloss_fboelck`;
-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

CREATE PROCEDURE `H_Accounting`.`sp_profitloss_fboelck`(varCalendarYear SMALLINT)
BEGIN
	-- We receive as an argument the year for which we will calculate the revenues
    -- This value is stored as an 'YEAR' type in the variable `varCalendarYear`
    -- To avoid confusion among which are fields from a table vs. which are the variables
    -- A good practice is to adopt a naming convention for all variables
    -- In these lines of code we are naming prefixing every variable as "var"
  
	-- DECLARING THE VARIABLES FOR THE PROFIT & LOSS STATEMENT
	-- We can define variables inside of our procedure
    
    -- Defining the variable for Revenue & Revenue0
	DECLARE varTotalRevenue DOUBLE DEFAULT 0;
    DECLARE varTotalRevenue0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalRRD & TotalRRD0
    DECLARE varTotalRRD DOUBLE DEFAULT 0;
    DECLARE varTotalRRD0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalCostsGS & TotalCostsGS0
    DECLARE varTotalCostsGS DOUBLE DEFAULT 0;
    DECLARE varTotalCostsGS0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalAdminExp  & TotalAdminExp0
    DECLARE varTotalAdminExp DOUBLE DEFAULT 0;
    DECLARE varTotalAdminExp0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalSellExp & TotalSellExp0
    DECLARE varTotalSellExp DOUBLE DEFAULT 0;
    DECLARE varTotalSellExp0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalOtExp & TotalOtExp0
    DECLARE varTotalOtExp DOUBLE DEFAULT 0;
    DECLARE varTotalOtExp0 DOUBLE DEFAULT 0;
    
	-- Defining the variable for TotalOtInc & TotalOtInc0
    DECLARE varTotalOtInc DOUBLE DEFAULT 0;
    DECLARE varTotalOtInc0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalIncTax & TotalIncTax0
    DECLARE varTotalIncTax DOUBLE DEFAULT 0; 
    DECLARE varTotalIncTax0 DOUBLE DEFAULT 0;
    
    -- Defining the variable for TotalOtTax & TotalOtTax0
	DECLARE varTotalOtTax DOUBLE DEFAULT 0;
    DECLARE varTotalOtTax0 DOUBLE DEFAULT 0;
    
	
    -- Calculating the revenue for the actual and previous year and store it into the declared variables
	SELECT SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalRevenue
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 68
        AND YEAR(entry_date) = varCalendarYear
	;

	SELECT SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalRevenue0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 68
        AND YEAR(entry_date) = varCalendarYear - 1
	;

    -- Calculating the total returns, refunds & discounts for the actual and previous year and store them into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalRRD
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 69
        AND YEAR(entry_date) = varCalendarYear
	;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalRRD0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 69
        AND YEAR(entry_date) = varCalendarYear - 1
	;
    
    -- Calculating the total of goods & services  for the actual and previous year and store them into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalCostsGS
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 74
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalCostsGS0 
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 74
        AND YEAR(entry_date) = varCalendarYear - 1
        ;        
        
    -- Calculating the administrative expenses for the actual and previous year and store it into the declared variables
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalAdminExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 75
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalAdminExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 75
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
    
    -- Calculating the selling expenses for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalSellExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 76
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalSellExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 76
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
    
    -- Calculating the total other expenses for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtExp
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 77
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtExp0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 77
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	-- Calculating the total other income taxes for the actual and previous year and store it into the declared variables
	SELECT 
    SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalOtInc
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 78
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT 
    SUM(COALESCE(credit,0) - COALESCE(debit,0)) INTO varTotalOtInc0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 78
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	--  We calculate the value of the income taxes for the given year and we store it into the variable we just declared
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalIncTax
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 79
        AND YEAR(entry_date) = varCalendarYear
        ;

	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalIncTax0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 79
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
        
	--  We calculate the value of the other taxes for the given year and we store it into the variable we just declared
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtTax
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 80
        AND YEAR(entry_date) = varCalendarYear
        ;
        
	SELECT SUM(COALESCE(debit,0) - COALESCE(credit,0)) INTO varTotalOtTax0
		FROM H_Accounting.fboelck_view
		WHERE profit_loss_section_id = 80
        AND YEAR(entry_date) = varCalendarYear - 1
        ;
  
    -- Let's drop the `tmp` table where we will input the revenue
	-- The IF EXISTS is important. Because if the table does not exist the DROP alone would fail
	-- A store procedure will stop running whenever it faces an error. 
	DROP TABLE IF EXISTS `H_Accounting`.`fboelck_tmp`;
  
	-- Now we are certain that the table does not exist, we create with the columns that we need
	CREATE TABLE `H_Accounting`.`fboelck_tmp` (
    profit_loss_line_number INT,
    label VARCHAR(50),
    previous_year_amount VARCHAR(50),
    entered_year_amount VARCHAR(50),
    percentage_change_from_previous_year VARCHAR(50)
);
  
  -- INSERTING THE ROWS FOR THE PROFIT AND LOSS STATEMENT
	-- Now we insert the a header for the report
	INSERT INTO `H_Accounting`.`fboelck_tmp` 
		   (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES (1, 'PROFIT AND LOSS STATEMENT', "In '000s of USD", "In '000s of USD", "percentage_change_from_previous_year");
  
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(2, '', '', '', '');
    
	-- Finally we insert the Total Revenues with its value
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(3, 'Total Revenue', format(COALESCE(varTotalRevenue0, 0) / 1000, 2), format(COALESCE(varTotalRevenue, 0) / 1000, 2), CONCAT(FORMAT((varTotalRevenue-varTotalRevenue0)/ABS(NULLIF(varTotalRevenue0, 0))*100, 2),'%'));
    
	-- Finally we insert the Total Retruns, Refunds, Discounts with its value
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(4, 'Total Returns, Refunds, Discounts', format(COALESCE(varTotalRRD0, 0) / 1000, 2), format(COALESCE(varTotalRRD, 0) / 1000, 2), CONCAT(FORMAT((varTotalRRD-varTotalRRD0)/ABS(NULLIF(varTotalRRD0, 0))*100, 2),'%'));
    
	-- Next We insert the Net Revenues (Total Revenues - Total RRD)
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
    VALUES 	(5, 'Net Revenue', format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0)) / 1000, 2), format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0)) / 1000, 2), CONCAT(FORMAT(((varTotalRevenue)-(varTotalRevenue0))/ABS(NULLIF((varTotalRevenue0), 0))*100, 2),'%'));

	-- Next we insert an empty line to create some space between the total and the next line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(6, '', '', '', '');
    
    -- Finally we insert the Total Retruns, Refunds, Discounts with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(7, 'Total Cost of Goods and Services', format(COALESCE(varTotalCostsGS0, 0) / 1000, 2), format(COALESCE(varTotalCostsGS, 0) / 1000, 2), CONCAT(FORMAT(((varTotalCostsGS)-(varTotalCostsGS0))/ABS(NULLIF((varTotalCostsGS0), 0))*100, 2),'%'));

    -- Next We insert the Gross Profit (Net Revenues - Total Costs of Goods and Services)
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(8, 'Gross Profit', format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0)) / 1000, 2), format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0)) / 1000, 2), CONCAT(FORMAT(((varTotalRevenue-varTotalCostsGS)-(varTotalRevenue0-varTotalCostsGS0))/ABS(NULLIF((varTotalRevenue0-varTotalCostsGS0), 0))*100, 2),'%'));

    -- Next we insert an empty line to create some space between the total and the next line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
				 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(9, '', '', '', '');

    -- Finally we insert the Total Administrative Expenses with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
    VALUES 	(10, 'Total Administrative Expenses', format(COALESCE(varTotalAdminExp0, 0) / 1000, 2), format(COALESCE(varTotalAdminExp, 0) / 1000, 2), CONCAT(FORMAT(((varTotalAdminExp)-(varTotalAdminExp0))/ABS(NULLIF((varTotalAdminExp0), 0))*100, 2),'%'));

	-- Finally we insert the Total Selling Expenses with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(11, 'Total Selling Expenses', format(COALESCE(varTotalSellExp0, 0) / 1000, 2), format(COALESCE(varTotalSellExp, 0) / 1000, 2), CONCAT(FORMAT(((varTotalSellExp)-(varTotalSellExp0))/ABS(NULLIF((varTotalSellExp0), 0))*100, 2),'%'));

	-- Next We insert the Operating Profit (Gross Profit - Total Admin. Expenses - Total Sell. Expenses 
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
		VALUES 	(12, 'Operating Profit', format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)) / 1000, 2), format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)) / 1000, 2), CONCAT(FORMAT(((varTotalRevenue-varTotalCostsGS-varTotalSellExp)-(varTotalRevenue0-varTotalCostsGS0-varTotalSellExp0))/ABS(NULLIF((varTotalRevenue0-varTotalCostsGS0-varTotalSellExp0), 0))*100, 2),'%'));

    -- Next we insert an empty line to create some space between the total and the next line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
				 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(13, '', '', '', '');
  
	-- Finally we insert the Total Other Expenses with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(14, 'Total Other Expenses', format(COALESCE(varTotalOtExp0, 0) / 1000, 2), format(COALESCE(varTotalOtExp, 0) / 1000, 2), CONCAT(FORMAT(((varTotalOtExp)-(varTotalOtExp0))/ABS(NULLIF((varTotalOtExp0), 0))*100, 2),'%'));

	-- Finally we insert the Total Other Income with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(15, 'Total Other Income', format(COALESCE(varTotalOtInc0, 0) / 1000, 2), format(COALESCE(varTotalOtInc, 0) / 1000, 2), CONCAT(FORMAT(((varTotalOtInc)-(varTotalOtInc0))/ABS(NULLIF((varTotalOtInc0), 0))*100, 2),'%')); 

    -- Next We insert the Profit Before Tax (Operating Profit - Total Other Expenses + Total Other Income 
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	    VALUES 	(16, 'Profit Before Tax', format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0) - COALESCE(varTotalSellExp0, 0) - COALESCE(varTotalOtExp0, 0) + COALESCE(varTotalOtInc0, 0)) / 1000, 2), format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0) - COALESCE(varTotalSellExp, 0) - COALESCE(varTotalOtExp, 0) + COALESCE(varTotalOtInc, 0)) / 1000, 2), CONCAT(FORMAT(((varTotalRevenue-varTotalCostsGS-varTotalSellExp-varTotalOtExp+varTotalOtInc)-(varTotalRevenue0-varTotalCostsGS0-varTotalSellExp0-varTotalOtExp0+varTotalOtInc0))/ABS(NULLIF((varTotalRevenue0-varTotalCostsGS0-varTotalSellExp0-varTotalOtExp0+varTotalOtInc0), 0))*100, 2),'%'));

    -- Next we insert an empty line to create some space between the total and the next line items
	INSERT INTO `H_Accounting`.`fboelck_tmp`
				 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(17, '', '', '', '');

	-- Finally we insert the Total Income Taxes with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(18, 'Total Income Taxes', format(COALESCE(varTotalIncTax0, 0) / 1000, 2), format(COALESCE(varTotalIncTax, 0) / 1000, 2), CONCAT(FORMAT(((varTotalIncTax)-(varTotalIncTax0))/ABS(NULLIF((varTotalIncTax0), 0))*100, 2),'%'));    

	-- Finally we insert the Total Other Taxes with its value
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(19, 'Total Other Taxes', format(COALESCE(varTotalOtTax0, 0) / 1000, 2), format(COALESCE(varTotalOtTax, 0) / 1000, 2), '');
  
  	-- Finally we insert the Net Profit (Profit Before Tax - Total Income Taxes + Total Other Taxes ) with its value for the actual and previous year and we calculate the percentage change
    INSERT INTO `H_Accounting`.`fboelck_tmp`
			 (profit_loss_line_number, label, previous_year_amount, entered_year_amount, percentage_change_from_previous_year)
	VALUES 	(20, 'Net Profit', format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0)) / 1000, 2), 
      format((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)  - COALESCE(varTotalOtExp, 0)  + COALESCE(varTotalOtInc, 0) - COALESCE(varTotalIncTax, 0) - COALESCE(varTotalOtTax, 0)) / 1000, 2), 
      CONCAT(FORMAT((FORMAT((COALESCE(varTotalRevenue, 0) - COALESCE(varTotalRRD, 0) - COALESCE(varTotalCostsGS, 0) - COALESCE(varTotalAdminExp, 0)  - COALESCE(varTotalSellExp, 0)  - COALESCE(varTotalOtExp, 0)  + COALESCE(varTotalOtInc, 0) - COALESCE(varTotalIncTax, 0) - COALESCE(varTotalOtTax, 0)) / 1000, 2)-format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0)) / 1000, 2))/
      ABS(NULLIF(format((COALESCE(varTotalRevenue0, 0) - COALESCE(varTotalRRD0, 0) - COALESCE(varTotalCostsGS0, 0) - COALESCE(varTotalAdminExp0, 0)  - COALESCE(varTotalSellExp0, 0)  - COALESCE(varTotalOtExp0, 0)  + COALESCE(varTotalOtInc0, 0) - COALESCE(varTotalIncTax0, 0) - COALESCE(varTotalOtTax0, 0)) / 1000, 2),0))*100, 2),'%'));
 
SET SQL_SAFE_UPDATES = 0;
UPDATE `fboelck_tmp` SET percentage_change_from_previous_year = 0 WHERE percentage_change_from_previous_year IS NULL;
UPDATE `fboelck_tmp` SET percentage_change_from_previous_year = 0 WHERE percentage_change_from_previous_year = '100.00%' OR percentage_change_from_previous_year = '-100.00%';


END $$
DELIMITER ;
-- The line above changes the DELIMITER back to the original semicolon 


CALL `H_Accounting`.`sp_profitloss_fboelck` (2016);

SELECT * FROM `H_Accounting`.`fboelck_tmp`;