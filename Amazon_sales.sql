-- Amazon data for product analysis,sales analysis,customer analysis.
use amazon_project;
select * from amazon;

alter table amazon change `Invoice ID` Invoice_id text,
change `Customer type` Customer_type text,
change `Product line` Product_line text,
change `Unit price` Unit_price double,
change `Tax 5%` Tax_5perc double,
change `gross margin percentage` gross_margin_percentage double,
change `gross income` gross_income double;


alter table amazon modify column Invoice_id text not null;
alter table amazon modify column Branch text not null,
modify column city text not null,
modify column Customer_type text not null,
modify column gender text not null,
modify column Product_line text not null,
modify column Unit_price double not null,
modify column Quantity int not null,
modify column Tax_5perc double not null,
modify column Total double not null,
modify column `Date` text not null,
modify column `Time` text not null,
modify column Payment text not null,
modify column cogs double not null,
modify column gross_margin_percentage double not null,
modify column gross_income double not null,
modify column Rating double not null;

show columns from amazon_project.amazon;

-- Feature Engineering

alter table amazon add column timeofday varchar(25) not null,
add column dayname varchar(25) not null,
add column monthname varchar(25) not null;


set sql_safe_updates=0;

update amazon set timeofday = 
case when '00:00:00' <= time(Time) and time(Time) < '12:00:00' then "Morning"
	 when '12:00:00' <= time(Time) and time(Time) < '17:00:00' then "Afternoon"
     else "Evening" 
end;

update amazon set dayname = 
dayname(Date) ;

update amazon set monthname =
monthname(Date);

alter table amazon modify timeofday varchar(25) after Time ;

alter table amazon modify monthname varchar(25) after Date;

alter table amazon modify dayname varchar(25) after monthname;

select * from amazon;
--  Exploratory Data Analysis (EDA)

-- 1.What is the count of distinct cities in the dataset?
select count(distinct city) as count_of_distinct_cities from amazon; -- 3

-- 2.For each branch, what is the corresponding city?
select distinct branch,city from amazon;
/*  A	Yangon
	C	Naypyitaw
	B	Mandalay*/

-- 3.What is the count of distinct product lines in the dataset?
select count(distinct product_line) as count_of_distinct_product_lines from amazon; -- 6

-- 4.Which payment method occurs most frequently?
select payment,count(*) as frequent_payment_methods from amazon group by payment 
order by frequent_payment_methods desc limit 1; -- Ewallet	345

-- 5.Which product line has the highest sales?
select product_line,count(total) as max_sales from amazon group by product_line order by max_sales desc limit 1; -- Fashion accessories	178

-- 6.How much revenue is generated each month?
select monthname,sum(total) as revenue from amazon group by monthname; 
/* January	116291.86800000005
   March	109455.50700000004
   February	97219.37399999997*/

-- 7.In which month did the cost of goods(cogs) sold reach its peak?
select monthname,sum(cogs) total_cost from amazon group by monthname order by total_cost desc limit 1; -- January	110754.16000000002

-- 8.Which product line generated the highest revenue?
select product_line,sum(total) as revenue from amazon group by product_line order by revenue desc limit 1; 
-- Food and beverages	56144.844000000005

-- 9.In which city was the highest revenue recorded?
select city,sum(total) as revenue from amazon group by city order by revenue desc limit 1; -- Naypyitaw	110568.70649999994

-- 10.Which product line incurred the highest Value Added Tax?
select product_line,sum(Tax_5perc) as HVAT from amazon group by product_line order by HVAT desc limit 1; 
-- Food and beverages	2673.5639999999994

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
--  average sales 
select avg(total_sales) from 
(select product_line,sum(total) as total_sales from amazon group by product_line) as t;
-- So, average sales is 53827.7915

-- now the actual task...
select product_line,sum(total) as total_sales,
case
when sum(total)>( select avg(total_sales) from 
				(select product_line,sum(total) as total_sales from amazon group by product_line) as t)
then "Good" 
else "Bad"
end as sales_stats
from amazon
group by product_line order by total_sales desc; 

