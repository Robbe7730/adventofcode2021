#!/bin/sh

input="`head -n 1`"

# Skip 1 line
head -n 1 > /dev/null

declare -A board

row=0
while IFS= read -r line; do
    for (( col=0; col<${#line}; col++ )); do
        board[0,$row,$col]="${line:$col:1}"
    done
    row=$((row+1))
done

# for ((j=0;j<100;j++)) do
#     for ((i=0;i<100;i++)) do
#         echo -n "${board[0,$i,$j]}"
#     done
#     echo
# done

function getBit {
    if [[ $1 -lt $boardMin ]] || [[ $2 -lt $boardMin ]] || [[ $1 -ge $boardMax ]] || [[ $2 -ge $boardMax ]]; then
        return $sides
    fi
    c="${board[$3,$1,$2]}"
    if [ "$c" == "#" ]; then
        return 1
    else
        return 0
    fi
}

boardMin=0
boardMax=100
sides=0

for ((iteration=0;iteration<50;iteration++)) do
    echo Iteration $((iteration+1))
    for ((row=$((boardMin-1));row<$((boardMax+1));row++)) do
        for ((col=$((boardMin-1));col<$((boardMax+1));col++)) do
            index=0

            getBit $((row-1)) $((col-1)) $iteration
            index=$((256 * $?))

            getBit $((row-1)) $((col  )) $iteration
            index=$((index + (128 * $?)))

            getBit $((row-1)) $((col+1)) $iteration
            index=$((index + (64 * $?)))
            
            getBit $((row  )) $((col-1)) $iteration
            index=$((index + (32 * $?)))
            
            getBit $((row  )) $((col  )) $iteration
            index=$((index + (16 * $?)))
            
            getBit $((row  )) $((col+1)) $iteration
            index=$((index + (8 * $?)))
            
            getBit $((row+1)) $((col-1)) $iteration
            index=$((index + (4 * $?)))
            
            getBit $((row+1)) $((col  )) $iteration
            index=$((index + (2 * $?)))
            
            getBit $((row+1)) $((col+1)) $iteration
            index=$((index + $?))

            board[$((iteration+1)),$row,$col]="${input:$index:1}"
        done
    done
    boardMin=$((boardMin-1))
    boardMax=$((boardMax+1))
    sides=$((1-sides))
done

ret=0
for ((row=boardMin;row<boardMax;row++)) do
    for ((col=boardMin;col<boardMax;col++)) do
        char="${board[50,$row,$col]}"
        if [ "$char" == "#" ]; then
            ret=$((ret+1))
        fi
    done
done
echo $ret
