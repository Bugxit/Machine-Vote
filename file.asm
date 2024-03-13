global _start

section .bss
cNames resb 144
input resb 1

section .data
clearSequence db 27, "[H", 27, "[J"
bootMsg db "Entrez le nom du candidat N - "
adminMsg db "## Admin mode ##", 10, "0 - Votes à 0", 10, "1 - Afficher résultats", 10, "2 - Arreter la machine", 10, "3 - Reprendre le vote", 0x0a, "Entrez un choix:", 0x0a
showVotesMsg db "## Resultats : ##", 10
voteMsg db " - "
cVotes db 0, 0, 0, 0, 0, 0, 0, 0, 0
counter db 1, ":", 0x0a

section .text
_start:
    jmp bootMode

clear:
    mov rax, 1
    mov rdi, 1
    mov rsi, clearSequence
    mov rdx, 6
    syscall

    ret

bootMode:
    call clear

    movzx r9, byte [counter]
    add [counter], byte '0'
    cmp r9, 9
    jg adminMode

    mov rax, 1
    mov rdi, 1
    mov rsi, bootMsg
    mov rdx, 30
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, counter
    mov rdx, 3
    syscall

    sub [counter], byte '0'

    movzx r9, byte [counter]
    dec r9
    shl r9, 4

    mov rax, 0
    mov rdi, 0
    mov rsi, cNames
    add rsi, r9
    mov rdx, 17
    syscall

    inc byte [counter]
    jmp bootMode

adminMode:
    call clear

    mov rax, 1
    mov rdi, 1
    mov rsi, adminMsg
    mov rdx, 118
    syscall

    call getInput

    mov rax, [input]
    cmp rax, 48
    je resetVotes

    cmp rax, 49
    je showVotes

    cmp rax, 50
    je endVote

    cmp rax, 51
    je voteMode

    jmp adminMode

voteMode:
    call printVoteMsg

    call getInput
    jmp voteMode

printVoteMsg:
    cmp r9, 9
    jge end_func

    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    mov rsi, r9
    add rsi, 48
    syscall

    mov rsi, voteMsg
    mov rdx, 3
    syscall

    mov rsi, cNames
    mov rdx, r9
    imul rdx, 15
    movzx rsi, byte [rsi+rdx]
    mov rdx, 15

    inc r9
end_func:
    ret

resetVotes:
    jmp adminMode

showVotes:
    mov byte [counter], 1

    call clear
    mov rax, 1
    mov rdi, 1
    mov rsi, showVotesMsg
    mov rdx, 18
    syscall

    jmp showVotesLoop

showVotesLoop:
    movzx r9, byte [counter]
    cmp r9, 9
    jg _sys_exit

    add [counter], byte '0'
    mov rax, 1
    mov rdi, 1
    mov rsi, counter
    mov rdx, 3
    syscall

    sub [counter], byte '0'

    mov rax, 1
    mov rdi, 1

    inc byte [counter]
    jmp showVotesLoop

endVote:
    jmp _sys_exit

getInput:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 1
    syscall

    ret
_sys_exit:
    mov rax, 60
    xor rdi, rdi
    syscall
