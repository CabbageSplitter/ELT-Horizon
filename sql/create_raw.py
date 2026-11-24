class CreateRawTables:
    
    def __init__(self):
        self.db_name = 'horizon'

    def create_cards(self):
        return f"""
            create table if not exists {self.db_name}.raw_cards
            (
                card_id String,
                client_id String,
                card_number String,
                issue_date String,
                status String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (card_id)
        """

    def create_clients(self):
        return f"""
            create table if not exists {self.db_name}.raw_clients
            (
                client_id String,
                full_name String,
                birth_date String,
                phone String,
                email String,
                registration_date String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (client_id)
        """

    def create_products(self):
        return f"""
            create table if not exists {self.db_name}.raw_products
            (
                product_id String,
                name String,
                category String,
                brand String,
                purchase_price String,
                status String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (product_id)
        """
    
    def create_sales(self):
        return f"""
            create table if not exists {self.db_name}.raw_sales
            (
                transaction_id String,
                product_id String,
                amount String,
                oquantity String,
                store_id String,
                datetime String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (transaction_id)
        """

    def create_stores(self):
        return f"""
            create table if not exists {self.db_name}.raw_stores
            (
                store_id String,
                address String,
                region String,
                phone String,
                type String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (store_id)
        """
    
    def create_transactions(self):
        return f"""
            create table if not exists {self.db_name}.raw_transactions
            (
                loyalty_transaction_id String,
                card_id String,
                points String,
                transaction_date String,
                store_id String,
                source_transaction_id String,
                _loaded_at Datetime default now()
            )
            Engine = MergeTree
            order by (loyalty_transaction_id)
        """