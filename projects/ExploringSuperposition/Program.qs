namespace ExploringSuperposition {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    
    @EntryPoint()
    operation GenerateUniformState(): Int {
        use qubits = Qubit[3];
        ApplyToEach(H, qubits);
        Message("The qubit register in a uniform superposition: ");
        DumpMachine();

        mutable results = [];
        for q in qubits {
            Message("");
            set results += [M(q)];
            DumpMachine();
        }

        Message("");
        Message("Your random number is: ");
        return ResultArrayAsInt(results);
    }


    operation GenerateRandomNumber(): Int {
        use qubits = Qubit[3];
        ApplyToEach(H, qubits);
        Message("The qubit register in a uniform superposition: ");
        DumpMachine();
        let result = ForEach(M, qubits);
        Message("Measuring the qubits collapses the superposition to a basis state.");
        DumpMachine();
        return ResultArrayAsInt(result);
    }



    operation GenerateSpecificState(alpha: Double) : Result {
        use q = Qubit();
        Ry(2.0 * ArcCos(Sqrt(alpha)), q);
        Message("The qubit is in the desired state.");
        Message("");
        DumpMachine();
        Message("");
        Message("Your skewed random bit is:");
        return M(q);
    }
}
