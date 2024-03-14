global _start

section .bss
cNames resb 144
input resb 1


section .data
sFile db 'candidats.txt', 0
clearSequence db 27, "[H", 27, "[J"
adminMsg db "## Admin mode ##", 10, "0 - Votes à 0", 10, "1 - Afficher résultats", 10, "2 - Arreter la machine", 10, "3 - Reprendre le vote", 0x0a, "Entrez un choix:", 0x0a
showVotesMsg db "## Resultats : ##", 10
waitShowVotesMsg db "Entrez une touche :"
showVotesMsg2 db ' : '
voteMsg db " - "
voteMsg2 db "Entrez un choix :", 0x0a
cVotes db 0, 0, 0, 0, 0, 0, 0, 0, 0
counter db 1

nl db 0x0a

section .text
_start:
    jmp bootMode

bootMode:
    jmp getCandidates

getCandidates:
    mov rax, 2
    mov rdi, sFile
    mov rsi, 0
    syscall
    mov rbp, rax

    mov rax, 0
    mov rdi, rbp
    mov rsi, cNames
    mov rdx, 144
    syscall

    mov rax, 3
    mov rdi, rbp
    syscall

    jmp adminMode

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
    call clear
    mov byte [counter], 1
    call printVoteMsg
    mov byte [counter], 1

    mov rax, 1
    mov rdi, 1
    mov rsi, voteMsg2
    mov rdx, 18
    syscall

    call getInput
    cmp [input], byte 109
    je adminMode

    cmp [input], byte 48
    je voteMode

    mov r9, [input]
    sub r9, 49
    shl r9, 4
    mov rax, cVotes
    add rax, r9
    mov byte [rax], 1

    jmp voteMode    

printVoteMsg:
    movzx r9, byte [counter]
    cmp r9, 9
    jg end_func

    add byte [counter], '0'
    mov rsi, counter
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    syscall
    sub byte [counter], '0'
    
    mov rax, 1
    mov rdi, 1
    mov rsi, voteMsg
    mov rdx, 3
    syscall

    mov rsi, cNames
    shl r9, 4
    add rsi, r9
    sub rsi, 16
    mov rax, 1
    mov rdi, 1
    mov rdx, 16
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    inc byte [counter]
    jmp printVoteMsg

end_func:
    ret

resetVotes:
    shl byte [cVotes+9], 9
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
    jg waitShowVotes

    mov rsi, cNames
    shl r9, 4
    add rsi, r9
    sub rsi, 16
    mov rax, 1
    mov rdi, 1
    mov rdx, 16
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, showVotesMsg2
    mov rdx, 3
    syscall 

    ;ICI AFFICHER VOTE POUR LES CANDIDATS

    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    inc byte [counter]
    jmp showVotesLoop

waitShowVotes:
    mov rax, 1
    mov rdi, 1
    mov rsi, waitShowVotesMsg
    mov rdx, 19
    syscall

    call getInput

    jmp _sys_exit
endVote:
    jmp _sys_exit

getInput:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 1
    syscall

    ret
clear:
    mov rax, 1
    mov rdi, 1
    mov rsi, clearSequence
    mov rdx, 6
    syscall

    ret

_sys_exit:
    mov rax, 60
    xor rdi, rdi
    syscall
