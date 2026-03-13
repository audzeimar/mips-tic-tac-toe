.data
welcome:            .asciiz "\nWitaj w grze Kó?ko i krzy?yk"
choose_symbol:      .asciiz "\nWybierz swoj znak (O/X): "
err_symbol:         .asciiz "Blad: wpisz tylko 'O' lub 'X'.\n"
text_choose_rounds: .asciiz "\nIle rund (1-5)? "
err_rounds:         .asciiz "Blad: wpisz liczbe od 1 do 5.\n"
prompt_move:        .asciiz "Twoj ruch (1-9): "
err_move:           .asciiz "Blad: niepoprawny ruch lub pole zajete.\n"
round_result:       .asciiz "Wynik rundy: "
human_win:          .asciiz "Wygral gracz.\n"
computer_win:       .asciiz "Wygral komputer.\n"
draw:               .asciiz "Remis.\n"
final_result:       .asciiz "\nPodsumowanie:\n"
total_wins:         .asciiz "Gracz wygral: "
total_losses:       .asciiz "Komputer wygral: "
total_draws:        .asciiz "Remisy: "
newline:            .asciiz "\n"
sep:                .asciiz " | "
hr:                 .asciiz "-----------\n"
play_again_prompt:  .asciiz "\nCzy chcesz zagrac ponownie? (T/N): "

# --- Zmienne gry ---
board:      .space 9
wins:       .word 0
losses:     .word 0
draws:      .word 0

.text
.globl main

main:
    # Powitanie
    li $v0, 4
    la $a0, welcome
    syscall

choose_symbol_loop:
    # Zapytanie o symbol gracza
    li $v0, 4
    la $a0, choose_symbol
    syscall

    # Odczyt znaku gracza
    li $v0, 12
    syscall
    move $s5, $v0	# $s5 = symbol gracza
    li $t1, 'X'
    li $t2, 'O'
    li $t3, 'x'
    li $t4, 'o'

    beq $s5, $t1, player_X	# Je?li 'X', gracz = X
    beq $s5, $t3, player_X	# Je?li 'x', gracz = X
    beq $s5, $t2, player_O	# Je?li 'O', gracz = O
    beq $s5, $t4, player_O	# Je?li 'o', gracz = O

    # W przeciwnym razie b??d i powtórzenie
    li $v0, 4
    la $a0, err_symbol
    syscall
    j choose_symbol_loop

player_X:
    li $s6, 'O'
    j choose_rounds

player_O:
    li $s6, 'X'

choose_rounds:
    # Zapytanie o liczb? rund
    li $v0, 4
    la $a0, text_choose_rounds
    syscall

    li $v0, 5
    syscall
    move $s0, $v0	# $s0 = liczba rund
    blt $s0, 1, choose_rounds
    bgt $s0, 5, choose_rounds

    li $s1, 0		# Licznik rozegranych rund

next_round:
    beq $s1, $s0, summary	# Koniec wszystkich rund

    # Wyczy?? plansz?
    la $t0, board
    li $t1, 0
clear_loop:
    sb $zero, 0($t0)
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    li $t2, 9
    blt $t1, $t2, clear_loop

    jal print_board	# Wy?wietl pust? plansz?

    li $s2, 0	 # Licznik wykonanych ruchów

play_round:
    li $t7, 9
    beq $s2, $t7, draw_result	# Je?li 9 ruchów -> remis

player_move:
    li $v0, 4
    la $a0, prompt_move
    syscall

    li $v0, 5
    syscall
    move $t3, $v0
    blt $t3, 1, invalid_move
    bgt $t3, 9, invalid_move

    addi $t3, $t3, -1
    la $t4, board
    add $t4, $t4, $t3
    lb $t5, 0($t4)
    bnez $t5, invalid_move	# Pole zaj?te

    sb $s5, 0($t4)	# Zapisz ruch gracza
    jal print_board
    addiu $s2, $s2, 1

    jal check_win	# Sprawd? zwyci?stwo
    beq $v0, 1, player_wins

computer_move:
    li $t3, 0	# Szukamy pustego pola od pocz?tku planszy
find_empty:
    la $t4, board
    add $t4, $t4, $t3
    lb $t5, 0($t4)
    beqz $t5, found	# Szukaj pustego pola
    addiu $t3, $t3, 1
    blt $t3, 9, find_empty
    j draw_result

found:	
    sb $s6, 0($t4)	# Komputer robi ruch
    jal print_board
    addiu $s2, $s2, 1

    jal check_win	# Sprawd? czy komputer wygra?
    beq $v0, 1, computer_wins

    j play_round

invalid_move:
    li $v0, 4
    la $a0, err_move	# Komunikat o b??dnym ruchu
    syscall
    j player_move	# Powrót do wprowadzenia ruchu

player_wins:
    # Gracz wygra?: wypisz wynik rundy, zwi?ksz licznik zwyci?stw
    li $v0, 4
    la $a0, round_result
    syscall
    la $a0, human_win
    syscall
    lw $t0, wins
    addiu $t0, $t0, 1
    sw $t0, wins
    addiu $s1, $s1, 1	# Zwi?ksz licznik rozegranych rund
    j next_round

computer_wins:
    # Komputer wygra?: wypisz wynik rundy, zwi?ksz licznik pora?ek
    li $v0, 4
    la $a0, round_result
    syscall
    la $a0, computer_win
    syscall
    lw $t0, losses
    addiu $t0, $t0, 1
    sw $t0, losses
    addiu $s1, $s1, 1
    j next_round

