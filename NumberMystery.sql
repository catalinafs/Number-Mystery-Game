CREATE DATABASE number_mystery_db;

\c number_mystery_db;

CREATE TABLE player(
    id SERIAL,
    username CHARACTER VARYING(30) NOT NULL UNIQUE,
    score BIGINT NOT NULL DEFAULT 0,
    last_played TIMESTAMP DEFAULT now(),
    CONSTRAINT user_pkey PRIMARY KEY (id)
);