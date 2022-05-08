/*
SQL Project

Project Problem Statement:

You are hired by a chain of online retail stores “Reliant retail limited”. They provided you with “orders” database and seek answers
to the following queries as the results from these queries will help the company in making data-driven decisions that will impact the
 overall growth of the online retail store.*/
 
 /*
 1. Write a query to display the product details (product_class_code, product_id, product_desc, 
product_price) as per the following criteria and sort them descending order of category: 

i) If the category is 2050, increase the price by 2000 
ii) If the category is 2051, increase the price by 500 
iii) If the category is 2052, increase the price by 600
*/

select p.product_class_code, p.product_id, p.product_desc,
case
	when p.product_class_code = 2050 then p.product_price =(p.product_price+ 2000)
    when p.product_class_code = 2051 then p.product_price=(p.product_price + 500)
    when p.product_class_code = 2052 then p.product_price=(p.product_price + 600)
    else p.product_price
    end as product_price
from product p
order by p.product_class_code desc;





/*
2. Write a query to display (product_class_desc, product_id, 
product_desc, product_quantity_avail ) and Show inventory status of products as below 
as per their available quantity: 

a. For Electronics and Computer categories, if available quantity is <= 10, show 'Low stock', 11 <= qty <= 30, 
show 'In stock', >= 31, show 'Enough stock' 
b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <= 80, show 'In stock', >=81, 
show 'Enough stock' 
c. Rest of the categories, if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >= 51 – 'Enough stock' 

For all categories, if available quantity is 0, show 'Out of 
stock'.
*/
select pr.product_class_desc, p.product_id, p.product_desc, p.product_quantity_avail,
case
	when pr.product_class_desc IN ('Electronics', 'Computer') and p.product_quantity_avail>=31 then "Enough stock"
    when pr.product_class_desc IN ('Electronics', 'Computer') and p.product_quantity_avail<=10 then "Low stock"
    when pr.product_class_desc IN ('Stationery','Clothes') and p.product_quantity_avail>=81 then "Enough stock"
    when pr.product_class_desc IN ('Stationery','Clothes') and p.product_quantity_avail<=20 then "Low stock"
	when pr.product_class_desc not IN ('Electronics', 'Computer','Stationery','Clothes') and p.product_quantity_avail>=51 then "Enough stock"
    when pr.product_class_desc IN ('Electronics', 'Computer','Stationery','Clothes') and p.product_quantity_avail<=15 then "Low stock"
    else "Out of stock"
    end as inventory_status
from product p left join product_class pr
on p.product_class_code = pr.product_class_code;


/*
3. Write a query to Show the count of cities in all countries other than USA & MALAYSIA, with 
more than 1 city, in the descending order of CITIES.
*/
select country, count(city) as number_city from address where country not in ('USA', 'MALAYSIA') group by country having number_city>1;


/*
4) Write a query to display the customer_id,customer full name ,city,pincode,and order 
details (order id, product class desc, product desc, subtotal(product_quantity * 
product_price)) for orders shipped to cities whose pin codes do not have any 0s in them. 
Sort the output on customer name, order date and subtotal./*
*/

select  oc.customer_id,
concat(oc.customer_fname,oc.customer_lname) as fullname,
a.city,
a.pincode,
oh.order_id,
pc.product_class_desc,
p.product_desc,
(p.product_price*oi.product_quantity) as subtotal
from ((((online_customer oc left join
address a on  oc.address_id=a.address_id
left join order_header oh on oc.customer_id=oh.customer_id)
left join order_items oi on oh.order_id=oi.order_id)
left join product p on oi.product_id=p.product_id)
left join product_class pc on p.product_class_code=pc.product_class_code)
where a.pincode not like '%0'
and a.pincode not like '0%'
and a.pincode not like '%0%'
and p.product_desc is not null
order by fullname,oh.order_date,subtotal ;

/*
5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a 
given item whose product id is 201 and which item has been bought along with it maximum no. of 
times. Display only one record which has the maximum value for total quantity in this scenario. 
*/
with high as (select a.product_id, count(*) as cnt,p.product_desc as Highest_Bought_along
from ((order_items a
join (select distinct order_id from order_items where product_id = 201) b on (a.order_id = b.order_id))
left join product p on a.product_id= p.product_id)
where a.product_id != 201
group by a.product_id 
order by cnt desc 
limit 1)

