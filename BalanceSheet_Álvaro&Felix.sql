DROP PROCEDURE IF EXISTS H_Accounting.`fboelck_balance_sheet_for_every_year`;
-- The tpycal delimiter for Stored procedures is a double dollar sign
DELIMITER $$

-- Balance Sheet -- 
CREATE PROCEDURE H_Accounting.fboelck_balance_sheet_for_every_year(variableCurrentAssetslendarYear SMALLINT)
BEGIN  

	-- 'Current Assets'
	DECLARE variableCurrentAssets DOUBLE DEFAULT 0;
    -- 'Fixed Assets'
    DECLARE variableFixedAssets DOUBLE DEFAULT 0;
    -- 'Deferred Assets'
    DECLARE variableDeferredAssets DOUBLE DEFAULT 0;
    -- 'Current Liabilities'
    DECLARE variableCurrentLiabilities DOUBLE DEFAULT 0;
    -- 'LongTerm Liabilities'
    DECLARE variableLongTermLiabilities DOUBLE DEFAULT 0;
    -- 'Deferred Liabilitites'
    DECLARE variableDeferredLiabilities DOUBLE DEFAULT 0;
    -- 'Equity'
    DECLARE variableEquity DOUBLE DEFAULT 0;
    
	-- 'Previous Current Assets'
	DECLARE variableCurrentAssets_1 DOUBLE DEFAULT 0;
    -- 'Previous Fixed Assets'
    DECLARE variableFixedAssets_1 DOUBLE DEFAULT 0;
    -- 'Previous Deferred Assets'
    DECLARE variableDeferredAssets_1 DOUBLE DEFAULT 0;
    -- 'Previous Current Liabilities'
    DECLARE variableCurrentLiabilities_1 DOUBLE DEFAULT 0;
    -- 'PreviousPrevious LongTerm Liabilities'
    DECLARE variableLongTermLiabilities_1 DOUBLE DEFAULT 0;
    -- 'Previous Deferred Liabilities'
    DECLARE variableDeferredLiabilities_1 DOUBLE DEFAULT 0;
    -- 'Previous Equity'
    DECLARE variableEquity_1 DOUBLE DEFAULT 0;

DROP VIEW IF EXISTS `H_Accounting`.`fboelck_view`;

CREATE VIEW `H_Accounting`.`fboelck_view` AS
SELECT 
	`jei`.`entry_date`,
	`jeli`.`company_id`,
    `jei`.`journal_entry_id`,
    `jeli`.`line_item`,
    `ac`.`account_id`,
    `ac`.`account_code`,
    `ac`.`account`,
    `ac`.`inventory_type`,
    `ac`.`bank_account_type`,
    `ac`.`balance_sheet_section_id`,
	`ac`.`profit_loss_section_id`,
    `ac`.`last_modified`,
	`ss`.`statement_section_order`,
    `ss`.`statement_section_code`,
    `ss`.`statement_section`,
    `ac`.`fiscal_id`,
    `jeli`.`description`,
    `jei`.`journal_entry`,
    `ss`.`debit_is_positive`,
	 COALESCE(`jeli`.`debit`, 0) AS debit,
     COALESCE(`jeli`.`credit`, 0) AS credit,
    `jei`.`debit_credit_balanced`,
    `jei`.`cancelled`,
	`jei`.`closing_type`
	FROM `H_Accounting`.`journal_entry_line_item` AS `jeli`
	INNER JOIN `H_Accounting`.`account` AS `ac` ON `ac`.`account_id` = `jeli`.`account_id`
	INNER JOIN `H_Accounting`.`journal_entry` AS `jei` ON `jei`.`journal_entry_id` = `jeli`.`journal_entry_id`
	INNER JOIN `H_Accounting`.`statement_section` AS `ss` ON `ss`.`statement_section_id` = `ac`.`profit_loss_section_id`
    WHERE `jeli`.`company_id` = 1 AND `jei`.`debit_credit_balanced` = 1
;

     --   value of the current assets 
	SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableCurrentAssets
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 61 AND YEAR(entry_date) = variableCurrentAssetslendarYear 
    GROUP BY debit_is_positive
    ;
    
	 --   value of the previous assets 
	SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableCurrentAssets_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 61 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
    ;

    --   value of the fixed assets 
    SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableFixedAssets
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 62 AND YEAR(entry_date) = variableCurrentAssetslendarYear 
    GROUP BY debit_is_positive
	;
    
    --   value of the previous fixed assets 
    SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableFixedAssets_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 62 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;
    
     --   value of the deferred assets 
    SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableDeferredAssets
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 63 AND YEAR(entry_date) = variableCurrentAssetslendarYear
    GROUP BY debit_is_positive
	;

     --   value of the previous deferred assets 
    SELECT SUM(COALESCE (debit,0) - COALESCE (credit,0)) INTO variableDeferredAssets_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 63 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;
    
    --  value of the current liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableCurrentLiabilities
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 64 AND YEAR(entry_date) = variableCurrentAssetslendarYear
    GROUP BY debit_is_positive
	;

    --  value of the previous liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableCurrentLiabilities_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 64 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;
    
 --  value of long term liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableLongTermLiabilities
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 65 AND YEAR(entry_date) = variableCurrentAssetslendarYear
    GROUP BY debit_is_positive
	;

 --  value of previous long term liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableLongTermLiabilities_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 65 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;
    
