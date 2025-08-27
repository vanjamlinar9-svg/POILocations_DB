# POILocations_DB
This repository contains the SQL Server database model for managing Points of Interest (POI) including 
locations, categories, tags, postal codes and geometries - within Free City Guide software.

Repository structure:

1_schema/ - schema creation scripts and erd
2_tables/ - table definitions
3_views/ - views definition
4_procedures/ - stored procedures/packages
5_dbBackup/ - database backup
testCases/ - queries for testing
dataload.sql - initial load of data from SourceData.tsv

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
Notes: 
    Database is compatible with MS SQL Server 2019- v15
