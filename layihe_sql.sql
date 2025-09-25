CREATE TABLE transactions_fact (
    transaction_id         varchar2(30),
    transaction_start_datetime date,
    transaction_end_datetime   date,
    cardholder_id          varchar2(30),
    location_id            varchar2(30),
    transaction_type_id    NUMBER,
    transaction_amount     NUMBER
);
SELECT * FROM transactions_fact FOR UPDATE
SELECT * FROM transactions_fact;

CREATE TABLE customers_dimension (
  CardholderID     VARCHAR2(30),
  FirstName        VARCHAR2(50),
  LastName         VARCHAR2(50),
  Gender           VARCHAR2(10),
  ATMID            VARCHAR2(30),
  BirthDate        DATE,
  Occupation       VARCHAR2(100),
  AccountType      VARCHAR2(50),
  IsMegabank       NUMBER
);
SELECT * FROM customers_dimension FOR UPDATE
SELECT * FROM customers_dimension;


CREATE TABLE transaction_type(
  TransactionTypeID NUMBER,
  TransactionTypeName VARCHAR2(20)
);
SELECT * FROM transaction_type FOR UPDATE
SELECT * FROM transaction_type;

--1. Hər müştərinin sonuncu tranzaksiyasının tarixi və həmin tarixdən bugünədək neçə gün keçdiyinin ekrana çıxardılması
SELECT 
    c.CardholderID,
    c.FirstName, c.LastName,
    max(t.transaction_end_datetime) AS LastTransactionDate,
    TRUNC(SYSDATE - max(t.transaction_end_datetime)) AS DaysDifference
FROM customers_dimension c
JOIN transactions_fact t
    ON c.CardholderID = t.cardholder_id
GROUP BY c.CardholderID, c.FirstName, c.LastName
ORDER BY DaysDifference DESC;

--max isletdim cunki bir musteri bir nece defe tranzaksiya ede biler max gedir sonuncunu goturur



--2. Ən böyük məbləğli tranzaksiyanı edən şəxsin adı və hansı məbləğdə tranzaksiya etdiyi və hansı peşənin sahibi olması
SELECT 
    c.FirstName, c.LastName,
    t.transaction_amount,
    c.Occupation
FROM transactions_fact t
JOIN customers_dimension c
    ON t.cardholder_id = c.cardholderid
ORDER BY t.transaction_amount DESC
FETCH FIRST 1 ROWS WITH TIES;
--basqa cur

SELECT FirstName, LastName, transaction_amount, Occupation 
FROM (SELECT c.FirstName,c.LastName,t.Transaction_amount, c.Occupation,
      RANK() OVER (ORDER BY t.transaction_amount DESC) rnk
      FROM transactions_fact t
      JOIN customers_dimension c
      ON t.cardholder_id = c.cardholderid)
 WHERE rnk = 1;

--3. Heç tranzaksiya etməmiş neçə müştərinin sayının təyini
SELECT COUNT(*)
FROM customers_dimension c
LEFT JOIN transactions_fact t
    ON c.CardholderID = t.cardholder_id
WHERE t.transaction_id IS NULL;


--4. Hər müştəriyə görə tranzaksiya məbləği ortalamasının tapılması 
--və yalnız tam hissə məbləğlərin yuvarlaşdırılaraq kəsr hissəsiz ekrana çıxardılması. 
--Burada müştəri adlarını ekrana çıxararkən bütün adların bütün simvollarının böyük hərflə qeyd edilməsi lazımdır.
SELECT 
    UPPER(c.FirstName || ' ' || c.LastName) AS FullName,
    ROUND(AVG(t.transaction_amount), 0) AS Avg_TransactionAmount
FROM transactions_fact t
JOIN customers_dimension c
    ON t.cardholder_id = c.cardholderid
GROUP BY c.FirstName, c.LastName
ORDER BY Avg_TransactionAmount DESC;

--5. Ən uzun müddətli 10 transaksiyanı tapmaq.
SELECT 
    t.transaction_id,
    t.cardholder_id,
    t.transaction_start_datetime,
    t.transaction_end_datetime,
    ROUND((t.transaction_end_datetime - t.transaction_start_datetime)*24*60) AS Duration_Minutes
