# Changelog

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
