-- 1. tạo database và sử dụng
create database session_sales;
use session_sales;
-- 2. tạo bảng theo SRS

create table customers (
    customer_id int auto_increment primary key,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
);

create table categories (
    category_id int auto_increment primary key,
    category_name varchar(255) not null unique
);

create table products (
    product_id int auto_increment primary key,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check (price > 0),
    category_id int not null,
    foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int auto_increment primary key,
    customer_id int not null,
    order_date datetime default current_timestamp,
    status enum('Pending','Completed','Cancel') default 'Pending',
    foreign key (customer_id) references customers(customer_id)
);

create table order_items (
    order_item_id int auto_increment primary key,
    order_id int,
    product_id int,
    quantity int not null check (quantity > 0),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);

-- 3. dữ liệu mẫu
insert into customers (customer_name, email, phone) values
('Nguyen Van A', 'a@gmail.com', '0901111111'),
('Tran Thi B', 'b@gmail.com', '0902222222'),
('Le Van C', 'c@gmail.com', '0903333333'),
('Pham Van D', 'd@gmail.com', '0904444444');

insert into categories (category_name) values
('Laptop'),
('Phone'),
('Accessory');

insert into products (product_name, price, category_id) values
('Laptop Dell', 2000, 1),
('Laptop HP', 1800, 1),
('Macbook Pro', 2500, 1),
('Iphone 15', 1500, 2),
('Samsung S23', 1300, 2),
('Mouse Logitech', 50, 3),
('Keyboard Corsair', 120, 3);

insert into orders (customer_id, status) values
(1, 'Completed'),
(1, 'Completed'),
(2, 'Pending'),
(3, 'Completed'),
(4, 'Cancel');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 6, 2),
(2, 4, 1),
(2, 7, 1),
(3, 5, 2),
(4, 3, 1);

-- 1. danh sách tất cả danh mục
select * from categories;

-- 2. đơn hàng có trạng thái completed
select * from orders
where status = 'Completed';

-- 3. danh sách sản phẩm sắp xếp giá giảm dần
select * from products
order by price desc;

-- 4. 5 sản phẩm giá cao nhất, bỏ 2 sản phẩm đầu
select * from products
order by price desc
limit 5 offset 2;

-- PHẦN B – TRUY VẤN NÂNG CAO

-- 1. sản phẩm kèm tên danh mục
select
    p.product_name,
    c.category_name
from products p
join categories c on p.category_id = c.category_id;

-- 2. danh sách đơn hàng
select
    o.order_id,
    o.order_date,
    c.customer_name,
    o.status
from orders o
join customers c on o.customer_id = c.customer_id;

-- 3. tổng số lượng sản phẩm trong từng đơn hàng
select
    order_id,
    sum(quantity) as total_quantity
from order_items
group by order_id;

-- 4. số đơn hàng của mỗi khách hàng
select
    customer_id,
    count(*) as total_orders
from orders
group by customer_id;

-- 5. khách hàng có tổng số đơn hàng ≥ 2
select
    customer_id,
    count(*) as total_orders
from orders
group by customer_id
having count(*) >= 2;

-- 6. thống kê giá theo danh mục
select
    c.category_name,
    avg(p.price) as avg_price,
    min(p.price) as min_price,
    max(p.price) as max_price
from products p
join categories c on p.category_id = c.category_id
group by c.category_name;

-- PHẦN C – TRUY VẤN LỒNG (SUBQUERY)
-- 1 sản phẩm có giá cao hơn giá trung bình
select *
from products
where price > (
    select avg(price) from products
);

-- 2. khách hàng đã từng đặt ít nhất 1 đơn
select *
from customers
where customer_id in (
    select distinct customer_id from orders
);

-- 3. đơn hàng có tổng số lượng sản phẩm lớn nhất
select order_id
from order_items
group by order_id
having sum(quantity) = (
    select max(total_qty)
    from (
        select sum(quantity) as total_qty
        from order_items
        group by order_id
    ) as temp
);

-- 4. tên khách hàng mua sản phẩm thuộc danh mục có giá trung bình cao nhất
select distinct c.customer_name
from customers c
join orders o on c.customer_id = o.customer_id
join order_items oi on o.order_id = oi.order_id
join products p on oi.product_id = p.product_id
where p.category_id = (
    select category_id
    from products
    group by category_id
    order by avg(price) desc
    limit 1
);

-- 5. từ bảng tạm, tổng số lượng sản phẩm đã mua của từng khách hàng
select
    customer_id,
    sum(total_quantity) as total_quantity
from (
    select
        o.customer_id,
        sum(oi.quantity) as total_quantity
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
) as temp
group by customer_id;

-- 6. sản phẩm có giá cao nhất (subquery trả 1 giá trị)
select *
from products
where price = (
    select max(price) from products
);