Данная спецификация описывает модель данных DDS слоя DWH



| Сущность                    | Атрибут                   | Тип данных    | Ключ | Описание                                      | Ограничения      |
| --------------------------- | ------------------------- | ------------- | ---- | --------------------------------------------- | ---------------- |
| **HUB_PRODUCT**             | hk_product_id             | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | product_id                | string        | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_STORE**               | hk_store_id               | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | store_id                  | string        | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_TRANSACTON**          | hk_transaction_id         | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | transaction_id            | string        | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_CLIENT**              | hk_client_id              | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | client_id                 | integer       | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_CARD**                | hk_card_id                | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | card_id                   | integer       | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_LOYALTY_TRANSACTION** | hk_loyalty_transaction_id | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | loyalty_transaction_id    | integer       | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **HUB_EMPLOYEE**            | hk_employee_id            | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | employee_id               | integer       | -    | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_SALE**               | hk_sale_id                | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_transaction_id         | string        | FK   | -                                             | NOT NULL         |
|                             | hk_product_id             | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_TRANSATION_STORE**   | hk_txn_store_id           | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_transaction_id         | string        | FK   | -                                             | NOT NULL         |
|                             | hk_store_id               | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_CARD_CLIENT**        | hk_card_client_id         | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_card_id                | string        | FK   | -                                             | NOT NULL         |
|                             | hk_client_id              | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_LOYALTY_TXN_STORE**  | hk_loyalty_store_id       | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_loyalty_transaction_id | string        | FK   | -                                             | NOT NULL         |
|                             | hk_store_id               | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_LOYALTY_TXN_SOURCE** | hk_loyalty_source_id      | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_loyalty_transaction_id | string        | FK   | -                                             | NOT NULL         |
|                             | hk_transaction_id         | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **LINK_EMPLOYEE_STORE**     | hk_employee_store_id      | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | hk_employee_id            | string        | FK   | -                                             | NOT NULL         |
|                             | hk_store_id               | string        | FK   | -                                             | NOT NULL         |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
| **SAT_PRODUCT_STATIC**      | hk_product_id             | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от category, brand                       | NOT NULL, UNIQUE |
|                             | name                      | varchar(100)  | -    | -                                             | NOT NULL         |
|                             | category                  | varchar(50)   | -    | -                                             | NOT NULL         |
|                             | brand                     | varchar(50)   | -    | -                                             | NOT NULL         |
| **SAT_PRODUCT_DYNAMIC**     | hk_product_id             | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от purchase_price, status                | NOT NULL, UNIQUE |
|                             | purchase_price            | decimal(10,2) | -    | -                                             | NOT NULL         |
|                             | status                    | boolean       | -    | -                                             | NOT NULL         |
| **SAT_STORE**               | hk_store_id               | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от address, region, phone                | NOT NULL, UNIQUE |
|                             | address                   | varchar(100)  | -    | -                                             | NOT NULL         |
|                             | region                    | varchar(50)   | -    | -                                             | NOT NULL         |
|                             | phone                     | varchar(11)   | -    | -                                             | NOT NULL         |
|                             | type                      | varchar(30)   | -    | -                                             | NOT NULL         |
| **SAT_TRANSACTION**         | hk_transaction_id         | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от date_time, sum_amount, payment_method | NOT NULL, UNIQUE |
|                             | transaction_date          | timestamp     | -    | -                                             | NOT NULL         |
|                             | sum_amount                | decimal(10,2) | -    | -                                             | NOT NULL         |
|                             | payment_method            | varchar(10)   | -    | -                                             | NOT NULL         |
| **SAT_CLIENT**              | hk_client_id              | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от full_name, phone, email               | NOT NULL, UNIQUE |
|                             | full_name                 | varchar(255)  | -    | -                                             | NOT NULL         |
|                             | birth_date                | date          | -    | -                                             | NOT NULL         |
|                             | phone                     | varchar(20)   | -    | -                                             | NOT NULL         |
|                             | email                     | varchar(255)  | -    | -                                             | NOT NULL         |
|                             | registratrion_date        | date          | -    | -                                             | NOT NULL         |
| **SAT_CARD**                | hk_card_id                | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от card_number, status                   | NOT NULL, UNIQUE |
|                             | card_number               | varchar(50)   | -    | -                                             | NOT NULL         |
|                             | issue_date                | date          | -    | -                                             | NOT NULL         |
|                             | status                    | varchar(20)   | -    | -                                             | NOT NULL         |
| **SAT_LOYALTY_TXN**         | hk_loyalty_transaction_id | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от points, transaction_date, type        | NOT NULL, UNIQUE |
|                             | points                    | integer       | -    | -                                             | NOT NULL         |
|                             | transaction_date          | timestamp     | -    | -                                             | NOT NULL         |
|                             | type                      | varchar(20)   | -    | -                                             | NOT NULL         |
| **SAT_EMPLOYEE**            | hk_employee_id            | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от full_name, position                   | NOT NULL, UNIQUE |
|                             | full_name                 | varchar(255)  | -    | -                                             | NOT NULL         |
|                             | position                  | varchar(100)  | -    | -                                             | NOT NULL         |
|                             | ohire_date                | date          | -    | -                                             | NOT NULL         |
|                             | termination_date          | date          | -    | -                                             | NOT NULL         |
| **SAT_SALE**                | hk_sale_id                | string        | PK   | -                                             | NOT NULL, UNIQUE |
|                             | source                    | varchar(50)   | -    | Источник                                      | NOT NULL         |
|                             | load_dts                  | timestamp     | -    | Дата и время загрузки                         | NOT NULL         |
|                             | load_end_dts              | timestamp     | -    | Дата и время окончания актуальности           | NULLABLE         |
|                             | hash_diff                 | varchar(32)   | -    | hash от amount, quantity                      | NOT NULL, UNIQUE |
|                             | amount                    | decimal(10,2) | -    | -                                             | NOT NULL         |
|                             | quantity                  | decimal(10,3) | -    | -                                             | NOT NULL         |