-- 12.Identify the branch that exceeded the average number of products sold.
-- average products sold
select round(avg(total_sold)) from(
select branch,sum(quantity) as total_sold from amazon group by branch) as t; -- 1837

-- Actual Task
select branch,sum(quantity) products_sold from amazon group by branch having  sum(quantity) > 
(select round(avg(total_sold)) from(
select branch,sum(quantity) as total_sold from amazon group by branch) as t);

-- 13.Which product line is most frequently associated with each gender?
select product_line,gender,count(*) as most_frequent from amazon 
group by product_line,gender order by most_frequent desc ;

-- 14.Calculate the average rating for each product line.
select product_line,avg(rating) as avg_rating from amazon group by product_line;

-- 15.Count the sales occurrences for each time of day on every weekday.
select timeofday,dayname,count(total) as sales_occurences from amazon 
group by timeofday,dayname order by sales_occurences desc; 
-- sales occurence on every weekday.
select dayname,count(total) as sales_occurences from amazon 
group by dayname order by sales_occurences desc;
 
-- 16.Identify the customer type contributing the highest revenue.
select customer_type,sum(total) as revenue from amazon group by customer_type order by revenue desc limit 1; -- member

-- 17.Determine the city with the highest VAT percentage.
select city,(round(sum(tax_5perc),2) / round(sum(total),2))*100 as highest_vat_perc from amazon 
group by city order by highest_vat_perc desc; 
-- city with  highest VAT percentage.
select city,(round(sum(tax_5perc),2) / round(sum(total),2))*100 as highest_vat_perc from amazon 
group by city order by highest_vat_perc desc limit 1;-- naypyitaw

-- 18.dentify the customer type with the highest VAT payments.
select customer_type,count(payment) highest_vat_payments, sum(total) as total_vat from amazon 
group by customer_type order by highest_vat_payments desc limit 1; -- memeber

-- 19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type) customer_types_count from amazon; -- 2

-- 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment) payment_methods_count from amazon; -- 3

-- 21.Which customer type occurs most frequently?
select customer_type,count(*) as frequency from amazon 
group by customer_type order by frequency desc limit 1; -- member

-- 22.Identify the customer type with the highest purchase frequency.
select customer_type,count(payment) as frequency from amazon 
group by customer_type order by frequency desc limit 1; 

-- 23.Determine the predominant gender among customers.
select gender predominant_gender,count(*) countofcustomers from amazon 
group by gender order by countofcustomers desc limit 1; -- Female

-- 24.Examine the distribution of genders within each branch.
select branch,gender,count(*) distribution_of_genders  from amazon 
group by branch,gender order by distribution_of_genders desc;

-- 25.Identify the time of day when customers provide the most ratings.
select timeofday,count(rating) most_ratings from amazon 
group by timeofday order by most_ratings desc limit 1; -- Afternoon

-- 26.Determine the time of day with the highest customer ratings for each branch.
select branch,timeofday,count(rating) from amazon group by branch,timeofday order by count(rating) desc;

-- 27.Identify the day of the week with the highest average ratings.
select dayname,avg(rating) as highest_average_ratings from amazon 
group by dayname order by highest_average_ratings desc ; -- monday

-- 28.Determine the day of the week with the highest average ratings for each branch.
select branch,dayname,avg(rating) as highest_average_ratings from amazon 
group by branch,dayname order by highest_average_ratings desc;

-- Product analysis
/*Food and Beverages: Highest total sales 56,144.84.
Sports and Travel: Second highest sales 55,122.83.
Electronic Accessories: Third in sales 54,337.53.
Need to improve
Health and Beauty: Lowest total sales 49,193.74*/

-- sales Analysis 
/*Food and Beverages: Quantity Sold: 952 units

Sports and Travel: Quantity Sold: 920 units

Electronic Accessories: Quantity Sold: 971 units
*/

-- Customer Analysis 
/*The distribution is relatively balanced across genders within both customer types, 
with a slight predominance of females among Members and males among Normal customers.
*/