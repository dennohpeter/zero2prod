-- migrations/20221125155023_create_subscriptions_table.sql
-- Create subscriptions table

CREATE TABLE subscriptions (
  id UUID NOT NULL,
  PRIMARY KEY (id),
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
