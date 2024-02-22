global _start

section .data
adminMessage db "## Admin Mode ##:", 0x0a, "1 - Afficher les résultats", 0x0a, "2 - Continuer le vote", 0x0a, "3 - Finir le vote", 0x0a, "4 - Mettre à 0", 0x0a, "Choisisez une option :", 0x0a
lenAdminMessage equ $ - adminMessage

thing db 'a', 0x0a
choice : db 1

section .text
    _start:
        jmp admin
    admin:
        mov rax, 1
        mov rdi, 1
        mov rsi, adminMessage
        mov rdx, lenAdminMessage
        syscall

        mov rax, 0
        mov rdi, 0
        mov rsi, choice
        mov rdx, 1
        syscall

        mov eax, [choice]
        sub eax, '0'

        cmp eax, 1

        je equal

        mov rax, 60
        mov rdi, 0
        syscall

    equal:
        mov rax, 1
        mov rdi, 1
        mov rsi, choice
        mov rdx, 2
        syscall

        mov rax, 60
        mov rdi, 0
        syscall
