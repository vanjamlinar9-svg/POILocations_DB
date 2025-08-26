# POILocations_DB
This repository contains the SQL Server database model for managing Points of Interest (POI) including 
locations, categories, tags, postal codes and geometries.

Repository structure:

schema/ - schema creation scripts
tables/ - table definitions
views/ - views definition
procedures/ - stored procedures/packages
testCases/ - queries for testing
dataload.sql - initial load of data

Setup steps
To Create a new database execute following script:
    
    CREATE DATABASE POI_Locations;
    USE POI_Locations;
    GO

    CREATE SCHEMA poi;
    GO

In order to create db objects run scripts in the following order:

    schema/schema.sql
    tables/*
    views/*
    procedures/*
