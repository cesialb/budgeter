CREATE TABLE categories (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE expenses (
  id serial PRIMARY KEY,
  category_id int UNIQUE NOT NULL,
  name text NOT NULL,
  amount numeric(6,2) NOT NULL CHECK (amount > 0.01),
  created_on date NOT NULL DEFAULT NOW(),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);