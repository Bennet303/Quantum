namespace ExploringInterference {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    
    @EntryPoint()
    operation TestInterference3(): Unit {
        use q = Qubit();
        Y(q);
        H(q);
        DumpMachine();
        Reset(q);
    }

    operation TestInterference2(): Unit {
        use q = Qubit();
        X(q);
        H(q);
        DumpMachine();
        Reset(q);
    }

    operation TestInterference1() : Result {
        use q = Qubit();
        Message(" ");
        Message("At the beginning the qubit is in the state |0>.");
        DumpMachine();
        
        H(q);
        Message(" ");
        Message("After applying H the qubit is in the uniform superposition.");
        DumpMachine();

        H(q);
        Message(" ");
        Message("If we apply H again, interference gives back the state to |0>.");
        DumpMachine();

        Message(" ");
        Message("If we measure we will alway receive Zero.");
        return MResetZ(q);
    }
}
