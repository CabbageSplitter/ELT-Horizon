Данная спецификация описывает модель данных DM слоя DWH

| Сущность             | Атрибут                | Тип данных    | Ключ   | Описание                                                                     | Ограничения      |
| -------------------- | ---------------------- | ------------- | ------ | ---------------------------------------------------------------------------- | ---------------- |
| **dim_calendar**     | date_key               | integer       | PK     | SK                                                                           | NOT NULL, UNIQUE |
|                      | full_date              | date          | -      | -                                                                            | NOT NULL         |
|                      | day_of_week            | tinyint       | -      | -                                                                            | NOT NULL         |
|                      | day_name               | varchar(10)   | -      | -                                                                            | NOT NULL         |
|                      | quarter                | tinyint       | -      | -                                                                            | NOT NULL         |
|                      | year                   | smallint      | -      | -                                                                            | NOT NULL         |
|                      | is_holiday             | boolean       | -      | Выходной или нет                                                             | NOT NULL         |
| **dim_product**      | product_key            | integer       | PK     | SK                                                                           | NOT NULL, UNIQUE |
|                      | product_id             | string        | -      | -                                                                            | NOT NULL         |
|                      | product_name           | varchar(255)  | -      | -                                                                            | NOT NULL         |
|                      | category               | varchar(100)  | -      | -                                                                            | NOT NULL         |
|                      | brand                  | varchar(100)  | -      | -                                                                            | NOT NULL         |
|                      | valid_from             | date          | -      | -                                                                            | NOT NULL         |
|                      | valid_to               | date          | -      | -                                                                            | NULLABLE         |
|                      | is_current             | boolean       | -      | Текущая версия                                                               | NOT NULL         |
| **dim_store**        | store_key              | integer       | PK     | SK                                                                           | NOT NULL, UNIQUE |
|                      | store_id               | string        | -      | -                                                                            | NOT NULL         |
|                      | address                | varchar(255)  | -      | -                                                                            | NOT NULL         |
|                      | region                 | varchar(100)  | -      | -                                                                            | NOT NULL         |
|                      | valid_from             | date          | -      | -                                                                            | NOT NULL         |
|                      | valid_to               | date          | -      | -                                                                            | NULLABLE         |
|                      | is_current             | boolean       | -      | Текущая версия                                                               | NOT NULL         |
| **fact_sales_daily** | date_key               | integer       | FK     | -                                                                            | NOT NULL         |
|                      | store_key              | integer       | FK     | -                                                                            | NOT NULL         |
|                      | product_key            | integer       | FK     | -                                                                            | NOT NULL         |
|                      | sum_sales              | decimal(12,2) | Metric | Общая сумма продаж товара за день (сумма amount по позициям)                 | NOT NULL         |
|                      | num_transactions       | integer       | Metric | Кол-во уникальных чеков, содержащих данный товар в этот день в этом магазине | NOT NULL         |
|                      | avg_transaction_amount | decimal(10,2) | Metric | Средняя общая сумма чека по этим чекам                                       | NOT NULL         |
