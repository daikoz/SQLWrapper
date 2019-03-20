# SQLWrapper
A high performance SQL Wrapper and syntax checking supporting MySQL, MariaDB... SQLWrapper generate call code from SQL file and check SQL syntax before compile task. The call automatically created and check syntax identify database changes.

SQL Wrapper is not a ORM: it generate code form SQL request. It have better performance than linq or EntityFramework and there are not SQL limitation.

SQL Wrapper get database structure to check SQL syntax and generate a XML with all returned columns of SQL request. From this XML, you can apply our XLST (or the XLST provided) to generate the code.

Thus, SQL Wrapper can generate SQL call code from any language like C#, Java, Python, Javascript, VB .NET, ADO .NET ...
