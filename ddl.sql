CREATE SCHEMA "cfr";

CREATE TABLE "cfr"."organisers" (
  "id" serial PRIMARY KEY,
  "name" varchar(255) NOT NULL,
  "description" varchar(255),
  "tax_id" varchar(30),
  "address_1" varchar(255),
  "address_2" varchar(255),
  "address_city" varchar(100),
  "address_zipcode" varchar(50),
  "address_country" varchar(2)
);

CREATE TABLE "cfr"."conferences" (
  "id" serial PRIMARY KEY,
  "name" varchar(255) NOT NULL,
  "description" varchar(2000),
  "start_time" timestamptz NOT NULL,
  "end_time" timestamptz NOT NULL,
  "country" varchar(2) NOT NULL,
  "city" varchar(100),
  "organiser_id" serial NOT NULL
);

CREATE TABLE "cfr"."offers" (
  "id" serial PRIMARY KEY,
  "name" varchar(255) NOT NULL,
  "description" varchar(2000),
  "price" decimal(19,2) NOT NULL DEFAULT 0,
  "max_slots" integer NOT NULL,
  "conference_id" integer NOT NULL
);

CREATE TABLE "cfr"."accommodation_options" (
  "id" serial PRIMARY KEY,
  "name" varchar(255) NOT NULL,
  "description" varchar(2000),
  "accommodation_type_id" integer NOT NULL,
  "surcharge" decimal(19,2) NOT NULL DEFAULT 0,
  "address_1" varchar(255),
  "address_2" varchar(255),
  "address_city" varchar(100),
  "address_zipcode" varchar(50),
  "address_country" varchar(2),
  "total_capacity" integer
);

CREATE TABLE "cfr"."accomodation_types" (
  "id" serial PRIMARY KEY,
  "type_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."room_options" (
  "id" serial PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar(2000),
  "room_type_id" integer NOT NULL,
  "surcharge" decimal(19,2) NOT NULL DEFAULT 0,
  "max_persons" smallint,
  "total_available_rooms" integer,
  "accommodation_option_id" integer NOT NULL
);

CREATE TABLE "cfr"."room_types" (
  "id" serial PRIMARY KEY,
  "type_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."activities" (
  "id" serial PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" varchar(2000),
  "start_time" timestamptz NOT NULL,
  "end_time" timestamptz,
  "surcharge" decimal(19,2) NOT NULL DEFAULT 0,
  "location_name" varchar(255),
  "address_1" varchar(255),
  "address_2" varchar(255),
  "address_city" varchar(100),
  "address_zipcode" varchar(50),
  "address_country" varchar(2)
);

CREATE TABLE "cfr"."orders" (
  "id" serial PRIMARY KEY,
  "order_status_id" integer NOT NULL,
  "total" decimal(19,2) NOT NULL,
  "client_id" integer NOT NULL
);

CREATE TABLE "cfr"."order_statuses" (
  "id" serial PRIMARY KEY,
  "status_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."payments" (
  "id" serial PRIMARY KEY,
  "status_id" integer NOT NULL,
  "payment_type_id" integer NOT NULL,
  "payment_gateway_id" integer NOT NULL,
  "external_id" varchar,
  "order_id" integer NOT NULL
);

CREATE TABLE "cfr"."payment_statuses" (
  "id" serial PRIMARY KEY,
  "status_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."payment_types" (
  "id" serial PRIMARY KEY,
  "type_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."payment_gateways" (
  "id" serial PRIMARY KEY,
  "gateway_name" varchar(50) UNIQUE NOT NULL
);

CREATE TABLE "cfr"."clients" (
  "id" serial PRIMARY KEY,
  "name" varchar(255),
  "surname" varchar(255),
  "email" varchar NOT NULL,
  "food_preferrence" varchar(255),
  "special_needs" varchar(255),
  "id_no" varchar(50),
  "phone_number" varchar(30),
  "address_1" varchar(255),
  "address_2" varchar(255),
  "address_city" varchar(100),
  "address_zipcode" varchar(50),
  "address_country" varchar(2)
);

CREATE TABLE "cfr"."offer_activities" (
  "offer_id" integer NOT NULL,
  "activity_id" integer NOT NULL,
  PRIMARY KEY ("offer_id", "activity_id")
);

CREATE TABLE "cfr"."offer_orders" (
  "offer_id" integer NOT NULL,
  "order_id" integer NOT NULL,
  PRIMARY KEY ("offer_id", "order_id")
);

CREATE TABLE "cfr"."offer_accommodation_options" (
  "offer_id" integer NOT NULL,
  "accommodation_option_id" integer NOT NULL,
  PRIMARY KEY ("offer_id", "accommodation_option_id")
);

ALTER TABLE "cfr"."accommodation_options" ADD FOREIGN KEY ("accommodation_type_id") REFERENCES "cfr"."accomodation_types" ("id");

ALTER TABLE "cfr"."room_options" ADD FOREIGN KEY ("room_type_id") REFERENCES "cfr"."room_types" ("id");

ALTER TABLE "cfr"."orders" ADD FOREIGN KEY ("order_status_id") REFERENCES "cfr"."order_statuses" ("id");

ALTER TABLE "cfr"."payments" ADD FOREIGN KEY ("status_id") REFERENCES "cfr"."payment_statuses" ("id");

ALTER TABLE "cfr"."payments" ADD FOREIGN KEY ("payment_type_id") REFERENCES "cfr"."payment_types" ("id");

ALTER TABLE "cfr"."payments" ADD FOREIGN KEY ("payment_gateway_id") REFERENCES "cfr"."payment_gateways" ("id");

ALTER TABLE "cfr"."conferences" ADD FOREIGN KEY ("organiser_id") REFERENCES "cfr"."organisers" ("id");

ALTER TABLE "cfr"."offers" ADD FOREIGN KEY ("conference_id") REFERENCES "cfr"."conferences" ("id");

ALTER TABLE "cfr"."offer_accommodation_options" ADD FOREIGN KEY ("accommodation_option_id") REFERENCES "cfr"."accommodation_options" ("id");

ALTER TABLE "cfr"."offer_accommodation_options" ADD FOREIGN KEY ("offer_id") REFERENCES "cfr"."offers" ("id");

ALTER TABLE "cfr"."room_options" ADD FOREIGN KEY ("accommodation_option_id") REFERENCES "cfr"."accommodation_options" ("id");

ALTER TABLE "cfr"."offer_activities" ADD FOREIGN KEY ("offer_id") REFERENCES "cfr"."offers" ("id");

ALTER TABLE "cfr"."offer_activities" ADD FOREIGN KEY ("activity_id") REFERENCES "cfr"."activities" ("id");

ALTER TABLE "cfr"."offer_orders" ADD FOREIGN KEY ("offer_id") REFERENCES "cfr"."offers" ("id");

ALTER TABLE "cfr"."offer_orders" ADD FOREIGN KEY ("order_id") REFERENCES "cfr"."orders" ("id");

ALTER TABLE "cfr"."payments" ADD FOREIGN KEY ("order_id") REFERENCES "cfr"."orders" ("id");

ALTER TABLE "cfr"."orders" ADD FOREIGN KEY ("client_id") REFERENCES "cfr"."clients" ("id");