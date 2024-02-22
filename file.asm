global _start
    
section .data
configMessageOne db "## Configuration ##", 0x0a, "Entrez le nom du candidat:", 0x0a
lenConfigMessage equ $ - configMessageOne
adminMessage db "## Admin Mode ##:", 0x0a, "1 - Voter", 0x0a, "2 - Etat", 0x0a, "3 - Mettre à 0", 0x0a, "4 - Finir", 0x0a, "Choisisez une option :", 0x0a
lenAdminMessage equ $ - adminMessage
choiceNumber : db 1
choice : db 15
candidateNameOne db 15
candidateNameTwo db 15
candidateNameThr db 15
candidateNameFou db 15
candidateNameFiv db 15
candidateNameSix db 15
candidateNameSev db 15
candidateNameEig db 15
candidateVoteOne db 15
candidateVoteTwo db 15
candidateVoteThr db 15
candidateVoteFou db 15
candidateVoteFiv db 15
candidateVoteSix db 15
candidateVoteSev db 15
candidateVoteEig db 15

section .text
    _start:
        call printConfig
        mov rax, choice
        mov [candidateNameOne], rax 

        call printConfig
        mov rax, choice
        mov [candidateNameTwo], rax 

        call printConfig
        mov rax, choice
        mov [candidateNameThr], rax 

        call printConfig
        mov rax, choice
        mov [candidateNameFou], rax

        call printConfig
        mov rax, choice
        mov [candidateNameFiv], rax 

        call printConfig
        mov rax, choice
        mov [candidateNameSix], rax

        call printConfig
        mov rax, choice
        mov [candidateNameSev], rax 

        call printConfig
        mov rax, choice
        mov [candidateNameEig], rax

        jmp admin

    printConfig:
        mov rax, 1
        mov rdi, 1
        mov rsi, configMessageOne
        mov rdx, lenConfigMessage
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, choice
        mov rdx, 15
        syscall
        
        mov rax, 1
        mov rdi, 1
        mov rsi, choice
        mov rdx, 15
        syscall
        ret

    admin:
        mov rax, 1
        mov rdi, 1
        mov rsi, adminMessage
        mov rdx, lenAdminMessage
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, choiceNumber
        mov rdx, 1
        syscall

        mov rax, qword [choiceNumber]
        sub al, '0'

        cmp al, 2
        je adminCase2

        mov rsi, rax
        mov rdi, 1
        mov rdx, 1
        mov rax, 1
        syscall

        mov rax, 60
        mov rdi, 0
        syscall

    adminCase2:
        mov rax, 1
        mov rdi, 1
        mov rsi, candidateNameOne
        mov rdx, 15
        syscall

        mov rax, 60
        mov rdi, 0
        syscall
