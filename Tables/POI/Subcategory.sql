CREATE TABLE poi.Subcategory (
    SubcategoryID INT IDENTITY(1,1) PRIMARY KEY,
    SubcategoryName VARCHAR(255) NOT NULL,
    CategoryID INT NOT NULL,
    CONSTRAINT UQ_Subcategory UNIQUE (SubcategoryName, CategoryID),
    FOREIGN KEY (CategoryID) REFERENCES poi.Category(CategoryID),
    CreatedOn DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CreatedBy VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
    UpdatedOn DATETIME2 NULL,
    UpdatedBy VARCHAR(100) NULL
);
