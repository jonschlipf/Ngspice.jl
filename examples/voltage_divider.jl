using Ngspice

lines=["voltagedivider simulation",
       "vin 1 0 1.0",
       "r1 1 2 10K",
       "r2 2 0 5K",
       ".op",
       ".end"]
resultnames=["V(1)",
             "V(2)"]
results=Ngspice.run_sim(lines,resultnames)

println("Voltage at R1:")
println(string("V_R1 = ",results["V(1)"][1]-results["V(2)"][1]," V"))
println("Voltage at R2:")
println(string("V_R2 = ",results["V(2)"][1]," V"))
