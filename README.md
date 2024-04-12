SQLWrapper makes it easier to create code wrappers for SQL queries. It's a powerful tool that helps speed up development by reducing the need for manual coding. It works with databases various SQL database (MySQL, MariaDB, ...), checking the syntax and performance of SQL queries before you execute them.

It's important to note that SQLWrapper isn't like other tools that map objects to database tables (ORMs). Instead, it directly generates code from your SQL queries and database structure, which performs better than tools like LINQ, EntityFramework, dapper, ... and doesn't have the same limitations.

One feature is that it can look at your database's structure to check if your SQL queries are correct, and it can create an XML file listing all the data your queries need and return. Then, you can use XSLT templates to turn that XML into code in languages like C#, and more.

Overall, SQLWrapper is a handy tool for making SQL code easier to work with, saving time, and helping you write better code.

## Links
* [Change log](https://github.com/daikoz/SQLWrapper/blob/master/CHANGELOG.md)
* [Official website](https://www.sqlwrapper.com)
* [Package .NET](https://www.nuget.org/packages/Daikoz.SQLWrapper/)
* [Documentation](https://github.com/daikoz/SQLWrapper/wiki)
* [Issues/Bugs](https://github.com/daikoz/SQLWrapper/issues)
* [Videos](https://www.youtube.com/@SQLWrapper)
* [Facebook](https://www.facebook.com/sqlwrapper/)
* [Twitter](https://twitter.com/sqlwrapper)

## Getting started with package NuGet Daikoz.SQLWrapper

**Video of demonstration:**

[![Watch the video](https://raw.githubusercontent.com/daikoz/SQLWrapper/master/img/video.jpg)](https://www.youtube.com/watch?v=xEeWnESZki0)

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

SQLWrapper can be use in console.

### Database

First, extract and cache database structure in XML File:

``` dos
>SQLWrapper help database
SQL Wrapper Generator
Copyright (C) DAIKOZ. All rights reserved.
USAGE:
Extract and cache database structure in XML file:
  SQLWrapper database --connectionstring "server=servernamedb;user id=userid;password='password';database=db1" --outputfile sqlwrapper-cachedb.xml --type mariadb --verbose

  -t, --type                Required. Type of database: mysql, mariadb.

  -c, --connectionstring    Required. List of .net database connection string (https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/connection-string-syntax).

  -o, --outputfile          Output XML file (default: stdout).

  -v, --verbose             Set output to verbose messages.

  --help                    Display this help screen.

  --version                 Display version information.
```

**Example:**

``` dos
SQLWrapper database --connectionstring "server=servernamedb;user id=userid;password='password';database=db1" --outputfile sqlwrapper-cachedb.xml --type mariadb --verbose
```

This command connect to **database** of **type** with connection information **connectionstring**. The output is written in **outputfile**.

### Wrapper

Generate the wrapper source code from SQL queries:

``` dos
>SQLWrapper help wrapper
SQL Wrapper Generator
Copyright (C) DAIKOZ. All rights reserved.
USAGE:
Generate code from sql request:
  SQLWrapper wrapper --database sqlwrapper-cachedb.xml --inputfiles request1.mysql request2.mysql --outputfile mysqlrequest.cs --params namespace=DAIKOZ classname=SQLWrapper --xslt Template\CSharp\charpADO.xslt

  -d, --database       Required. XML file of cache database structure to load. Generate it before with database command

  -i, --inputfiles     Required. SQL files. Relative or full path. wildcard * is supported for filename.

  -o, --outputfile     Output file

  -p, --params         XLST Parameters

  -t, --customtypes    Force custom type for database field (table.col=MyEmu

  -x, --xslt           XSLT file path to transform XML output.

  -v, --verbose        Set output to verbose messages.

  --help               Display this help screen.

  --version            Display version information.
```

**Example:**

``` dos
SQLWrapper wrapper --database sqlwrapper-cachedb.xml --inputfiles request1.mysql request2.mysql --outputfile mysqlrequest.cs --params namespace=DAIKOZ classname=SQLWrapper --xslt Template\CSharp\charpADO.xslt
```

This command create a **wrapper** from **database** for 2 queries defined in **inputfiles**. It use the **XSLT** file to generate the **outputfile**. **params** give parameters defined in **XLST** file (here the namespace).

### Helper

Generate a source code helper to help the access to database. For example: the length of all text columns.

``` dos
>SQLWrapper help helper
SQL Wrapper Generator
Copyright (C) DAIKOZ. All rights reserved.
USAGE:
Generate code helper to access database:
  SQLWrapper helper --database sqlwrapper-cachedb.xml --outputfile helper.cs --xslt Template\CSharp\helper.xslt

  -d, --database       Required. XML file of cache database structure to load. Generate it before with database command

  -o, --outputfile     Output file

  -p, --params         XLST Parameters

  -t, --customtypes    Force custom type for database field (table.col=MyEmu

  -x, --xslt           XSLT file path to transform XML output.

  -v, --verbose        Set output to verbose messages.

  --help               Display this help screen.

  --version            Display version information.
```

**Example:**

``` dos
SQLWrapper helper --database sqlwrapper-cachedb.xml --outputfile helper.cs --xslt Template\CSharp\helper.xslt
```

This command create a **helper** for **database**. It use **XLST** file to generate the **outputfile**.


## Template XLST

In template section, you can found several XLST files to generate wrappers and helpers in several programming language.
You can create or modify your own and use it with **--xslt** parameter.


