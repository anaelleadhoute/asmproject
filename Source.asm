.486
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib
include drd.inc
includelib drd.lib

.data
    ;consts
	bgfile BYTE "dinoproject/white.bmp", 0
	bgimage Img<0,0,0,0>
	dinofile BYTE "dinoproject/frames.bmp" , 0
	dinoimage Img<0,0,0,0> 
	frame1file BYTE "dinoproject/frame1.bmp", 0
	frame1img Img <0,0,0,0>
	frame2file BYTE "dinoproject/frame2.bmp", 0
	frame2img Img <0,0,0,0>

	space BYTE 20h
	floory DWORD 8000
	vdown DWORD 300
	gravity DWORD 1
	dinox DWORD 50
	jumpv DWORD 100
	;state
	dinoy DWORD 8000
	dinov DWORD 200


.code
drd_imageLoadFile PROTO filename:DWORD, pimg:DWORD
jump PROC
	push eax
	invoke GetAsyncKeyState, space
	test eax, 1
	jz isnotpressed

	mov eax, dinov
	sub eax, jumpv
	mov dinov, eax

	isnotpressed:
	pop eax
	ret
jump ENDP



gravityfunc PROC
	push eax
	push ebx
	
 	mov eax, dinoy
	mov ebx, dinov
	shr ebx, 5
	add eax, ebx
	mov dinoy, eax
	
	mov eax, dinov
	mov ebx, gravity
	add eax, ebx
	mov dinov, eax
	
	pop ebx
	pop eax
	ret
gravityfunc ENDP

floorcheck PROC
    push eax 
	mov eax, floory
	cmp eax, dinoy
	jge nofloor
	mov dinov, 0
	mov dinoy, eax
	nofloor:

	pop eax
	ret 
floorcheck ENDP

update PROC
    push ebx
	push eax

	call gravityfunc
	call floorcheck
	call jump
	
	pop eax
	pop ebx
	ret

update ENDP 

	

draw PROC
	push eax
	invoke drd_imageDraw, offset bgimage, 0, 0 
	mov eax, dinoy
	shr eax, 4
	cmp eax, floory 
	invoke drd_imageDraw, offset frame1img, dinox, eax 
	invoke drd_processMessages
 	invoke drd_flip
	pop eax
	ret
	draw ENDP




main PROC
	push eax
	push ebx
	invoke drd_init, 1000, 1000, INIT_WINDOW
	invoke drd_imageLoadFile, offset dinofile, offset dinoimage
	invoke drd_imageLoadFile, offset bgfile, offset bgimage
	invoke drd_imageLoadFile, offset frame1file, offset frame1img
	invoke drd_imageLoadFile, offset frame2file, offset frame2img
	invoke drd_processMessages
 	invoke drd_flip 

	
	main_loop:
     
	call draw

	call update
	
	jmp main_loop	
	pop ebx
	pop eax
main ENDP
end main