--   value of the deferred liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableDeferredLiabilities
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 66 AND YEAR(entry_date) = variableCurrentAssetslendarYear
    GROUP BY debit_is_positive
	;

--   value of the previous deferred liabilities 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableDeferredLiabilities_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 66 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;

--  value of the equity 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableEquity
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 67 AND YEAR(entry_date) = variableCurrentAssetslendarYear
    GROUP BY debit_is_positive
	;

--  value of the previous equity 
    SELECT SUM(COALESCE (credit,0) - COALESCE (debit,0)) INTO variableEquity_1
	FROM `H_Accounting`.`fboelck_view`
	WHERE balance_sheet_section_id = 67 AND YEAR(entry_date) = (variableCurrentAssetslendarYear - 1)
    GROUP BY debit_is_positive
	;

    DROP TABLE IF EXISTS H_Accounting.fboelck_tmp;
  
	-- Now we are certain that the table does not exist, we create with the columns that we need
	CREATE TABLE H_Accounting.fboelck_tmp
		(balance_sheet_line_number INT, 
		 label VARCHAR(50), 
	     current_amount VARCHAR(50), 
         previous_year_amount VARCHAR(50),
         percentage_change_from_previous_year VARCHAR(50)
		);
  
  -- Now we insert the a header for the report
  INSERT INTO H_Accounting.fboelck_tmp 
		   (balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES (1, 'BALANCE SHEET', "In '000s of USD", "In '000s of USD", "Progress from previous year in %");
  
	-- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.fboelck_tmp
				(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
		VALUES 	(2, '', '', '', '');
            
	--  Inserting the Current Assets
	INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(3, 'Currents Assets', COALESCE(format(variableCurrentAssets / 1000, 2),0), COALESCE(format(variableCurrentAssets_1 / 1000, 2),0), CONCAT(FORMAT((variableCurrentAssets-variableCurrentAssets_1)/ABS(NULLIF(variableCurrentAssets_1, 0))*100, 2),'%'));
    
      -- Insertingthe Fixed Assets
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(4, 'Fixed Assets', COALESCE(format(variableFixedAssets / 1000, 2),0), COALESCE(format(variableFixedAssets_1 / 1000, 2),0), CONCAT(FORMAT((variableFixedAssets-variableFixedAssets_1)/ABS(NULLIF(variableFixedAssets_1, 0))*100, 2),'%'));

    -- Inserting the Deferred Assets 
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(5, 'Deferred Assets', COALESCE(format(variableDeferredAssets / 1000, 2),0), COALESCE(format(variableDeferredAssets_1 / 1000, 2),0), CONCAT(FORMAT((variableDeferredAssets-variableDeferredAssets_1)/ABS(NULLIF(variableDeferredAssets_1, 0))*100, 2),'%'));

    --   Total Assets
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(6, 'Total Assets', format((COALESCE(variableCurrentAssets,0) + COALESCE(variableFixedAssets,0) + COALESCE(variableDeferredAssets,0))/ 1000, 2), format((COALESCE(variableCurrentAssets_1,0) + COALESCE(variableFixedAssets_1,0) + COALESCE(variableDeferredAssets_1,0))/ 1000, 2), CONCAT(FORMAT(((variableCurrentAssets+variableFixedAssets+variableDeferredAssets)-(variableCurrentAssets_1+variableFixedAssets_1+variableDeferredAssets_1))/NULLIF(ABS(variableCurrentAssets_1+variableFixedAssets_1+variableDeferredAssets_1), 0)*100 , 2),'%'));

    -- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.fboelck_tmp
				(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
		VALUES 	(7, '', '', '', '');
    
    -- Inserting the Current Liabilities 
	INSERT INTO H_Accounting.fboelck_tmp
				(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
		VALUES 	(8, 'Current Liabilities', COALESCE(format(variableCurrentLiabilities / 1000, 2),0), COALESCE(format(variableCurrentLiabilities_1 / 1000, 2),0), CONCAT(FORMAT((variableCurrentLiabilities-variableCurrentLiabilities_1)/ABS(NULLIF(variableCurrentLiabilities_1, 0))*100, 2),'%'));

    -- Inserting the Long-Term Liabilities
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(9, 'Long Term Liabilities', COALESCE(format(variableLongTermLiabilities / 1000, 2),0), COALESCE(format(variableLongTermLiabilities_1 / 1000, 2),0), CONCAT(FORMAT((variableLongTermLiabilities-variableLongTermLiabilities_1)/ABS(NULLIF(variableLongTermLiabilities_1, 0))*100, 2),'%'));

    -- Inserting the Deferred Liabilities
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(10, 'Deferred Liabilities', COALESCE(format(variableDeferredLiabilities / 1000, 2),0), COALESCE(format(variableDeferredLiabilities_1 / 1000, 2),0), CONCAT(FORMAT((variableDeferredLiabilities-variableDeferredLiabilities_1)/ABS(NULLIF(variableDeferredLiabilities_1, 0))*100, 2),'%'));

    -- Total Liabilities
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(11, 'Total Liabilities', COALESCE(format((COALESCE(variableCurrentLiabilities,0) + COALESCE(variableLongTermLiabilities,0) + COALESCE(variableDeferredLiabilities,0))/ 1000, 2),0), COALESCE(format((COALESCE(variableCurrentLiabilities_1,0) + COALESCE(variableLongTermLiabilities_1,0) + COALESCE(variableDeferredLiabilities_1,0))/ 1000, 2),0), CONCAT(FORMAT(((variableCurrentLiabilities+variableLongTermLiabilities+variableDeferredLiabilities)-(variableCurrentLiabilities_1+variableLongTermLiabilities_1+variableDeferredLiabilities_1))/NULLIF(ABS(variableCurrentLiabilities_1+variableLongTermLiabilities_1+variableDeferredLiabilities_1), 0)*100, 2),'%'));

      -- Next we insert an empty line to create some space between the header and the line items
	INSERT INTO H_Accounting.fboelck_tmp
				(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
		VALUES 	(12, '', '', '', '');
    
     -- Inserting Equity
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(13, 'Equity', COALESCE(format(variableEquity / 1000, 2),0), COALESCE(format(variableEquity_1 / 1000, 2),0), CONCAT(FORMAT((variableEquity-variableEquity_1)/ABS(NULLIF(variableEquity_1, 0))*100, 2),'%'));

	-- Inserting Assets = Libilities + Equity 
    INSERT INTO H_Accounting.fboelck_tmp
			(balance_sheet_line_number, label, current_amount, previous_year_amount, percentage_change_from_previous_year)
	VALUES 	(14, 'A - L - E', format(((COALESCE(variableCurrentAssets,0) + COALESCE(variableFixedAssets,0) + COALESCE(variableDeferredAssets,0)) - (COALESCE(variableCurrentLiabilities,0) + COALESCE(variableLongTermLiabilities,0) + COALESCE(variableDeferredLiabilities,0)) - variableEquity)/ 1000, 2), format(((COALESCE(variableCurrentAssets_1,0) + COALESCE(variableFixedAssets_1,0) + COALESCE(variableDeferredAssets_1,0)) - (COALESCE(variableCurrentLiabilities_1,0) + COALESCE(variableLongTermLiabilities_1,0) + COALESCE(variableDeferredLiabilities_1,0)) - variableEquity_1)/ 1000, 2), CONCAT(FORMAT(((variableCurrentAssets+variableFixedAssets+variableDeferredAssets) - (variableCurrentLiabilities+variableLongTermLiabilities+variableDeferredLiabilities) - variableEquity) - ((variableCurrentAssets_1+variableFixedAssets_1+variableDeferredAssets_1) - (variableCurrentLiabilities_1+variableLongTermLiabilities_1+variableDeferredLiabilities_1) - variableEquity_1) / NULLIF(ABS((variableCurrentAssets_1+variableFixedAssets_1+variableDeferredAssets_1) - (variableCurrentLiabilities_1+variableLongTermLiabilities_1+variableDeferredLiabilities_1) - variableEquity_1), 0)*100, 2),'%') );

    SELECT * FROM H_Accounting.fboelck_tmp;
    --
SET SQL_SAFE_UPDATES = 0;
UPDATE `fboelck_tmp` SET percentage_change_from_previous_year = 0 WHERE percentage_change_from_previous_year IS NULL;
UPDATE `fboelck_tmp` SET percentage_change_from_previous_year = 0 WHERE percentage_change_from_previous_year = '100.00%' OR percentage_change_from_previous_year = '-100.00%';

    END $$

DELIMITER ;
# THE LINE ABOVES CHANGES BACK OUR DELIMETER TO OUR USUAL ;

CALL H_Accounting.`fboelck_balance_sheet_for_every_year` (2016);

SELECT * FROM H_Accounting.fboelck_tmp;