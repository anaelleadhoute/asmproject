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
	floory DWORD 5000
	vdown DWORD 300
	gravity DWORD 1
	dinox DWORD 50
	;state
	dinoy DWORD 10000
	dinov DWORD 200
	MAXY DWORD 100


.code
drd_imageLoadFile PROTO filename:DWORD, pimg:DWORD
update PROC
    push ebx
	push eax
	

	mov eax, dinoy
	mov ebx, dinov
	shr ebx, 5
	sub eax, ebx
	mov dinoy, eax
	
	mov eax, dinov
	mov ebx, gravity
	add eax, ebx
	mov dinov, eax
	

	mov eax, dinoy
	cmp eax, MAXY

	jge nomax
	
	mov ebx , dinov
	add ebx, gravity
	mov eax, dinoy
	add eax, ebx
	mov dinoy, eax
	cmp eax, floory
	jle nofloor
	
	
	mov dinov, 0
nofloor:
nomax:
	
	pop eax
	pop ebx
	ret

update ENDP 
	kkkk

	

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