FROM transactions_fact t
ORDER BY Duration_Minutes DESC
FETCH FIRST 10 ROWS WITH TIES;
--basqa yol
SELECT transaction_id,cardholder_id,transaction_start_datetime,transaction_end_datetime, Duration
  FROM (SELECT t.transaction_id,
               t.cardholder_id,
               t.transaction_start_datetime,
               t.transaction_end_datetime,
               ROUND((t.transaction_end_datetime - t.transaction_start_datetime) * 24 * 60) AS Duration,
               RANK() OVER (ORDER BY(t.transaction_end_datetime - t.transaction_start_datetime) DESC) AS rnk
          FROM transactions_fact t)
 WHERE rnk <= 10;

--6. Hər bir Tranzaksiya Tipinə Görə Ümumi Tranzaksiya Sayı və Toplam Məbləğin tapilmasi.
SELECT 
    ty.TransactionTypeName,
    COUNT(t.transaction_id) AS TotalTransactions,
    SUM(t.transaction_amount) AS TotalAmount
FROM transactions_fact t
JOIN transaction_type ty
    ON t.transaction_type_id = ty.transactiontypeid
GROUP BY ty.TransactionTypeName
ORDER BY TotalAmount DESC;


----7. BirthDate sütununa əsasən müştəriləri yaş qruplarına ayırın və ortalama tranzaksiya məbləğini göstərin. 
--(25 yaşdan aşağı, 25-40 yaş, 41-60 yaş ve 60 yaşdan yuxarı)
SELECT AgeGroup, COUNT(*) AS CustomerCount, ROUND(AVG(transaction_amount), 2) AS Avg_TransactionAmount
FROM (SELECT t.transaction_amount,
CASE 
        WHEN (MONTHS_BETWEEN(SYSDATE, c.BirthDate)/12) < 25 THEN 'Under 25'
        WHEN (MONTHS_BETWEEN(SYSDATE, c.BirthDate)/12) BETWEEN 25 AND 40 THEN '25-40'
        WHEN (MONTHS_BETWEEN(SYSDATE, c.BirthDate)/12) BETWEEN 41 AND 60 THEN '41-60'
        ELSE 'Above 60'
    END AS AgeGroup
    FROM transactions_fact t
          JOIN customers_dimension c
            ON t.cardholder_id = c.CardholderID) sub
 GROUP BY AgeGroup
 ORDER BY AgeGroup;
 
--8. ATMID-yə görə hər bir ATM-də yerli və qeyri-yerli müştərilərin tranzaksiya sayını göstərir.
SELECT 
    c.ATMID,
    SUM(CASE WHEN c.IsMegabank = 1 THEN 1 ELSE 0 END) AS LocalTransactions,
    SUM(CASE WHEN c.IsMegabank = 0 THEN 1 ELSE 0 END) AS NonLocalTransactions
FROM transactions_fact t
JOIN customers_dimension c
    ON t.cardholder_id = c.cardholderid
GROUP BY c.ATMID
ORDER BY c.ATMID;

--9. Ən Çox Müxtəlif ATM-lərdən İstifadə Edən İlk 10 Müştəri
SELECT 
    c.CardholderID,
    c.FirstName, c.LastName,
    COUNT(DISTINCT t.location_id) AS ATMCount
FROM transactions_fact t
JOIN customers_dimension c
    ON t.cardholder_id = c.cardholderid
GROUP BY c.CardholderID, c.FirstName, c.LastName
ORDER BY ATMCount DESC
FETCH FIRST 10 ROWS WITH TIES;
--basqa yol
SELECT CardholderID, FirstName, LastName, ATMCount
  FROM (SELECT c.CardholderID, c.FirstName, c.LastName,
               COUNT(DISTINCT t.location_id) AS ATMCount,
               RANK() OVER (ORDER BY COUNT(DISTINCT t.location_id) DESC) AS rnk
               FROM transactions_fact t
               JOIN customers_dimension c
               ON t.cardholder_id = c.CardholderID
         GROUP BY c.CardholderID, c.FirstName, c.LastName)
 WHERE rnk <= 10;


--10. Müştəri Tiplərinə Görə Ümumi Tranzaksiya Məbləği
SELECT 
    c.AccountType,
    SUM(t.transaction_amount) AS TotalTransactionAmount
FROM transactions_fact t
JOIN customers_dimension c
    ON t.cardholder_id = c.cardholderid
GROUP BY c.AccountType
ORDER BY TotalTransactionAmount DESC;

