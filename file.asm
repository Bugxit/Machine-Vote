global _start

section .bss
cNames resb 144
fd resq 1
input resb 1
temp resq 1


section .data
oFile db 'resultats.txt', 0
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

    cmp [input], byte 13
    je voteMode

    mov r9, [input]
    sub r9, 49
    mov rax, cVotes
    add rax, r9
    add byte [rax], 1

    call writeOFile

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
    mov r9, 0
    mov rsi, cVotes
    jmp adminMode

resetVotesLoop:
    cmp r9, 9
    jge adminMode

    mov byte [rsi], 0

    inc rsi
    inc r9
    jmp resetVotesLoop

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

    movzx r9, byte [counter]
    mov rdi, cVotes
    lea rax, [rdi+r9-1]
    movzx rbx, byte [rax]
    push rbx
    call writeNumber
    pop rax

    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    inc byte [counter]
    jmp showVotesLoop

endVote:
    jmp _sys_exit

writeNumber:
    mov r9, 0
    mov rax, [rsp+8]
    jmp writeNumberLoop

writeNumberLoop:
    cmp r9, 3
    jge end_func

    xor rdx, rdx
    mov rdi, 10
    div rdi
    mov r8, rax
    add rdx, 48
    mov rax, 1
    mov rdi, 1
    mov [temp], rdx
    mov rsi, temp
    mov rdx, 1
    syscall

    mov rax, r8
    inc r9
    jmp writeNumberLoop

writeOFile:
    mov rax, 2
    mov rdi, oFile
    mov rsi, 0
    mov rdx, 0644
    syscall
    mov qword [fd], rax

    cmp rax, 0
    jl error_exit

    mov rax, 1
    mov rdi, qword [fd]
    mov rsi, voteMsg
    mov rdx, 3
    syscall

    cmp rax, 0
    jl error_exit

    mov rax, 3
    mov rdi, qword [fd]
    syscall

    ret

error_exit:
    mov rax, 60
    mov rdi, 1
    syscall

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
