// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Extensions.Logging;
using Microsoft.Quantum.Chemistry;
using System.Linq;
using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using McMaster.Extensions.CommandLineUtils;
using Microsoft.Quantum.Chemistry.Broombridge;
using System.IO;
using System;

// This loads a Hamiltonian from file and computes some of its features
// - L1-Norm of terms

namespace Microsoft.Quantum.Chemistry.Sample
{

    class Program
    {
        public static int Main(string[] args) =>
            CommandLineApplication.Execute<Program>(args);

        public enum DataFormat
        {
            LiQuiD, Broombridge
        }

        [Option(Description = "Format to use when loading data.")]
        public DataFormat Format { get; } = DataFormat.Broombridge;

        [Option(Description = "Path to data to be loaded.")]
        public string Path { get; } = System.IO.Path.Combine(
            "..", "IntegralData", "YAML", "lih_sto-3g_0.800_int.yaml"
        );

        void OnExecute()
        {
            var logger = new LoggerFactory().CreateLogger<Program>();

            // Directory containing integral data generated by Microsoft.
            //Example Liquid data format files
            /*
            "h2_sto3g_4.dat" // 4 SO
            "B_sto6g.dat" // 10 SO
            "Be_sto6g_10.dat" // 10 SO
            "h2o_sto6g_14.dat" // 14 SO
            "h2s_sto6g_22.dat" // 22 SO
            "co2_sto3g_30.dat" // 30 SO
            "co2_p321_54.dat" // 54 SO
            "fe2s2_sto3g.dat" // 110 SO
            "nitrogenase_tzvp_54.dat" // 108 SO
            */

            // For loading data in the format consumed by Liquid.
            logger.LogInformation($"Processing {Path}...");
            using var reader = File.OpenText(Path);
            var generalHamiltonian = (Format switch
            {
                DataFormat.Broombridge => BroombridgeSerializer
                      .Deserialize(reader),
                DataFormat.LiQuiD => LiQuiDSerializer
                      .Deserialize(reader),
                _ => throw new ArgumentException($"Invalid data format {Format}.")
            })
            .Single()
            .OrbitalIntegralHamiltonian
            .ToFermionHamiltonian(IndexConvention.UpDown);

            logger.LogInformation("End read file. Computing one-norms.");
            
            foreach (var termType in generalHamiltonian.Terms.Keys)
            {
                var line = $"One-norm for term type {termType}: {generalHamiltonian.Norm(new[] { termType }, 1.0)}";
                logger.LogInformation(line);
            }
            logger.LogInformation("Computed one-norm.");

            if (System.Diagnostics.Debugger.IsAttached)
            {
                System.Console.ReadLine();
            }
        }
    }
}