--11. Müştəri Adlarının Duplicated Olmadığı Üzrə Tranzaksiyalar
SELECT c.FirstName, c.LastName, t.*
FROM transactions_fact t
JOIN customers_dimension c
ON t.cardholder_id = c.CardholderID
WHERE c.CardholderID IN (SELECT CardholderID
                            FROM customers_dimension
                           GROUP BY CardholderID
                          HAVING COUNT(*) = 1);


--12. Hər Müştəri Üçün Tranzaksiya İlinə Görə Bölünməsi
SELECT c.CardholderID, 
       EXTRACT(YEAR FROM t.transaction_start_datetime) AS transaction_year,
       COUNT(*) AS transaction_count
  FROM transactions_fact t
JOIN customers_dimension c
ON t.cardholder_id = c.CardholderID
 GROUP BY c.CardholderID, EXTRACT(YEAR FROM t.transaction_start_datetime)
 ORDER BY c.CardholderID, transaction_year;
--13. Hər Müştərinin Ən Çox Tranzaksiya Etmiş Olduğu ATM
SELECT location_id,
       cardholder_id,
       transaction_count
FROM (
    SELECT t.cardholder_id,
           t.location_id,
           COUNT(*) AS transaction_count,
           ROW_NUMBER() OVER (
               PARTITION BY t.cardholder_id 
               ORDER BY COUNT(*) DESC
           ) AS rn
    FROM transactions_fact t
    GROUP BY t.cardholder_id, t.location_id
) sub
WHERE rn = 1;



--14. Müştərilərin həftəlik tranzaksiya sayı və ortalama tranzaksiya məbləğini tapin.
SELECT 
    t.cardholder_id,
    TO_CHAR(t.transaction_start_datetime, 'IW') AS WeekNumber,
    COUNT(*) AS WeeklyTransactionCount,
    ROUND(AVG(t.transaction_amount), 2) AS AvgTransactionAmount
FROM transactions_fact t
GROUP BY 
    t.cardholder_id,
    TO_CHAR(t.transaction_start_datetime, 'IW')
ORDER BY 
    t.cardholder_id,
    WeekNumber;

--15. Hər Müştərinin Ən Yüksək Tranzaksiya Məbləğinin 2-ci Yüksək Məbləğdən Fərqi (yalnız iki və daha çox tranzaksiya edən müştərilər)
SELECT t1.cardholder_id,
       t1.transaction_amount - t2.transaction_amount AS dif_amount
FROM (SELECT RANK() OVER (PARTITION BY cardholder_id ORDER BY transaction_amount DESC) AS rnk,
           t.* FROM transactions_fact t) t1
JOIN (
    SELECT RANK() OVER (PARTITION BY cardholder_id ORDER BY transaction_amount DESC) AS rnk,
           t.*
    FROM transactions_fact t
) t2
ON t1.cardholder_id = t2.cardholder_id
WHERE t1.rnk = 1
  AND t2.rnk = 2;
  
----
SELECT 
    cardholder_id,
    transaction_id,
    transaction_amount
FROM transactions_fact
WHERE cardholder_id = 'LA-001-1073';

WITH ranked AS (
    SELECT DISTINCT cardholder_id,
           transaction_amount,
           DENSE_RANK() OVER (PARTITION BY cardholder_id ORDER BY transaction_amount DESC) AS rnk
    FROM transactions_fact
)
SELECT t1.cardholder_id,
       t1.transaction_amount - t2.transaction_amount AS dif_amount
FROM ranked t1
JOIN ranked t2
  ON t1.cardholder_id = t2.cardholder_id
WHERE t1.rnk = 1
  AND t2.rnk = 2;


SELECT t1.cardholder_id,
       t1.transaction_amount - t2.transaction_amount AS dif_amount
FROM (
    SELECT DISTINCT cardholder_id,
           transaction_amount,
           RANK() OVER (PARTITION BY cardholder_id ORDER BY transaction_amount DESC) AS rnk
    FROM transactions_fact
) t1
JOIN (
    SELECT DISTINCT cardholder_id,
           transaction_amount,
           RANK() OVER (PARTITION BY cardholder_id ORDER BY transaction_amount DESC) AS rnk
    FROM transactions_fact
) t2
ON t1.cardholder_id = t2.cardholder_id
WHERE t1.rnk = 1
  AND t2.rnk = 2;