draw_result:
    # Remis: wypisz wynik rundy, zwi?ksz licznik remisów
    li $v0, 4
    la $a0, round_result
    syscall
    la $a0, draw
    syscall
    lw $t0, draws
    addiu $t0, $t0, 1
    sw $t0, draws
    addiu $s1, $s1, 1
    j next_round

summary:
    # Podsumowanie gry po wszystkich rundach
    li $v0, 4
    la $a0, final_result
    syscall

    # Wypisz liczb? zwyci?stw gracza
    li $v0, 4
    la $a0, total_wins
    syscall
    lw $a0, wins
    li $v0, 1
    syscall

    # Wypisz liczb? pora?ek
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, total_losses
    syscall
    lw $a0, losses
    li $v0, 1
    syscall

    # Wypisz liczb? remisów
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, total_draws
    syscall
    lw $a0, draws
    li $v0, 1
    syscall

    # Pytanie o kontynuacj?
    li $v0, 4
    la $a0, play_again_prompt
    syscall
    li $v0, 12
    syscall
    li $t0, 'T'
    li $t1, 't'
    beq $v0, $t0, main
    beq $v0, $t1, main
    
    li $v0, 10	# Zako?cz program
    syscall

# === Funkcja sprawdzaj?ca wygran? ===
check_win:
    la $t0, board
    # Sprawd? ka?dy z 3 wierszy
    lb $t1, 0($t0)  
    lb $t2, 1($t0)    
    lb $t3, 2($t0)
    beqz $t1, chk_row2    
    beq $t1, $t2, r1    
    j chk_row2
r1: beq $t1, $t3, win
chk_row2:
    lb $t1, 3($t0)    
    lb $t2, 4($t0)    
    lb $t3, 5($t0)
    beqz $t1, chk_row3    
    beq $t1, $t2, r2    
    j chk_row3
r2: beq $t1, $t3, win
chk_row3:
    lb $t1, 6($t0)    
    lb $t2, 7($t0)    
    lb $t3, 8($t0)
    beqz $t1, chk_col1    
    beq $t1, $t2, r3    
    j chk_col1
r3: beq $t1, $t3, win

# Sprawd? kolumny
chk_col1:
    lb $t1, 0($t0)    
    lb $t2, 3($t0)    
    lb $t3, 6($t0)
    beqz $t1, chk_col2    
    beq $t1, $t2, c1    
    j chk_col2
c1: beq $t1, $t3, win
chk_col2:
    lb $t1, 1($t0)    
    lb $t2, 4($t0)    
    lb $t3, 7($t0)
    beqz $t1, chk_col3    
    beq $t1, $t2, c2    
    j chk_col3
c2: beq $t1, $t3, win
chk_col3:
    lb $t1, 2($t0)    
    lb $t2, 5($t0)    
    lb $t3, 8($t0)
    beqz $t1, chk_diag1    
    beq $t1, $t2, c3    
    j chk_diag1
c3: beq $t1, $t3, win

# Sprawd? przek?tne
chk_diag1:
    lb $t1, 0($t0)    
    lb $t2, 4($t0)    
    lb $t3, 8($t0)
    beqz $t1, chk_diag2    
    beq $t1, $t2, d1    
    j chk_diag2
d1: beq $t1, $t3, win
chk_diag2:
    lb $t1, 2($t0)    
    lb $t2, 4($t0)    
    lb $t3, 6($t0)
    beqz $t1, no_win    
    beq $t1, $t2, d2    
    j no_win
d2: beq $t1, $t3, win

no_win:
    li $v0, 0	# Brak zwyci?zcy
    jr $ra
win:
    li $v0, 1 # Jest zwyci?zca
    jr $ra

# === Funkcja wypisuj?ca plansz? ===
print_board:
    li $t9, 0	# Indeks pozycji w planszy
    li $t8, 1	# Numer pola do wy?wietlenia, je?li puste
print_row:
    li $t7, 3	# Licznik komórek w rz?dzie
print_cell:
    la $a0, board
    add $a0, $a0, $t9
    lb $t0, 0($a0)	# Wczytaj warto?? pola
    beqz $t0, print_number	# Je?li puste, poka? numer pola
    li $v0, 11	# Inaczej wypisz znak (X lub O)
    move $a0, $t0
    syscall
    j print_separator
print_number:
    li $v0, 1	# Wypisz numer pola
    move $a0, $t8
    syscall
print_separator:
    addiu $t9, $t9, 1	# Przejd? do nast?pnej komórki
    addiu $t8, $t8, 1	# Zwi?ksz numer pola
    addiu $t7, $t7, -1	# Zmniejsz licznik kolumn w rz?dzie
    beqz $t7, end_row	# Je?li koniec rz?du, przejd? dalej
    li $v0, 4
    la $a0, sep	# Wypisz separator
    syscall
    j print_cell
end_row:
    li $v0, 4
    la $a0, newline	# Nowa linia po rz?dzie
    syscall
    beq $t9, 9, print_board_end	# Je?li wszystkie komórki wypisane
    li $v0, 4
    la $a0, hr	# Wypisz lini? oddzielaj?c? rz?dy
    syscall
    j print_row
print_board_end:
    jr $ra	 # Powrót z funkcji

Add Tic-Tac-Toe implementation in MIPS Assembly
