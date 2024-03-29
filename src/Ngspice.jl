module Ngspice

greet() = print("Hello World!")

const libngspice = "libngspice"
struct ngcomplex_t
    cx_real::Cdouble
    cx_imag::Cdouble
end
struct vector_info
    v_name::Ptr{Cchar}
    v_type::Cint
    v_flags::Cshort
    v_realdata::Ptr{Cdouble}
    v_compdata::Ptr{ngcomplex_t}
    v_length::Cint
end
function printstr(toprt,prtint,voidpoint)
    @debug unsafe_string(toprt)
    #println(unsafe_string(toprt)[8:end])
    return Cint(0)
end
printstr_c=Base.@cfunction(printstr,Cint,(Ptr{Cchar},Cint,Ptr{Cvoid}))

function contexit(i1,b1,b2,i2,voidpoint)
    println("crash")
    return Cint(i1)
end
contexit_c=Base.@cfunction(contexit,Cint,(Cint,Cchar,Cchar,Cint,Ptr{Cvoid}))

function ngSpice_Init()
    @ccall libngspice.ngSpice_Init(printstr_c::Ptr{Cvoid},
                                C_NULL::Ptr{Nothing},
                                contexit_c::Ptr{Cvoid},
                                C_NULL::Ptr{Nothing},
                                C_NULL::Ptr{Nothing},
                                C_NULL::Ptr{Nothing},
                                C_NULL::Ptr{Nothing})::Cint
end
function ngSpice_Command(command::String)
    return @ccall libngspice.ngSpice_Command(string(command)::Cstring)::Cint
end
function run_sim(lines,resultnames)
    ngSpice_Init()
    for element in lines
        ngSpice_Command(string("circbyline ",element))
    end
    ngSpice_Command("run")
    ngSpice_Command("print all")
    results=Dict()
    for resultname in resultnames
        vector_info_pointer=@ccall libngspice.ngGet_Vec_Info(resultname::Cstring)::Ptr{vector_info}
        data=zeros(unsafe_load(vector_info_pointer).v_length)
        for j=1:length(data)
            data[j]=unsafe_load(unsafe_load(vector_info_pointer).v_realdata,j)
        end
        results[resultname]=data
    end
    return results
end
end # module Ngspice
