-- 理发店预约数据库初始化脚本
-- 创建数据库和用户

-- 创建数据库（如果不存在）
CREATE DATABASE barber_shop;

-- 创建用户（如果不存在）
CREATE USER barber_user WITH PASSWORD 'barber_password';

-- 授予权限
GRANT ALL PRIVILEGES ON DATABASE barber_shop TO barber_user;

-- 连接到数据库
\c barber_shop;

-- 创建扩展（如果需要）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 设置时区
SET timezone = 'Asia/Shanghai';

-- 授权schema权限
GRANT ALL ON SCHEMA public TO barber_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO barber_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO barber_user;