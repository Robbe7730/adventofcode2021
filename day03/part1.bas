Dim inputvalue As Integer
Dim digit As Integer
Dim counts(0 To 11) As Integer
Dim gamma_rate As Integer
Dim epsilon_rate As Integer

Do
    Input "", inputvalue
    if inputvalue = 0 Then Exit Do

    For i As Single = 0 To 11 Step 1
        digit = (inputvalue / (10 ^ (11-i))) Mod 10
        If digit = 0 Then
            counts(i) = counts(i) - 1
        Else
            counts(i) = counts(i) + 1
        End If
    Next i

Loop

For i As Single = 0 To 11 Step 1
    gamma_rate = gamma_rate * 2
    epsilon_rate = epsilon_rate * 2
    If counts(i) > 0 Then 
        gamma_rate += 1
    Else
        epsilon_rate += 1
    End If
Next i

Print gamma_rate * epsilon_rate
