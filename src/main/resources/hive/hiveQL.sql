-- noinspection SqlNoDataSourceInspectionForFile

-- 1：创建内部表：
create table student(
id int,
name string,
age int)
comment 'this is student message table'
row format delimited fields terminated by '\t';

-- 从本地加载数据
load data local inpath './data/hive/student.txt' into table student;
-- 从HDFS加载数据
load data inpath './data/hive/student.txt' into table student;


-- 2：创建外部表
create external table external_student(
id int,
name string,
age int)
comment 'this is student message table'
row format delimited fields terminated by '\t'
location "/user/hive/external";

-- 加载数据
-- 直接将源文件放在外部表的目下即可
-- 这种加载方式常常用于当hdfs上有一些历史数据，而我们需要在这些数据上做一些hive的操作时使用。这种方式避免了数据拷贝开销
hdfs dfs -put ./data/hive/external_student /user/hive/external



-- 3：创建copy_student表，并从student表中导入数据
create table copy_student(
id int,
name string,
age int)
comment 'this is student message table'
row format delimited fields terminated by '\t';

-- 导入数据
from student stu insert overwrite table copy_student select *;


-- 4：创建复杂类型的表
Create table complex_student(
stu_mess ARRAY<STRING>,
stu_score MAP<STRING,INT>,
stu_friend STRUCT<a:STRING,
b :STRING,c:STRING>)
comment 'this is complex_student message table'
row format delimited fields terminated by '\t'
COLLECTION ITEMS TERMINATED BY ','
MAP KEYS TERMINATED BY ':';

-- #修改表名字
alter table complex rename to complex_student;
-- #加载数据
load data local inpath "./data/hive/complex_student" into table complex_student;

-- #截断表 :从表或者表分区删除所有行，不指定分区，将截断表中的所有分区，也可以一次指定多个分区，截断多个分区。
truncate table complex_student;

-- #查询示例
select stu_mess[0],stu_score["chinese"],stu_friend.a from complex_student;
-- 结果：thinkgamer	50	cyan


-- 5：创建分区表partition_student
create table partition_student(
id int,
name string,
age int)
comment 'this is student message table'
Partitioned by (grade string,class string)
row format delimited fields terminated by "\t";
-- #加载数据
load data local inpath "./data/hive/partiton_student" into table partition_student partition (grade="2013", class="34010301");
load data local inpath "./data/hive/partiton_student2" into table partition_student partition (grade="2013", class="34010302");


-- 6:桶 创建临时表
create table student_tmp(
id int,
name string,
age int)
comment 'this is student message table'
row format delimited fields terminated by '\t';

-- 加载数据：
load data local inpath './data/hive/student.txt' into table student_tmp;

-- 创建指定桶的个数的表student_bucket
create table student_bucket(
id int,
name string,
age int)
clustered by(id) sorted by(age) into 2 buckets
row format delimited fields terminated by '\t';

-- 设置环境变量：
set hive.enforce.bucketing = true; 

-- 从student_tmp 装入数据
from student_tmp
insert overwrite table student_bucket
select *;

