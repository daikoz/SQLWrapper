# Changelog

## [2.2.1] (2025-04-20)

### SQLWrapper
- Fix #8 Wrong CSharp code generate with a SELECT with no WHERE


## [2.2] (2024-08-02)

### SQLWrapper
- Replace isnull by nullable attribute for database type

### Template
- **Database VB**: add new template database-vb-ado.xslt and sql-vb-ado.xslt to generate Visual Basic .Net wrapper
- Unify isnull and nullable for database type
- **sql-csharp-ado.xslt**: Read data asyn (await reader.ReadAsync())
- **Rename template** to use this rules:
    - database or sql: use database for template to apply to all database and use sql for template to apply on SQL queries 
    - language: charp, vb, ...
    - type: ado
- **Template available**:
    - **database-csharp-ado.xslt**: generate a database helper from schema xml in C# ADO
    - **database-vb-ado.xslt**: generate a database helper from schema xml in Visual Basic ADO
    - **sql-cshapr-ado.xslt**: generate a SQL query wrapper from schema xml and SQL query in C# ADO
    - **sql-vb-ado.xslt**: generate a SQL query wrapper from schema xml and SQL query in Visual Basic ADO


## [2.1.1] (2024-07-17)

### Daikoz.SQLWrapper NuGet Package
- Fix issue: database name is not provided to XSLT.

### Template
- **Database C#**: Fix return value for function
- **Database C#**: Fix column, table and method name to follow microft recommendation to avoid message IDEXXXX
- **Database C#**: Move UpdateIfModified method in database class to avoid compilation error with several database helper


## [2.1] (2024-07-08)

### SQLWrapper
- **break changes** Modify command line name for better understanding
- Add Linux support (Debian 12)
- Generate stored procedure and function wrapper for mysql/mariadb
- Fix error with mariadb/mysql function: UNIX_TIMESTAMP
- Fix #3 error with mariadb/mysql function: SUBSTR
- Fix error with mariadb/mysql: EXISTS
- Fix line break when generate XML request

### Daikoz.SQLWrapper NuGet Package
- **break changes** Modify sqlwrapper.json configuration for better understanding
- Add Linux support (Debian 12)

### Template
- **SQL C# ADO**: Replace mysqlconnector by DbConnection to allow use this template with other database.
- **Database C#**: Generate stored procedure and function wrapper for mysql/mariadb
- **Database C#**: Replace mysqlconnector by DbConnection to allow use this template with other database.
- **Database C#**: Fix formating


## [2.0.1] (2024-04-12)

### SQLWrapper
- Order caseinsentive input SQL variables.
- Enhance display warning message
- MariaDB/MySQL: Fix UNION column checking with BOOL, INT, INTEGER type

### Daikoz.SQLWrapper NuGet Package
- Visual Studio can generate wrapper in background
- Fix compilation error after clean the project, the generated source is now added to compile process. Don't need to build again the project.
- Enhance display warning message
- Update readme.md

### Template
- **Database C#**: Use int type for length or long instead of uint to avoid int cast with index of string function.
- **Database C#**: Rename SQLWrapper::UpdateIfModified to SQLWrapperHelper::UpdateIfModified method and move it in same namespace to avoid warning this Daikoz.SQLWrapper NuGet package.
- **SQL C# ADO**: Fix tab/space mix
- **SQL C# ADO**: Fix spaces
