#macro push_back( array, value )
    Redim Preserve array(LBOUND(array) To UBOUND(array)+1)
    array(UBOUND(array)) = value
#endmacro

#define LENGTH 12

Dim oxygen_options() As Integer
Dim co2_options() As Integer
Dim new_oxygen_options() As Integer
Dim new_co2_options() As Integer
Dim read_index As Integer
Dim inputvalue As Integer
Dim oxygen_one_count As Integer
Dim co2_one_count As Integer
Dim digit As Integer

Do
    Input "", inputvalue
    if inputvalue = 0 Then Exit Do

    push_back( oxygen_options, inputvalue)
    push_back( co2_options, inputvalue)

    read_index += 1
Loop

For bit_index as Single = 0 To LENGTH-1 Step 1
    oxygen_one_count = 0
    For input_index as Single = LBOUND(oxygen_options) To UBOUND(oxygen_options)
        digit = (oxygen_options(input_index) / (10 ^ (LENGTH-1-bit_index))) Mod 10
        If digit = 1 Then
            oxygen_one_count += 1
        Else
            oxygen_one_count -= 1
        End If
    Next input_index

    Erase new_oxygen_options
    For input_index as Single = LBOUND(oxygen_options) To UBOUND(oxygen_options)
        If oxygen_one_count >= 0 And (oxygen_options(input_index) Mod (10^(LENGTH-bit_index))) >= (10 ^ (LENGTH-1-bit_index)) Then
            push_back(new_oxygen_options, oxygen_options(input_index))
        Elseif oxygen_one_count < 0 And (oxygen_options(input_index) Mod (10^(LENGTH-bit_index))) <= (10 ^ (LENGTH-1-bit_index)) Then
            push_back(new_oxygen_options, oxygen_options(input_index))
        End If
    Next input_index
    
    Erase oxygen_options
    For i as Single = LBOUND(new_oxygen_options) To UBOUND(new_oxygen_options)
        push_back( oxygen_options, new_oxygen_options(i))
    Next i
Next bit_index

Print "Oxigen: ";
For i as Single = LBOUND(new_oxygen_options) To UBOUND(new_oxygen_options)
    Print new_oxygen_options(i) & ", ";
Next i
Print

For bit_index as Single = 0 To LENGTH-1 Step 1
    co2_one_count = 0
    For input_index as Single = LBOUND(co2_options) To UBOUND(co2_options)
        digit = (co2_options(input_index) / (10 ^ (LENGTH-1-bit_index))) Mod 10
        If digit = 1 Then
            co2_one_count += 1
        Else
            co2_one_count -= 1
        End If
    Next input_index

    Erase new_co2_options
    For input_index as Single = LBOUND(co2_options) To UBOUND(co2_options)
        If co2_one_count < 0 And (co2_options(input_index) Mod (10^(LENGTH-bit_index))) >= (10 ^ (LENGTH-1-bit_index)) Then
            push_back(new_co2_options, co2_options(input_index))
        Elseif co2_one_count >= 0 And (co2_options(input_index) Mod (10^(LENGTH-bit_index))) <= (10 ^ (LENGTH-1-bit_index)) Then
            push_back(new_co2_options, co2_options(input_index))
        End If
    Next input_index
    
    Erase co2_options
    For i as Single = LBOUND(new_co2_options) To UBOUND(new_co2_options)
        push_back( co2_options, new_co2_options(i))
    Next i

    If LBOUND(co2_options) = UBOUND(co2_options) Then
        Exit For
    End If
Next bit_index

Print "CO2: ";
For i as Single = LBOUND(new_co2_options) To UBOUND(new_co2_options)
    Print new_co2_options(i) & ", ";
Next i
Print
