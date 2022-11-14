SELECT * FROM [dbo].[sales_data_sample ]

-- Inspecting data. Checking unique values
SELECT DISTINCT STATUS FROM dbo.[sales_data_sample ]
SELECT DISTINCT YEAR_ID FROM dbo.[sales_data_sample ]
SELECT DISTINCT PRODUCTLINE FROM dbo.[sales_data_sample ]
SELECT DISTINCT COUNTRY FROM dbo.[sales_data_sample ]
SELECT DISTINCT DEALSIZE FROM dbo.[sales_data_sample ]
SELECT DISTINCT TERRITORY FROM dbo.[sales_data_sample ]

SELECT DISTINCT MONTH_ID FROM dbo.[sales_data_sample ]
WHERE YEAR_ID = 2005

/*Display both contact first name and last name as full name*/
SELECT CONTACTFIRSTNAME,CONTACTLASTNAME,concat(CONTACTFIRSTNAME,' ',CONTACTLASTNAME) "CONTACT FULLNAME" 
FROM [sales_data_sample ]

/*Grouping sales by productline*/
SELECT PRODUCTLINE,SUM(SALES) TOTAL_SALES FROM [dbo].[sales_data_sample ]
GROUP BY PRODUCTLINE
ORDER BY 2 DESC

/*Grouping sales by year*/
SELECT YEAR_ID,SUM(SALES) TOTAL_SALES FROM [dbo].[sales_data_sample ]
GROUP BY YEAR_ID
ORDER BY 1 DESC

/*Grouping sales by DEALSIZE*/
SELECT DEALSIZE,CAST(SUM(SALES) AS NUMERIC) TOTAL_SALES FROM [dbo].[sales_data_sample ]
GROUP BY DEALSIZE
ORDER BY 2 DESC

/*What was the best month for sales in a specific year? How much was earned that month?*/
SELECT * FROM
(SELECT YEAR_ID,MONTH_ID,SUM(SALES)TOTAL_SALES,
ROW_NUMBER() OVER(PARTITION BY YEAR_ID ORDER BY SUM(SALES) DESC) RN FROM [dbo].[sales_data_sample ]
GROUP BY YEAR_ID,MONTH_ID) D
WHERE RN = 1

/*WHICH PRODUCTS WHERE SOLD IN NOVEMBER OF EACH YEAR (2003-2004)*/

SELECT MONTH_ID,SUM(SALES)TOTAL_SALES,PRODUCTLINE
 FROM [dbo].[sales_data_sample ]
 WHERE MONTH_ID = 11 AND YEAR_ID = 2004 --Change year for other years
GROUP BY MONTH_ID,PRODUCTLINE
ORDER BY 2 DESC

--Who is our best customer We use RFM analysis
SELECT * FROM [dbo].[sales_data_sample ]

DROP TABLE IF EXISTS #rfm
WITH RFM1  AS (
SELECT CUSTOMERNAME,
SUM(SALES) TOTAL_MONETORY,
AVG(SALES) AVERAGE_NONEY,
COUNT(CUSTOMERNAME) FREQUENCY,
MAX(ORDERDATE) last_order_date,
(SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample ]) max_order_date,
DATEDIFF(DD,MAX(ORDERDATE),(SELECT MAX(ORDERDATE) FROM [dbo].[sales_data_sample ])) RECENCY
FROM  DBO.[sales_data_sample ]
GROUP BY CUSTOMERNAME
),
RFM_CALC AS(
SELECT r.*, NTILE(4) OVER(ORDER BY RECENCY DESC) rfm_recency,NTILE(4) OVER(ORDER BY FREQUENCY) rfm_frequency,
NTILE(4) OVER(ORDER BY TOTAL_MONETORY) rfm_monetory FROM RFM1 r)

SELECT *,(CAST(rfm_recency AS varchar)+CAST(rfm_frequency AS varchar)+CAST(rfm_monetory AS varchar)) RFM_RATING 
INTO #rfm
from RFM_CALC

SELECT CUSTOMERNAME,RFM_RATING FROM #rfm
ORDER BY RFM_RATING DESC



/*What Products are most often sold together*/
--Orders with two products purchased together. You can change the value for the count ddepending on the number of orders
SELECT ORDERNUMBER,STUFF((
SELECT ','+PRODUCTCODE FROM [dbo].[sales_data_sample ] p
WHERE ORDERNUMBER IN (
SELECT ORDERNUMBER FROM
(SELECT ORDERNUMBER,count(*) COUNT FROM [dbo].[sales_data_sample ]
WHERE STATUS = 'Shipped'
GROUP BY ORDERNUMBER) d
WHERE COUNT = 2) AND p.ORDERNUMBER = s.ORDERNUMBER
FOR XML PATH('')),1,1,'') ORDER_CODES FROM [dbo].[sales_data_sample ] s
ORDER BY 2 DESC