select oi.product_id,
p.product_desc,
sum(oi.product_quantity) as totalquantity,
(select highest_bought_along from high) as Highest_bought_complimentary_product
from (order_items oi left join product p on oi.product_id= p.product_id)
where oi.product_id=201
group by oi.product_id,p.product_desc ;

/* 6. Write a query to display the customer_id,customer name, email and order details 
(order id, product desc,product qty, subtotal(product_quantity * product_price)) for all 
customers even if they have not ordered any item.(225 ROWS) */

select oc.customer_id,
concat(oc.customer_fname,oc.customer_lname) as fullname,
oc.customer_email,
oh.order_id,
p.product_desc,
oi.product_quantity,
(oi.product_quantity*p.product_price) as subtotal
from (((online_customer oc
left join order_header oh on oc.customer_id=oh.customer_id)
left join order_items oi on oh.order_id=oi.order_id)
left join product p on oi.product_id=p.product_id);

/*7. Write a query to display carton id ,(len*width*height) as carton_vol and identify the 
optimum carton (carton with the least volume whose volume is greater than the total volume of 
all items(len * width * height * product_quantity)) for a given order whose order id is 10006 
, Assume all items of an order are packed into one single carton (box) */

with volume as (select o.order_id,
p.len,
p.width,
p.height,
(p.len*p.width*p.height) as volume_of_item
from order_items o 
left join product p on o.product_id=p.product_id 
where order_id=10006
group by order_id),

CARTONS AS (select c.carton_id,
(c.len*c.width*c.height) as carton_vol
from carton c 
order by carton_vol asc)

SELECT CARTONS.CARTON_ID,
CARTONS.CARTON_VOL,
(SELECT VOLUME.ORDER_ID FROM VOLUME) AS ORDER_IDS,
(SELECT VOLUME.VOLUME_OF_ITEM FROM VOLUME) AS VOLUME_OF_ORDER
FROM CARTONS
ORDER BY CARTONS.CARTON_VOL ASC LIMIT 1;

/*
8. Write a query to display details (customer id,customer fullname,order id,product quantity) 
of customers who bought more than ten (i.e. total order qty) products with credit card or net 
banking as the mode of payment per shipped order. (6 ROWS) */

SELECT
OH.CUSTOMER_ID,
oh.order_id,
concat(oc.customer_fname,oc.customer_lname) as fullname,
sum(OI.PRODUCT_quantity) as quantityordered
FROM ORDER_HEADER OH 
LEFT JOIN ORDER_ITEMS OI ON OH.ORDER_ID=OI.ORDER_ID
left join online_customer oc on oh.customer_id=oc.customer_id
WHERE OH.PAYMENT_MODE IN ('Credit Card','Net Banking') 
group by OH.CUSTOMER_ID,fullname
having quantityordered>10;


/* 9.Write a query to display the order_id,customer_id and customer fullname starting with “A” along 
with (product quantity) as total quantity of products shipped for order ids > 10030 
(5 Rows) [NOTE: TABLES to be used-online_customer,Order_header, order_items] */

select OH.CUSTOMER_ID,
oh.order_id,
concat(oc.customer_fname,oc.customer_lname) as fullname,
sum(OI.PRODUCT_quantity) as total_quantity_of_products_shipped
from order_header oh
left join online_customer oc on oh.customer_id=oc.customer_id
left join order_items oi on oh.order_id=oi.order_id
where oh.order_id>10030
group by OH.CUSTOMER_ID,oh.order_id,fullname
HAVING FULLNAME LIKE 'A%'
AND total_quantity_of_products_shipped IS NOT NULL;

/* 10. Write a query to display product class description, totalquantity(sum(product_quantity), Total 
value (product_quantity * product price) and show which class of products have been shipped 
highest(Quantity) to countries outside India other than USA? Also show the total value of those 
items. */

select pc.product_class_desc,
sum(oi.product_quantity),
sum(oi.product_quantity * p.product_price) as total_value,
ad.country
from product_class pc inner join product p on pc.product_class_code=p.product_class_code
inner join order_items oi on p.product_id=oi.product_id
left join order_header oh on oi.order_id=oh.order_id
left join online_customer OC on oh.customer_id=oc.customer_id
left join address ad on oc.address_id=ad.address_id
where ad.country not in ('India','USA')
group by pc.product_class_desc,ad.country
ORDER BY TOTAL_VALUE DESC
/* Furniture is the highest sold product class and Malaysia is the highest importer. */

  















 





 
