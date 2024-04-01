SQLWrapper makes it easier to create code wrappers for SQL queries. It's a powerful tool that helps speed up development by reducing the need for manual coding. It works with databases various SQL database (MySQL, MariaDB, ...), checking the syntax and performance of SQL queries before you execute them.

It's important to note that SQLWrapper isn't like other tools that map objects to database tables (ORMs). Instead, it directly generates code from your SQL queries and database structure, which performs better than tools like LINQ, EntityFramework, dapper, ... and doesn't have the same limitations.

One feature is that it can look at your database's structure to check if your SQL queries are correct, and it can create an XML file listing all the data your queries need and return. Then, you can use XSLT templates to turn that XML into code in languages like C#, and more.

Overall, SQLWrapper is a handy tool for making SQL code easier to work with, saving time, and helping you write better code.

## Getting started with package NuGet Daikoz.SQLWrapper

The .NET package NuGet [Daikoz.SQLWrapper](https://www.nuget.org/packages/Daikoz.SQLWrapper) integrate SQLWrapper in build process of our .NET project.

1. Create your .NET project
2. Add package NuGet Daikoz.SQLWrapper.

.NET CLI:
```
dotnet add package Daikoz.SQLWrapper
```
or use [Manage NuGet Packages...] in Visual Studio

3. The first build create on your project root, the configuration file **sqlwrapper.conf**

``` json
{
    "Verbose": false,
    "Database": [
        {
            "Name": "Name of this database. Should be contain only characters: a-z A-Z 0-9 _ -",
            "ConnectionString": ".NET connection string to connect to database. If empty, use FilePath to get cached database previously generated.",
            "FilePath": "File path of cached database. If empty, store it in obj of project"
        }
    ],
    "Helper": [
        {
            "Database": "Name of database defined in Database section",
            "Namespace": "Namespace in generated source. If empty, take the default namespace of project",
            "XLST": "Provide your own XLST to generate a helper. If empty, use default XLST provided by SQLWrapper",
            "OutputFilePath": "File path of helper"
        }
    ],
    "Wrapper": [
        {
            "Database": "Name of database defined in Database section",
            "Namespace": "Namespace in generated source. If empty, take the default namespace of project",
            "XLST": "Provide your own XLST to generate the wrapper. If empty, use default XLST provided by SQLWrapper",
            "Path": "Absolute or relative path where to search sql file pattern. If empty, use path of project",
            "FilePattern": "SQL file to wrap. If empty, use \"*.sql\""
        }
    ]
}
```

To start, follow a minimal configuration file. Modify HOSTNAME, USERID, PASSWORD and DATABASENAME

``` json
{
    "Database": [
        {
            "Name": "MyDatabase",
            "ConnectionString": "server=HOSTNAME;user id=USERID;password='PASSWORD';database=DATABASENAME"
        }
    ],
    "Helper": [
        {
            "Database": "MyDatabase",
            "OutputFilePath": "MyDataseHelper.cs"
        }
    ],
    "Wrapper": [
        {
            "Database": "MyDatabase"
        }
    ]
}
```

4. Add your database query in files .sql in your project
5. Build you project
* Your database structure is cached in obj
* A database helper if generate in file MyDataseHelper.cs
* For each *.sql, a wrapper is generated

## Getting started with command line SQLWrapper

## Links
* [Official web](https://www.sqlwrapper.com)
* [Package .NET](https://www.nuget.org/packages/Daikoz.SQLWrapper/)
* [Documentation](https://github.com/daikoz/SQLWrapper/wiki)
* [Issues/Bugs](https://github.com/daikoz/SQLWrapper/issues)
* [Videos](https://www.youtube.com/@SQLWrapper)
* [Reddit](https://www.reddit.com/r/sqlwrapper/)
* [Facebook](https://www.facebook.com/sqlwrapper/)
* [Twitter](https://twitter.com/sqlwrapper)
