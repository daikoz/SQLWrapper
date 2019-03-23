# SQLWrapper
A high performance SQL Wrapper and syntax checking supporting MySQL, MariaDB... SQLWrapper generate call code from SQL file and check SQL syntax before compile task. The call automatically created and check syntax identify database changes.

SQL Wrapper is not a ORM: it generate code form SQL request. It have better performance than linq or EntityFramework and there are not SQL limitation.

SQL Wrapper get database structure to check SQL syntax and generate a XML with all returned columns of SQL request. From this XML, you can apply our XLST (or the XLST provided) to generate the code.

Thus, SQL Wrapper can generate SQL call code from any language like C#, Java, Python, Javascript, VB .NET, ADO .NET ...

# SQLWrapper Extention
The SQLWrapper extantion is a pugin to add to our projet csproj. The SQL file is automatically generate.

# Architecture

1. Read database structure
  
  SQL Wrapper ----> read database ----> extract database structure (table, columns, ...)

2. Extract SQL result from SQL file

  SQL File +  DB Structure  ----> SQLWrapper ----> XML File

3. Generate our code 

  XSLT (default or provide one) ----> SQL Wrapper ----> C# code wrapper
  
  
# Configuration

if no configuration not found in root of csproj, one is created:

```json
[
  {
    "RelativePath": [ "" ],
    "FilePattern": "*.sql",
    "Namespace": "Daikoz",
    "ConnectionStrings": [
      "server=mysqlserver;user id=user1;password=pwd;database=DB1;",
      "server=mysqlserver;user id=user2;password=pwd;database=DB2;"
    ]
  }
]
```

* *RelativePath*: array of string - relative path where found SQL file
* *FilePattern*: string - sql file
* *Namespace*: string - namespace of generated class
* *ConnectionString*: array of string - list of connection string 

