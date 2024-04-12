# Changelog

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
- **C# Helper**: Use int type for length or long instead of uint to avoid int cast with index of string function.
- **C# Helper**: Rename SQLWrapper::UpdateIfModified to SQLWrapperHelper::UpdateIfModified method and move it in same namespace to avoid warning this Daikoz.SQLWrapper NuGet package.
- **C# Helper**: Fix tab/space mix
- **C# Helper**: Fix spaces
