---
page_type: sample
languages:
- qsharp
products:
- qdk
description: "This sample uses the `Microsoft.Quantum.AutoSubstitution` NuGet package to provide alternative operations based on the simulator that is used."
---

# Using the AutoSubstitution rewrite step

The `Microsoft.Quantum.AutoSubstitution` NuGet package offers an attribute `@SubstitutableOnTarget` that lets you replace one operation with another when using a particular simulator. For instance, decorating the operation `Op` with `@SubstitutableOnTarget("AltOp", "Sim")` lets the compiler perform a rewrite step that can link an operation `Op` to a set of pairs of an alternative operations `AltOp` and a simulator `Sim`, such that `AltOp` is executed as a replacement for `Op` when being invoked in `Sim`.

[This auto substitution blog
post](https://devblogs.microsoft.com/qsharp/the-autosubstitution-rewrite-step/)
in the [Q# blog](https://devblogs.microsoft.com/qsharp/) describes this sample
in more detail.

## Running the program

First, run

```shell
dotnet run
```

and you should see `Quantum version` as output, but when running

```shell
dotnet run -- -s ToffoliSimulator
```

the program prints `Classical version` instead, since the alternative operation
is executed.

## Manifest

- [AutoSubstitution.qs](./AutoSubstitution.qs): The main Q# example code implementing quantum operations for this sample.
- [AutoSubstitution.csproj](./AutoSubstitution.csproj): Main Q# project for the sample.
