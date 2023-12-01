.data
    test: .word 0,1067057152,1075052544                         #true t0=0x3f99999a
.text
main:
    la a1, test    
    addi t0, zero,3                                 #set count =3       
     li sp, 0x0C
loop:
    lw a2, 0(a1)                                    #load data
    li t1, 0x7F800000
    and a3, t1, a2                                  #a3=exp                                                     
    li t3, 0x007FFFFF  
    and a4, t3, a2                                  #a4=man
                                    
    addi t0, t0, -1                                 #count-1
    addi a1, a1, 4                                  #offset data address
    
    or t5, a3, a4
    beq t5, zero, end_z                             #check if zero
    beq a3,t1, end_ion                              #check if infinity or NaN
    
    #Start conversion, we don't need t1,t3,t5 anymore, while t2,t4 is unused                                       
    li t1, 0xFF800000                               #r has the same exp as x(not used)
    and t3, t1, a2                                 
    
                                
    srli t3, a4, 8                                  #r_man/=0x100, since t3 won't used, just recover it by new data
    li t2, 0x8000
    or t3, t3, t2                                   #obtain r_man when r_exp no change

                                                    #find y = x + r ; r/=0x100                    

    add a5, t3, a4                                  #a5=y_man
    add t6, a5, a2                                  #t6=value y
    
    li t1, 0xFFFF0000
    and t6, t6, t1                                  #transfer to bf16, t6=y
               
    addi a6, zero, 0                                #reset count     
count_ones:
    addi t1, t6, -1                                 # *p - 1
    and  t6, t6, t1                                 #*p &= (*p - 1)
    addi a6, a6, 1                                  #count++,a6
    bne  t6, zero, count_ones                       #if t6!=0 goto loop                                            
     
    sw a6, 0(sp)     
    addi sp, sp, -4
                    
    bnez t0, loop                       
    beqz t0, end
end_z:
    
    bnez t0, loop
    sw a6, 0(sp)     
    addi sp, sp, -4
    beqz t0, end
end_ion:

    bnez t0, loop
    beqz t0, end
end:
    nop
