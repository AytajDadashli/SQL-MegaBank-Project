# SQL ATM Tranzaksiya Layihəsi

Bu layihədə ATM tranzaksiyaları SQL ilə analiz edilmişdir. Layihə cədvəl yaradılması skriptləri və müştəri davranışı, tranzaksiya tendensiyaları və ATM istifadəsi haqqında məlumat əldə etmək üçün sorğular ehtiva edir.

## Layihə Strukturu

- **datasets/**: Dataset faylları (csv formatında)
  - `Texas.csv` - tranzaksiya məlumatları
  - `Dim_customers.csv` - müştəri məlumatları
  - `Dim_transaction_type.csv` - tranzaksiya növləri
- **layihe_sql.sql**: Analiz üçün bütün SQL sorğuları
- **dataset_description.txt**: Dataset haqqında qısa izah

## Sorğuların Xülasəsi

Layihədəki SQL sorğuları aşağıdakıları əhatə edir:

1. **Hər Müştərinin Son Tranzaksiyası**: Hər müştərinin ən son tranzaksiyasının tarixi və bu tarixdən keçən gün sayı.
2. **Ən Böyük Tranzaksiya**: Ən böyük məbləğli tranzaksiyanı edən müştəri və peşəsi.
3. **Tranzaksiya Etməmiş Müştərilər**: Heç bir tranzaksiya etməyən müştərilərin sayı.
4. **Müştəri Başına Orta Tranzaksiya**: Müştəri başına orta tranzaksiya məbləği (yuvarlaqlaşdırılmış və adlar böyük hərflə).
5. **Ən Uzun 10 Tranzaksiya**: Ən uzun müddətli 10 tranzaksiyanın tapılması.
6. **Tranzaksiya Tipinə Görə Ümumi Statistikalar**: Hər tranzaksiya növü üzrə ümumi say və məbləğ.
7. **Müştəri Yaş Qrupları**: Müştərilərin yaş qruplarına bölünməsi və ortalama tranzaksiya məbləği.
8. **ATM üzrə Yerli və Qeyri-Yerli Tranzaksiyalar**: Hər ATM-də yerli və qeyri-yerli müştəri tranzaksiyaları.
9. **Ən Çox ATM İstifadə Edən 10 Müştəri**: Müxtəlif ATM-ləri istifadə edən müştərilər.
10. **Hesab Tipinə Görə Tranzaksiya Məbləği**: Müştəri hesab tipinə görə ümumi tranzaksiya məbləği.
11. **Tək ID-li Müştərilərin Tranzaksiyaları**: Duplicated olmayan müştərilərin tranzaksiyaları.
12. **Müştəri üzrə İllik Tranzaksiyalar**: Hər müştərinin illik tranzaksiya sayı.
13. **Müştərinin Ən Çox Tranzaksiya Etdiyi ATM**: Hər müştəri üçün ən çox istifadə edilən ATM.
14. **Həftəlik Tranzaksiyalar**: Hər müştərinin həftəlik tranzaksiya sayı və ortalama məbləği.
15. **Ən Yüksək və İkinci Yüksək Tranzaksiya Fərqi**: İki və daha çox tranzaksiya edən müştərilər üçün fərq.

## Necə istifadə etmək olar

1. CSV dataset fayllarını `datasets/` qovluğuna qoyun.  
2. `layihe_sql.sql` faylını SQL mühitində açın və sorğuları işlədin.  
3. Nəticələri müştəri davranışı və ATM tranzaksiya tendensiyaları üçün analiz edin.

---
# SQL ATM Transactions Project

This project analyzes ATM transaction data using SQL. It includes table creation scripts and queries to gain insights about customer behavior, transaction trends, and ATM usage.

## Project Structure

- **datasets/**: Contains the dataset files in csv format
  - `Texas.csv` - transaction details
  - `Dim_customers.csv` - customer information
  - `Dim_transaction_type.csv` - transaction types
- **layihe_sql.sql**: All SQL queries for analysis
- **dataset_description.txt**: Short description of the datasets

## Queries Overview

The SQL queries included in this project cover:

1. **Last Transaction per Customer**: Finds each customer's most recent transaction date and days since that transaction.
2. **Highest Transaction**: Shows the customer with the highest transaction amount and their occupation.
3. **Customers Without Transactions**: Counts the number of customers who never made a transaction.
4. **Average Transaction per Customer**: Calculates the rounded average transaction amount per customer with names in uppercase.
5. **Top 10 Longest Transactions**: Identifies the 10 transactions with the longest duration.
6. **Transaction Type Summary**: Total count and amount for each transaction type.
7. **Customer Age Groups**: Categorizes customers by age groups and calculates average transaction amount.
8. **ATM Local vs Non-Local Transactions**: Shows the number of local and non-local customer transactions per ATM.
9. **Top 10 Customers Using Most ATMs**: Identifies customers using the most distinct ATMs.
10. **Transaction Amount by Account Type**: Total transaction amount per account type.
11. **Transactions of Unique Customers**: Transactions of customers with unique IDs.
12. **Yearly Transactions per Customer**: Transaction count per year for each customer.
13. **Most Frequent ATM per Customer**: Finds the ATM with the highest transaction count for each customer.
14. **Weekly Transactions per Customer**: Weekly transaction count and average amount.
15. **Difference Between Highest and Second Highest Transaction**: For customers with at least two transactions.

## How to Use

1. Place the CSV datasets in the `datasets/` folder.  
2. Open `layihe_sql.sql` in your SQL environment and execute queries.  
3. Review results for insights on customer behavior and ATM transaction trends.
