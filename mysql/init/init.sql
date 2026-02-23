-- 1. 사장님 (계정/관리)
CREATE TABLE IF NOT EXISTS owner (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    login_id VARCHAR(50) NOT NULL UNIQUE COMMENT '사장 ID',
    password VARCHAR(255) NOT NULL COMMENT '암호화된 비번',
    name VARCHAR(50) COMMENT '이름',
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6)
);

-- 2. 사업장 (store)
CREATE TABLE IF NOT EXISTS store (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    owner_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT '매장명',
    industry VARCHAR(30) COMMENT '업종',
    address VARCHAR(255) COMMENT '주소',
    business_number VARCHAR(20) COMMENT '사업자번호',
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    FOREIGN KEY (owner_id) REFERENCES owner(id)
);

-- 3. 재고 (inventory)
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    item_name VARCHAR(100) NOT NULL COMMENT '품목명',
    current_stock INT DEFAULT 0 COMMENT '현재 재고',
    unit VARCHAR(20) COMMENT '단위(kg, 개 등)',
    last_updated DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    FOREIGN KEY (store_id) REFERENCES store(id),
    UNIQUE KEY uk_store_item (store_id, item_name) -- 매장 내 중복 품목 방지
);

-- 4. AI 수요 예측용 피처 (ML Store Month Features)
CREATE TABLE IF NOT EXISTS ml_store_month_features (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    store_id BIGINT NOT NULL,
    ym CHAR(7) NOT NULL COMMENT '기준년월(YYYY-MM)',
    industry VARCHAR(30),
    sales_amount DECIMAL(14,2) DEFAULT 0.00,
    labor_amount DECIMAL(14,2) DEFAULT 0.00,
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
    FOREIGN KEY (store_id) REFERENCES store(id)
);