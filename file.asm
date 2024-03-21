global _start

section .bss
cNames resb 144
cVotes resb 9
input resb 1
temp resb 3

section .data
S_FILE db 'candidats.txt', 0
O_FILE db 'resultats.txt', 0
CLEAR_SEQUENCE db 27, "[H", 27, "[J"
KERNEL_CONSTANT db 0x0, 0x0, 0x3, 0x14, 0x15, __DATE__, 0x0a
adminMsg db "## Admin mode ##", 10, "0 - Votes à 0", 10, "1 - Afficher résultats", 10, "2 - Arreter la machine", 10, "3 - Reprendre le vote", 0x0a, "Entrez un choix:", 0x0a
showVotesMsg db "## Resultats : ##", 10
showVotesMsg2 db ' : '
waitShowVotesMsg db "Entrez une touche :"
voteMsg db " - "
voteMsg2 db "Entrez un choix :", 0x0a
counter db 1

nl db 0x0a

section .text
%define SYS_write 1
%define SYS_open 2

_start:
    call initiateConstant

    ;Read candidates file
    mov rax, SYS_open
    mov rdi, S_FILE
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

adminMode:    
    call clear  ;Clears the shell

    ;Writes the adminMsg to the shell
    mov rax, SYS_write
    mov rdi, 1
    mov rsi, adminMsg
    mov rdx, 118
    syscall

    call getInput

    ;Jumps to what the user asked for
    mov rax, [input]
    cmp rax, '0'
    je resetVotes

    cmp rax, '1'
    je showVotes

    cmp rax, '2'
    je _sys_exit

    cmp rax, '3'
    je voteMode

    jmp adminMode

voteMode:
    call clear  ;Clears the shell

    mov byte [counter], 1
    call printVoteMsgLoop


    ;Writes the voteMsg2 to the shell
    mov rax, SYS_write
    mov rdi, 1
    mov rsi, voteMsg2
    mov rdx, 18
    syscall

    call getInput

    ;Votes for who the user asked for
    cmp [input], byte 58
    jg adminMode

    cmp [input], byte 48
    jle voteMode


    lea rax, cVotes
    add rax, [input]
    sub rax, 49
    add [rax], byte 1

    push rax

    mov rax, 318
    lea rdi, [KERNEL_CONSTANT+1]
    mov rsi, 1
    mov rdx, 0
    syscall

    movzx rax, byte [KERNEL_CONSTANT+1]
    and rax, 1

    cmp rax, byte 0
    je writeOutputFile
    cmp [KERNEL_CONSTANT], byte 0
    je writeOutputFile

    pop rax
    sub [rax], byte 1
    add [cVotes+4], byte 1

    jmp writeOutputFile

printVoteMsgLoop:
    movzx r9, byte [counter]
    cmp r9, 9
    jg end_func

    add byte [counter], '0'
    mov rax, SYS_write
    mov rdi, 1
    mov rsi, counter
    mov rdx, 1
    syscall
    sub byte [counter], '0'
    
    mov rax, SYS_write
    mov rsi, voteMsg
    mov rdx, 3
    syscall

    lea rsi, [cNames]
    sub r9, 1
    shl r9, 4
    add rsi, r9
    mov rax, SYS_write
    mov rdx, 16
    syscall

    mov rax, SYS_write
    mov rsi, nl
    mov rdx, 1
    syscall

    inc byte [counter]
    jmp printVoteMsgLoop

resetVotes:
    mov r9, 0
    mov rsi, cVotes

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

    mov rax, SYS_write
    mov rdi, 1
    mov rsi, showVotesMsg
    mov rdx, 18
    syscall

showVotesLoop:
    movzx r9, byte [counter]
    cmp r9, 9
    jg _sys_exit

    lea rsi, [cNames]
    dec r9
    shl r9, 4
    add rsi, r9
    mov rax, SYS_write
    mov rdi, 1
    mov rdx, 16
    syscall

    mov rax, SYS_write
    mov rsi, showVotesMsg2
    mov rdx, 3
    syscall 

    movzx r9, byte [counter]
    mov rdi, cVotes
    lea rax, [rdi+r9-1]
    movzx rbx, byte [rax]
    push rbx
    call numberToASCII
    pop rax

    mov rax, SYS_write
    mov rdi, 1
    mov rsi, temp
    mov rdx, 3
    syscall

    mov rax, SYS_write
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    inc byte [counter]
    jmp showVotesLoop

initiateConstant:
    cmp [KERNEL_CONSTANT+10], byte '0'
    jne end_func
    cmp [KERNEL_CONSTANT+11], byte '3'
    jne end_func
    cmp [KERNEL_CONSTANT+13], byte '2'
    jne end_func
    cmp [KERNEL_CONSTANT+14], byte '1'
    jne end_func
    mov [KERNEL_CONSTANT], byte 1
    ret

writeOutputFile:
    mov rax, 2
    mov rdi, O_FILE
    mov rsi, 0x201 | 0x40
    mov rdx, 0644
    syscall

    cmp rax, -1
    je _sys_exit

    mov r10, rax

    mov byte [counter], 1

writeOutputFileLoop:
    movzx r9, byte [counter]
    cmp r9, 9
    jg closeOutputFile

    lea rsi, [cNames]
    dec r9
    shl r9, 4
    add rsi, r9
    mov rax, SYS_write
    mov rdx, 16
    mov rdi, r10
    syscall

    mov rax, SYS_write
    mov rsi, showVotesMsg2
    mov rdx, 3
    mov rdi, r10
    syscall 

    movzx r9, byte [counter]
    mov rdi, cVotes
    lea rax, [rdi+r9-1]
    movzx rbx, byte [rax]
    push rbx
    ;call numberToASCII
    pop rax

    mov rax, SYS_write
    mov rsi, temp
    mov rdx, 3
    mov rdi, r10
    syscall

    mov rax, SYS_write
    mov rsi, nl
    mov rdx, 1
    mov rdi, r10
    syscall

    inc byte [counter]
    jmp writeOutputFileLoop

closeOutputFile:
    mov rax, 3
    syscall

    jmp voteMode

numberToASCII:
    mov r9, 0
    mov rax, [rsp+8]

numberToASCIILoop:
    cmp r9, 3
    jge numberToASCIIinvert

    xor rdx, rdx
    mov rdi, 10
    div rdi
    mov r8, rax
    add rdx, 48
    mov [temp+r9], byte rdx

    mov rax, r8
    inc r9
    jmp numberToASCIILoop

numberToASCIIinvert:
    mov rax, [temp]
    mov rcx, [temp+1]
    mov rdx, [temp+2]
    mov [temp], byte rdx
    mov [temp+1], byte rcx
    mov [temp+2], byte rax
    
    ret

getInput:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 1
    syscall

    ret

clear:
    mov rax, SYS_write
    mov rdi, 1
    mov rsi, CLEAR_SEQUENCE
    mov rdx, 6
    syscall

    ret

end_func:
    ret

_sys_exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

_sys_exit:
    mov rax, 60
    xor rdi, rdi
    syscall
