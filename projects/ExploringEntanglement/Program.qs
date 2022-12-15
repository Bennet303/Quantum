namespace ExploringEntanglement {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    
    @EntryPoint()
    operation MultiQubitGate(count: Int, initial: Result): (Int, Int, Int, Int) {
        mutable numOnesQ1 = 0;
        mutable numOnesQ2 = 0;

        // allocate the qubits
        use (q1, q2) = (Qubit(), Qubit());

        for test in 1..count {
            setQubitState(initial, q1);
            setQubitState(Zero, q2);

            H(q1);
            // CNOT(q1, q2);
            Controlled X([q1], q2);

            // measure each qubit
            let resultQ1 = M(q1);
            let resultQ2 = M(q2);

            // Count the number of 'Ones'
            if resultQ1 == One {
                set numOnesQ1 += 1;
            }
            if resultQ2 == One {
                set numOnesQ2 += 1;
            }
        }

        // reset the qubits
        setQubitState(Zero, q1);
        setQubitState(Zero, q2);

        // Return number of |0> states, number of |1> states
        Message("q1:Zero, One  q2:Zero, One");
        return (count - numOnesQ1, numOnesQ1, count - numOnesQ2, numOnesQ2 );
    }

    
    operation TestBellState(count: Int, initial: Result): (Int, Int, Int, Int) {
        mutable numOnesQ1 = 0;
        mutable numOnesQ2 = 0;

        // allocate the qubits
        use (q1, q2) = (Qubit(), Qubit());

        for test in 1..count {
            setQubitState(initial, q1);
            setQubitState(Zero, q2);

            H(q1);

            // measure each qubit
            let resultQ1 = M(q1);
            let resultQ2 = M(q2);

            // Count the number of 'Ones'
            if resultQ1 == One {
                set numOnesQ1 += 1;
            }
            if resultQ2 == One {
                set numOnesQ2 += 1;
            }
        }

        // reset the qubits
        setQubitState(Zero, q1);
        setQubitState(Zero, q2);

        // Return number of |0> states, number of |1> states
        Message("q1:Zero, One  q2:Zero, One");
        return (count - numOnesQ1, numOnesQ1, count - numOnesQ2, numOnesQ2 );
    }

    operation setQubitState(desired: Result, target: Qubit): Unit {
        if desired != M(target) {
            X(target); // Inverts the amplitudes for Zero and One
        }
    }
}
