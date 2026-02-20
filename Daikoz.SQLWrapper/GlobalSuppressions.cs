// This file is used by Code Analysis to maintain SuppressMessage
// attributes that are applied to this project.
// Project-level suppressions either have no target or are given
// a specific target and scoped to a namespace, type, member, etc.

using System.Diagnostics.CodeAnalysis;

[assembly: SuppressMessage("Performance", "CA1812:Avoid uninstantiated internal classes", Justification = "Use for XML serialisation", Scope = "type", Target = "~T:Daikoz.SQLWrapper.Schema")]
[assembly: SuppressMessage("Performance", "CA1812:Avoid uninstantiated internal classes", Justification = "Use for XML serialisation", Scope = "type", Target = "~T:Daikoz.SQLWrapper.Database")]
[assembly: SuppressMessage("Performance", "CA1812:Avoid uninstantiated internal classes", Justification = "Use for XML serialisation", Scope = "type", Target = "~T:Daikoz.SQLWrapper.SQL")]
[assembly: SuppressMessage("Performance", "CA1812:Avoid uninstantiated internal classes", Justification = "Use for XML serialisation", Scope = "type", Target = "~T:Daikoz.SQLWrapper.Wrapper")]
[assembly: SuppressMessage("Performance", "CA1812:Avoid uninstantiated internal classes", Justification = "Use for XML serialisation", Scope = "type", Target = "~T:Daikoz.SQLWrapper.SQLWrapperConfig")]

[assembly: SuppressMessage("Usage", "CA2227:Collection properties should be read only", Justification = "Use by target", Scope = "member", Target = "~P:Daikoz.SQLWrapper.SQLWrapperTask.GeneratedSources")]
