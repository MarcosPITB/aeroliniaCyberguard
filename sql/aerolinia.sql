--
-- PostgreSQL database dump
--

\restrict gfdiZnYK2eWI7pgEaF7i6yQ3xYHZvG3vU0neBn3pJOIcaQbaNMhE0yxVl0d4xQX

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: pasajeros; Type: TABLE; Schema: public; Owner: pau
--

CREATE TABLE public.pasajeros (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    pasaporte character varying(20) NOT NULL,
    numero_vuelo character varying(10) NOT NULL,
    origen character varying(50) NOT NULL,
    destino character varying(50) NOT NULL,
    fecha_vuelo date NOT NULL,
    asiento character varying(5) NOT NULL,
    maletas_facturadas integer DEFAULT 0
);


ALTER TABLE public.pasajeros OWNER TO pau;

--
-- Name: pasajeros_id_seq; Type: SEQUENCE; Schema: public; Owner: pau
--

CREATE SEQUENCE public.pasajeros_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pasajeros_id_seq OWNER TO pau;

--
-- Name: pasajeros_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pau
--

ALTER SEQUENCE public.pasajeros_id_seq OWNED BY public.pasajeros.id;


--
-- Name: pasajeros id; Type: DEFAULT; Schema: public; Owner: pau
--

ALTER TABLE ONLY public.pasajeros ALTER COLUMN id SET DEFAULT nextval('public.pasajeros_id_seq'::regclass);


--
-- Data for Name: pasajeros; Type: TABLE DATA; Schema: public; Owner: pau
--

COPY public.pasajeros (id, nombre, apellidos, pasaporte, numero_vuelo, origen, destino, fecha_vuelo, asiento, maletas_facturadas) FROM stdin;
1       Alen    cortes  54037625E       fh402   cancun  sevilla 2026-05-29      12B     1
3       pau     cortes  7658394F        DE34    BARCELONA       TARAGONA        2026-05-28      23       1
4       marcos  perez   32423424        2424234234      2342342 23423   2026-05-29      23b     1
5       paco    martin  6543394B        fh340   madrid  zaragoza        2026-05-22      9b      1
6       Marcos  Perez   777777  777777  barcelona       madrid  2026-05-21      12b     0
\.


--
-- Name: pasajeros_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pau
--

SELECT pg_catalog.setval('public.pasajeros_id_seq', 6, true);


--
-- Name: pasajeros pasajeros_pasaporte_key; Type: CONSTRAINT; Schema: public; Owner: pau
--

ALTER TABLE ONLY public.pasajeros
    ADD CONSTRAINT pasajeros_pasaporte_key UNIQUE (pasaporte);


--
-- Name: pasajeros pasajeros_pkey; Type: CONSTRAINT; Schema: public; Owner: pau
--

ALTER TABLE ONLY public.pasajeros
    ADD CONSTRAINT pasajeros_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict gfdiZnYK2eWI7pgEaF7i6yQ3xYHZvG3vU0neBn3pJOIcaQbaNMhE0yxVl0d4xQX
