000000 IDENTIFICATION DIVISION.
000100 PROGRAM-ID. PART1.
000150 ENVIRONMENT DIVISION.
000151 INPUT-OUTPUT SECTION.
000152 FILE-CONTROL.
000153     SELECT SYSIN ASSIGN TO KEYBOARD ORGANIZATION LINE SEQUENTIAL.
000200 DATA DIVISION.
000300 FILE SECTION.
000400     FD SYSIN.
000450     01 ln PIC X(20).
000480     88 EOF VALUE HIGH-VALUES.
000410 WORKING-STORAGE SECTION.
000470     01 x1 PIC 9(3).
000471     01 y1 PIC 9(3).
000472     01 x2 PIC 9(3).
000473     01 y2 PIC 9(3).
000474     01 min_x PIC 9(3).
000475     01 max_x PIC 9(3).
000476     01 min_y PIC 9(3).
000477     01 max_y PIC 9(3).
000478     01 curr_x PIC 9(3).
000479     01 curr_y PIC 9(3).
000480     01 hit-count.
000481         05 hit-count-row OCCURS 1000 TIMES.
000482             10 hit-count-col PIC 9(3) OCCURS 1000 TIMES.
000483     01 result PIC 9(6).
000600 PROCEDURE DIVISION.
000700     OPEN INPUT SYSIN
000701     READ SYSIN
000710       AT END SET EOF TO TRUE
000712     END-READ.
000720     PERFORM PROCESS_LINE UNTIL EOF.
000800     DISPLAY result.
000900     CLOSE SYSIN.
001000     STOP RUN.
010000 PROCESS_LINE.
010750     UNSTRING ln DELIMITED BY " -> " OR ","
010751       INTO x1, y1, x2, y2
010753     END-UNSTRING.
010770     ADD 1 TO x1
010771     ADD 1 TO x2
010772     ADD 1 TO y1
010773     ADD 1 TO y2
010800     MOVE FUNCTION max(x1, x2) TO max_x.
010800     MOVE FUNCTION min(x1, x2) TO min_x.
010800     MOVE FUNCTION max(y1, y2) TO max_y.
010800     MOVE FUNCTION min(y1, y2) TO min_y.
010900     IF x1 = x2 OR y1 = y2
010910       PERFORM INCREASE_COUNT THRU INCREASE_COUNT_EXIT
010911         VARYING curr_x FROM min_x BY 1 UNTIL curr_x > max_x
010912         AFTER curr_y FROM min_y BY 1 UNTIL curr_y > max_y.
011070     READ SYSIN
011071       AT END SET EOF TO TRUE
011072     END-READ.
011080     EXIT.
020000 INCREASE_COUNT.
020010     ADD 1 TO hit-count-col(curr_x, curr_y).
020030     IF hit-count-col(curr_x, curr_y) = 2
020031       ADD 1 TO result.
021000 INCREASE_COUNT_EXIT.
021010     EXIT.
