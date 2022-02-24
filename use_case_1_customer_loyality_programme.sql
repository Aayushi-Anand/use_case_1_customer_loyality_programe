CREATE TABLE menu
(
product_id int PRIMARY KEY,
product_name varchar(5),
price int
);

CREATE TABLE members
(
customer_id varchar(1) PRIMARY KEY,
join_date timestamp
);

CREATE TABLE sales
(
customer_id varchar(1) REFERENCES members(customer_id),
order_date date,
product_id int REFERENCES menu(product_id)
);


insert into menu values (1,'sushi',10);
insert into menu values (2,'curry',15);
insert into menu values (3,'ramen',12);

insert into members values ('A','07/01/2021');
insert into members values ('B','09/01/2021');
insert into members values ('C','12/01/2021');


insert into sales values ('A','01/01/2021',1);
insert into sales values ('A','01/01/2021',2);
insert into sales values ('A','07/01/2021',2);
insert into sales values ('A','10/01/2021',3);
insert into sales values ('A','11/01/2021',3);
insert into sales values ('A','11/01/2021',3);
insert into sales values ('B','01/01/2021',2);
insert into sales values ('B','02/01/2021',2);
insert into sales values ('B','01/01/2021',1);
insert into sales values ('B','11/01/2021',1);
insert into sales values ('B','16/01/2021',3);
insert into sales values ('B','01/01/2021',3);
insert into sales values ('C','01/01/2021',3);
insert into sales values ('C','01/01/2021',3);
insert into sales values ('C','07/01/2021',3);

select * from sales;
select * from members;
select * from menu;

--Question 1
select s.customer_id,sum(b.price) amount from sales s,menu b where s.product_id = b.product_id
group by s.customer_id;

--Question 2
select customer_id,count(distinct(order_date)) as count from sales group by customer_id order by customer_id;

--Question 3
select DISTINCT t.customer_id,m.product_name 
from (select s.* ,DENSE_RANK() over (order by  s.order_date) as k from sales s) t, menu m 
where t.product_id = m.product_id and k = 1 order by t.customer_id;


--Question 4
select * from (
select m.product_name, s.product_id, count(s.product_id) as most_purchased_item from sales s join menu m
on s.product_id = m.product_id group by m.product_name, s.product_id order by most_purchased_item desc) where rownum=1;

--Question 5
select customer_id,product_id,product_name from (
select t.customer_id,t.product_id,t.cnt,m.product_name,rank() over(partition by customer_id order by t.customer_id ASC,t.cnt DESC) as rankk from
(select customer_id,product_id,count(product_id) cnt 
from sales group by customer_id,product_id order by customer_id ASC,cnt DESC) t,menu m
where t.product_id = m.product_id  order by t.customer_id ) q where rankk=1;

-- Q6) Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name, order_date FROM
(SELECT customer_id, join_date, order_date, product_name, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as rn
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)
 WHERE order_date >= join_date) sq
 WHERE rn = 1;
 
 -- 7)Q Which item was purchased just before the customer became a member?
SELECT customer_id, product_name, order_date FROM
(SELECT customer_id, join_date, order_date, product_name, RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as rn
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)
 WHERE order_date < join_date) sq
WHERE rn = 1;

--Question 8
select a.customer_id,count(a.order_date) total ,sum(c.price) 
from sales a,members b,menu c
where a.customer_id = b.customer_id
and a.product_id = c.product_id
and to_char(b.join_date,'DD-MM-YY') > a.order_date
group by a.customer_id;

--Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? 

SELECT DISTINCT customer_id, 
SUM(CASE WHEN product_name = 'sushi' THEN price*20 
ELSE price*10 END) OVER (PARTITION BY customer_id)as Reward
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)order by customer_id;
 

--Question 10
 select customer_id,sum(points) total_points from (
 select sales.customer_id customer_id,sales.product_id product_id,menu.product_name product_name,menu.price,
sales.order_date-to_date(to_char(members.join_date,'dd-mm-yy')) no_of_days,sales.order_date order_date,
case
when 
(sales.order_date-to_date(to_char(members.join_date,'dd-mm-yy')) >0) and 
(sales.order_date-to_date(to_char(members.join_date,'dd-mm-yy'))<7) then menu.price*210
else(  case when product_name ='sushi' then price*102 else price*10 end )
end points
from sales inner join members on sales.customer_id=members.customer_id 
inner join menu on sales.product_id=menu.product_id ) where order_date < to_date('01-02-21','dd-mm-yy') group by customer_id ;
 
 
 
 
 
 
 


