CREATE DATABASE number_mystery_db;

\c number_mystery_db;

CREATE TABLE user(
    id SERIAL,
    username CHARACTER VARYING(30) NOT NULL UNIQUE,
    score BIGINT NOT NULL DEFAULT 0,
    CONSTRAINT user_pkey PRIMARY KEY (id)
);